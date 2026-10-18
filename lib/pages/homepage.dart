import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'navigation_bar.dart';
import '../data_model/book.dart';
import '../database_helper.dart';
import 'book_details.dart';
import '/pages/add_book_screen.dart';

import 'package:cached_network_image/cached_network_image.dart';

enum BookSortOption {
  titleAsc,
  titleDesc,
  authorAsc,
  authorDesc,
  dateStartedAsc,
  dateStartedDesc,
  dateFinishedAsc,
  dateFinishedDesc,
  dateAddedAsc,
  dateAddedDesc,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Book> _books = [];
  bool _isLoading = true;

  BookSortOption _readingNowSort = BookSortOption.dateAddedDesc;
  BookSortOption _readSort = BookSortOption.dateAddedDesc;

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

  List<Book> _sortBooks(List<Book> books, BookSortOption option) {
    final sorted = List<Book>.from(books);
    sorted.sort((a, b) {
      switch (option) {
        case BookSortOption.titleAsc:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case BookSortOption.titleDesc:
          return b.title.toLowerCase().compareTo(a.title.toLowerCase());
        case BookSortOption.authorAsc:
          final authorA = a.authors?.join(', ').toLowerCase() ?? '';
          final authorB = b.authors?.join(', ').toLowerCase() ?? '';
          return authorA.compareTo(authorB);
        case BookSortOption.authorDesc:
          final authorA = a.authors?.join(', ').toLowerCase() ?? '';
          final authorB = b.authors?.join(', ').toLowerCase() ?? '';
          return authorB.compareTo(authorA);
        // ------- ALL OUR DATES SORTING -----------
        case BookSortOption.dateStartedAsc:
          return _compareNullableDates(a.dateStarted, b.dateStarted, true);
        case BookSortOption.dateStartedDesc:
          return _compareNullableDates(a.dateStarted, b.dateStarted, false);
        case BookSortOption.dateFinishedAsc:
          return _compareNullableDates(a.dateFinished, b.dateFinished, true);
        case BookSortOption.dateFinishedDesc:
          return _compareNullableDates(a.dateFinished, b.dateFinished, false);
        case BookSortOption.dateAddedAsc:
          return a.addedOnDate.compareTo(b.addedOnDate);
        case BookSortOption.dateAddedDesc:
          return b.addedOnDate.compareTo(a.addedOnDate);
      }
    });
    return sorted;
  }

  // helper function to handle null dates and shit
  int _compareNullableDates(DateTime? a, DateTime? b, bool ascending) {
    if (a == null && b == null) return 0;
    if (a == null) return 1; // 'a' goes after 'b' (pushes nulls to the bottom)
    if (b == null) return -1; // 'a' goes before 'b'
    return ascending ? a.compareTo(b) : b.compareTo(a);
  }

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

    final read = _sortBooks(
      _books.where((book) => book.isRead).toList(),
      _readSort,
    );

    final readGroupedByYear = _groupBooksByYear(read);

    final years = readGroupedByYear.keys.toList();
    years.sort((a, b) {
      if (a == 'Unknown') return 1;
      if (b == 'Unknown') return -1;
      return int.parse(b).compareTo(int.parse(a));
    });

