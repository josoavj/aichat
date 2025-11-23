import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/chatscreen.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isObscure = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top,
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _fadeInAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    _buildHeader(colorScheme, textTheme),
                    const SizedBox(height: 48),
                    _buildLoginForm(colorScheme),
                    const SizedBox(height: 24),
                    _buildLoginButton(colorScheme, textTheme),
                    const SizedBox(height: 24),
                    _buildRememberMe(colorScheme, textTheme),
                    const SizedBox(height: 32),
                    _buildTestAccountsToggle(colorScheme, textTheme),
                    const Spacer(),
                    _buildFooter(colorScheme, textTheme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            CupertinoIcons.person_circle_fill,
            size: 64,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "Connexion",
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Connectez-vous à votre compte",
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(ColorScheme colorScheme) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildUsernameField(colorScheme),
          const SizedBox(height: 16),
          _buildPasswordField(colorScheme),
        ],
      ),
    );
  }

  Widget _buildUsernameField(ColorScheme colorScheme) {
    return TextFormField(
      controller: _usernameController,
      decoration: InputDecoration(
        labelText: "Nom d'utilisateur",
        prefixIcon: const Icon(CupertinoIcons.person_fill),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: colorScheme.surface,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Veuillez entrer votre nom d'utilisateur";
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(ColorScheme colorScheme) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _isObscure,
      decoration: InputDecoration(
        labelText: "Mot de passe",
        prefixIcon: const Icon(CupertinoIcons.lock_fill),
        suffixIcon: IconButton(
          icon: Icon(_isObscure
              ? CupertinoIcons.eye_slash_fill
              : CupertinoIcons.eye_fill),
          onPressed: () {
            setState(() {
              _isObscure = !_isObscure;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: colorScheme.surface,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Veuillez entrer votre mot de passe";
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton(ColorScheme colorScheme, TextTheme textTheme) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                ),
              )
            : Text(
                "Se connecter",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildRememberMe(ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
            ),
            Text(
              "Se souvenir de moi",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            _showForgotPasswordDialog();
          },
          child: Text(
            "Mot de passe oublié?",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  // Nouveau widget pour le bouton de basculement qui affiche le dialogue
  Widget _buildTestAccountsToggle(
      ColorScheme colorScheme, TextTheme textTheme) {
    return InkWell(
      onTap: () {
        _showTestAccountsDialog();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
                child: Divider(color: colorScheme.onSurface.withOpacity(0.3))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    "Comptes de test",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    CupertinoIcons.arrow_right,
                    size: 14,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ),
            Expanded(
                child: Divider(color: colorScheme.onSurface.withOpacity(0.3))),
          ],
        ),
      ),
    );
  }

  // Ce widget n'est plus utilisé directement dans le build()
  Widget _buildTestUserCard({
    required String username,
    required String fullName,
    required String description,
    required bool isOnline,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.onSurface.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: colorScheme.onSurface.withOpacity(0.1),
                  child: Text(
                    fullName.split(' ').map((n) => n[0]).join(),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                if (isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: colorScheme.surface, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(
                    "@$username",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: textTheme.bodySmall?.color,
                    ),
                  ),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.arrow_right_circle_fill,
              color: colorScheme.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showTestAccountsDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Comptes de test",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textTheme.bodyLarge?.color,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTestUserCard(
                  username: "sudoted",
                  fullName: "Sudo Ted",
                  description: "Développeur · Antananarivo",
                  isOnline: true,
                  onTap: () {
                    _fillCredentials("sudoted", "password123");
                    Navigator.of(context).pop();
                  },
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                const SizedBox(height: 12),
                _buildTestUserCard(
                  username: "marie_dev",
                  fullName: "Marie Rakoto",
                  description: "Designer · Fianarantsoa",
                  isOnline: false,
                  onTap: () {
                    _fillCredentials("marie_dev", "marie2024");
                    Navigator.of(context).pop();
                  },
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Fermer",
                  style: GoogleFonts.poppins(color: colorScheme.primary)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFooter(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      children: [
        Text(
          "Pas de compte?",
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: textTheme.bodySmall?.color,
          ),
        ),
        TextButton(
          onPressed: () {
            _showRegisterDialog();
          },
          child: Text(
            "Créer un compte",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  void _fillCredentials(String username, String password) {
    setState(() {
      _usernameController.text = username;
      _passwordController.text = password;
    });
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      try {
        final authService = AuthService();
        await authService.initialize();
        await authService.login(
          username,
          password,
          rememberMe: _rememberMe,
        );

        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Connexion réussie! Bienvenue ${authService.currentUser?.fullName}",
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ChatScreen()),
          );
        }
      } on AuthException catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.message,
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Erreur: ${e.toString()}',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Mot de passe oublié",
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textTheme.bodyLarge?.color),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Entrez votre nom d'utilisateur pour réinitialiser votre mot de passe.",
                style: GoogleFonts.poppins(
                    fontSize: 14, color: textTheme.bodyMedium?.color),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: "Nom d'utilisateur",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                "Annuler",
                style: GoogleFonts.poppins(
                    fontSize: 14, color: colorScheme.onSurface),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                "Envoyer",
                style: GoogleFonts.poppins(
                    fontSize: 14, color: colorScheme.primary),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Instructions envoyées par email")));
              },
            ),
          ],
        );
      },
    );
  }

  void _showRegisterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Créer un compte",
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textTheme.bodyLarge?.color),
          ),
          content: Text(
            "La création de compte n'est pas encore disponible. Utilisez les comptes de test pour le moment.",
            style: GoogleFonts.poppins(
                fontSize: 14, color: textTheme.bodyMedium?.color),
          ),
          actions: [
            TextButton(
              child: Text(
                "Compris",
                style: GoogleFonts.poppins(
                    fontSize: 14, color: colorScheme.primary),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
