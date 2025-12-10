# Configuration Firebase - Guide Complet

## 📦 Installation et Configuration

### 1. Dépendances Installées
```yaml
firebase_core: ^4.2.1        # Core Firebase
cloud_firestore: ^6.1.0      # Base de données Firestore
firebase_auth: ^6.1.2        # Authentification
firebase_storage: ^13.0.4    # Stockage cloud
```

### 2. Structure du Projet Firebase

```
lib/
├── config/
│   ├── firebase_config.dart        # Initialisation Firebase
│   └── firebase_constants.dart     # Constantes (collections, fields)
│
├── services/
│   ├── firebase_auth_service.dart        # Service d'authentification
│   ├── firestore_service.dart            # Service Firestore
│   ├── firebase_storage_service.dart     # Service de stockage
│   ├── firebase_service.dart             # Singleton principal
│   └── FIREBASE_EXAMPLES.dart            # Exemples d'utilisation
│
├── providers/
│   ├── auth_provider.dart          # Provider authentification
│   ├── chat_provider.dart          # Provider chats
│   └── message_provider.dart       # Provider messages
│
└── main.dart                       # App avec tous les providers
```

## 🔐 Services Disponibles

### FirebaseAuthService
Gère l'authentification utilisateur:
- `signUpWithEmailAndPassword()` - Créer un compte
- `signInWithEmailAndPassword()` - Se connecter
- `resetPassword()` - Réinitialiser le mot de passe
- `signOut()` - Se déconnecter
- `updateUserProfile()` - Mettre à jour le profil
- `changePassword()` - Changer le mot de passe
- `deleteAccount()` - Supprimer le compte

### FirestoreService
Gère la base de données Firestore:

**Utilisateurs:**
- `createUser()` - Créer un utilisateur
- `getUser()` - Récupérer les données d'un utilisateur
- `updateUser()` - Mettre à jour les données
- `getAllUsers()` - Récupérer tous les utilisateurs (stream)
- `deleteUser()` - Supprimer un utilisateur

**Chats:**
- `createChat()` - Créer un chat
- `getUserChats()` - Récupérer les chats de l'utilisateur
- `getChat()` - Récupérer un chat spécifique
- `updateChat()` - Mettre à jour un chat
- `deleteChat()` - Supprimer un chat

**Messages:**
- `addMessage()` - Ajouter un message
- `getChatMessages()` - Récupérer les messages (stream)
- `updateMessage()` - Mettre à jour un message
- `deleteMessage()` - Supprimer un message

### FirebaseStorageService
Gère le stockage cloud:
- `uploadUserProfileImage()` - Uploader une photo de profil
- `uploadChatImage()` - Uploader une image de chat
- `uploadFile()` - Uploader un fichier quelconque
- `getDownloadUrl()` - Obtenir l'URL de téléchargement
- `deleteFile()` - Supprimer un fichier
- `deleteFolder()` - Supprimer un dossier
- `listFiles()` - Lister les fichiers d'un dossier

## 📱 Providers (State Management)

### AuthProvider
Gère l'état d'authentification:
```dart
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    if (authProvider.isLoggedIn) {
      print('Utilisateur: ${authProvider.currentUser?.email}');
    }
  },
);
```

### ChatProvider
Gère les chats:
```dart
final chatProvider = Provider.of<ChatProvider>(context);
chatProvider.loadUserChats(userId);
chatProvider.createNewChat(userId: userId, title: 'Nouveau chat');
```

### MessageProvider
Gère les messages:
```dart
final messageProvider = Provider.of<MessageProvider>(context);
messageProvider.loadChatMessages(chatId);
messageProvider.addMessage(
  chatId: chatId,
  userId: userId,
  content: 'Message',
  role: 'user',
);
```

## 🗄️ Structure Firestore

### Collections

