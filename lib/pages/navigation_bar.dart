import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// my main page
import 'package:bookworm/pages/homepage.dart';

// my other pages
import 'settings_page.dart';
import 'bug_report_page.dart';
import 'about.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final int selectedIndex; // Used to highlight the active page in the drawer
  final Widget? floatingActionButton;

  const AppScaffold({
    super.key,
    required this.body,
    this.selectedIndex = -1,
    this.floatingActionButton,
  });

  // Helper function to handle navigation cleanly
  void _navigateTo(BuildContext context, Widget page) {
    Navigator.pop(context); // 1. Close the drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page), // 2. Navigate to new page
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 12),
                  Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 24.0,
                    ), // Adds 24px of space to the right of the picture
                    child: Image.asset(
                      'assets/logos/resized7.png',
                      width: 60,
                      height: 60,
                    ),
                    // (Or your Icon widget if you are using that instead!)
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Dashboard'),
              selected: selectedIndex == 0,
              onTap: () => _navigateTo(
                context,
                const HomeScreen(),
              ), // Replace with your actual page
            ),
            ListTile(
              leading: const Icon(Icons.question_mark),
              title: const Text('About'),
              selected: selectedIndex == 1,
              onTap: () => _navigateTo(context, const AboutPage()),
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Bug Report'),
              selected: selectedIndex == 3,
              onTap: () => _navigateTo(
                context,
                const BugReportPage(),
              ), // Replace with your actual page
            ),
          ],
        ),
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
