import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Importing the standard navigation bar
import 'navigation_bar.dart';

import 'package:bookworm/database_helper.dart';
import 'package:bookworm/data_model/book.dart';

class VocabularyPage extends StatelessWidget {
  const VocabularyPage({super.key});

  Widget _buildVocabularyItem(String word, String? definition) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            word,
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.left, // Explicitly force left alignment
          ),
          const SizedBox(height: 4),
          Text(
            definition?.isNotEmpty == true
                ? definition!
                : "No meaning provided",
            style: GoogleFonts.lato(
              fontSize: 16,
              height: 1.5,
              color: Colors.black87,
            ),
            textAlign: TextAlign.left, // Explicitly force left alignment
          ),
          // Added a subtle divider between words for better readability
          const Divider(height: 32, color: Colors.black12),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      selectedIndex: 1, // Your navbar index
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          // ✅ CRITICAL FIX: Changed from .center to .stretch
          // This forces the Card to be full-width, preventing short words
          // from making the card narrow and appear "centered" on the screen.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),

            // ✅ The Vocabulary List Card
            Card(
              elevation: 2,
              // Removed horizontal margin so it stretches perfectly within the 24.0 padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "My Vocabulary",
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24),

                    // Fetch and display the vocabulary
                    FutureBuilder<List<VocabularyEntry>>(
                      future: DatabaseHelper.instance.getAllVocabularyEntries(),
                      builder: (context, snapshot) {
                        // Loading State
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        // Error State
                        if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              "Error loading vocabulary.",
                              style: GoogleFonts.lato(color: Colors.red),
                            ),
                          );
                        }

                        final entries = snapshot.data ?? [];

                        // Empty State
                        if (entries.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              "No vocabulary added yet.",
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[600],
                              ),
                            ),
                          );
                        }

                        // List of Entries
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Ensure list is left-aligned
                          children: entries.map((entry) {
                            return _buildVocabularyItem(
                              entry.word,
                              entry.definition,
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
