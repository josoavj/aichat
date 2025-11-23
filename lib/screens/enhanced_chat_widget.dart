import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';

/// Interface améliorée pour les conversations de chat
class EnhancedChatWidget extends StatefulWidget {
  final String apiKey;
  final VoidCallback? onApiKeyInvalid;

  const EnhancedChatWidget({
    required this.apiKey,
    this.onApiKeyInvalid,
    super.key,
  });

  @override
  State<EnhancedChatWidget> createState() => _EnhancedChatWidgetState();
}

class _EnhancedChatWidgetState extends State<EnhancedChatWidget> {
  late final ApiService _apiService;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode(debugLabel: 'TextField');

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApi();
  }

  /// Initialise le service API
  Future<void> _initializeApi() async {
    try {
      _apiService = ApiService();
      _apiService.initialize(widget.apiKey);
      setState(() => _isInitializing = false);
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur d\'initialisation: $e';
        _isInitializing = false;
      });
      widget.onApiKeyInvalid?.call();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    _textFieldFocus.dispose();
    _apiService.dispose();
    super.dispose();
  }

  /// Envoie un message et gère la réponse
  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isFromUser: true));
      _isLoading = true;
      _errorMessage = null;
    });

    _textController.clear();
    _textFieldFocus.unfocus();
    _scrollToBottom();

    try {
      final response = await _apiService.sendMessage(text);
      setState(() {
        _messages.add(ChatMessage(text: response, isFromUser: false));
      });
    } on ApiServiceException catch (e) {
      setState(() {
        _messages.add(ChatMessage.error(e.message));
        _errorMessage = e.message;
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  /// Fait défiler jusqu'en bas
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Efface l'historique des messages
  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Effacer l\'historique',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir effacer toute la conversation?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _messages.clear());
              _apiService.resetConversation();
              Navigator.pop(context);
            },
            child: const Text('Effacer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isInitializing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: theme.primaryColor),
            const SizedBox(height: 16),
            Text(
              'Initialisation du chat...',
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: theme.colorScheme.error),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: widget.onApiKeyInvalid,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Barre d'info
        if (_messages.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_messages.length} messages',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: _clearHistory,
                  tooltip: 'Effacer l\'historique',
                ),
              ],
            ),
          ),
        // Liste des messages
        Expanded(
          child: _messages.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  itemCount: _messages.length,
                  itemBuilder: (context, idx) {
                    final message = _messages[idx];
                    return MessageBubble(message: message);
                  },
                ),
        ),
        // Zone de saisie
        _buildInputArea(theme),
      ],
    );
  }

  /// Widget pour afficher quand il n'y a pas de messages
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: theme.primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun message pour le moment',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez une conversation!',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// Construit la zone de saisie
  Widget _buildInputArea(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(12),
        color: isDark ? Colors.grey[850] : Colors.white,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                focusNode: _textFieldFocus,
                enabled: !_isLoading,
                maxLines: 5,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: _isLoading
                      ? 'Veuillez attendre...'
                      : 'Tapez votre message...',
                  hintStyle: GoogleFonts.poppins(
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey[700] : Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: theme.primaryColor,
                      width: 2,
                    ),
                  ),
                ),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                onSubmitted: _isLoading ? null : _sendMessage,
              ),
            ),
            const SizedBox(width: 12),
            _isLoading
                ? Padding(
                    padding: const EdgeInsets.all(8),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        color: theme.primaryColor,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () => _sendMessage(_textController.text),
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                      ),
                      tooltip: 'Envoyer',
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

/// Composant pour afficher un message
class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isError = message.error != null;
    final bubbleColor = message.isFromUser
        ? theme.primaryColor
        : isError
            ? theme.colorScheme.error.withOpacity(0.2)
            : isDark
                ? Colors.grey[700]
                : Colors.grey[200];

    final textColor = message.isFromUser
        ? Colors.white
        : isError
            ? theme.colorScheme.error
            : isDark
                ? Colors.white70
                : Colors.black87;

    final alignment =
        message.isFromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: message.isFromUser
          ? const Radius.circular(20)
          : const Radius.circular(4),
      bottomRight: message.isFromUser
          ? const Radius.circular(4)
          : const Radius.circular(20),
    );

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: borderRadius,
            border: isError
                ? Border.all(color: theme.colorScheme.error, width: 1)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 16,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Erreur',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              Text(
                message.text,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: textColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(message.timestamp),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: textColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Formate l'heure du message
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (time.year == now.year &&
        time.month == now.month &&
        time.day == now.day) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    return '${time.day}/${time.month} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
