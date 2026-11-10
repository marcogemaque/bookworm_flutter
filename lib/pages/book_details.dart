import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/data_model/book.dart';
import '/database_helper.dart';
import '/pages/edit_book_screen.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;
  const BookDetailScreen({super.key, required this.book});

  @override
  BookDetailScreenState createState() => BookDetailScreenState();
}

class BookDetailScreenState extends State<BookDetailScreen> {
  late TextEditingController _notesController;

  List<VocabularyEntry> _vocabList = [];
  bool _isLoadingVocab = true;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.book.notes ?? '');
    _loadVocabulary();
  }

  Future<void> _loadVocabulary() async {
    if (widget.book.id == null) return;
    final entries = await DatabaseHelper.instance.getVocabularyByBook(
      widget.book.id!,
    );
    if (mounted) {
      setState(() {
        _vocabList = entries;
        _isLoadingVocab = false;
      });
    }
  }

  Future<void> _showEditVocabularyDialog(VocabularyEntry entry) async {
    if (entry.id == null) return;

    final wordController = TextEditingController(text: entry.word);
    final defController = TextEditingController(text: entry.definition ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Edit Vocabulary',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: wordController,
              decoration: InputDecoration(
                labelText: 'Word',
                hintText: 'e.g., Ephemeral',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: defController,
              decoration: InputDecoration(
                labelText: 'Definition (Optional)',
                hintText: 'e.g., Lasting for a very short time',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved == true && wordController.text.trim().isNotEmpty) {
      final updatedEntry = VocabularyEntry(
        id: entry.id,
        word: wordController.text.trim(),
        definition: defController.text.trim().isNotEmpty
            ? defController.text.trim()
            : null,
        bookId: entry.bookId,
      );

      await DatabaseHelper.instance.updateVocabulary(updatedEntry);

      if (mounted) {
        setState(() {
          final index = _vocabList.indexWhere((e) => e.id == entry.id);
          if (index != -1) {
            _vocabList[index] = updatedEntry;
          }
        });
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      wordController.dispose();
      defController.dispose();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _showAddVocabularyDialog() async {
    final wordController = TextEditingController();
    final defController = TextEditingController();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Add Vocabulary',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: wordController,
              decoration: InputDecoration(
                labelText: 'Word',
                hintText: 'e.g., Ephemeral',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: defController,
              decoration: InputDecoration(
                labelText: 'Definition (Optional)',
                hintText: 'e.g., Lasting for a very short time',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved == true &&
        wordController.text.trim().isNotEmpty &&
        widget.book.id != null) {
      final tempEntry = VocabularyEntry(
        word: wordController.text.trim(),
        definition: defController.text.trim().isNotEmpty
            ? defController.text.trim()
            : null,
        bookId: widget.book.id,
      );

      final newId = await DatabaseHelper.instance.insertVocabulary(tempEntry);

      if (mounted) {
        setState(() {
          final newEntry = VocabularyEntry(
            id: newId,
            word: tempEntry.word,
            definition: tempEntry.definition,
            bookId: tempEntry.bookId,
          );
          _vocabList.add(newEntry);
        });
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      wordController.dispose();
      defController.dispose();
    });
  }

  Widget _buildVocabularyItem(VocabularyEntry entry) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _showEditVocabularyDialog(entry),
                child: Padding(
                  padding: const EdgeInsets.all(
                    4.0,
                  ), // Gives a better tap hit area
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Word on top - bold and prominent
                      Text(
                        entry.word,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Definition below - lighter and readable
                      Text(
                        entry.definition?.isNotEmpty == true
                            ? entry.definition!
                            : 'No definition added',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Subtle hint that the card is editable
                      Text(
                        'Tap to edit',
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Delete button aligned to top-right
            IconButton(
              icon: const Icon(Icons.close, size: 20, color: Colors.grey),
              tooltip: 'Remove word',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () async {
                if (entry.id != null) {
                  await DatabaseHelper.instance.deleteVocabulary(entry.id!);
                  if (mounted) {
                    setState(() {
                      _vocabList.removeWhere((e) => e.id == entry.id);
                    });
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVocabularySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Vocabulary',
              style: GoogleFonts.playfairDisplay(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.orange),
              tooltip: 'Add Word',
              onPressed: _showAddVocabularyDialog,
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (_isLoadingVocab)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_vocabList.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'If you learned new words, tap + to add them!',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade700,
              ),
            ),
          )
        else
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 12.0,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _vocabList.length,
              itemBuilder: (context, index) =>
                  _buildVocabularyItem(_vocabList[index]),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade100,
      appBar: AppBar(
        title: Text(
          widget.book.title,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFFDB975),
        foregroundColor: Colors.black87,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black),
            tooltip: 'Delete Book',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Delete Book'),
                  content: const Text('Are you sure? This cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await DatabaseHelper.instance.deleteBook(
                  widget.book.copyWith(
                    notes: _notesController.text.trim().isNotEmpty
                        ? _notesController.text.trim()
                        : null,
                  ),
                );
                if (context.mounted) Navigator.pop(context, true);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            tooltip: 'Save Notes',
            onPressed: () async {
              await DatabaseHelper.instance.updateBook(
                widget.book.copyWith(
                  notes: _notesController.text.trim().isNotEmpty
                      ? _notesController.text.trim()
                      : null,
                ),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Notes saved!')));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            tooltip: 'Edit Book Details',
            onPressed: () async {
              final changed = await showDialog<bool>(
                context: context,
                builder: (c) => EditBookDialog(book: widget.book),
              );
              if (changed == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'By ${widget.book.authors?.join(', ') ?? 'Unknown'}',
              style: GoogleFonts.playfairDisplay(
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
            _buildVocabularySection(),
            Text(
              'My Notes',
              style: GoogleFonts.playfairDisplay(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 300,
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: TextField(
                controller: _notesController,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText:
                      'To persist your notes, click on the save button above!',
                  hintStyle: TextStyle(color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.orange.shade50,
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
