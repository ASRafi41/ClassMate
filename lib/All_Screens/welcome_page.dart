import 'package:flutter/material.dart';
import 'package:routine_generator/All_Screens/register_page_for_student.dart';
import 'package:routine_generator/All_Screens/register_page_for_teacher.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});  // Added key

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background color with gradient
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.purpleAccent],  // Background gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,  // Centers content vertically
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Welcome to Our Platform!",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  // fontFamily: 'Lobster',  // Custom font for an elegant look
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                "Are you a Student or a Teacher?",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),

              // Student Card
              _buildOptionCard(
                context,
                title: "I am a Student",
                icon: Icons.school,
                backgroundColor: Colors.blueAccent,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPageForStudent(userType: 'student'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Teacher Card
              _buildOptionCard(
                context,
                title: "I am a Teacher",
                icon: Icons.person,
                backgroundColor: Colors.orangeAccent,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPageForTeacher(userType: 'teacher'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to create option cards for Student and Teacher
  Widget _buildOptionCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color backgroundColor,
        required VoidCallback onPressed,
      }) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),  // Rounded corners
        ),
        elevation: 8,  // Shadow effect for card
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(width: 16),
              Expanded(//By using Expanded, the card can dynamically adjust its size based on the screen size. For example, on a larger device, the card will still take up a significant portion of the vertical space, while on smaller devices, it shrinks to fit within the available space.
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // Text(
              //   title,
              //   style: const TextStyle(
              //     fontSize: 20,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.white,
              //   ),
              // ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
