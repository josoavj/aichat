import 'package:ai_test/pages/firebase_login.dart';
import 'package:ai_test/pages/firebase_profile.dart';
import 'package:ai_test/pages/settings.dart';
import 'package:ai_test/screens/intro.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_test/screens/chatscreen.dart';
import 'package:ai_test/pages/about.dart';
import 'package:ai_test/config/firebase_config.dart';
import 'package:ai_test/providers/auth_provider.dart';
import 'package:ai_test/providers/chat_provider.dart';
import 'package:ai_test/providers/message_provider.dart';
import 'others/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Firebase avant de lancer l'app
  await FirebaseConfig.initialize();

  // Initialiser le ThemeNotifier avant de lancer l'app
  final themeNotifier = ThemeNotifier();
  await themeNotifier.initializeSync();

  runApp(
    MultiProvider(
      providers: [
        // Theme Provider
        ChangeNotifierProvider.value(
          value: themeNotifier,
        ),
        // Firebase Providers
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ChatProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => MessageProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Le Consumer écoute les changements dans ThemeNotifier et AuthProvider
    return Consumer2<ThemeNotifier, AuthProvider>(
      builder: (context, themeNotifier, authProvider, child) {
        // Déterminer la route initiale selon l'authentification
        String initialRoute;
        if (!themeNotifier.isInitialized) {
          initialRoute = '/intro';
        } else if (!authProvider.isLoggedIn) {
          initialRoute = '/login';
        } else {
          initialRoute = '/';
        }

        return MaterialApp(
          title: 'MyAI Assistant',
          debugShowCheckedModeBanner: false,
          theme: AppThemes.lightTheme(themeNotifier.primarySwatch),
          darkTheme: AppThemes.darkTheme(themeNotifier.primarySwatch),
          themeMode: themeNotifier.themeMode,
          routes: {
            '/': (context) => const ChatScreen(),
            '/login': (context) => const FirebaseLoginPage(),
            '/settings': (context) => const Settings(),
            '/about': (context) => const About(),
            '/profile': (context) => const FirebaseProfilePage(),
            '/intro': (context) => const Intro(),
          },
          initialRoute: initialRoute,
        );
      },
    );
  }
}
