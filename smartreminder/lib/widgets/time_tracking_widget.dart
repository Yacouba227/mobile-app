import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/time_tracking_service.dart';

class TimeTrackingWidget extends StatelessWidget {
  final String taskId;
  final VoidCallback? onTrackingStarted;
  final VoidCallback? onTrackingStopped;

  const TimeTrackingWidget({
    Key? key,
    required this.taskId,
    this.onTrackingStarted,
    this.onTrackingStopped,
  }) : super(key: key);

  static const primaryBlue = Color(0xFF1976D2);
  static const secondaryBlue = Color(0xFF42A5F5);
  static const successGreen = Color(0xFF4CAF50);
  static const warningOrange = Color(0xFFFF9800);
  static const errorRed = Color(0xFFF44336);
  static const lightBackground = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Consumer<TimeTrackingService>(
      builder: (context, timeTrackingService, child) {
        final isCurrentTaskTracking =
            timeTrackingService.isTracking &&
            timeTrackingService.currentSession?.taskId == taskId;

        if (isCurrentTaskTracking) {
          return _buildTrackingControls(context, timeTrackingService);
        } else {
          return _buildStartButton(context, timeTrackingService);
        }
      },
    );
  }

  Widget _buildStartButton(BuildContext context, TimeTrackingService service) {
    return ElevatedButton.icon(
      onPressed: () {
        service.startTracking(taskId);
        onTrackingStarted?.call();
      },
      icon: const Icon(Icons.play_arrow),
      label: const Text('Démarrer le suivi'),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildTrackingControls(
    BuildContext context,
    TimeTrackingService service,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryBlue.withOpacity(0.1),
            lightBackground.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryBlue.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chronomètre
          Center(
            child: Text(
              service.formattedTime,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Contrôles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Pause/Reprendre
              ElevatedButton.icon(
                onPressed: service.isTracking
                    ? service.pauseTracking
                    : service.resumeTracking,
                icon: Icon(service.isTracking ? Icons.pause : Icons.play_arrow),
                label: Text(service.isTracking ? 'Pause' : 'Reprendre'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: warningOrange,
                  foregroundColor: Colors.white,
                ),
              ),

              // Stopper
              ElevatedButton.icon(
                onPressed: () {
                  service.stopTracking();
                  onTrackingStopped?.call();
                },
                icon: const Icon(Icons.stop),
                label: const Text('Stop'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: errorRed,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Interruptions
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () => _showInterruptionDialog(context, service),
                icon: const Icon(Icons.pause_circle_outline),
                label: const Text('Interruption'),
                style: TextButton.styleFrom(foregroundColor: warningOrange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showInterruptionDialog(
    BuildContext context,
    TimeTrackingService service,
  ) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Interruption'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Raison de l\'interruption :'),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  hintText: 'Ex: Pause café, Réunion...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                service.addInterruption(reasonController.text);
                Navigator.pop(context);
              },
              child: const Text('Valider'),
            ),
          ],
        );
      },
    );
  }
}
