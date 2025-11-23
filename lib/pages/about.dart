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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[50], // Fond gris très clair
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: Colors.black87), // Icône sombre
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Informations",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87, // Titre sombre
          ),
        ),
        backgroundColor: Colors.grey[50], // Fond d'AppBar gris très clair
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section principale "À propos"
            _buildInfoCard(
              title: "AI ChatBot Application",
              description: "Ceci est une application de ChatBot IA simple développée avec Flutter et Dart. Son objectif est de fournir une interface de conversation fluide et élégante avec une IA.",
              colorScheme: colorScheme,
              child: const SizedBox(height: 0),
            ),
            const SizedBox(height: 24),

            // Section du développeur et du dépôt
            _buildInfoCard(
              title: "Développeur & Dépôt",
              colorScheme: colorScheme,
              child: Column(
                children: [
                  _buildLinkTile(
                    icon: CupertinoIcons.person_fill,
                    label: "Développé par",
                    text: "josoavj",
                    url: "https://github.com/josoavj",
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 12),
                  _buildLinkTile(
                    icon: CupertinoIcons.link,
                    label: "Dépôt GitHub",
                    text: "AI CHAT (TEST)",
                    url: "https://github.com/josoavj/aichat",
                    colorScheme: colorScheme,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bouton pour les informations avancées
            _buildAdvancedInfoButton(context, colorScheme),
          ],
        ),
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
