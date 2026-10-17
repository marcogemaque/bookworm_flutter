import 'package:flutter/material.dart';

import 'navigation_bar.dart'; // Assuming this is your AppScaffold
import '../data_model/book.dart';
import '../database_helper.dart';

import 'dart:math';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  List<Book> _books = [];
  int? _selectedYear;
  int intValue = 0;

  List<String> funnySentences = [
    "Lord Read-a-Lot over here!",
    "Officer, they're reading too much!",
    "SuperReader legend!",
    "It ain't easy reading this much.",
    "Seomeong's got super eyes!",
    "Man, you're good at reading!",
    "Book-a-licious",
  ];

  @override
  void initState() {
    super.initState();
    _loadBooks();
    intValue = Random().nextInt(funnySentences.length);
  }

  Future<void> _loadBooks() async {
    final books = await DatabaseHelper.instance.getBooks();
    if (mounted) {
      setState(() {
        _books = books;
        final years = _getAvailableYears().whereType<int>().toList();
        _selectedYear = years.isNotEmpty ? years.first : null;
      });
    }
  }

  // Helper to get only read books
  List<Book> _getReadBooks() {
    return _books.where((book) => book.isRead).toList();
  }

  // Helper to get only read books THIS calendar year
  List<Book> _getReadBooksThisYear() {
    final currentYear = DateTime.now().year;

    return _books.where((book) {
      return book.isRead &&
          book.dateFinished != null &&
          book.dateFinished!.year == currentYear;
    }).toList();
  }

  // Helper to format the reading duration strictly in days
  String _formatReadingDuration(DateTime start, DateTime end) {
    final days = end.difference(start).inDays;

    // Handle same-day finishes or negative values gracefully
    if (days <= 0) return "1 day";

    // Handle proper pluralization
    return days == 1 ? "1 day" : "$days days";
  }

  // Helper to get filtered books based on selected year
  List<Book> _getFilteredBooks() {
    final readBooks = _getReadBooks();
    if (_selectedYear == null) return readBooks;

    return readBooks
        .where((book) => book.dateFinished?.year == _selectedYear)
        .toList();
  }

  // Helper to get unique years for the dropdown (derived from loaded books)
  List<int?> _getAvailableYears() {
    final readBooks = _getReadBooks();
    final years =
        readBooks
            .where((book) => book.dateFinished != null)
            .map((book) => book.dateFinished!.year)
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    return [null, ...years];
  }

  @override
  Widget build(BuildContext context) {
    final filteredBooks = _getFilteredBooks();
    final availableYears = _getAvailableYears();

    return AppScaffold(
      selectedIndex: 1,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Dashboard Header
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // 2. Stats Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      "${_getReadBooksThisYear().length}", // Total read books overall
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                        height: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "books read this year.\n${funnySentences[intValue]}",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 3. Reading History Header & Year Filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reading History',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                // Year Dropdown Filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: _selectedYear,
                      isDense: true,
                      icon: const Icon(
                        Icons.filter_list,
                        size: 20,
                        color: Colors.grey,
                      ),
                      items: availableYears.map((int? year) {
                        return DropdownMenuItem<int?>(
                          value: year,
                          child: Text(
                            year == null ? 'All Years' : year.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedYear = newValue;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 4. Filtered Book List
            filteredBooks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.menu_book,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No books found for this selection.',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true, // Required for ListView inside SingleChildScrollView
                    physics: const NeverScrollableScrollPhysics(), // Prevents nested scroll conflicts
                    itemCount: filteredBooks.length,
                    itemBuilder: (context, index) {
                      final book = filteredBooks[index];
                      return _buildBookListItem(book, context);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookListItem(Book book, BuildContext context) {
    // Safely extract the year if dateFinished exists
    final yearString = book.dateFinished?.year.toString() ?? '';

    // Calculate duration if both dates exist
    String? durationString;
    if (book.dateStarted != null && book.dateFinished != null) {
      durationString = _formatReadingDuration(
        book.dateStarted!,
        book.dateFinished!,
      );
    }

    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Book Icon / Cover Placeholder
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.book, color: Colors.orange, size: 24),
            ),
            const SizedBox(width: 16),

            // Title and Authors
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (book.authors?.isNotEmpty ?? false)
                        ? book.authors!.join(', ')
                        : 'Unknown Author',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Right Side: Duration (optional) + Year Badge
            Row(
              mainAxisSize: MainAxisSize.min, // Shrinks to fit content
              children: [
                // Duration Badge (Only shows if dateStarted is available)
                if (durationString != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors
                          .blue
                          .shade50, // Soft blue to differentiate from year
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          durationString,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8), // Space between duration and year
                ],
                // Year Badge
                if (yearString.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      yearString,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
