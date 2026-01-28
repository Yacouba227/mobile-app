import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/task.dart';
import '../models/time_tracking.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'smart_reminder.db';

  // Table names
  static const String _tasksTable = 'tasks';
  static const String _timeTrackingTable = 'time_tracking_sessions';
  static const String _interruptionsTable = 'interruptions';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    // Create tasks table
    await db.execute('''
      CREATE TABLE $_tasksTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        category INTEGER NOT NULL,
        priority INTEGER NOT NULL,
        deadline INTEGER,
        estimated_duration INTEGER,
        status INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        completion_count INTEGER DEFAULT 0,
        postpone_count INTEGER DEFAULT 0,
        postponement_history TEXT
      )
    ''');

    // Create time tracking sessions table
    await db.execute('''
      CREATE TABLE $_timeTrackingTable (
        id TEXT PRIMARY KEY,
        task_id TEXT NOT NULL,
        start_time INTEGER NOT NULL,
        end_time INTEGER,
        duration INTEGER NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (task_id) REFERENCES $_tasksTable (id) ON DELETE CASCADE
      )
    ''');

    // Create interruptions table
    await db.execute('''
      CREATE TABLE $_interruptionsTable (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        start_time INTEGER NOT NULL,
        end_time INTEGER,
        duration INTEGER NOT NULL,
        reason TEXT,
        FOREIGN KEY (session_id) REFERENCES $_timeTrackingTable (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_tasks_status ON $_tasksTable(status)');
    await db.execute(
      'CREATE INDEX idx_tasks_deadline ON $_tasksTable(deadline)',
    );
    await db.execute(
      'CREATE INDEX idx_tasks_category ON $_tasksTable(category)',
    );
    await db.execute(
      'CREATE INDEX idx_time_tracking_task ON $_timeTrackingTable(task_id)',
    );
    await db.execute(
      'CREATE INDEX idx_time_tracking_start ON $_timeTrackingTable(start_time)',
    );
  }

  // Task operations
  Future<String> insertTask(Task task) async {
    final db = await database;
    await db.insert(_tasksTable, task.toMap());
    return task.id;
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final maps = await db.query(_tasksTable, orderBy: 'created_at DESC');
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    final db = await database;
    final maps = await db.query(
      _tasksTable,
      where: 'status = ?',
      whereArgs: [status.index],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> getTasksByCategory(TaskCategory category) async {
    final db = await database;
    final maps = await db.query(
      _tasksTable,
      where: 'category = ?',
      whereArgs: [category.index],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<Task?> getTaskById(String id) async {
    final db = await database;
    final maps = await db.query(_tasksTable, where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      _tasksTable,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(String id) async {
    final db = await database;
    return await db.delete(_tasksTable, where: 'id = ?', whereArgs: [id]);
  }

  // Time tracking operations
  Future<String> insertTimeTrackingSession(TimeTrackingSession session) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert(_timeTrackingTable, session.toMap());

      // Insert interruptions
      for (var interruption in session.interruptions) {
        await txn.insert(_interruptionsTable, {
          'id': interruption.id,
          'session_id': session.id,
          'start_time': interruption.startTime.millisecondsSinceEpoch,
          'end_time': interruption.endTime?.millisecondsSinceEpoch,
          'duration': interruption.duration.inSeconds,
          'reason': interruption.reason,
        });
      }
    });
    return session.id;
  }

  Future<List<TimeTrackingSession>> getTimeTrackingSessionsByTask(
    String taskId,
  ) async {
    final db = await database;
    final sessionMaps = await db.query(
      _timeTrackingTable,
      where: 'task_id = ?',
      whereArgs: [taskId],
      orderBy: 'start_time DESC',
    );

    final sessions = <TimeTrackingSession>[];
    for (var sessionMap in sessionMaps) {
      // Get interruptions for this session
      final interruptionMaps = await db.query(
        _interruptionsTable,
        where: 'session_id = ?',
        whereArgs: [sessionMap['id']],
      );

      final interruptions = interruptionMaps
          .map((map) => Interruption.fromMap(map))
          .toList();

      sessions.add(
        TimeTrackingSession.fromMap(
          sessionMap,
        ).copyWith(interruptions: interruptions),
      );
    }

    return sessions;
  }

  Future<List<TimeTrackingSession>> getTimeTrackingSessionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final startMs = start.millisecondsSinceEpoch;
    final endMs = end.millisecondsSinceEpoch;

    final sessionMaps = await db.query(
      _timeTrackingTable,
      where: 'start_time >= ? AND start_time <= ?',
      whereArgs: [startMs, endMs],
      orderBy: 'start_time DESC',
    );

    final sessions = <TimeTrackingSession>[];
    for (var sessionMap in sessionMaps) {
      // Get interruptions for this session
      final interruptionMaps = await db.query(
        _interruptionsTable,
        where: 'session_id = ?',
        whereArgs: [sessionMap['id']],
      );

      final interruptions = interruptionMaps
          .map((map) => Interruption.fromMap(map))
          .toList();

      sessions.add(
        TimeTrackingSession.fromMap(
          sessionMap,
        ).copyWith(interruptions: interruptions),
      );
    }

    return sessions;
  }

  Future<int> updateTimeTrackingSession(TimeTrackingSession session) async {
    final db = await database;
    return await db.update(
      _timeTrackingTable,
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<int> deleteTimeTrackingSession(String id) async {
    final db = await database;
    return await db.delete(
      _timeTrackingTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Analytics methods
  Future<Map<TaskCategory, Duration>> getTotalTimeByCategory(
    DateTime start,
    DateTime end,
  ) async {
    final sessions = await getTimeTrackingSessionsByDateRange(start, end);
    final timeByCategory = <TaskCategory, Duration>{};

    for (var session in sessions) {
      final task = await getTaskById(session.taskId);
      if (task != null) {
        final currentDuration = timeByCategory[task.category] ?? Duration.zero;
        timeByCategory[task.category] = currentDuration + session.duration;
      }
    }

    return timeByCategory;
  }

  Future<Duration> getTotalTimeSpent(DateTime start, DateTime end) async {
    final sessions = await getTimeTrackingSessionsByDateRange(start, end);
    Duration total = Duration.zero;
    for (var session in sessions) {
      total += session.duration;
    }
    return total;
  }

  Future<int> getTotalTasksCompleted(DateTime start, DateTime end) async {
    final db = await database;
    final startMs = start.millisecondsSinceEpoch;
    final endMs = end.millisecondsSinceEpoch;

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count FROM $_tasksTable 
      WHERE status = ? AND updated_at >= ? AND updated_at <= ?
    ''',
      [TaskStatus.completed.index, startMs, endMs],
    );

    return result.first['count'] as int;
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
