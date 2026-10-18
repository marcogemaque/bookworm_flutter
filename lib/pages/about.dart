import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//importing the standard navigation bar
import 'navigation_bar.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  //for our section. A small widget
  Widget _buildFutureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ", style: GoogleFonts.lato(fontSize: 16, height: 1.5)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.lato(fontSize: 16, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

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
              'Version 1.0.0+1',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            Text(
              "We don't collect any data. Just an offline note taking and book tracker.",
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),

            Card(
              elevation: 2, // Adds a subtle shadow
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
              ), // Keeps it away from screen edges
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  12,
                ), // Makes the corners nicely rounded
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0), // Padding inside the card
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment
                      .start, // Left-aligns the text inside the card
                  children: [
                    // The Title
                    Text(
                      "Future improvements for next version:",
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold, // Make the title pop a bit more
                      ),
                    ),

                    const SizedBox(height: 12),

                    // The List
                    _buildFutureItem("Multiple book covers."),
                    _buildFutureItem("Multiple file-extension export."),
                    _buildFutureItem("CSV/JSON import."),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
