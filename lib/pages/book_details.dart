import 'package:flutter/material.dart';

import '/data_model/book.dart';
import '/database_helper.dart';

// ==========================================
// 1. THE MAIN DETAIL SCREEN
// ==========================================
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
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: Text(
          widget.book.title,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.grey.shade100, // Blends with background
        foregroundColor: Colors.black87,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          // SAVE NOTES BUTTON
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Notes',
            onPressed: () async {
              final updatedBook = widget.book.copyWith(
                notes: _notesController.text.trim().isNotEmpty
                    ? _notesController.text.trim()
                    : null,
              );
              await DatabaseHelper.instance.updateBook(updatedBook);
              if (mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
          // EDIT BOOK DETAILS BUTTON
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Book Details',
            onPressed: () async {
              final didChange = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => _EditBookDialog(book: widget.book),
              );

              if (didChange == true && mounted) {
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
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
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

            const Text(
              'My Notes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: TextField(
                controller: _notesController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'I bet you found lots to remember about this book!',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white, // Pops against the gray background
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
class _EditBookDialog extends StatefulWidget {
  final Book book;
  const _EditBookDialog({required this.book});

  @override
  State<_EditBookDialog> createState() => _EditBookDialogState();
}

class _EditBookDialogState extends State<_EditBookDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _genreController;
  late final TextEditingController _notesController;

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  late bool _isRead;

  @override
  void initState() {
    super.initState();
    // Pre-fill with the existing book's data
    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(
      text: widget.book.authors.join(', '),
    );
    _genreController = TextEditingController(
      text: widget.book.genre?.join(', ') ?? '',
    );
    _notesController = TextEditingController(text: widget.book.notes ?? '');
    _selectedStartDate = widget.book.dateStarted;
    _selectedEndDate = widget.book.dateFinished;
    _isRead = widget.book.isRead;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _genreController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  List<String> _parseCommaSeparatedList(String text) {
    return text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Future<void> _pickDate(bool isStart) async {
    final DateTime initialDate = isStart
        ? (_selectedStartDate ?? DateTime.now())
        : (_selectedEndDate ?? DateTime.now());

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      helpText: isStart ? 'Update start date' : 'Update finish date',
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _selectedStartDate = picked;
          if (_selectedEndDate != null && _selectedEndDate!.isBefore(picked)) {
            _selectedEndDate = null;
          }
        } else {
          _selectedEndDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _saveChanges() async {
    if (_titleController.text.trim().isEmpty ||
        _authorController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and Author are required')),
      );
      return;
    }

    final updatedBook = widget.book.copyWith(
      title: _titleController.text.trim(),
      authors: _parseCommaSeparatedList(_authorController.text),
      genre: _parseCommaSeparatedList(_genreController.text),
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      dateStarted: _selectedStartDate,
      dateFinished: _selectedEndDate,
      isRead: _isRead,
    );

    await DatabaseHelper.instance.updateBook(updatedBook);

    if (mounted) {
      Navigator.of(context)
          .pop(true); // Tells the detail screen to close and refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Book Details'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Authors (comma-separated)',
                hintText: 'e.g. Neil Gaiman, Terry Pratchett',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _genreController,
              decoration: const InputDecoration(
                labelText: 'Genres (comma-separated)',
              ),
            ),
            const SizedBox(height: 10),

            // Date Started
            InkWell(
              onTap: () => _pickDate(true),
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date Started',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedStartDate != null
                          ? _formatDate(_selectedStartDate!)
                          : 'Tap to select',
                      style: TextStyle(
                        color: _selectedStartDate != null
                            ? Colors.black87
                            : Colors.grey,
                      ),
                    ),
                    if (_selectedStartDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () =>
                            setState(() => _selectedStartDate = null),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Date Finished
            InkWell(
              onTap: () => _pickDate(false),
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date Finished',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedEndDate != null
                          ? _formatDate(_selectedEndDate!)
                          : 'Tap to select',
                      style: TextStyle(
                        color: _selectedEndDate != null
                            ? Colors.black87
                            : Colors.grey,
                      ),
                    ),
                    if (_selectedEndDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () =>
                            setState(() => _selectedEndDate = null),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Read Status Toggle
            Row(
              children: [
                const Text(
                  'Mark as Read',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Switch(
                  value: _isRead,
                  activeThumbColor: Colors.green,
                  onChanged: (value) => setState(() => _isRead = value),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveChanges,
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}
