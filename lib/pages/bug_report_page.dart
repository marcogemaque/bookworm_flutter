import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'navigation_bar.dart';

class BugReportPage extends StatefulWidget {
  const BugReportPage({super.key});

  @override
  State<BugReportPage> createState() => _BugReportPageState();
}

class _BugReportPageState extends State<BugReportPage> {
  // Put this inside your _BugReportPageState class
  Future<void> _sendBugReport() async {
    const String yourEmail = 'imediogre@gmail.com';

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: yourEmail,
      queryParameters: {
        'subject': 'Bookworm Bug Report',
        'body':
            'Hi Developer,\n\nI found a bug in the app!\n\n'
            'Device: [Your Phone Model]\n'
            'App Version: [Version]\n\n'
            'Steps to reproduce:\n1. \n2. \n3. \n\n'
            'Expected behavior:\n\n'
            'Actual behavior:\n',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open email app. Please email imediogre@gmail.com directly.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      selectedIndex: 1,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // App Logo/Icon Placeholder
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: const Icon(
                Icons.menu_book_rounded,
                size: 50,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Bookworm',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Version 0.0.1b',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            Text(
              "Found a bug?",
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: Card(
                color: Colors.white.withValues(alpha: 0.8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: _sendBugReport,
                      icon: const Icon(Icons.email),
                      label: const Text('Send Bug Report via Email'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
