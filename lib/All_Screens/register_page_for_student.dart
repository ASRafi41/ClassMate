import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:routine_generator/All_Screens/register_email_verification_page.dart';
import 'login.dart';

class RegisterPageForStudent extends StatefulWidget {
  final String? userType;
  const RegisterPageForStudent({super.key, this.userType});

  @override
  State<RegisterPageForStudent> createState() => _RegisterState();
}

class _RegisterState extends State<RegisterPageForStudent> {


  Future<bool> checkEmailInDatabase(String email) async {
    // Get the instance of Firestore
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Query the UserInfo collection to check if the email already exists
    try {
      final querySnapshot = await firestore
          .collection('UserInfo')
          .where('Email', isEqualTo: email)
          .get();

      // If there is any document with the same email, return true
      if (querySnapshot.docs.isNotEmpty) {
        return true; // Email exists
      } else {
        return false; // Email does not exist
      }
    } catch (e) {
      print('Error checking email in database: $e');
      return false; // Handle the error (optional)
    }
  }

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _batch = TextEditingController(); // New controller for Batch
  final TextEditingController _section = TextEditingController(); // New controller for Section
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // To avoid overflow when keyboard appears
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.purpleAccent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Text(
                  widget.userType == null
                      ? "Create Your Account"
                      : "Register as a ${widget.userType}",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Lobster',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Join us for a wonderful journey",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),

                // Registration Form
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            controller: _name,
                            label: "Name",
                            icon: Icons.person,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // New Row for Batch and Section fields side by side
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _batch,
                                  label: "Batch",
                                  icon: Icons.class_,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Enter your batch';
                                    } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                      return 'Only Integer Value';
                                    }
                                    return null;
                                  },

                                ),
                              ),
                              const SizedBox(width: 16), // Spacing between the two fields
                              Expanded(
                                child: _buildTextField(
                                  controller: _section,
                                  label: "Section",
                                  icon: Icons.layers,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Enter your section';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _email,
                            label: "Email",
                            icon: Icons.email,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              } else if (!RegExp(
                                  r'^[a-zA-Z0-9.a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email';
                                //[text]@[domain].[extension]
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Password Field with eye icon
                          _buildTextField(
                            controller: _password,
                            obscureText: !_isPasswordVisible,
                            label: "Password",
                            icon: Icons.lock,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }

                              // Regex for password validation: at least 1 digit, 1 lowercase, 1 uppercase, 1 special character,
                              // no spaces, and length between 8 to 16 characters.
                              String pattern = r'^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*\W)(?!.* ).{8,16}$';
                              RegExp regex = RegExp(pattern);

                              if (!regex.hasMatch(value)) {
                                return 'Password must be 8-16 characters long,\n contain uppercase, lowercase, number,\n special character, and no spaces';
                              }

                              return null; // Password is valid
                            },
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Confirm Password Field with eye icon
                          _buildTextField(
                            controller: _confirmPassword,
                            label: "Confirm Password",
                            icon: Icons.lock_outline,
                            obscureText: !_isConfirmPasswordVisible,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _password.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                if(await checkEmailInDatabase(_email.text))
                                {
                                    Get.snackbar("Error", "The email is already registered.");
                                }
                                else{
                                  _signup();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                backgroundColor: Colors.indigo,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account?",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Login(),
                          ),
                        );
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.yellowAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    required String? Function(String?)? validator,
    Widget? suffixIcon, // Added suffixIcon parameter for eye button
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon, // Set the suffix icon
      ),
      validator: validator,
    );
  }

  _signup() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_password.text != _confirmPassword.text) {
        Get.snackbar("Error", "Passwords do not match",
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      _sendOTP(); // sending OTP to the email before going to Email Verification page
      Get.to(RegisterEmailVerificationPage(
        name: _name.text,
        email: _email.text,
        password: _password.text,
        confirmPassword: _confirmPassword.text,
        nameAcronym: "I Am a Student",
        batch: _batch.text,
        section: _section.text,
        isTeacher: false,
      ));

      _name.clear();
      _batch.clear();
      _section.clear();
      _email.clear();
      _password.clear();
      _confirmPassword.clear();
    }
  }

  void _sendOTP() async {
    if (await EmailOTP.sendOTP(email: _email.text)) {
      Get.snackbar("Sent", "OTP has been sent", snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar("Failed", "Failed to send OTP", snackPosition: SnackPosition.BOTTOM);
    }
  }
}


