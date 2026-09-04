import 'package:ai_test/screens/dashboard_screen.dart';
import 'package:ai_test/screens/enhanced_api_key_widget.dart';
import 'package:ai_test/screens/enhanced_chat_widget.dart';
import 'package:ai_test/screens/journal_screen.dart';
import 'package:ai_test/screens/focus_screen.dart';
import 'package:ai_test/services/api_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? apiKey;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    try {
      final key = await ApiManager.getApiKey();
      if (mounted) setState(() => apiKey = key);
    } catch (e) {
      if (mounted) setState(() => apiKey = null);
    }
  }

  Future<void> _handleApiKeySubmitted(String key) async {
    try {
      await ApiManager.saveApiKey(key);
      if (mounted) setState(() => apiKey = key);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _resetApiKey() {
    setState(() => apiKey = null);
    ApiManager.deleteApiKey();
  }

  @override
  Widget build(BuildContext context) {
    if (apiKey == null) {
      return EnhancedApiKeyWidget(onSubmitted: _handleApiKeySubmitted);
    }

    final List<Widget> screens = [
      EnhancedChatWidget(apiKey: apiKey!, onApiKeyInvalid: _resetApiKey),
      const DashboardScreen(),
      const JournalScreen(),
      const FocusScreen(),
    ];

    final List<String> titles = ['FocusFlow Chat', 'Mes Tâches', 'Mon Journal', 'Focus Mode'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[_currentIndex],
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed('/profile'),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      drawer: _AppDrawer(onExit: () => SystemNavigator.pop()),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment),
              label: 'Tâches',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_stories_outlined),
              selectedIcon: Icon(Icons.auto_stories),
              label: 'Journal',
            ),
            NavigationDestination(
              icon: Icon(Icons.timer_outlined),
              selectedIcon: Icon(Icons.timer),
              label: 'Focus',
            ),
          ],
        ),
      ),
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
            decoration: BoxDecoration(color: theme.primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.bubble_chart, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text('FocusFlow', style: GoogleFonts.poppins(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w700)),
                Text('Votre assistant intelligent', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.info_outline, color: theme.primaryColor),
            title: Text('À propos', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/about');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings_outlined, color: theme.primaryColor),
            title: Text('Paramètres', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/settings');
            },
          ),
          const Divider(indent: 15, endIndent: 15),
          ListTile(
            leading: const Icon(Icons.exit_to_app_rounded, color: Colors.redAccent),
            title: Text('Quitter', style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.w500)),
            onTap: onExit,
          ),
        ],
      ),
    );
  }
}
