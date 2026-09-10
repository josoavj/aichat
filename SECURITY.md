# Politique de Sécurité

## Sécurité des Données

FocusFlow est une application "Local-First". Cela signifie que l'immense majorité de vos données (tâches, notes, journal, historique des conversations) ne quitte jamais votre appareil.

- **Stockage** : Les données sont stockées dans une base de données SQLite locale.
- **Clé API** : Votre clé API Gemini est stockée de manière sécurisée dans le coffre-fort de votre système d'exploitation (Secure Storage). Elle n'est utilisée que pour communiquer directement avec les serveurs de Google AI.

## Signalement d'une vulnérabilité

Si vous découvrez une faille de sécurité, merci de ne pas l'exposer publiquement. Veuillez nous contacter via les moyens suivants :

1. Ouvrez une "Issue" privée sur GitHub si l'option est disponible.
2. Contactez le développeur principal par email (voir profil GitHub).

Nous nous engageons à traiter les rapports de sécurité avec priorité.

## Versions Supportées

| Version | Supporté |
| ------- | -------- |
| 1.0.0   | Oui      |
