import 'package:ai_test/providers/profile_provider.dart';
import 'package:ai_test/pages/profile_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ai_test/pages/settings.dart';
import 'package:ai_test/screens/intro.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_test/screens/chatscreen.dart';
import 'package:ai_test/pages/about.dart';
import 'package:ai_test/providers/task_provider.dart';
import 'package:ai_test/providers/journal_provider.dart';
import 'others/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeNotifier = ThemeNotifier();
  await themeNotifier.initializeSync();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeNotifier),
        ChangeNotifierProvider(create: (context) => ProfileProvider()..loadProfile()),
        ChangeNotifierProvider(create: (context) => TaskProvider()..loadTasks()),
        ChangeNotifierProvider(create: (context) => JournalProvider()..loadEntries()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        String initialRoute = themeNotifier.isInitialized ? '/' : '/intro';

        return MaterialApp(
          title: 'FocusFlow Assistant',
          debugShowCheckedModeBanner: false,
          theme: AppThemes.lightTheme(themeNotifier.primarySwatch),
          darkTheme: AppThemes.darkTheme(themeNotifier.primarySwatch),
          themeMode: themeNotifier.themeMode,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('fr', 'FR'),
          ],
          routes: {
            '/': (context) => const ChatScreen(),
            '/settings': (context) => const Settings(),
            '/about': (context) => const About(),
            '/intro': (context) => const Intro(),
            '/profile': (context) => const ProfilePage(),
          },
          initialRoute: initialRoute,
        );
      },
    );
  }
}
