import 'package:flutter/material.dart';

import '/data_model/book.dart';
import '/database_helper.dart';
import '/pages/edit_book_screen.dart';

import 'package:google_fonts/google_fonts.dart';

// ==========================================
// 1. THE MAIN DETAIL SCREEN
// ==========================================
class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  BookDetailScreenState createState() => BookDetailScreenState();
}

class BookDetailScreenState extends State<BookDetailScreen> {
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.book.notes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Nice soft background color
      backgroundColor: Colors.orange.shade100,

      appBar: AppBar(
        title: Text(
          widget.book.title,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color(0xFFFDB975),
        foregroundColor: Colors.black87,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          // DELETE BOOK BUTTON
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black),
            tooltip: 'Delete Book',
            onPressed: () async {
              // 1. Show the confirmation dialog
              final bool? confirmDelete = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Delete Book'),
                    content: const Text(
                      'Are you sure you want to delete this book? This action cannot be undone.',
                    ),
                    actions: <Widget>[
                      // Cancel button
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      // Confirm delete button
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
              // 2. Proceed only if the user explicitly tapped "Delete" (returns true)
              if (confirmDelete == true) {
                final updatedBook = widget.book.copyWith(
                  notes: _notesController.text.trim().isNotEmpty
                      ? _notesController.text.trim()
                      : null,
                );
                await DatabaseHelper.instance.deleteBook(updatedBook);
                if (context.mounted) {
                  Navigator.pop(context, true);
                }
              }
            },
          ),
          // SAVE NOTES BUTTON
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            tooltip: 'Save Notes',
            onPressed: () async {
              final updatedBook = widget.book.copyWith(
                notes: _notesController.text.trim().isNotEmpty
                    ? _notesController.text.trim()
                    : null,
              );
              await DatabaseHelper.instance.updateBook(updatedBook);
              if (context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
          // EDIT BOOK DETAILS BUTTON
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            tooltip: 'Edit Book Details',
            onPressed: () async {
              final didChange = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => EditBookDialog(book: widget.book),
              );
              if (didChange == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'By ${widget.book.authors.join(', ')}',
              style: GoogleFonts.playfairDisplay(
                // Replace 'poppins' with your chosen font
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.book.isRead ? 'Status: Read' : 'Status: Reading Now',
              style: TextStyle(
                color: widget.book.isRead ? Colors.green : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Divider(height: 32),
            Text(
              // 'const' is removed
              'My Notes',
              style: GoogleFonts.playfairDisplay(
                // Replace 'poppins' with your chosen font
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _notesController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText:
                      'To persist your notes, click on the save button above!',
                  hintStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.orange.shade50,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
