import 'package:ai_test/screens/enhanced_api_key_widget.dart';
import 'package:ai_test/screens/enhanced_chat_widget.dart';
import 'package:ai_test/services/api_manager.dart';
import 'package:ai_test/others/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? apiKey;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  // Chargement de la clé API depuis l'API Manager
  Future<void> _loadApiKey() async {
    try {
      final key = await ApiManager.getApiKey();
      setState(() {
        apiKey = key;
      });
    } catch (e) {
      // Clé API non trouvée, l'utilisateur devra la saisir
      setState(() {
        apiKey = null;
      });
    }
  }

  // Fonction pour gérer la soumission de la clé API
  Future<void> _handleApiKeySubmitted(String key) async {
    try {
      await ApiManager.saveApiKey(key);
      setState(() {
        apiKey = key;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Fonction pour réinitialiser la clé API
  void _resetApiKey() {
    setState(() {
      apiKey = null;
    });
    ApiManager.deleteApiKey();
  }

  // Fonction pour afficher la boîte de dialogue de confirmation de sortie
  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Quitter l'application",
            style:
                GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Vous êtes sur le point de quitter l'application. Voulez-vous continuer ?",
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Annuler",
                style: GoogleFonts.poppins(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              child: Text(
                "Quitter",
                style: GoogleFonts.poppins(
                    color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Utilisation de Consumer pour écouter les changements de thème
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'My Chat-AI',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              Tooltip(
                message: "Mon Profil",
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/profile');
                  },
                  icon: const Icon(Icons.person, color: Colors.white),
                ),
              ),
            ],
          ),
          drawer: _AppDrawer(
            onExit: _showExitConfirmationDialog,
          ),
          body: switch (apiKey) {
            final providedKey? => EnhancedChatWidget(
                apiKey: providedKey,
                onApiKeyInvalid: _resetApiKey,
              ),
            _ => EnhancedApiKeyWidget(
                onSubmitted: _handleApiKeySubmitted,
              ),
          },
        );
      },
    );
  }
}

// Widget pour le tiroir de navigation (Drawer)
class _AppDrawer extends StatelessWidget {
  final VoidCallback onExit;

  const _AppDrawer({required this.onExit});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: isDark ? theme.primaryColor : theme.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const Icon(
                    Icons.bubble_chart,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'MyAI ChatBot',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Votre assistant intelligent',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.info, color: theme.primaryColor),
            title: Text(
              'À propos',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.blueGrey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/about');
            },
            selectedTileColor: theme.primaryColor.withOpacity(0.1),
            hoverColor: theme.primaryColor.withOpacity(0.05),
          ),
          ListTile(
            leading: Icon(Icons.settings, color: theme.primaryColor),
            title: Text(
              'Paramètres',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.blueGrey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/settings');
            },
            selectedTileColor: theme.primaryColor.withOpacity(0.1),
            hoverColor: theme.primaryColor.withOpacity(0.05),
          ),
          const Divider(indent: 15, endIndent: 15),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
            title: Text(
              'Quitter',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.redAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              onExit();
            },
            selectedTileColor: Colors.redAccent.withOpacity(0.1),
            hoverColor: Colors.redAccent.withOpacity(0.05),
          ),
        ],
      ),
    );
  }
}
