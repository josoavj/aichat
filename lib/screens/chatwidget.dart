import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({required this.apiKey, super.key});

  final String apiKey;

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  late final GenerativeModel _model;
  late ChatSession _chat;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode(debugLabel: 'TextField');
  bool _loading = false;

  final List<Content> _messages = [];

  // Paramètres de sécurité
  final safetySettings = [
    SafetySetting(HarmCategory.harassment, HarmBlockThreshold.low),
    SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.low),
  ];

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: widget.apiKey,
      safetySettings: safetySettings, // Appliquer les paramètres de sécurité
    );
    _chat = _model.startChat(history: _messages); // Passer notre liste _messages ici
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    _textFieldFocus.dispose();
    super.dispose();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(
          milliseconds: 300,
        ),
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyToDisplay = _messages;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
              itemBuilder: (context, idx) {
                final content = historyToDisplay[idx];
                final text = content.parts
                    .whereType<TextPart>()
                    .map<String>((e) => e.text)
                    .join('');
                return MessageBubble(
                  text: text,
                  isFromUser: content.role == 'user',
                );
              },
              itemCount: historyToDisplay.length,
            ),
          ),
          _buildInputArea(context),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        color: theme.brightness == Brightness.dark ? Colors.grey[850] : Colors.white,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                focusNode: _textFieldFocus,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: _buildTextFieldDecoration(context, 'Tapez votre message ici...'),
                onSubmitted: (String value) {
                  _sendChatMessage(value);
                },
                maxLines: 5,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 10),
            _loading
                ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                color: theme.primaryColor,
              ),
            )
                : Container(
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {
                  _sendChatMessage(_textController.text);
                },
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                tooltip: 'Envoyer le message',
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildTextFieldDecoration(BuildContext context, String hintText) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(color: isDark ? Colors.grey[500] : Colors.grey[700], fontSize: 16),
      filled: true,
      fillColor: isDark ? Colors.grey[700] : Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: BorderSide(color: theme.primaryColor, width: 2.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
    );
  }

  Future<void> _sendChatMessage(String message) async {
    if (message.trim().isEmpty) return;

    final userMessage = Content.text(message);
    setState(() {
      _loading = true;
      _messages.add(userMessage);
    });
    _textController.clear();
    _textFieldFocus.unfocus(); // Ferme le clavier
    _scrollDown();

    try {
      final response = await _chat.sendMessage(userMessage);

      if (response.candidates.isNotEmpty) {
        final aiResponseContent = response.candidates.first.content;
        setState(() {
          _messages.add(aiResponseContent);
        });
            } else {
        _showError('Aucune réponse valide de l\'IA reçue.');
      }

    } catch (e) {
      _showError('Erreur: ${e.toString()}');
    } finally {
      setState(() {
        _loading = false;
      });
      _scrollDown();
    }
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Erreur d\'exécution', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Text(message, style: GoogleFonts.poppins()),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK', style: GoogleFonts.poppins(color: Theme.of(context).primaryColor)),
            )
          ],
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    required this.text,
    required this.isFromUser,
    super.key,
  });

  final String text;
  final bool isFromUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bubbleColor = isFromUser
        ? theme.primaryColor
        : isDark ? Colors.grey[700] : Colors.grey[200]!;

    final textColor = isFromUser
        ? Colors.white
        : isDark ? Colors.white : Colors.black87;

    final CrossAxisAlignment alignment =
    isFromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    final BorderRadius borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(20.0),
      topRight: const Radius.circular(20.0),
      bottomLeft: isFromUser ? const Radius.circular(20.0) : const Radius.circular(5.0),
      bottomRight: isFromUser ? const Radius.circular(5.0) : const Radius.circular(20.0),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: borderRadius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: textColor,
                fontSize: 15.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
