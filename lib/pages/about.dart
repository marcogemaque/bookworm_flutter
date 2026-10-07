import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//importing the standard navigation bar
import 'navigation_bar.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      selectedIndex: 1,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
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
              "While I love reading, I wanted a single place to hold all the notes I take for what I read. Now you can too.\n\n No AI.",
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
