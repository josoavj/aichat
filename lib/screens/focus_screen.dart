import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/focus_provider.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<FocusProvider>(
      builder: (context, focusProvider, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Focus Mode',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: focusProvider.isActive ? theme.primaryColor : Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: CircularProgressIndicator(
                      value: focusProvider.secondsRemaining / (25 * 60),
                      strokeWidth: 8,
                      backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                      color: theme.primaryColor,
                    ),
                  ),
                  Text(
                    focusProvider.timerString,
                    style: GoogleFonts.firaCode(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!focusProvider.isActive)
                    ElevatedButton.icon(
                      onPressed: () => focusProvider.startTimer(),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Commencer'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () => focusProvider.stopTimer(),
                      icon: const Icon(Icons.pause_rounded),
                      label: const Text('Pause'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                    ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () => focusProvider.resetTimer(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Reset'),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                'Cycles terminés : ${focusProvider.completedCycles}',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }
}
