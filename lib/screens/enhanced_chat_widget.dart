import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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
  bool _showScrollButton = false;

  @override
  void initState() {
    super.initState();
    _initializeApi();
    _scrollController.addListener(_handleScroll);
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

  void _handleScroll() {
    if (_scrollController.hasClients) {
      final isNearBottom = _scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 200;
      if (isNearBottom && _showScrollButton) {
        setState(() => _showScrollButton = false);
      } else if (!isNearBottom && !_showScrollButton) {
        setState(() => _showScrollButton = true);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
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
          duration: const Duration(milliseconds: 500),
          curve: Curves.outPowerful,
        );
      }
    });
  }

  /// Efface l'historique des messages
  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            child: Text('Annuler', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              setState(() => _messages.clear());
              _apiService.resetConversation();
              Navigator.pop(context);
            },
            child: Text('Effacer',
                style: GoogleFonts.poppins(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isInitializing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: theme.primaryColor,
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Initialisation de l\'IA...',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500, letterSpacing: 0.5),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.bolt, color: theme.colorScheme.error, size: 48),
              ),
              const SizedBox(height: 24),
              Text(
                'Oups ! Une erreur est survenue',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: widget.onApiKeyInvalid,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.key),
                label: const Text('Modifier la clé API'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        Column(
          children: [
            // Barre d'info (optionnelle, déplacée dans le Drawer ou AppBar idéalement)
            if (_messages.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: _clearHistory,
                      icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                      label: Text(
                        'Effacer',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey,
                      ),
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
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
                      itemCount: _messages.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, idx) {
                        if (idx == _messages.length) {
                          return const TypingIndicator();
                        }
                        final message = _messages[idx];
                        return MessageBubble(message: message);
                      },
                    ),
            ),
          ],
        ),
        // Bouton Scroll to Bottom
        if (_showScrollButton)
          Positioned(
            bottom: 110,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: _scrollToBottom,
              backgroundColor: theme.primaryColor,
              child: const Icon(Icons.arrow_downward, color: Colors.white),
            ),
          ),
        // Zone de saisie flottante
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildInputArea(theme),
        ),
      ],
    );
  }

  /// Widget pour afficher quand il n'y a pas de messages
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 80,
                color: theme.primaryColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Prêt à vous aider !',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'Posez-moi n\'importe quelle question pour commencer notre conversation.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 40),
            _buildQuickActions(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    final actions = [
      'Explique-moi le code Quantum',
      'Écris un poème sur la mer',
      'Idées de repas sains',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: actions
          .map((action) => ActionChip(
                label: Text(action),
                labelStyle: GoogleFonts.poppins(fontSize: 12),
                backgroundColor: theme.primaryColor.withOpacity(0.05),
                onPressed: () => _sendMessage(action),
              ))
          .toList(),
    );
  }

  /// Construit la zone de saisie
  Widget _buildInputArea(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.scaffoldBackgroundColor.withOpacity(0),
            theme.scaffoldBackgroundColor.withOpacity(0.9),
            theme.scaffoldBackgroundColor,
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.grey[850]!.withOpacity(0.8)
                  : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black12,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
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
                      hintText: 'Écrivez votre message...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    onSubmitted: _isLoading ? null : _sendMessage,
                  ),
                ),
                const SizedBox(width: 4),
                _isLoading
                    ? const SizedBox(
                        width: 44,
                        height: 44,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        onPressed: () => _sendMessage(_textController.text),
                        icon: Icon(
                          Icons.send_rounded,
                          color: theme.primaryColor,
                        ),
                        tooltip: 'Envoyer',
                      ),
              ],
            ),
          ),
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

    final alignment =
        message.isFromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: message.isFromUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!message.isFromUser) _buildAvatar(theme),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: message.isFromUser
                        ? LinearGradient(
                            colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: !message.isFromUser
                        ? (isError
                            ? theme.colorScheme.error.withOpacity(0.1)
                            : isDark
                                ? Colors.grey[800]
                                : Colors.grey[100])
                        : null,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(message.isFromUser ? 20 : 4),
                      bottomRight: Radius.circular(message.isFromUser ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isError)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  size: 14, color: theme.colorScheme.error),
                              const SizedBox(width: 4),
                              Text('Erreur',
                                  style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.error)),
                            ],
                          ),
                        ),
                      MarkdownBody(
                        data: message.text,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                          p: GoogleFonts.poppins(
                            fontSize: 14,
                            color: message.isFromUser
                                ? Colors.white
                                : isError
                                    ? theme.colorScheme.error
                                    : (isDark ? Colors.white70 : Colors.black87),
                            height: 1.5,
                          ),
                          code: GoogleFonts.firaCode(
                            backgroundColor: isDark ? Colors.black26 : Colors.black12,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 9,
                          color: (message.isFromUser ? Colors.white : Colors.grey)
                              .withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (message.isFromUser) _buildAvatar(theme, isUser: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme, {bool isUser = false}) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isUser ? theme.primaryColor.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isUser ? Icons.person_outline : Icons.smart_toy_outlined,
        size: 16,
        color: isUser ? theme.primaryColor : Colors.grey[600],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

/// Indicateur de saisie (typing)
class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                _buildDot(theme, 0),
                const SizedBox(width: 4),
                _buildDot(theme, 1),
                const SizedBox(width: 4),
                _buildDot(theme, 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(ThemeData theme, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 150)),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: 0.3 + (0.7 * value),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
