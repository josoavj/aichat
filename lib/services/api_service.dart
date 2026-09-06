import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:ai_test/services/logger_service.dart';
import 'package:ai_test/services/task_service.dart';

/// Service pour gérer l'API Generative AI avec Function Calling
class ApiService {
  late GenerativeModel _model;
  late ChatSession _chat;
  bool _isInitialized = false;
  final TaskService _taskService = TaskService();
  
  /// Callback pour les actions UI (comme lancer un minuteur)
  void Function(String action, Map<String, dynamic> params)? onUiAction;

  // Configuration
  static const Duration _apiTimeout = Duration(seconds: 30);

  // Définition des outils (fonctions que l'IA peut appeler)
  late final List<Tool> _tools;

  // Paramètres de sécurité
  static final safetySettings = [
    SafetySetting(HarmCategory.harassment, HarmBlockThreshold.low),
    SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.low),
  ];

  ApiService() {
    _tools = [
      Tool(functionDeclarations: [
        FunctionDeclaration(
          'ajouter_tache',
          'Ajoute une nouvelle tâche ou un objectif à la liste locale de l\'utilisateur.',
          Schema.object(properties: {
            'titre': Schema.string(description: 'Le titre clair de la tâche'),
            'description': Schema.string(description: 'Détails supplémentaires ou contexte'),
            'urgence': Schema.number(description: 'Niveau d\'urgence de 1 à 5'),
            'etapes': Schema.array(items: Schema.string(), description: 'Liste de micro-étapes pour accomplir la tâche'),
          }, requiredProperties: ['titre']),
        ),
        FunctionDeclaration(
          'lister_taches',
          'Récupère la liste de toutes les tâches en cours (non terminées).',
          Schema.object(properties: {}),
        ),
        FunctionDeclaration(
          'terminer_tache',
          'Marque une tâche spécifique comme terminée en utilisant son identifiant numérique.',
          Schema.object(properties: {
            'id': Schema.number(description: 'L\'identifiant unique (ID) de la tâche'),
          }, requiredProperties: ['id']),
        ),
        FunctionDeclaration(
          'ajouter_journal',
          'Enregistre une pensée, une note ou une entrée de journal pour l\'utilisateur.',
          Schema.object(properties: {
            'contenu': Schema.string(description: 'Le texte de la note ou de la réflexion'),
            'humeur': Schema.string(description: 'L\'état émotionnel détecté ou exprimé (ex: calme, anxieux, motivé)'),
            'tags': Schema.array(items: Schema.string(), description: 'Mots-clés pour classer la note'),
          }, requiredProperties: ['contenu']),
        ),
        FunctionDeclaration(
          'lister_journal',
          'Récupère les dernières entrées du journal ou des notes.',
          Schema.object(properties: {
            'limite': Schema.number(description: 'Nombre d\'entrées à récupérer'),
          }),
        ),
        FunctionDeclaration(
          'lancer_focus',
          'Démarre un minuteur de concentration (Pomodoro) pour l\'utilisateur.',
          Schema.object(properties: {
            'minutes': Schema.number(description: 'La durée du minuteur en minutes (défaut: 25)'),
          }),
        ),
      ])
    ];
  }

  /// Initialise le service avec une clé API et charge l'historique
  Future<void> initialize(String apiKey) async {
    try {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        safetySettings: safetySettings,
        tools: _tools,
        systemInstruction: Content.system(
          'Tu es \'FocusFlow\', le copilote exécutif de l\'utilisateur. Ton but est de hacker son attention pour transformer son hyperactivité en super-pouvoir. '
          'Règles d\'or de ton Persona : '
          '1. **Micro-étapes ridicules** : Ne propose jamais une étape de plus de 10 min. Si l\'utilisateur veut "nettoyer la cuisine", ton étape 1 est "Mettre 3 assiettes dans le lave-vaisselle". '
          '2. **Scan visuel** : Utilise massivement le **gras** pour les actions et les objets. Les hyperactifs scannent le texte au lieu de le lire. '
          '3. **Zéro Culpabilité** : Si une tâche est en retard, dis "C\'est pas grave, le plan change. On fait quoi maintenant ?". '
          '4. **Body Doubling** : Utilise le "On" ou "Nous". Dis "On s\'y met ensemble". '
          '5. **Dopamine Hit** : Célèbre chaque petite victoire. '
          '6. **Accès Local** : Utilise \'ajouter_tache\', \'lister_taches\', \'terminer_tache\' pour agir. '
          '7. **Brain Dump** : Si l\'utilisateur divague, utilise \'ajouter_journal\' pour capturer l\'idée et ramène-le au focus actuel. '
          '8. **Mode Urgence** : Si l\'utilisateur est submergé, propose-lui de fermer les yeux et de lancer un Focus de 5 min via \'lancer_focus\'.'
        ),
      );

      // Charger l'historique depuis la base de données
      final history = await _taskService.getChatHistory();
      final List<Content> chatHistory = history.map((m) {
        return m['role'] == 'user' 
          ? Content.text(m['content']) 
          : Content.model([TextPart(m['content'])]);
      }).toList();

      _chat = _model.startChat(history: chatHistory);
      _isInitialized = true;
      AppLogger.info('ApiService (FocusFlow) initialisé avec mémoire');
    } catch (e) {
      AppLogger.error('Erreur lors de l\'initialisation d\'ApiService', e);
      throw ApiServiceException('Erreur lors de l\'initialisation: $e');
    }
  }

  bool get isInitialized => _isInitialized;

  /// Envoie un message, gère les fonctions et sauvegarde
  Future<String> sendMessage(String message) async {
    if (!_isInitialized) throw ApiServiceException('Service non initialisé.');

    try {
      AppLogger.debug('Envoi message : $message');
      
      // Sauvegarder le message utilisateur
      await _taskService.saveChatMessage('user', message);

      var response = await _chat.sendMessage(Content.text(message)).timeout(_apiTimeout);

      while (response.functionCalls.isNotEmpty) {
        final List<FunctionResponse> functionResponses = [];

        for (final call in response.functionCalls) {
          final result = await _executeFunction(call.name, call.args);
          functionResponses.add(FunctionResponse(call.name, result));
        }

        response = await _chat.sendMessage(Content.functionResponses(functionResponses)).timeout(_apiTimeout);
      }

      final responseText = response.text ?? 'Action effectuée.';
      
      // Sauvegarder la réponse de l'IA
      await _taskService.saveChatMessage('model', responseText);

      return responseText;
    } catch (e) {
      AppLogger.error('Erreur lors de l\'envoi du message', e);
      throw ApiServiceException('Erreur: $e');
    }
  }

  Future<Map<String, dynamic>> _executeFunction(String name, Map<String, dynamic> args) async {
    AppLogger.info('Appel fonction : $name');
    
    switch (name) {
      case 'ajouter_tache':
        final res = await _taskService.addTask(
          args['titre'],
          description: args['description'] ?? '',
          urgency: (args['urgence'] ?? 3).toInt(),
          subTasks: args['etapes'] != null ? List<String>.from(args['etapes']) : null,
        );
        return {'resultat': res};
      case 'lister_taches':
        final res = await _taskService.listPendingTasks();
        return {'liste': res};
      case 'terminer_tache':
        final res = await _taskService.completeTask((args['id'] as num).toInt());
        return {'resultat': res};
      case 'ajouter_journal':
        final res = await _taskService.addJournalEntry(
          args['contenu'],
          mood: args['humeur'],
          tags: args['tags'] != null ? List<String>.from(args['tags']) : null,
        );
        return {'resultat': res};
      case 'lister_journal':
        final res = await _taskService.listJournalEntries(limit: (args['limite'] ?? 10).toInt());
        return {'journal': res};
      case 'lancer_focus':
        if (onUiAction != null) {
          onUiAction!('lancer_focus', {'minutes': (args['minutes'] ?? 25).toInt()});
        }
        return {'resultat': 'Minuteur lancé pour ${args['minutes'] ?? 25} minutes.'};
      default:
        return {'erreur': 'Fonction inconnue'};
    }
  }

  /// Obtient l'historique actuel de la session de chat
  List<Content> getHistory() {
    if (!_isInitialized) return [];
    return _chat.history.toList();
  }

  void resetConversation() {
    if (_isInitialized) {
      _chat = _model.startChat(history: []);
    }
  }

  void dispose() {
    _isInitialized = false;
  }
}

class ApiServiceException implements Exception {
  final String message;
  ApiServiceException(this.message);
  @override
  String toString() => message;
}
