import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:routine_generator/Auth%20UI%20Controller/global_variable.dart';

class ProfileSettingsPageUser extends StatefulWidget {
  const ProfileSettingsPageUser({super.key});

  @override
  _ProfileSettingsPageUserState createState() => _ProfileSettingsPageUserState();
}

class _ProfileSettingsPageUserState extends State<ProfileSettingsPageUser> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _batchController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _nameAcronymController = TextEditingController();

  bool isTeacher = false;
  bool isStudent = false;

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
        isTeacher = userData['is_teacher'];
        isStudent = !isTeacher;
        if (isTeacher) {
          _nameAcronymController.text = userData['Name Acronym'];
        } else {
          _batchController.text = userData['Batch'] ?? '';
          _sectionController.text = userData['Section'] ?? '';
        }
      });
    } else {
      Get.snackbar("Error", "User data not found", snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _updateProfile() async {
    final String newName = _nameController.text.trim();
    final String newPassword = _passwordController.text.trim();

    if (newName.isEmpty || newPassword.isEmpty) {
      Get.snackbar("Error", "Name cannot be empty");
      return;
    }

    try {
      CollectionReference users = FirebaseFirestore.instance.collection('UserInfo');
      final querySnapshot = await users.where('Email', isEqualTo: FinalEmail).get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        String docId = userDoc.id;
        users.doc(docId).update({"Full Name": newName});
        if (isTeacher) {
          final String newNameAcronym = _nameAcronymController.text.trim();
          users.doc(docId).update({"Name Acronym": newNameAcronym});
        } else if (isStudent) {
          final String newBatch = _batchController.text.trim();
          final String newSection = _sectionController.text.trim();
          users.doc(docId).update({"Batch": newBatch, "Section": newSection});
        }
      } else {
        Get.snackbar("Error", "No user is found with that email");
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
            height: MediaQuery.of(context).size.height, // Ensure the content fills the screen
            decoration: const BoxDecoration(
              color: Colors.white10,  // Use a solid color for the background
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
                  // Conditionally render fields based on user role
                  if (isTeacher)
                    _buildTextField(
                      label: "Name Acronym",
                      controller: _nameAcronymController,
                      icon: Icons.short_text,
                    )
                  else if (isStudent) ...[
                    _buildTextField(
                      label: "Batch",
                      controller: _batchController,
                      icon: Icons.batch_prediction,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: "Section",
                      controller: _sectionController,
                      icon: Icons.school,
                    ),
                  ],
                  const SizedBox(height: 30),
                  // Update Button
                  _buildGorgeousButton(
                    label: "Update Profile",
                    onPressed: _updateProfile,
                    colors: [Colors.blue, Colors.indigo],
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
