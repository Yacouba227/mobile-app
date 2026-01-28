import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../providers/chat_provider.dart';
import '../providers/settings_provider.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ChatProvider, SettingsProvider>(
      builder: (context, chatProvider, settingsProvider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Recherche',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  // Show filter options
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Filtres de recherche',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const ListTile(
                              title: Text('Rechercher uniquement dans mes messages'),
                              trailing: Switch(value: false, onChanged: null),
                            ),
                            const ListTile(
                              title: Text('Rechercher uniquement dans les réponses IA'),
                              trailing: Switch(value: false, onChanged: null),
                            ),
                            const ListTile(
                              title: Text('Rechercher dans les conversations récentes'),
                              trailing: Switch(value: true, onChanged: null),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Appliquer les filtres'),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                tooltip: 'Filtres',
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (query) {
                      // Search happens in real-time as the user types
                    },
                    decoration: InputDecoration(
                      hintText: 'Rechercher dans les messages...',
                      hintStyle: TextStyle(
                        color: Theme.of(context).hintColor,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).primaryColor,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          // Clear search functionality would be implemented here
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Recent searches section
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recherches récentes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          settingsProvider.clearRecentSearches();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Historique des recherches effacé'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: const Text('Effacer tout'),
                      ),
                    ],
                  ),
                ),
                // Recent searches chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: settingsProvider.recentSearches.map((searchTerm) {
                    return FilterChip(
                      label: Text(searchTerm),
                      onSelected: (bool selected) {
                        if (selected) {
                          // Would populate search field with this term
                          // This would require access to the text controller
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Recherche pour: $searchTerm'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Expanded(child: _SearchResults()),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SearchResults extends StatefulWidget {
  @override
  __SearchResultsState createState() => __SearchResultsState();
}

class __SearchResultsState extends State<_SearchResults> {
  final TextEditingController _controller = TextEditingController();
  List<Message> _searchResults = [];
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_performSearch);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _controller.text;
    if (query != _currentQuery) {
      setState(() {
        _currentQuery = query;
        if (query.isEmpty) {
          _searchResults = [];
        } else {
          _searchResults = context.read<ChatProvider>().searchMessages(query);
          // Add to recent searches
          context.read<SettingsProvider>().addRecentSearch(query);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_currentQuery.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text(
              'Résultats pour "${_currentQuery}" (${_searchResults.length})',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        Expanded(
          child: _searchResults.isEmpty
              ? _currentQuery.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              size: 80,
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Rechercher dans les conversations',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Entrez vos mots-clés pour rechercher dans les conversations',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Theme.of(context).hintColor,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Aucun résultat trouvé',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Aucun message ne correspond à votre recherche',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ],
                        ),
                      )
              : RefreshIndicator(
                  onRefresh: () async {
                    // Refresh search results
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final message = _searchResults[index];
                      return Dismissible(
                        key: Key(message.timestamp.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          setState(() {
                            _searchResults.removeAt(index);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${message.isUser ? 'Votre message' : 'Réponse IA'} supprimé'),
                              action: SnackBarAction(
                                label: 'Annuler',
                                onPressed: () {
                                  setState(() {
                                    _searchResults.insert(index, message);
                                  });
                                },
                              ),
                            ),
                          );
                        },
                        child: GestureDetector(
                          onTap: () {
                            // Navigate to conversation containing this message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Navigation vers la conversation...'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          onLongPress: () {
                            // Copy message functionality
                            Clipboard.setData(ClipboardData(text: message.text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(message.isUser ? 'Message copié!' : 'Réponse copiée!'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              title: Text(
                                message.text,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  message.isUser ? 'Vous' : 'Assistant IA',
                                  style: TextStyle(
                                    color: message.isUser 
                                        ? Theme.of(context).primaryColor 
                                        : Colors.green.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${message.timestamp.day}/${message.timestamp.month}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