    // Wrap CustomScrollView in a standard Padding widget
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: CustomScrollView(
        scrollCacheExtent: ScrollCacheExtent.pixels(1500.0),
        slivers: [
          if (readingNow.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _buildSectionHeader('Reading Now', _readingNowSort, (
                newSort,
              ) {
                setState(() => _readingNowSort = newSort);
              }),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            _buildBookSliverGrid(readingNow),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
          if (read.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                'Read',
                _readSort,
                (newSort) => setState(() => _readSort = newSort),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            for (final year in years) ...[
              SliverToBoxAdapter(child: _buildYearSubHeader(year)),
              _buildBookSliverGrid(readGroupedByYear[year]!),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildBookSliverGrid(List<Book> books) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        childAspectRatio: 0.75,
      ),
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return _buildBookCard(books[index]);
      }, childCount: books.length),
    );
  }

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
              const PopupMenuItem(
                value: BookSortOption.dateStartedAsc,
                child: Text('Started (New-Old)'),
              ),
              const PopupMenuItem(
                value: BookSortOption.dateStartedDesc,
                child: Text('Started (Old-New)'),
              ),
              const PopupMenuItem(
                value: BookSortOption.dateFinishedAsc,
                child: Text('Finished (New-Old)'),
              ),
              const PopupMenuItem(
                value: BookSortOption.dateFinishedDesc,
                child: Text('Finished (Old-New)'),
              ),
              const PopupMenuItem(
                value: BookSortOption.dateAddedAsc,
                child: Text('Added (New-Old)'),
              ),
              const PopupMenuItem(
                value: BookSortOption.dateAddedDesc,
                child: Text('Added (Old-New)'),
              ),
            ],
          ),
        ],
      ),
    );
  }

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

  Widget _buildBookCard(Book book) {
    return Card(
      color: const Color.fromARGB(255, 249, 245, 240),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade600, width: 1),
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
        child: Stack(
          children: [
            // 1. Background Image covering the ENTIRE card
            Positioned.fill(
              child: book.coverUrl != null && book.coverUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      key: ValueKey('${book.id}_${book.coverUrl}'),
                      imageUrl: book.coverUrl!,
                      fit: BoxFit.cover, // Fills the entire space
                      placeholder: (context, url) => Container(
                        color: const Color.fromARGB(255, 249, 245, 240),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: const Color.fromARGB(255, 249, 245, 240),
                        child: const Center(
                          child: Icon(Icons.book, size: 48, color: Colors.grey),
                        ),
                      ),
                    )
                  : Container(
                      color: const Color.fromARGB(255, 249, 245, 240),
                      child: const Center(
                        child: Icon(Icons.book, size: 48, color: Colors.grey),
                      ),
                    ),
            ),

            // Gradient overlay at the bottom for text readability
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 130,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.85),
                      Colors.black.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Checkbox at the top right
            Positioned(
              top: 8,
              right: 8,
              child: Checkbox(
                value: book.isRead,
                onChanged: (bool? newValue) {
                  if (newValue != null) {
                    _toggleReadStatus(book);
                  }
                },
                activeColor: Theme.of(context).primaryColor,
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: const BorderSide(
                  color: Color.fromARGB(255, 217, 179, 81),
                  width: 4,
                ),
              ),
            ),

            // 4. Bottom Section (Title, Author, etc.) overlaid on top
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            book.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              // decoration: book.isRead
                              // ? TextDecoration.lineThrough
                              // : null,
                              color: book.isRead
                                  ? Colors.white70
                                  : Colors.white,
                              shadows: const [
                                Shadow(
                                  offset: Offset(1.0, 1.0),
                                  blurRadius: 3.0,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            book.authors?.join(', ') ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                              shadows: [
                                Shadow(
                                  offset: Offset(1.0, 1.0),
                                  blurRadius: 3.0,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (book.genre.isNotEmpty) ...[
                            const SizedBox(height: 1),
                            Text(
                              book.genre.join(', '),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white60,
                                fontStyle: FontStyle.italic,
                                shadows: [
                                  Shadow(
                                    offset: Offset(1.0, 1.0),
                                    blurRadius: 3.0,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        book.rating != null && book.rating! > 0
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${book.rating}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(1.0, 1.0),
                                          blurRadius: 3.0,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(
                                    Icons.star,
                                    size: 10,
                                    color: Colors.amber,
                                  ),
                                ],
                              )
                            : const Text(
                                'Unrated',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white70,
                                ),
                              ),
                        if (book.notes != null && book.notes!.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 4.0),
                            child: Icon(
                              Icons.notes_outlined,
                              size: 12, // Slightly larger for visibility
                              color: Colors.white70,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
