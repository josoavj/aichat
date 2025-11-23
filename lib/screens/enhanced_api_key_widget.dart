import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/link.dart';
import '../services/api_manager.dart';

/// Interface améliorée pour saisir la clé API
class EnhancedApiKeyWidget extends StatefulWidget {
  final ValueChanged<String> onSubmitted;
  final VoidCallback? onCancel;

  const EnhancedApiKeyWidget({
    required this.onSubmitted,
    this.onCancel,
    super.key,
  });

  @override
  State<EnhancedApiKeyWidget> createState() => _EnhancedApiKeyWidgetState();
}

class _EnhancedApiKeyWidgetState extends State<EnhancedApiKeyWidget> {
  late TextEditingController _textController;
  String? _errorMessage;
  bool _isObscured = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// Valide et soumet la clé API
  Future<void> _submitApiKey() async {
    final apiKey = _textController.text.trim();

    setState(() => _errorMessage = null);

    if (apiKey.isEmpty) {
      setState(() => _errorMessage = 'Veuillez entrer une clé API.');
      return;
    }

    if (!ApiManager.isValidApiKey(apiKey)) {
      setState(() {
        _errorMessage =
            'Clé API invalide. La clé doit contenir au moins 20 caractères.';
      });
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ApiManager.saveApiKey(apiKey);
      if (mounted) {
        widget.onSubmitted(apiKey);
      }
    } on ApiManagerException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isSubmitting = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur inattendue: $e';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.vpn_key,
                  size: 48,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              // Titre
              Text(
                'Configurez votre clé API',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              // Description
              Text(
                'Vous avez besoin d\'une clé API Google Generative AI pour utiliser cette application.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              // Lien pour obtenir une clé
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Obtenir une clé API',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Link(
                            uri: Uri.https(
                                'makersuite.google.com', '/app/apikey'),
                            target: LinkTarget.blank,
                            builder: (context, followLink) => TextButton(
                              onPressed: followLink,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Créez votre clé sur makersuite.google.com',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: theme.primaryColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Champ de saisie
              TextField(
                controller: _textController,
                enabled: !_isSubmitting,
                obscureText: _isObscured,
                textInputAction: TextInputAction.done,
                onSubmitted: _isSubmitting ? null : (_) => _submitApiKey(),
                decoration: InputDecoration(
                  labelText: 'Clé API',
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  hintText: 'Collez votre clé API ici...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  errorText: _errorMessage,
                  errorMaxLines: 2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _errorMessage != null
                          ? theme.colorScheme.error
                          : Colors.grey[400]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _errorMessage != null
                          ? theme.colorScheme.error
                          : theme.primaryColor,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _errorMessage != null
                          ? theme.colorScheme.error
                          : Colors.grey[300]!,
                    ),
                  ),
                  suffixIcon: _textController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: Icon(
                            _isObscured
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: theme.primaryColor,
                          ),
                          onPressed: () {
                            setState(() => _isObscured = !_isObscured);
                          },
                          tooltip: _isObscured
                              ? 'Afficher la clé'
                              : 'Masquer la clé',
                        ),
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),
              // Boutons
              Row(
                children: [
                  if (widget.onCancel != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : widget.onCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: theme.primaryColor.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          'Annuler',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  if (widget.onCancel != null) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitApiKey,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.check_circle),
                      label: Text(
                        _isSubmitting ? 'Vérification...' : 'Connecter',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
