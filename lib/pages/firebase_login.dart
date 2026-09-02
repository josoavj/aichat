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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? [const Color(0xFF1A1A1A), const Color(0xFF0F0F0F)]
              : [const Color(0xFFF8F9FA), const Color(0xFFE9ECEF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: FadeTransition(
              opacity: _fadeInAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 60),
                        _buildHeader(colorScheme, theme.textTheme, isDark),
                        const SizedBox(height: 50),
                        _buildForm(colorScheme, isDark),
                        const SizedBox(height: 40),
                        _buildSubmitButton(authProvider, colorScheme),
                        const SizedBox(height: 24),
                        _buildToggleMode(colorScheme, theme.textTheme),
                        const SizedBox(height: 40),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, TextTheme textTheme, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
          ),
          child: Icon(
            _isSignup ? CupertinoIcons.person_add_solid : CupertinoIcons.lock_shield_fill,
            size: 48,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          _isSignup ? "Créer un compte" : "Bienvenue !",
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _isSignup
              ? "Rejoignez l'aventure avec MyAI"
              : "Heureux de vous revoir parmi nous",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(ColorScheme colorScheme, bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (_isSignup) ...[
            _buildTextField(
              controller: _nameController,
              label: "Nom complet",
              icon: CupertinoIcons.person,
              colorScheme: colorScheme,
              isDark: isDark,
              validator: (value) {
                if (_isSignup && (value == null || value.isEmpty)) {
                  return "Entrez votre nom";
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
          ],
          _buildTextField(
            controller: _emailController,
            label: "Adresse Email",
            icon: CupertinoIcons.mail,
            colorScheme: colorScheme,
            isDark: isDark,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) return "Entrez votre email";
              if (!value.contains('@')) return "Email invalide";
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _passwordController,
            label: "Mot de passe",
            icon: CupertinoIcons.lock,
            colorScheme: colorScheme,
            isDark: isDark,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) return "Entrez votre mot de passe";
              if (_isSignup && value.length < 6) return "Minimum 6 caractères";
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ColorScheme colorScheme,
    required bool isDark,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && _isObscure,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isObscure ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                  size: 20,
                ),
                onPressed: () => setState(() => _isObscure = !_isObscure),
              )
            : null,
      ),
    );
  }

  Widget _buildSubmitButton(AuthProvider authProvider, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: authProvider.isLoading
            ? null
            : () => _isSignup ? _handleSignup(authProvider) : _handleLogin(authProvider),
        child: authProvider.isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
              )
            : Text(
                _isSignup ? 'Créer mon compte' : 'Se connecter',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
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
