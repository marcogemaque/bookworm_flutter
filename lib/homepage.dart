import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'data_model/book.dart';
import 'database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Book> _books = [];
  bool _isLoading = true;

  // 1. Load books from the database when the screen opens
  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final books = await DatabaseHelper.instance.getBooks();
    setState(() {
      _books = books;
      _isLoading = false;
    });
  }

  // 2. Show a dialog to add a new book
  Future<void> _showAddBookDialog() async {
    final titleController = TextEditingController();
    final authorController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add a New Book'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: authorController,
              decoration: const InputDecoration(
                labelText: 'Authors (comma-separated)',
                hintText: 'e.g. Neil Gaiman, Terry Pratchett',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(dialogContext).pop,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty &&
                  authorController.text.isNotEmpty) {
                final newBook = Book(
                  title: titleController.text,
                  authors: authorController.text
                      .split(',')
                      .map((author) => author.trim())
                      .where((author) => author.isNotEmpty)
                      .toList(),
                );

                Navigator.of(dialogContext).pop();

                // 2. Now do the async database work
                _saveBookAndRefresh(newBook);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Helper method to handle the async work safely
  Future<void> _saveBookAndRefresh(Book book) async {
    await DatabaseHelper.instance.insertBook(book);

    // 3. Check 'mounted' to ensure the screen hasn't been destroyed
    if (mounted) {
      _loadBooks();
    }
  }

  // 1. Toggle the "isRead" status of a book
  Future<void> _toggleReadStatus(Book book) async {
    // Update the object in memory
    final updatedBook = book.copyWith(isRead: !book.isRead);

    // 2. Save the change to the database
    await DatabaseHelper.instance.updateBook(updatedBook);

    // 3. Refresh the UI safely
    if (mounted) {
      _loadBooks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Your custom background color
      backgroundColor: Colors.orange.shade50,

      // 2. Your beautiful custom AppBar
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: Text.rich(
          TextSpan(
            text: 'Book',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            children: [
              TextSpan(
                text: 'worm',
                style: GoogleFonts.playfairDisplay(
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),

      // 3. Your custom Drawer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              child: const Text('Menu', style: TextStyle(fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.question_mark),
              title: const Text('About'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Bug Report'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),

      // 4. OUR database-driven body
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _books.isEmpty
          ? const Center(child: Text('No books yet. Add one!'))
          : ListView.builder(
              itemCount: _books.length,
              itemBuilder: (BuildContext context, int index) {
                final book = _books[index];
                return ListTile(
                  title: Text(
                    book.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: book.isRead
                          ? TextDecoration.lineThrough
                          : null,
                      color: book.isRead ? Colors.grey : Colors.black,
                    ),
                  ),
                  subtitle: Text(book.authors?.join(', ') ?? 'Unknown Author'),
                  trailing: Checkbox(
                    value: book.isRead,
                    onChanged: (value) => _toggleReadStatus(book),
                  ),
                  onTap: () => _toggleReadStatus(book),
                );
              },
            ),

      // 5. OUR floating action button to add books
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBookDialog,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
