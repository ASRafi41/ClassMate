import 'package:flutter/material.dart';

class DeveloperInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Developer Info",
          style: TextStyle(
            color: Colors.white,          // White text color
            fontSize: 20,                 // Larger font size
            fontWeight: FontWeight.bold,  // Bold weight to make it stand out
            letterSpacing: 1.5,           // Add some spacing between the letters
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0, // Remove shadow
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back when pressed
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDeveloperCard(
              context: context,
              imagePath: 'assets/Abid.jpg', // You need to use your uploaded image
              name: 'Abid Hussen',
              batch: '57',
              university: 'Leading University',
              email: 'abidhussen351@gmail.com',
              contact: '01704206217',
            ),
            const SizedBox(height: 16),
            _buildDeveloperCard(
              context: context,
              imagePath: 'assets/Sufian.png', // Second image path
              name: 'Abu Sufian Rafi',
              batch: '57',
              university: 'Leading University',
              email: 'abusufianrafi326276@gmail.com',
              contact: '01640464210',
            ),
            const SizedBox(height: 16),
            _buildDeveloperCard(
              context: context,
              imagePath: 'assets/Nadim.jpg', // Third image path
              name: 'Muhammad Nadim',
              batch: '57',
              university: 'Leading University',
              email: 'cse_2122020018@lus.ac.bd',
              contact: '01406791514',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperCard({
    required BuildContext context,
    required String imagePath,
    required String name,
    required String batch,
    required String university,
    required String email,
    required String contact,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(imagePath), // Display the developer's image
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text("Batch: $batch"),
                  Text("University: $university"),
                  Text("Email: $email"),
                  Text("Contact: $contact"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
