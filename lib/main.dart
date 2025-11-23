import 'package:ai_test/pages/login.dart';
import 'package:ai_test/pages/settings.dart';
import 'package:ai_test/screens/intro.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_test/screens/chatscreen.dart';
import 'package:ai_test/pages/about.dart';
import 'package:ai_test/pages/profile.dart';
import 'others/app_theme.dart';

void main() {
  runApp(
    // On enveloppe l'application avec le ChangeNotifierProvider
    // pour rendre le ThemeNotifier disponible à tous les widgets en dessous.
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Le Consumer écoute les changements dans ThemeNotifier
    // et reconstruit l'application si le thème change.
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'MyAI Assistant',
          debugShowCheckedModeBanner: false,
          theme: AppThemes.lightTheme(themeNotifier.primarySwatch),
          darkTheme: AppThemes.darkTheme(themeNotifier.primarySwatch),
          themeMode: themeNotifier.themeMode,
          routes: {
            '/': (context) => const ChatScreen(),
            '/login': (context) => const LoginPage(),
            '/settings': (context) => const Settings(),
            '/about': (context) => const About(),
            '/profile': (context) => const Profile(),
            '/intro': (context) => const Intro(),
          },
          // Affiche l'intro seulement si le thème est initialisé
          initialRoute: themeNotifier.isInitialized ? '/intro' : '/',
        );
      },
    );
  }
}
