import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/journal_provider.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<JournalProvider>(
      builder: (context, journalProvider, child) {
        if (journalProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (journalProvider.entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_stories_outlined, size: 64, color: theme.primaryColor.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text('Votre journal est vide', style: GoogleFonts.poppins(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: journalProvider.entries.length,
          itemBuilder: (context, index) {
            final entry = journalProvider.entries[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('dd MMMM yyyy, HH:mm', 'fr_FR').format(entry.createdAt),
                          style: GoogleFonts.poppins(fontSize: 12, color: theme.primaryColor, fontWeight: FontWeight.w500),
                        ),
                        if (entry.mood != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(entry.mood!, style: const TextStyle(fontSize: 10)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      entry.content,
                      style: GoogleFonts.poppins(fontSize: 14, height: 1.6),
                    ),
                    if (entry.tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: entry.tags.map((tag) => Chip(
                          label: Text(tag, style: const TextStyle(fontSize: 10)),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
