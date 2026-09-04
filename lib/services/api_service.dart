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

  /// Initialise le service avec une clé API
  void initialize(String apiKey) {
    try {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        safetySettings: safetySettings,
        tools: _tools,
        systemInstruction: Content.system(
          'Tu es \'FocusFlow\', un assistant personnel ultra-performant conçu pour aider les personnes hyperactives à rester concentrées. '
          'Tu as accès à une liste de tâches locale et un journal sur l\'appareil de l\'utilisateur. '
          'Règles impératives : '
          '1. Quand l\'utilisateur mentionne une tâche à faire, utilise TOUJOURS \'ajouter_tache\'. '
          '2. Découpe SYSTEMATIQUEMENT les tâches complexes en micro-étapes. '
          '3. Sois concis. '
          '4. Si l\'utilisateur demande ce qu\'il a à faire, utilise \'lister_taches\'. '
          '5. Quand une pensée ou note est exprimée, utilise \'ajouter_journal\'.'
        ),
      );
      _chat = _model.startChat(history: []);
      _isInitialized = true;
      AppLogger.info('ApiService (FocusFlow) initialisé');
    } catch (e) {
      AppLogger.error('Erreur lors de l\'initialisation d\'ApiService', e);
      throw ApiServiceException('Erreur lors de l\'initialisation: $e');
    }
  }

  bool get isInitialized => _isInitialized;

  /// Envoie un message et gère les appels de fonctions
  Future<String> sendMessage(String message) async {
    if (!_isInitialized) throw ApiServiceException('Service non initialisé.');

    try {
      AppLogger.debug('Envoi message : $message');
      var response = await _chat.sendMessage(Content.text(message)).timeout(_apiTimeout);

      while (response.functionCalls.isNotEmpty) {
        final List<FunctionResponse> functionResponses = [];

        for (final call in response.functionCalls) {
          final result = await _executeFunction(call.name, call.args);
          functionResponses.add(FunctionResponse(call.name, result));
        }

        response = await _chat.sendMessage(Content.functionResponses(functionResponses)).timeout(_apiTimeout);
      }

      return response.text ?? 'Action effectuée.';
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
      case 'lancer_focus':
        if (onUiAction != null) {
          onUiAction!('lancer_focus', {'minutes': (args['minutes'] ?? 25).toInt()});
        }
        return {'resultat': 'Minuteur lancé pour ${args['minutes'] ?? 25} minutes.'};
      default:
        return {'erreur': 'Fonction inconnue'};
    }
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
