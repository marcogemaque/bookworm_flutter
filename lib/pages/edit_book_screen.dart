import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import '/data_model/book.dart';
import '/database_helper.dart';

class EditBookDialog extends StatefulWidget {
  final Book book;
  const EditBookDialog({super.key, required this.book});

  @override
  State<EditBookDialog> createState() => EditBookDialogState();
}

class EditBookDialogState extends State<EditBookDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _genreController;
  late final TextEditingController _notesController;

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  late bool _isRead;
  late int _rating;

  // Add loading state for when we fetch a new cover
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(
      text: widget.book.authors?.join(', '),
    );
    _genreController = TextEditingController(
      text: widget.book.genre.join(', '),
    );
    _notesController = TextEditingController(text: widget.book.notes ?? '');
    _selectedStartDate = widget.book.dateStarted;
    _selectedEndDate = widget.book.dateFinished;
    _isRead = widget.book.isRead;
    _rating = widget.book.rating ?? 0;
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

  Set<String> _words(String text) {
    const stop = {'a', 'an', 'the', 'of', 'and', 'in', 'on', 'to', 'for'};
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty && !stop.contains(w))
        .toSet();
  }

  double _score(String input, String candidate) {
    final a = _words(input);
    final b = _words(candidate);
    if (a.isEmpty || b.isEmpty) return 0;

    // Perfect match if one set contains all words from the other
    if (a.containsAll(b) || b.containsAll(a)) return 1.0;

    // Otherwise, what fraction of the user's input is in the candidate?
    return a.intersection(b).length / a.length;
  }

  Future<String?> fetchBookCoverUrl(String title, String? author) async {
    try {
      final uri = Uri.https('openlibrary.org', '/search.json', {
        'title': title,
        if (author != null && author.isNotEmpty) 'author': author,
        'limit': '5',
      });

      final response = await http.get(uri);
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final docs = data['docs'] as List;

      String? bestCoverUrl;
      double highestScore = 0.0;

      for (var doc in docs) {
        final coverId = doc['cover_i'];
        if (coverId == null) continue;

        final apiTitle = doc['title'] as String? ?? '';
        final score = _score(title, apiTitle);

        if (score > highestScore) {
          highestScore = score;
          bestCoverUrl = 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';
        }
      }

      if (highestScore >= 0.8) {
        return bestCoverUrl;
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
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Title is required')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newTitle = _titleController.text.trim();
      final newAuthors = _parseCommaSeparatedList(_authorController.text);
      final newAuthorString = newAuthors.join(', ');
      final oldAuthorString = widget.book.authors?.join(', ') ?? '';

      String? finalCoverUrl = widget.book.coverUrl;

      // If Title or Author changed, fetch a new cover URL
      if (newTitle != widget.book.title || newAuthorString != oldAuthorString) {
        finalCoverUrl = await fetchBookCoverUrl(newTitle, newAuthorString);
      }

      final updatedBook = Book(
        id: widget.book.id,
        title: newTitle,
        authors: newAuthors.isEmpty ? null : newAuthors,
        genre: _parseCommaSeparatedList(_genreController.text),
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        dateStarted: _selectedStartDate,
        dateFinished: _selectedEndDate,
        isRead: _isRead,
        rating: _rating == 0 ? null : _rating,
        coverUrl: finalCoverUrl,
        addedOnDate: widget.book.addedOnDate,
      );

      await DatabaseHelper.instance.updateBook(updatedBook);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      debugPrint('Error saving book: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save changes.')),
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
      backgroundColor: const Color.fromARGB(255, 226, 211, 176),
      surfaceTintColor: Colors.transparent,
      title: const Text('Edit Book Details'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _authorController,
              textCapitalization: TextCapitalization.words,
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
            const SizedBox(height: 16),
            const Text(
              'Rating',
              style: TextStyle(fontSize: 14, color: Colors.black87),
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
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Mark as Read',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
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
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel', style: TextStyle(color: Colors.black87)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveChanges,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Save Changes'),
        ),
      ],
    );
  }
}
