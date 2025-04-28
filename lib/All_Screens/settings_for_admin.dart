import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:routine_generator/All_Screens/profile_setting_page_admin.dart';

import 'admin_setting_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: const Text(
          "Settings",
          style: TextStyle(
            color: Colors.white,          // White text color
            fontSize: 20,                 // Larger font size
            fontWeight: FontWeight.bold,  // Bold weight to make it stand out
            letterSpacing: 1.5,           // Add some spacing between the letters
            // shadows: [
            //   Shadow(                      // Add a subtle shadow
            //     offset: Offset(2.0, 2.0),
            //     blurRadius: 3.0,
            //     color: Colors.black54,
            //   ),
            // ],
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
                label: "Admin Settings",
                onPressed: () {
                  // Navigate to Admin Settings page or functionality
                  Get.to(() => AdminSettingsPage()); // Create AdminSettingsPage as needed
                },
                colors: [Colors.green, Colors.lightGreenAccent],
                icon: Icons.admin_panel_settings,
                textColor: Colors.black,
              ),
              const SizedBox(height: 20),
              _buildGorgeousButton(
                label: "Profile Settings",
                onPressed: () {
                  // Navigate to Profile Settings page or functionality
                  Get.to(() => ProfileSettingsPageAdmin()); // Create ProfileSettingsPage as needed
                },
                colors: [Colors.blueAccent, Colors.lightBlueAccent],
                icon: Icons.person,
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
