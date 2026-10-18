Privacy Policy for Bookworm
Last Updated: October 19, 2026
Introduction
Welcome to Bookworm ("we," "our," or "us"). We are committed to protecting your privacy and ensuring you have a positive experience using our mobile application.
This Privacy Policy explains how we handle information when you use the Bookworm app.
Information We Collect
Information You Provide
Bookworm stores the following information locally on your device:
Book titles and authors
Reading dates (when you started and finished books)
Genres and categories
Personal ratings and notes
Book cover images (fetched from Open Library)

We do not collect, transmit, or store this information on any external servers. All your reading data remains entirely on your device. We do use OpenBook API, which we query using the book's author and title you provided.

Third-Party Services
Open Library API
Bookworm uses the Open Library API (operated by the Internet Archive) to fetch book cover images. When you add a book, the app sends the book title and author to Open Library's servers to retrieve the corresponding cover image.
Open Library's privacy policy can be found at: https://archive.org/about/terms.php
We do not send any personal information, reading history, or notes to Open Library—only the book title and author name needed to locate the cover image.
Data Storage and Security
All your personal reading data is stored locally on your device using an encrypted database. We do not:
Collect analytics or usage data
Store your information on external servers
Share your data with third parties
Require user accounts or authentication
Your data is only accessible on the device where it was created. If you uninstall the app, all locally stored data will be permanently deleted.
Children's Privacy
Bookworm does not knowingly collect any personal information from children under the age of 13. If you believe a child has provided us with personal information, please contact us immediately.
Your Rights
You have complete control over your data:
You can view, edit, or delete any book entry at any time
You can uninstall the app to permanently delete all local data
You can export or back up your data (if the app provides this feature)
Changes to This Privacy Policy
We may update this Privacy Policy from time to time. We will notify you of any changes by updating the "Last Updated" date at the top of this policy.
Contact Us
If you have any questions about this Privacy Policy, please contact us at:
[Your Name or Company Name]
Email: [your-email@example.com]
Website: [your-website.com]
Notes for You:
Replace the placeholders at the bottom with your actual contact information
If you add analytics later (like Firebase Analytics, Mixpanel, etc.), you'll need to update this policy
If you add user accounts or cloud sync, the policy will need significant updates
For App Store submission, you may need to provide a URL where this policy is hosted (you can use GitHub Pages, a simple website, or a Google Doc)
This is a template — while it covers the basics for your current app, consider having a legal professional review it if you plan to monetize or scale the app
Since your app is purely local with no data collection beyond the Open Library API calls, this policy is quite straightforward and user-friendly!
