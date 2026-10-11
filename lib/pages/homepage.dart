import 'package:flutter/material.dart';

import 'navigation_bar.dart';
import '../data_model/book.dart';
import '../database_helper.dart';
import 'book_details.dart';
import '/pages/add_book_screen.dart';

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
    final DateTime? newReadDate = newIsReadStatus ? DateTime.now() : null;
    final updatedBook = book.copyWith(
      isRead: newIsReadStatus,
      dateFinished: newReadDate,
    );
    await DatabaseHelper.instance.updateBook(updatedBook);
    if (mounted) {
      _loadBooks();
    }
  }

  // 3. Added helper method to sort books based on the selected option
  List<Book> _sortBooks(List<Book> books, BookSortOption option) {
    final sorted = List<Book>.from(books);
    sorted.sort((a, b) {
      switch (option) {
        case BookSortOption.titleAsc:
          return (a.title ?? '').toLowerCase().compareTo(
            (b.title ?? '').toLowerCase(),
          );
        case BookSortOption.titleDesc:
          return (b.title ?? '').toLowerCase().compareTo(
            (a.title ?? '').toLowerCase(),
          );
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
    // 4. Apply sorting to the filtered lists
    final readingNow = _sortBooks(
      _books.where((book) => !book.isRead).toList(),
      _readingNowSort,
    );
    final read = _sortBooks(
      _books.where((book) => book.isRead).toList(),
      _readSort,
    );

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
          _buildSectionHeader('Read', _readSort, (newSort) {
            setState(() => _readSort = newSort);
          }),
          const SizedBox(height: 8),
          _buildBookGrid(read),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  // 5. Updated header to include a PopupMenuButton for sorting
  Widget _buildSectionHeader(
    String title,
    BookSortOption currentSort,
    ValueChanged<BookSortOption> onSortChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
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
              Text(
                book.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  decoration: book.isRead ? TextDecoration.lineThrough : null,
                  color: book.isRead ? Colors.grey : Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                book.authors.join(', '),
                style: TextStyle(
                  fontSize: 13,
                  color: book.isRead ? Colors.black54 : Colors.black54,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                book.genre.join(', '),
                style: TextStyle(
                  fontSize: 13,
                  color: book.isRead
                      ? Colors.grey.shade500
                      : Colors.grey.shade500,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              if (book.notes != null && book.notes!.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(
                    Icons.notes_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
              const Spacer(),
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
                                fontSize: 13,
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
                            fontSize: 13,
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
