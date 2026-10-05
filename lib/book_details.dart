import 'package:flutter/material.dart';

import 'data_model/book.dart';
import 'database_helper.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    // Initialize the text controller with existing notes (if any)
    _notesController = TextEditingController(text: widget.book.notes);
  }

  @override
  void dispose() {
    // Always dispose controllers to prevent memory leaks!
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title, overflow: TextOverflow.ellipsis),
        actions: [
          // Save button in the top right
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Notes',
            onPressed: () async {
              // 1. Create a new immutable book instance with the updated notes
              final updatedBook = widget.book.copyWith(
                notes: _notesController.text,
              );

              // 2. Save the change to the database
              await DatabaseHelper.instance.updateBook(updatedBook);

              // 3. Pop the screen and return 'true' to tell the previous screen we made changes
              if (mounted) {
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
            // Book Metadata
            Text(
              'By ${widget.book.authors.join(', ') ?? 'Unknown Author'}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              widget.book.isRead ? 'Status: Read' : 'Status: Reading Now',
              style: TextStyle(
                color: widget.book.isRead ? Colors.green : Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Divider(height: 32),

            // Notes Header
            const Text(
              'My Notes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Notes Text Field
            Expanded(
              child: TextField(
                controller: _notesController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'Write your thoughts, favorite quotes, or summaries here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
