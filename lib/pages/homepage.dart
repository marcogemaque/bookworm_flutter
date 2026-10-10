import 'package:flutter/material.dart';

import 'navigation_bar.dart';

import '../data_model/book.dart';
import '../database_helper.dart';
import 'book_details.dart';
import '/pages/add_book_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Book> _books = [];
  bool _isLoading = true;

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

  // 👇 SIMPLIFIED: Now just calls the extracted dialog widget
  Future<void> _showAddBookDialog() async {
    final Book? newBook = await showDialog<Book>(
      context: context,
      builder: (dialogContext) => const AddBookDialog(),
    );

    // If the user saved a book, refresh the list
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
    final updatedBook = book.copyWith(isRead: !book.isRead);
    await DatabaseHelper.instance.updateBook(updatedBook);
    if (mounted) {
      _loadBooks();
    }
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
    final readingNow = _books.where((book) => !book.isRead).toList();
    final read = _books.where((book) => book.isRead).toList();

    return ListView(
      padding: const EdgeInsets.all(12.0),
      children: [
        if (readingNow.isNotEmpty) ...[
          _buildSectionHeader('Reading Now'),
          const SizedBox(height: 8),
          _buildBookGrid(readingNow),
          const SizedBox(height: 24),
        ],
        if (read.isNotEmpty) ...[
          _buildSectionHeader('Read'),
          const SizedBox(height: 8),
          _buildBookGrid(read),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
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
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  book.authors.join(', '),
                  style: TextStyle(
                    fontSize: 13,
                    color: book.isRead ? Colors.grey.shade500 : Colors.black54,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
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
                    onChanged: (value) => _toggleReadStatus(book),
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
