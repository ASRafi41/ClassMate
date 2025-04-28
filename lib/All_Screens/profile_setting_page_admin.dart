import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:routine_generator/Auth%20UI%20Controller/global_variable.dart';

class ProfileSettingsPageAdmin extends StatefulWidget {
  const ProfileSettingsPageAdmin({super.key});

  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPageAdmin> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late TextEditingController _nameAcronymController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    CollectionReference users = FirebaseFirestore.instance.collection('UserInfo');
    final querySnapshot = await users.where('Email', isEqualTo: FinalEmail).get();
    if (querySnapshot.docs.isNotEmpty) {
      final userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
      setState(() {
        _nameController.text = userData['Full Name'];
        _passwordController.text = userData['Password'];
        bool isTeacher = userData['is_teacher'];
        if (isTeacher) {
          _nameAcronymController.text = userData['Name Acronym'];
        } else {
          _nameAcronymController.text = "User Is a Student.";
        }
      });
    } else {
      Get.snackbar("Error", "User data not found", snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _updateProfile() async {
    final String newName = _nameController.text.trim();
    final String newPassword = _passwordController.text.trim();
    final String newNameAcronym = _nameAcronymController.text.trim();

    if (newName.isEmpty || newPassword.isEmpty || newNameAcronym.isEmpty) {
      Get.snackbar("Error", "Name or Acronym cannot be empty");
      return;
    }

    try {
      CollectionReference users = FirebaseFirestore.instance.collection('UserInfo');
      final querySnapshot = await users.where('Email', isEqualTo: FinalEmail).get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        String docId = userDoc.id;
        users.doc(docId).update({"Name Acronym": newNameAcronym});
        users.doc(docId).update({"Full Name": newName});
      } else {
        Get.snackbar("Error", "No user is Found with that Email");
      }
    } catch (e) {
      log('Error updating user data: $e');
    }

    Get.snackbar("Success", "Profile updated successfully");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile Settings",
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,  // Ensure the content fills the screen
            decoration: const BoxDecoration(
              color: Colors.white10,  // Set the background color to match the other page
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Profile picture
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    child: const Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  // Name TextField
                  _buildTextField(
                    label: "Name",
                    controller: _nameController,
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 20),
                  // Name Acronym TextField
                  _buildTextField(
                    label: "Name Acronym",
                    controller: _nameAcronymController,
                    icon: Icons.short_text,
                  ),
                  const SizedBox(height: 30),
                  // Update Button
                  _buildGorgeousButton(
                    label: "Update Profile",
                    onPressed: _updateProfile,
                    colors: [Colors.green, Colors.lightGreenAccent],
                    icon: Icons.update,
                    textColor: Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        filled: true,
        fillColor: Colors.white,
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
        ),
      ),
    );
  }
}
