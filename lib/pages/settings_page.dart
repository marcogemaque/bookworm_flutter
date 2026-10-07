import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: Text.rich(
          TextSpan(
            text: 'Book',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            children: [
              TextSpan(
                text: 'worm',
                style: GoogleFonts.playfairDisplay(
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              child: const Text('Menu', style: TextStyle(fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.question_mark),
              title: const Text('About'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Bug Report'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
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

            // App Title
            Text(
              'Bookworm',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('Version 1.0.0', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 24),

            // Mission Statement
            Text(
              'All I wanted was to keep notes about the books I was reading. And now you can too.',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),

            // Action Links
            Card(
              color: Colors.white.withValues(alpha: 0.8),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.code),
                    title: const Text('View Source Code'),
                    onTap: () {
                      /* Link to GitHub */
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.gavel),
                    title: const Text('Open Source Licenses'),
                    onTap: () => showLicensePage(context: context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