**users/**
```
{
  uid: "user-id-123",
  name: "Nom Utilisateur",
  email: "user@example.com",
  photoUrl: "https://...",
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

**chats/**
```
{
  chatId: "chat-123",
  userId: "user-id-123",
  title: "Titre du chat",
  messageCount: 5,
  createdAt: Timestamp,
  updatedAt: Timestamp,
  messages/
    {
      messageId: "msg-123",
      userId: "user-id-123",
      content: "Contenu du message",
      role: "user" | "assistant",
      tokens: 0,
      createdAt: Timestamp
    }
}
```

## 🚀 Utilisation Rapide

### 1. Se connecter/S'inscrire
```dart
final authProvider = Provider.of<AuthProvider>(context, listen: false);

// Inscription
await authProvider.signUp(
  email: 'user@example.com',
  password: 'password123',
  displayName: 'Nom',
);

// Connexion
await authProvider.signIn(
  email: 'user@example.com',
  password: 'password123',
);
```

### 2. Créer et gérer des chats
```dart
final chatProvider = Provider.of<ChatProvider>(context, listen: false);

// Charger les chats
chatProvider.loadUserChats(userId);

// Créer un chat
final chatId = await chatProvider.createNewChat(
  userId: userId,
  title: 'Nouveau Chat',
);

// Sélectionner un chat
chatProvider.selectChat(chatId);
```

### 3. Ajouter des messages
```dart
final messageProvider = Provider.of<MessageProvider>(context, listen: false);

// Charger les messages
messageProvider.loadChatMessages(chatId);

// Ajouter un message
await messageProvider.addMessage(
  chatId: chatId,
  userId: userId,
  content: 'Bonjour!',
  role: 'user',
);
```

### 4. Afficher les messages en temps réel
```dart
StreamBuilder<QuerySnapshot>(
  stream: messageProvider.messagesStream,
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final messages = snapshot.data!.docs;
      return ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index].data() as Map<String, dynamic>;
          return ListTile(title: Text(message['content']));
        },
      );
    }
    return CircularProgressIndicator();
  },
);
```

## 🔧 Configuration Firebase Console

### Règles Firestore (Sécurité)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Les utilisateurs ne peuvent voir que leurs propres données
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Les utilisateurs ne peuvent voir que leurs chats
    match /chats/{chatId} {
      allow read, write: if request.auth.uid == resource.data.userId;
      
      // Les messages du chat
      match /messages/{messageId} {
        allow read, write: if request.auth.uid == get(/databases/$(database)/documents/chats/$(chatId)).data.userId;
      }
    }
  }
}
```

### Règles Storage (Sécurité)
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Les utilisateurs peuvent uploader leur propre profil
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Les utilisateurs peuvent uploader dans leurs chats
    match /chats/{chatId}/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 📊 Gestion des Erreurs

Tous les services gèrent les erreurs et les remontent via les providers:
```dart
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage!)),
      );
    }
  },
);
```

## 🔄 Flux de Données

```
UI Widget
   ↓
Provider (AuthProvider, ChatProvider, MessageProvider)
   ↓
Service (FirebaseAuthService, FirestoreService, FirebaseStorageService)
   ↓
Firebase SDK (Auth, Firestore, Storage)
   ↓
Firebase Backend
```

## ✅ Checklist de Configuration

- [x] Firebase initialisé dans main.dart
- [x] Services créés et fonctionnels
- [x] Providers intégrés avec MultiProvider
- [x] Configuration Firestore configurée
- [x] Configuration Storage configurée
- [x] Authentification Firebase configurée
- [x] google-services.json mis à jour
- [x] Package names synchronisés

## 🆘 Dépannage

**Erreur de connexion Firebase:**
- Vérifier que Firebase est initialisé avant d'utiliser les services
- Vérifier la configuration dans firebase_options.dart
- Vérifier que le google-services.json est à jour

**Erreur Firestore:**
- Vérifier les règles de sécurité Firestore
- Vérifier que l'utilisateur est authentifié
- Vérifier les noms de collections

**Erreur Storage:**
- Vérifier les règles de sécurité Storage
- Vérifier les chemins de fichiers
- Vérifier les permissions

## 📚 Ressources

- [Firebase Documentation](https://firebase.flutter.dev)
- [Firestore Guide](https://firebase.google.com/docs/firestore)
- [Firebase Auth](https://firebase.google.com/docs/auth)
- [Firebase Storage](https://firebase.google.com/docs/storage)

---

**Firebase est maintenant prêt à l'emploi!** 🎉
