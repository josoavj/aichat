import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pages/login.dart';

class Intro extends StatefulWidget {
  const Intro({super.key});

  @override
  State<Intro> createState() => _IntroState();
}

class _IntroState extends State<Intro> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Durée souhaitée pour les animations d'introduction
  final Duration _animationDuration = const Duration(milliseconds: 1500);
  // Délai avant de naviguer (devrait être >= _animationDuration si vous voulez voir toute l'animation)
  final Duration _navigationDelay = const Duration(milliseconds: 2000);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _animationDuration, // Durée de l'animation ajustée
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack, // Effet rebondissant pour l'avatar
      ),
    );

    // Lance l'animation au démarrage
    _controller.forward();

    // Navigue après un délai
    _scheduleNavigation();
  }

  void _scheduleNavigation() {
    Future.delayed(_navigationDelay, () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final avatarDiameter = screenWidth * 0.4;

    return Scaffold(
      body: Container(
        // ... (votre décoration de gradient) ...
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 7, 116, 206),
              Color.fromARGB(255, 1, 60, 107),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: SizedBox(
                    width: avatarDiameter,  // Utiliser la taille dynamique
                    height: avatarDiameter, // Utiliser la taille dynamique
                    child: CircleAvatar(
                      radius: avatarDiameter / 2, // Le rayon est la moitié du diamètre
                      foregroundImage: const AssetImage(
                        "assets/images/todoroki.png",
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // ... (le reste de vos widgets Text) ...
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Welcome to',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'MyAI',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black.withAlpha((255 * 0.5).round()),
                        offset: const Offset(3.0, 3.0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}