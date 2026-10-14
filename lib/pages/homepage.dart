import 'package:flutter/material.dart';

import 'navigation_bar.dart';
import '../data_model/book.dart';
import '../database_helper.dart';
import 'book_details.dart';
import '/pages/add_book_screen.dart';

import 'package:cached_network_image/cached_network_image.dart';

// 1. Added Sort Options Enum
enum BookSortOption { titleAsc, titleDesc, authorAsc, authorDesc }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Book> _books = [];
  bool _isLoading = true;

  // 2. Added state variables to track sort order for each section
  BookSortOption _readingNowSort = BookSortOption.titleAsc;
  BookSortOption _readSort = BookSortOption.titleAsc;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final books = await DatabaseHelper.instance.getBooks();
    if (mounted) {
      setState(() {
        _books = books;
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddBookDialog() async {
    final Book? newBook = await showDialog<Book>(
      context: context,
      builder: (dialogContext) => const AddBookDialog(),
    );

    if (newBook != null && mounted) {
      _saveBookAndRefresh(newBook);
    }
  }

  Future<void> _saveBookAndRefresh(Book book) async {
    await DatabaseHelper.instance.insertBook(book);
    if (mounted) {
      _loadBooks();
    }
  }

  Future<void> _toggleReadStatus(Book book) async {
    final bool newIsReadStatus = !book.isRead;

    final updatedBook = book.copyWith(isRead: newIsReadStatus);
    await DatabaseHelper.instance.updateBook(updatedBook);
    if (mounted) {
      _loadBooks();
    }
  }

  // 3. Helper method to sort books based on the selected option
  List<Book> _sortBooks(List<Book> books, BookSortOption option) {
    final sorted = List<Book>.from(books);
    sorted.sort((a, b) {
      switch (option) {
        case BookSortOption.titleAsc:
          return (a.title).toLowerCase().compareTo((b.title).toLowerCase());
        case BookSortOption.titleDesc:
          return (b.title).toLowerCase().compareTo((a.title).toLowerCase());
        case BookSortOption.authorAsc:
          final authorA = a.authors.isEmpty
              ? ''
              : a.authors.join(', ').toLowerCase();
          final authorB = b.authors.isEmpty
              ? ''
              : b.authors.join(', ').toLowerCase();
          return authorA.compareTo(authorB);
        case BookSortOption.authorDesc:
          final authorA = a.authors.isEmpty
              ? ''
              : a.authors.join(', ').toLowerCase();
          final authorB = b.authors.isEmpty
              ? ''
              : b.authors.join(', ').toLowerCase();
          return authorB.compareTo(authorA);
      }
    });
    return sorted;
  }

  // 4. NEW: Helper method to group books by year
  Map<String, List<Book>> _groupBooksByYear(List<Book> books) {
    final Map<String, List<Book>> grouped = {};
    for (final book in books) {
      final yearStr = book.dateFinished != null
          ? book.dateFinished!.year.toString()
          : 'Unknown';
      if (!grouped.containsKey(yearStr)) {
        grouped[yearStr] = [];
      }
      grouped[yearStr]!.add(book);
    }
    return grouped;
  }

  Widget _buildCoverPreview(
    String? coverUrl, {
    double width = 50,
    double height = 70,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(
          6,
        ), // Slightly tighter radius for small images
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: coverUrl != null && coverUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: coverUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(
                    Icons.book,
                    size: 24,
                    color: Colors.grey,
                  ), // Smaller icon fallback
                ),
              )
            : const Center(
                child: Icon(Icons.book, size: 24, color: Colors.grey),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      selectedIndex: 1,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _books.isEmpty
          ? const Center(child: Text("Want to add some books?"))
          : _buildBookSections(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBookDialog,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBookSections() {
    final readingNow = _sortBooks(
      _books.where((book) => !book.isRead).toList(),
      _readingNowSort,
    );

    // Sort all read books first, so they maintain order when grouped by year
    final read = _sortBooks(
      _books.where((book) => book.isRead).toList(),
      _readSort,
    );

    // Group read books by year
    final readGroupedByYear = _groupBooksByYear(read);

    // Sort years descending, putting 'Unknown' at the very end
    final years = readGroupedByYear.keys.toList();
    years.sort((a, b) {
      if (a == 'Unknown') return 1;
      if (b == 'Unknown') return -1;
      return int.parse(b)
          .compareTo(int.parse(a)); // Descending order (e.g., 2026, 2025)
    });

    return ListView(
      padding: const EdgeInsets.all(12.0),
      children: [
        if (readingNow.isNotEmpty) ...[
          _buildSectionHeader('Reading Now', _readingNowSort, (newSort) {
            setState(() => _readingNowSort = newSort);
          }),
          const SizedBox(height: 8),
          _buildBookGrid(readingNow),
          const SizedBox(height: 24),
        ],
        if (read.isNotEmpty) ...[
          _buildSectionHeader(
            'Read',
            _readSort,
            (newSort) => setState(() => _readSort = newSort),
          ),
          const SizedBox(height: 16),
          // Iterate through each year and build a subgroup
          for (final year in years) ...[
            _buildYearSubHeader(year),
            _buildBookGrid(readGroupedByYear[year]!),
            const SizedBox(height: 24),
          ],
        ],
      ],
    );
  }

  // Header for Read Books and Is Reading, plus the sorting
  Widget _buildSectionHeader(
    String title,
    BookSortOption currentSort,
    ValueChanged<BookSortOption> onSortChanged, {
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (subtitle != null && subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
            ],
          ),
          PopupMenuButton<BookSortOption>(
            icon: const Icon(Icons.sort, color: Colors.black54),
            tooltip: 'Sort books',
            initialValue: currentSort,
            onSelected: onSortChanged,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: BookSortOption.titleAsc,
                child: Text('Title (A-Z)'),
              ),
              const PopupMenuItem(
                value: BookSortOption.titleDesc,
                child: Text('Title (Z-A)'),
              ),
              const PopupMenuItem(
                value: BookSortOption.authorAsc,
                child: Text('Author (A-Z)'),
              ),
              const PopupMenuItem(
                value: BookSortOption.authorDesc,
                child: Text('Author (Z-A)'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // NEW: Helper for year subheaders
  Widget _buildYearSubHeader(String year) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: Text(
        year,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildBookGrid(List<Book> books) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        childAspectRatio: 0.75,
      ),
      itemCount: books.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildBookCard(books[index]);
      },
    );
  }

  Widget _buildBookCard(Book book) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: InkWell(
        onTap: () async {
          final didChange = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailScreen(book: book),
            ),
          );
          if (didChange == true && mounted) {
            _loadBooks();
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TITLE (TOP)
              Text(
                book.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  decoration: book.isRead ? TextDecoration.lineThrough : null,
                  color: book.isRead ? Colors.grey : Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // 2. AUTHOR
              Text(
                book.authors.join(', '),
                style: TextStyle(fontSize: 12, color: Colors.black54),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // 3. GENRE
              if (book.genre.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  book.genre.join(', '),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 6),
              // COVER IMAGE (MIDDLE)
              _buildCoverPreview(book.coverUrl),
              // NOTES INDICATOR
              if (book.notes != null && book.notes!.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
                  child: Icon(
                    Icons.notes_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
              const Spacer(), // Pushes the bottom row all the way down
              //RATING AND CHECKBOX (BOTTOM)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  book.rating != null && book.rating! > 0
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${book.rating}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: book.isRead
                                    ? Colors.grey.shade500
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                          ],
                        )
                      : Text(
                          'Unrated',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: book.isRead
                                ? Colors.grey.shade500
                                : Colors.black54,
                          ),
                        ),
                  Checkbox(
                    value: book.isRead,
                    onChanged: (bool? newValue) {
                      if (newValue != null) {
                        _toggleReadStatus(book);
                      }
                    },
                    activeColor: Theme.of(context).primaryColor,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
