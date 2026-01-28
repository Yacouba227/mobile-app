# ChatBot IA

Un application mobile de discussion avec une intelligence artificielle avancée, développée avec Flutter.

## Fonctionnalités

- Interface de messagerie en temps réel avec une IA (type Gemini)
- Historique des conversations avec recherche
- Personnalisation : thème clair/sombre, langue (français/anglais), ton des réponses
- Notifications push pour les nouveaux messages
- Interface accessible avec options de contraste et taille de texte
- Support multiplateforme (Android/iOS)

## Installation

1. Clonez le projet
2. Exécutez `flutter pub get` pour installer les dépendances
3. Configurez votre clé API Gemini dans les paramètres de l'application
4. Lancez l'application avec `flutter run`

## Architecture

L'application utilise l'architecture suivante :

- **Providers** : Gestion d'état avec Provider
- **Services** : Gestion des notifications et des API
- **Screens** : Écrans de l'application (accueil, chat, recherche, paramètres)
- **Utils** : Outils de localisation et configuration
- **Constants** : Constantes de l'application

## Configuration de l'API Gemini

Pour utiliser l'application avec une vraie IA, vous devez obtenir une clé API Gemini depuis Google AI Studio et la configurer dans les paramètres de l'application.

## Internationalisation

L'application prend en charge le français et l'anglais avec la possibilité d'ajouter d'autres langues facilement.

## Développement futur

- Amélioration de la détection automatique de langue
- Intégration d'autres modèles d'IA
- Amélioration des fonctionnalités d'accessibilité
- Ajout de fonctionnalités de transcription vocale