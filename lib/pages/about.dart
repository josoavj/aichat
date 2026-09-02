import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.info_outline_rounded, size: 60, color: theme.primaryColor),
            ),
            const SizedBox(height: 24),
            Text(
              'MyAI Assistant',
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Version 1.0.0',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            _buildInfoCard(
              title: "L'application",
              description: 'Une interface de conversation intelligente propulsée par l\'IA de Google, conçue pour être simple, rapide et élégante.',
              theme: theme,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Développeur',
              theme: theme,
              child: Column(
                children: [
                  _buildLinkTile(
                    icon: CupertinoIcons.person,
                    label: 'Auteur',
                    text: 'josoavj',
                    url: 'https://github.com/josoavj',
                    theme: theme,
                  ),
                  const Divider(height: 24, indent: 40),
                  _buildLinkTile(
                    icon: CupertinoIcons.link,
                    label: 'Code Source',
                    text: 'GitHub Repository',
                    url: 'https://github.com/josoavj/aichat',
                    theme: theme,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              '© 2024 Josoa Vonjiniaina',
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
              color: theme.primaryColor.withValues(alpha: 0.1),
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
}
