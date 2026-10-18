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

  Future<String?> fetchBookCoverUrl(String title, String author) async {
    try {
      final query = author.isNotEmpty ? '$title $author' : title;
      final url = Uri.parse(
        'https://openlibrary.org/search.json?q=${Uri.encodeComponent(query)}&limit=2',
      );

      final response = await http.get(url);
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final docs = data['docs'] as List;

      String? bestCoverUrl;
      double highestScore = 0.0;

      for (var doc in docs) {
        final coverId = doc['cover_i'];
        if (coverId == null) continue;

        double score = _calculateMatchScore(title, author, doc);

        if (score > highestScore) {
          highestScore = score;
          bestCoverUrl = 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';
        }
      }

      if (highestScore >= 0.70) {
        return bestCoverUrl;
      }
    } catch (e) {
      debugPrint('Error fetching cover: $e');
    }

    return null;
  }

  // Helper function to calculate the match percentage
  double _calculateMatchScore(
    String inputTitle,
    String inputAuthor,
    Map<String, dynamic> doc,
  ) {
    final returnedTitle = (doc['title'] as String? ?? '').toLowerCase();
    final returnedAuthors = (doc['author_name'] as List? ?? [])
        .map((a) => a.toString().toLowerCase())
        .join(' ');

    final cleanInputTitle = inputTitle.toLowerCase().trim();
    final cleanInputAuthor = inputAuthor.toLowerCase().trim();

    // Basic scoring logic (You can make this more complex)
    double titleScore = 0.0;
    double authorScore = 0.0;

    // Title scoring
    if (returnedTitle == cleanInputTitle) {
      titleScore = 1.0; // Exact match
    } else if (returnedTitle.contains(cleanInputTitle) ||
        cleanInputTitle.contains(returnedTitle)) {
      titleScore = 0.8; // Partial match
    }

    // Author scoring (if provided)
    if (cleanInputAuthor.isNotEmpty) {
      if (returnedAuthors.contains(cleanInputAuthor)) {
        authorScore = 1.0;
      } else {
        authorScore = 0.0;
      }
    } else {
      authorScore =
          1.0; // If user didn't type an author, don't penalize the score
    }

    return (titleScore * 0.9) + (authorScore * 0.1);
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
                  activeColor: Colors.green,
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
