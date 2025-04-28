import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:routine_generator/All_Screens/remove_admin.dart';
import 'package:routine_generator/All_Screens/show_all_admin.dart';

import 'make_admin.dart';

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Admin Settings",
          style: TextStyle(
            color: Colors.white,          // White text color
            fontSize: 23,                 // Larger font size
            fontWeight: FontWeight.bold,  // Bold weight to make it stand out
            letterSpacing: 1.5,           // Add some spacing between the letters
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGorgeousButton(
                label: "Make Admin",
                onPressed: () {
                  // Implement navigation to Make Admin functionality
                  Get.to(() => const MakeAdminInputPage());

                },
                colors: [Colors.green, Colors.lightGreenAccent],
                icon: Icons.person_add_alt_1,
                textColor: Colors.black,
              ),
              const SizedBox(height: 20),
              _buildGorgeousButton(
                label: "Remove Admin",
                onPressed: () {
                  // Implement navigation to Remove Admin functionality
                  Get.to(() => const RemoveAdminInputPage());
                },
                colors: [Colors.redAccent, Colors.pinkAccent],
                icon: Icons.person_remove_alt_1,
                textColor: Colors.black,
              ),
              const SizedBox(height: 20),
              _buildGorgeousButton(
                label: "Show All Admin",
                onPressed: () {
                  // Implement navigation to Show All Admin functionality
                  Get.to(() => ShowAllAdminPage());
                },
                colors: [Colors.blueAccent, Colors.lightBlueAccent],
                icon: Icons.people,
                textColor: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGorgeousButton({
    required String label,
    required VoidCallback onPressed,
    required List<Color> colors,
    required IconData icon,
    required Color textColor,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 28, color: textColor),
        onPressed: onPressed,
        label: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 8,
          shadowColor: Colors.black45,
          backgroundColor: null,
        ),
      ),
    );
  }
}