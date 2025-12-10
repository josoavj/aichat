import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ai_test/providers/auth_provider.dart';

class FirebaseLoginPage extends StatefulWidget {
  const FirebaseLoginPage({super.key});

  @override
  State<FirebaseLoginPage> createState() => _FirebaseLoginPageState();
}

class _FirebaseLoginPageState extends State<FirebaseLoginPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isObscure = true;
  bool _isSignup = false;

  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _handleLogin(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final success = await authProvider.signIn(
      email: email,
      password: password,
    );

    if (mounted) {
      if (success) {
        Navigator.of(context).pushReplacementNamed('/');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Erreur de connexion'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleSignup(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    final success = await authProvider.signUp(
      email: email,
      password: password,
      displayName: name,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compte créé avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Erreur d\'inscription'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: FadeTransition(
            opacity: _fadeInAnimation,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      _buildHeader(colorScheme, textTheme),
                      const SizedBox(height: 48),
                      _buildForm(colorScheme),
                      const SizedBox(height: 32),
                      _buildSubmitButton(authProvider, colorScheme, textTheme),
                      const SizedBox(height: 16),
                      _buildToggleMode(colorScheme, textTheme),
                      const SizedBox(height: 40),
                    ],
                  );
                },
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
          _isSignup ? "Créer un compte" : "Connexion",
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isSignup
              ? "Créez votre compte pour continuer"
              : "Connectez-vous à votre compte",
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(ColorScheme colorScheme) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (_isSignup) ...[
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Nom complet",
                prefixIcon: const Icon(CupertinoIcons.person_fill),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surface,
              ),
              validator: (value) {
                if (_isSignup && (value == null || value.isEmpty)) {
                  return "Veuillez entrer votre nom";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: "Email",
              prefixIcon: const Icon(CupertinoIcons.mail_solid),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: colorScheme.surface,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Veuillez entrer votre email";
              }
              if (!value.contains('@')) {
                return "Veuillez entrer un email valide";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
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
              if (_isSignup && value.length < 6) {
                return "Le mot de passe doit avoir au moins 6 caractères";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(
      AuthProvider authProvider, ColorScheme colorScheme, TextTheme textTheme) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: authProvider.isLoading
          ? null
          : () {
              if (_isSignup) {
                _handleSignup(authProvider);
              } else {
                _handleLogin(authProvider);
              }
            },
      child: authProvider.isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          : Text(
              _isSignup ? "S'inscrire" : "Se connecter",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
    );
  }

  Widget _buildToggleMode(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isSignup = !_isSignup;
            _formKey.currentState?.reset();
          });
        },
        child: RichText(
          text: TextSpan(
            text: _isSignup ? "Vous avez un compte? " : "Pas de compte? ",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: textTheme.bodyMedium?.color,
            ),
            children: [
              TextSpan(
                text: _isSignup ? "Connectez-vous" : "S'inscrire",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
