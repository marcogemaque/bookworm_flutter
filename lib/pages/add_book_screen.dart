import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import '../data_model/book.dart';

class AddBookDialog extends StatefulWidget {
  const AddBookDialog({super.key});

  @override
  State<AddBookDialog> createState() => AddBookDialogState();
}

class AddBookDialogState extends State<AddBookDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  int _rating = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _genreController.dispose();
    super.dispose();
  }

  List<String> _parseCommaSeparatedList(String text) {
    return text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Future<String?> fetchBookCoverUrl(String title, String author) async {
    try {
      final query = author.isNotEmpty ? '$title $author' : title;
      final encodedQuery = Uri.encodeComponent(query);
      final url = Uri.parse(
        'https://openlibrary.org/search.json?q=$encodedQuery&limit=1',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final docs = data['docs'] as List;

        if (docs.isNotEmpty) {
          final coverId = docs[0]['cover_i'];
          if (coverId != null) {
            return 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching cover: $e');
    }
    return null;
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
      helpText: isStart
          ? 'When did you start this book?'
          : 'When did you finish this book?',
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

  Future<void> _saveBook() async {
    if (_titleController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // Fetch the cover URL
      final String? coverUrl = await fetchBookCoverUrl(
        _titleController.text,
        _authorController.text,
      );

      final List<String> authors = _parseCommaSeparatedList(
        _authorController.text,
      );

      final newBook = Book(
        title: _titleController.text,
        authors: authors.isEmpty ? null : authors,
        genre: _parseCommaSeparatedList(_genreController.text),
        dateStarted: _selectedStartDate,
        dateFinished: _selectedEndDate,
        rating: _rating == 0 ? null : _rating,
        coverUrl: coverUrl,
      );
      if (mounted) {
        Navigator.of(context).pop(newBook);
      }
    } catch (e) {
      debugPrint('Error saving book: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save book. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add a New Book'),
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
                labelText: 'Author 1, Author 2',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _genreController,
              decoration: const InputDecoration(labelText: 'Sci-Fi, Horror'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Rating',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: const Color.fromARGB(255, 180, 138, 39),
                    size: 36,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = (index + 1 == _rating) ? 0 : index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 10),
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          // Disable button and call _saveBook when loading
          onPressed: _isLoading ? null : _saveBook,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
