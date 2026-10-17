import 'package:flutter/material.dart';

import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'dart:convert';

import 'package:share_plus/share_plus.dart';

import 'navigation_bar.dart';
import '../database_helper.dart';
import '/data_model/book.dart';

import 'package:google_fonts/google_fonts.dart';

class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({super.key});

  @override
  ExportDataScreenState createState() => ExportDataScreenState();
}

class ExportDataScreenState extends State<ExportDataScreen> {
  void _startDownload() async {
    try {
      List<Book> books = await DatabaseHelper.instance.getAllBooks();
      Map<String, dynamic> exportData = {
        'app_name': 'bookworm',
        'export_date': DateTime.now().toIso8601String(),
        'books': books.map((book) => book.toJson()).toList(),
      };
      String jsonString = jsonEncode(exportData);

      final tempDir = await getTemporaryDirectory();
      final path = tempDir.path;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'bookworm_export_$timestamp.json';

      final file = File('$path/$fileName');
      await file.writeAsString(jsonString);

      if (mounted) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            subject: 'Bookworm Data Export',
            text: 'Here is my Bookworm library export.',
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Export ready!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error exporting data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export data: $e'),
            backgroundColor: Colors.red,
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Wrapped the CircleAvatar in an InkWell to make it act like a button
            InkWell(
              onTap: _startDownload, // Calls the dummy function when tapped
              borderRadius: BorderRadius.circular(
                50,
              ), // Matches the avatar size for a circular ripple
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(
                  Icons.download,
                  size: 50,
                  color: Colors.orange,
                ),
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
            Text('Download JSON', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 24),
            Text(
              "You can export your data by clicking the button above.",
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
