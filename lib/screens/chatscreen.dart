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

  Future<void> _loadApiKey() async {
    try {
      final key = await ApiManager.getApiKey();
      if (mounted) {
        setState(() {
          apiKey = key;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          apiKey = null;
        });
      }
    }
  }

  Future<void> _handleApiKeySubmitted(String key) async {
    try {
      await ApiManager.saveApiKey(key);
      if (mounted) {
        setState(() {
          apiKey = key;
        });
      }
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

  void _resetApiKey() {
    setState(() {
      apiKey = null;
    });
    ApiManager.deleteApiKey();
  }

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
                'Annuler',
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
                'Quitter',
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
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'FocusFlow',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              Tooltip(
                message: 'Mon Profil',
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/profile');
                  },
                  icon: const Icon(Icons.person),
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

class _AppDrawer extends StatelessWidget {
  final VoidCallback onExit;

  const _AppDrawer({required this.onExit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: const Icon(
                    Icons.bubble_chart,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'FocusFlow',
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
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard_outlined, color: theme.primaryColor),
            title: Text(
              'Dashboard',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              // Navigation vers Dashboard à venir
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline, color: theme.primaryColor),
            title: Text(
              'À propos',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/about');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings_outlined, color: theme.primaryColor),
            title: Text(
              'Paramètres',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/settings');
            },
          ),
          const Divider(indent: 15, endIndent: 15),
          ListTile(
            leading: const Icon(Icons.exit_to_app_rounded, color: Colors.redAccent),
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
          ),
        ],
      ),
    );
  }
}
