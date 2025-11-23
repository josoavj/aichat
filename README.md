<h1 align="center">MyAI Assistant - Chat Application</h1>

<p align="center">
  <strong>Une application de chat IA moderne utilisant l'API Google Generative AI (Gemini Pro).</strong>
</p>

<p align="center">
  <!-- Badges -->
  <img src="https://img.shields.io/badge/Flutter-%3E%3D3.0.0-blue" alt="Flutter Version">
  <img src="https://img.shields.io/badge/Dart-3.4.3+-blue" alt="Dart Version">
  <img src="https://img.shields.io/badge/API-Google%20Generative%20AI-red" alt="API">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="License">
  <img src="https://img.shields.io/github/last-commit/josoavj/aichat" alt="Last Commit">
  <img src="https://img.shields.io/github/stars/josoavj/aichat?style=social" alt="GitHub Stars">
</p>

---

## ✨ Fonctionnalités Principales

### 🤖 Chat avec l'IA
- **Conversation en temps réel** avec le modèle Gemini Pro
- **Historique des messages** avec timestamps
- **Gestion complète des erreurs** avec messages détaillés
- **Indicateurs de chargement** pendant la réponse
- **Suppression de l'historique** en un clic
- **État vide informatif** au démarrage

### 🔐 Gestion de la Clé API
- **Validation robuste** de la clé API
- **Stockage sécurisé** avec SharedPreferences
- **Affichage/masquage** de la clé pour plus de sécurité
- **Lien direct** vers Google AI Studio
- **Messages d'erreur clairs** en cas de validation échouée
- **Possibilité de modifier** la clé à tout moment

### 🎨 Personnalisation de l'Interface
- **Mode clair et mode sombre** complets
- **Changement de couleur primaire** en temps réel
- **Thème persistant** entre les sessions
- **Ajustement de la taille de police** (80%-120%)
- **Désactivation/activation** des vibrations haptiques
- **Design moderne et responsive** sur tous les appareils

### ⚙️ Paramètres Avancés
- **Configuration du thème** (mode et couleurs)
- **Réglages de police** personnalisables
- **Gestion des retours haptiques**
- **Changement de clé API** depuis les paramètres
- **Suppression de l'historique** du chat
- **Page de déconnexion**

### 📱 Autres Fonctionnalités
- **Écran de profil** pour gérer les informations utilisateur
- **Page À propos** avec informations sur l'application
- **Écran d'introduction** (splash screen)
- **Navigation fluide** entre les pages
- **Menu tiroir** (drawer) intuitif
- **Feedback utilisateur** via snackbars

---

## 🏗️ Architecture et Améliorations

### Services Centralisés
- **ApiService**: Gestion unifiée de l'API Generative AI
- **ApiManager**: Persistance et validation des clés API
- **ThemeNotifier**: Gestion d'état du thème avec Provider

### Modèles de Données
- **ChatMessage**: Modèle typé pour les messages avec timestamps

### Widgets Améliorés
- **EnhancedChatWidget**: Interface de chat moderne et responsive
- **EnhancedApiKeyWidget**: Saisie sécurisée et validée de la clé API
- **MessageBubble**: Affichage élégant des messages

---

## 🚀 Démarrage Rapide

