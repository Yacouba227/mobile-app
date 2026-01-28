import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import 'navigation_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                size: 100,
                color: Colors.blue,
              ),
              const SizedBox(height: 32),
              Text(
                'Bienvenue sur ChatBot IA',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Votre assistant IA personnel disponible 24/7',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),
              _FeatureCard(
                icon: Icons.auto_fix_high,
                title: 'Réponses intelligentes',
                description:
                    'Notre IA comprend votre demande et vous fournit des réponses pertinentes',
              ),
              const SizedBox(height: 16),
              _FeatureCard(
                icon: Icons.history,
                title: 'Historique des conversations',
                description:
                    'Retrouvez toutes vos discussions précédentes facilement',
              ),
              const SizedBox(height: 16),
              _FeatureCard(
                icon: Icons.settings,
                title: 'Personnalisation',
                description: 'Adaptez le ton et le style selon vos préférences',
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  // Mark that the user has seen the welcome screen
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool('seenWelcomeScreen', true);

                  // Navigate to the main app
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const NavigationScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Commencer', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  // Mark that the user has seen the welcome screen
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool('seenWelcomeScreen', true);

                  // Navigate to the main app
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const NavigationScreen(),
                    ),
                  );
                },
                child: const Text('Passer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
