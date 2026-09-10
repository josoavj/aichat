<h1 align="center">FocusFlow Assistant</h1>

<p align="center">
  <strong>Un compagnon de productivité intelligent, local et privé pour transformer l'hyperactivité en super-pouvoir.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.24+-blue" alt="Flutter Version">
  <img src="https://img.shields.io/badge/Dart-3.5+-blue" alt="Dart Version">
  <img src="https://img.shields.io/badge/IA-Gemini%201.5%20Flash-red" alt="API">
  <img src="https://img.shields.io/badge/Base%20de%20données-SQLite-orange" alt="DB">
  <img src="https://img.shields.io/badge/Plateforme-Android%20%7C%20Linux%20%7C%20Windows-green" alt="Platforms">
</p>

---

## Vision

FocusFlow est conçu pour les personnes hyperactives qui ont besoin de structure sans friction. Contrairement aux outils classiques, FocusFlow utilise l'IA pour **découper** vos objectifs en micro-tâches non intimidantes et gère tout en **local** pour une confidentialité absolue.

## Fonctionnalités Clés

### 🤖 Coach IA Proactif (Gemini 1.5 Flash)
- **Découpage de tâches** : Transforme "Ranger la maison" en étapes de 5 minutes.
- **Function Calling** : L'IA agit directement sur votre base de données locale (ajout de tâches, notes, minuteurs).
- **Mémoire Contextuelle** : Se souvient de vos conversations passées et de vos notes de journal.
- **Zéro Émoji** : Une interface sobre pour minimiser les distractions visuelles.

### 📋 Gestion de Productivité Locale
- **Dashboard de Tâches** : Vue claire de vos priorités avec indicateurs d'urgence (1 à 5).
- **Journal / Brain Dump** : Capturez vos pensées et idées instantanément pour vider votre esprit.
- **Focus Mode (Pomodoro)** : Minuteur de concentration intégré, lançable vocalement par l'IA.
- **Statistiques** : Graphiques de progression sur 7 jours pour visualiser vos succès.

### 🔐 Confidentialité et Performance
- **Local-First** : Vos tâches, notes et historiques restent sur votre appareil (SQLite).
- **Zéro Compte** : Pas de login, pas de serveurs, utilité immédiate.
- **Sécurité** : Clé API Gemini stockée de manière sécurisée (Secure Storage).

### 🎨 Design Moderne (Material 3)
- **Thème Centralisé** : Mode clair/sombre et couleurs personnalisables.
- **Accessibilité** : Taille de police ajustable dynamiquement.
- **Navigation Fluide** : Interface à 5 onglets pour un accès rapide à tous les modules.

---

## 🚀 Démarrage Rapide

### Prérequis
- **Flutter SDK**: 3.24.x ou supérieur.
- **Clé API Google AI**: Gratuite sur [Google AI Studio](https://aistudio.google.com/).

### Installation

1. **Installation**
   ```bash
   git clone https://github.com/josoavj/aichat.git
   cd aichat
   flutter pub get
   ```

2. **Lancement**
   ```bash
   flutter run
   ```

3. **Configuration**
   - Entrez votre clé API Gemini au premier lancement.
   - Commencez à parler à FocusFlow : *"Aide-moi à organiser ma journée."*

---

## 🏗️ Architecture

- **State Management**: `Provider` pour une réactivité optimale.
- **Database**: `sqflite` + `sqflite_common_ffi` (Support Desktop natif).
- **Notifications**: `flutter_local_notifications` pour les rappels proactifs.
- **Charts**: `fl_chart` pour les visualisations de données.

---

## 🤝 Contribution

Les contributions sont les bienvenues pour améliorer l'expérience TDAH/Productivité ! Consultez notre [Guide de contribution](CONTRIBUTING.md) pour plus de détails.

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

<div align="center">
  <strong>Développé par [josoavj](https://github.com/josoavj)</strong>
</div>