### Prérequis
- **Flutter SDK**: Version 3.19.x ou supérieure (Dart 3.4.3+)
- **Android Studio** ou **VS Code** avec extensions Flutter
- **Émulateur** ou appareil physique connecté
- **Clé API Google Generative AI** (gratuite depuis [Google AI Studio](https://makersuite.google.com/app/apikey))

### Installation

1. **Clonez le dépôt**
   ```bash
   git clone https://github.com/josoavj/aichat.git
   cd aichat
   ```

2. **Installez les dépendances**
   ```bash
   flutter pub get
   ```

3. **Lancez l'application**
   ```bash
   flutter run
   ```

4. **Lors du premier lancement**, entrez votre clé API Google Generative AI
   - Accédez à [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Créez ou copiez votre clé API
   - Collez-la dans l'application

### Build pour Production

**Android**
```bash
flutter build apk --release
```

**iOS**
```bash
flutter build ios --release
```

---

## 📚 Dépendances Principales

| Package | Version | Utilisation |
|---------|---------|-------------|
| flutter | SDK | Framework principal |
| google_generative_ai | ^0.4.3 | API Gemini |
| google_fonts | ^6.2.1 | Typographie Poppins |
| provider | ^6.1.5 | Gestion d'état |
| shared_preferences | ^2.5.3 | Persistance locale |
| flutter_colorpicker | ^1.1.0 | Sélecteur de couleurs |
| url_launcher | ^6.3.0 | Ouverture de liens |
| firebase_core | ^4.0.0 | Firebase (pour futurs développements) |
| flutter_markdown | ^0.7.3 | Rendu Markdown |
| font_awesome_flutter | ^10.7.0 | Icônes supplémentaires |
| image_picker | ^1.2.0 | Sélection d'images |

---

## 📁 Structure du Projet

```
lib/
├── main.dart                           # Point d'entrée + MyApp
├── api/
│   └── api_call.dart                  # Ancien widget API (remplacé)
├── models/
│   └── chat_message.dart              # Modèle ChatMessage
├── services/
│   ├── api_service.dart               # Service API centralisé
│   └── api_manager.dart               # Manager de clé API
├── screens/
│   ├── chatscreen.dart                # Écran principal
│   ├── chatwidget.dart                # Ancien widget (remplacé)
│   ├── enhanced_chat_widget.dart      # Nouveau widget de chat
│   ├── enhanced_api_key_widget.dart   # Nouveau widget clé API
│   ├── intro.dart                     # Écran d'introduction
│   └── transition.dart                # Écran de transition
├── pages/
│   ├── login.dart                     # Page de connexion
│   ├── profile.dart                   # Page de profil
│   ├── settings.dart                  # Page de paramètres
│   └── about.dart                     # Page À propos
├── data/
│   └── users.dart                     # Données utilisateur
└── others/
    ├── app_theme.dart                 # Gestion du thème
    └── screenswidget.dart             # Widgets utilitaires

android/                                # Configuration Android
├── app/build.gradle                   # Build Gradle (v3.4+)
├── build.gradle                       # Configuration Gradle
└── gradle.properties                  # Propriétés Gradle

ios/                                    # Configuration iOS
└── Runner/Info.plist                  # Informations de l'app

pubspec.yaml                           # Dépendances et configuration
```

---

## 🔧 Configuration

### Android
- **minSdk**: Défini par Flutter (généralement 21)
- **targetSdk**: Défini par Flutter
- **compileSdk**: Défini par Flutter
- **Java**: Version 1.8
- **Gradle**: Compatible avec la dernière version
- **Firebase**: Intégré (optional)

### iOS
- **Deployement Target**: Compatible avec Flutter 3.19+
- **Architecture**: Support ARM64 et x86_64
- **Language**: Swift et Objective-C

### Flutter
- **SDK**: >=3.4.3 <4.0.0
- **Compilateur Dart**: Dernière version
- **Material Design 3**: Support complet

---

## 🧪 Vérifications Effectuées

### ✅ Compilation
- Tous les fichiers compilent **sans erreurs**
- Aucun warning sérieux
- Dépendances à jour et compatibles

### ✅ Architecture
- Séparation des préoccupations (Services/UI/Models)
- Code réutilisable et testable
- Gestion cohérente des états

### ✅ Configuration
- **Android Gradle**: Correct et fonctionnel
- **iOS**: Configuré correctement
- **Flutter**: Configuration optimale
- **Dépendances**: Toutes vérifiées

---

## 🎯 Prochaines Étapes Possibles

- [ ] Cache des réponses pour améliorer les performances
- [ ] Recherche dans l'historique des conversations
- [ ] Exportation des conversations (PDF/TXT)
- [ ] Tags et favoris pour l'historique
- [ ] Sauvegarde cloud des conversations
- [ ] Synchronisation multi-appareils
- [ ] Support de plusieurs modèles IA
- [ ] Prompts prédéfinis et personnalisés
- [ ] Mode offline avec cache
- [ ] Intégration avec d'autres APIs

---

## 📝 Documentation

Trois fichiers de documentation sont disponibles:
- **THEME_IMPROVEMENTS.md** - Détails sur la gestion du thème
- **API_UI_IMPROVEMENTS.md** - Détails sur les améliorations d'API/UI
- **IMPROVEMENTS_SUMMARY.md** - Résumé complet des améliorations

---

## 🤝 Contribution

Les contributions sont les bienvenues! Pour proposer des améliorations:

1. Fork le projet
2. Créez une branche pour votre fonctionnalité (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Poussez vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

---

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

## 👤 Contributeurs

- **[josoavj](https://github.com/josoavj)** - Développeur principal

---

## 💬 Support

Pour toute question ou problème:
- Ouvrez une [issue GitHub](https://github.com/josoavj/aichat/issues)
- Consultez la [documentation Flutter](https://flutter.dev/docs)
- Consultez la [documentation Google Generative AI](https://ai.google.dev/docs)

---

## 🙏 Remerciements

- **Google** pour l'API Generative AI (Gemini)
- **Flutter** et **Dart** pour le framework excellent
- Tous les contributeurs et utilisateurs

---

<div align="center">

**Créé avec ❤️ par [josoavj](https://github.com/josoavj)**

[GitHub](https://github.com/josoavj) • [Portfolio](#) • [Email](#)

</div>


