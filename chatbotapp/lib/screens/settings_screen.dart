import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/chat_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, SettingsProvider>(
      builder: (context, themeProvider, settingsProvider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Paramètres',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            centerTitle: true,
          ),
          body: Container(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // Theme Section
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
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
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                          ),
                          child: Icon(
                            Icons.brightness_6,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Thème',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      RadioListTile<String>(
                        title: const Text('Clair'),
                        value: 'light',
                        groupValue: themeProvider.isDarkTheme
                            ? 'dark'
                            : 'light',
                        onChanged: (value) {
                          if (!themeProvider.isDarkTheme) return;
                          themeProvider.toggleTheme();
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Sombre'),
                        value: 'dark',
                        groupValue: themeProvider.isDarkTheme
                            ? 'dark'
                            : 'light',
                        onChanged: (value) {
                          if (themeProvider.isDarkTheme) return;
                          themeProvider.toggleTheme();
                        },
                      ),
                    ],
                  ),
                ),

                // Language Section
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
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
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                          ),
                          child: Icon(
                            Icons.language,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Langue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      RadioListTile<String>(
                        title: const Text('Français'),
                        value: 'fr',
                        groupValue: themeProvider.language,
                        onChanged: (value) {
                          if (value != null) {
                            themeProvider.setLanguage(value);
                          }
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('English'),
                        value: 'en',
                        groupValue: themeProvider.language,
                        onChanged: (value) {
                          if (value != null) {
                            themeProvider.setLanguage(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // Tone Style Section
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
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
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                          ),
                          child: Icon(
                            Icons.style,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Style de réponse',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      RadioListTile<String>(
                        title: const Text('Amical'),
                        value: 'friendly',
                        groupValue: themeProvider.toneStyle,
                        onChanged: (value) {
                          if (value != null) {
                            themeProvider.setToneStyle(value);
                          }
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Formel'),
                        value: 'formal',
                        groupValue: themeProvider.toneStyle,
                        onChanged: (value) {
                          if (value != null) {
                            themeProvider.setToneStyle(value);
                          }
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Décontracté'),
                        value: 'casual',
                        groupValue: themeProvider.toneStyle,
                        onChanged: (value) {
                          if (value != null) {
                            themeProvider.setToneStyle(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // Notifications Section
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
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
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                          ),
                          child: Icon(
                            Icons.notifications,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      SwitchListTile(
                        title: const Text('Notifications de messages'),
                        subtitle: const Text(
                          'Recevoir des notifications lors de nouvelles réponses',
                        ),
                        value: settingsProvider.notificationsEnabled,
                        onChanged: (value) {
                          settingsProvider.toggleNotifications(value!);
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Son des notifications'),
                        subtitle: const Text(
                          'Activer le son pour les nouvelles notifications',
                        ),
                        value: settingsProvider.notificationSoundEnabled,
                        onChanged: (value) {
                          settingsProvider.toggleNotificationSound(value!);
                        },
                      ),
                      ListTile(
                        title: const Text('Test notification'),
                        subtitle: const Text(
                          'Envoyer une notification de test',
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Test notification functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notification de test envoyée!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Data Management Section
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
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
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                          ),
                          child: Icon(
                            Icons.storage,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Gestion des données',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      ListTile(
                        title: const Text('Exporter les conversations'),
                        subtitle: const Text(
                          'Sauvegarder toutes vos conversations',
                        ),
                        trailing: Icon(
                          Icons.download,
                          color: Theme.of(context).primaryColor,
                        ),
                        onTap: () async {
                          String result = await settingsProvider.exportData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        title: const Text('Effacer l\'historique'),
                        subtitle: const Text(
                          'Supprimer toutes les conversations',
                        ),
                        trailing: const Icon(
                          Icons.delete_forever,
                          color: Colors.red,
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirmation'),
                                content: const Text(
                                  'Êtes-vous sûr de vouloir supprimer toutes les conversations ? Cette action est irréversible.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Annuler'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      await settingsProvider.clearAllData();
                                      // Also clear chat provider data
                                      context.read<ChatProvider>().clearAllConversations();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Historique effacé'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Confirmer',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      ListTile(
                        title: const Text('Statistiques'),
                        subtitle: const Text(
                          'Voir vos statistiques de conversation',
                        ),
                        trailing: Icon(
                          Icons.analytics,
                          color: Theme.of(context).primaryColor,
                        ),
                        onTap: () {
                          // Show statistics
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
                                      'Statistiques',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const ListTile(
                                      title: Text('Total conversations'),
                                      subtitle: Text('12 conversations'),
                                    ),
                                    const ListTile(
                                      title: Text('Total messages'),
                                      subtitle: Text('245 messages'),
                                    ),
                                    const ListTile(
                                      title: Text(
                                        'Temps moyen par conversation',
                                      ),
                                      subtitle: Text('15 minutes'),
                                    ),
                                    const SizedBox(height: 20),
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Fermer'),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Security Section
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
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
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                          ),
                          child: Icon(
                            Icons.security,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Sécurité',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      SwitchListTile(
                        title: const Text('Verrouillage biométrique'),
                        subtitle: const Text(
                          'Utiliser l\'empreinte digitale ou Face ID',
                        ),
                        value: settingsProvider.biometricLockEnabled,
                        onChanged: (value) {
                          settingsProvider.toggleBiometricLock(value!);
                        },
                      ),
                      ListTile(
                        title: const Text('Changer le mot de passe'),
                        subtitle: const Text('Modifier votre code d\'accès'),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Password change functionality
                        },
                      ),
                    ],
                  ),
                ),

                // Accessibility Options
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
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
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                          ),
                          child: Icon(
                            Icons.accessibility,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Accessibilité',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      SwitchListTile(
                        title: const Text('Augmenter la taille du texte'),
                        subtitle: const Text('Pour une meilleure lisibilité'),
                        value: settingsProvider.largeTextEnabled,
                        onChanged: (value) {
                          settingsProvider.toggleLargeText(value!);
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Contraste élevé'),
                        subtitle: const Text(
                          'Meilleure visibilité des éléments',
                        ),
                        value: settingsProvider.highContrastEnabled,
                        onChanged: (value) {
                          settingsProvider.toggleHighContrast(value!);
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Mode lecture'),
                        subtitle: const Text(
                          'Optimisé pour la lecture prolongée',
                        ),
                        value: settingsProvider.readingModeEnabled,
                        onChanged: (value) {
                          settingsProvider.toggleReadingMode(value!);
                        },
                      ),
                    ],
                  ),
                ),

                // About Section
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
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
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                          ),
                          child: Icon(
                            Icons.info,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'À propos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      const ListTile(
                        title: Text('Version'),
                        subtitle: Text('1.0.0'),
                      ),
                      const ListTile(
                        title: Text('Application ChatBot IA'),
                        subtitle: Text(
                          'Une application de discussion avec une IA avancée',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
