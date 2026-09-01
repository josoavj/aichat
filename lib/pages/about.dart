import 'package:flutter/cupertino.dart';
// Import pour TapGestureRecognizer
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart'; // Utilisation directe de url_launcher

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  // Fonction pour lancer les URLs
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("À propos"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.info_outline_rounded, size: 60, color: theme.primaryColor),
            ),
            const SizedBox(height: 24),
            Text(
              "MyAI Assistant",
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              "Version 1.0.0",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            _buildInfoCard(
              title: "L'application",
              description: "Une interface de conversation intelligente propulsée par l'IA de Google, conçue pour être simple, rapide et élégante.",
              theme: theme,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: "Développeur",
              theme: theme,
              child: Column(
                children: [
                  _buildLinkTile(
                    icon: CupertinoIcons.person,
                    label: "Auteur",
                    text: "josoavj",
                    url: "https://github.com/josoavj",
                    theme: theme,
                  ),
                  const Divider(height: 24, indent: 40),
                  _buildLinkTile(
                    icon: CupertinoIcons.link,
                    label: "Code Source",
                    text: "GitHub Repository",
                    url: "https://github.com/josoavj/aichat",
                    theme: theme,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              "© 2024 Josoa Vonjiniaina",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required ThemeData theme,
    String? description,
    Widget? child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 12),
              Text(
                description,
                style: GoogleFonts.poppins(fontSize: 14, height: 1.5),
              ),
            ],
            if (child != null) ...[
              const SizedBox(height: 16),
              child,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLinkTile({
    required IconData icon,
    required String label,
    required String text,
    required String url,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: () => _launchUrl(url),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: theme.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(text, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Icon(CupertinoIcons.chevron_right, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required ColorScheme colorScheme,
    String? description,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87, // Texte sombre pour le contraste
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 12),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black54, // Texte légèrement plus clair
              ),
            ),
          ],
          if (child != const SizedBox(height: 0)) ...[
            const SizedBox(height: 20),
            child,
          ],
        ],
      ),
    );
  }

  Widget _buildLinkTile({
    required IconData icon,
    required String label,
    required String text,
    required String url,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: () => _launchUrl(url),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[200], // Fond gris clair pour l'icône
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Icon(CupertinoIcons.chevron_forward, color: Colors.black87, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedInfoButton(BuildContext context, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            showAboutDialog(
              context: context,
              applicationLegalese: "© 2024 Josoa Vonjiniaina",
              applicationName: "AI ChatBot",
              applicationVersion: "1.0.0",
              applicationIcon: const FlutterLogo(size: 30),
              children: [
                const SizedBox(height: 15),
                Text(
                  "Ceci est une application de ChatBot IA simple développée par Josoa Vonjiniaina.",
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  "Cette application est open source et peut être trouvée sur GitHub.",
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  "Elle est développée avec Flutter et Dart.",
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
                ),
              ],
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: colorScheme.onPrimary, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      "Informations Avancées",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Icon(CupertinoIcons.right_chevron, color: colorScheme.onPrimary, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
