import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:routine_generator/All_Screens/homepage_user_view.dart';
import 'package:routine_generator/Auth%20UI%20Controller/sign_up_and_login_controller.dart';

class RegisterEmailVerificationPage extends StatefulWidget {
  final String? name;
  final String? email;
  final String? password;
  final String? confirmPassword;
  final String? nameAcronym;
  final String? batch;
  final String? section;
  final bool? isTeacher;

  const RegisterEmailVerificationPage({
    super.key,
    this.name,
    this.email,
    this.password,
    this.confirmPassword,
    this.nameAcronym,
    this.batch,
    this.section,
    this.isTeacher,
  });

  @override
  State<RegisterEmailVerificationPage> createState() => _RegisterEmailVerificationPage();
}

class _RegisterEmailVerificationPage extends State<RegisterEmailVerificationPage> {

  final _auth = AuthService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
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
              colors: [Colors.indigo, Colors.purpleAccent],  // Background gradient matching your style
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100),

                // Title Text
                const Text(
                  "OTP Verification",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Enter the OTP sent to your email",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Display user email
                Text(
                  "Email: ${widget.email}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),

                // Card for OTP Input
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
                          const SizedBox(height: 30),

                          // OTP Input Field
                          TextFormField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "OTP",
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the OTP';
                              }
                              // Basic validation for OTP
                              if (value.length != 6) {
                                return 'OTP must be 6 digits';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 30),

                          // Verify OTP Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  // Perform OTP verification logic here
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => ResetPasswordPage(email: widget.email),  // Navigate to OTP page
                                  //   ),
                                  // );
                                  _verifyOTP();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                backgroundColor: Colors.indigo,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Verify OTP",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // void updateDisplayName(String fullName) async {
  //   try {
  //     // Get the current user
  //     User? user = FirebaseAuth.instance.currentUser;
  //
  //     if (user != null) {
  //       // Update the user's display name
  //       await user.updateProfile(displayName: fullName);
  //
  //       // Optionally reload the user to apply the changes
  //       await user.reload();
  //
  //       log("Display Name updated to: ${user.displayName}");
  //     }
  //   } catch (e) {
  //     log("Error: $e");
  //   }
  // }

  void _verifyOTP() async{
    if (EmailOTP.verifyOTP(otp: _otpController.text)) {
      Get.snackbar("Successfull", "OTP verification Successfull.", snackPosition: SnackPosition.BOTTOM);
      if(widget.isTeacher == true){
        CollectionReference collRef =
        FirebaseFirestore.instance.collection('UserInfo');
        try {
          await collRef.add({
            'Full Name': widget.name,
            'Name Acronym' : widget.nameAcronym,
            'Email': widget.email,
            'Password': widget.password,
            'Confirm Password': widget.confirmPassword,
            'is_admin' : false,
            'is_teacher' : true,
          });
          Get.snackbar("Success", "Stored in Firebase successfully.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green.withOpacity(0.1),
              colorText: Colors.green);
        } catch (e) {
          Get.snackbar("Error", "Failed to store in Firebase: $e",
              snackPosition: SnackPosition.BOTTOM);
          log("Failed to store in Firebase : $e");
        }
      }
      else{
        CollectionReference collRef =
        FirebaseFirestore.instance.collection('UserInfo');
        try {
          await collRef.add({
            'Full Name': widget.name,
            'Batch' : widget.batch,
            'Section' : widget.section,
            'Email': widget.email,
            'Password': widget.password,
            'Confirm Password': widget.confirmPassword,
            'is_admin' : false,
            'is_teacher' : false,
          });
          Get.snackbar("Success", "Stored in Firebase successfully.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green.withOpacity(0.1),
              colorText: Colors.green);
        } catch (e) {
          Get.snackbar("Error", "Failed to store in Firebase: $e",
              snackPosition: SnackPosition.BOTTOM);
          log("Failed to store in Firebase : $e");
        }
      }
      final user = await _auth.createUserWithEmailAndPassword(widget.email ?? "NULL", widget.password ?? "NULL");
      await user?.updateDisplayName(widget.name);// to set the display name which is differnt from Full Name ;
      if (user != null) {
        log("User Created successfully");
        Get.snackbar("Create", "User Created successfully",
            snackPosition: SnackPosition.TOP);
      } else {
        Get.snackbar("Error", "Sign up failed",
            snackPosition: SnackPosition.BOTTOM);
      }
      Get.to(HomePageUserView(name: widget.name, email: widget.email,));
    } else {
      Get.snackbar("Unsuccessfull", "OTP verification Unsuccessfull.", snackPosition: SnackPosition.BOTTOM);
    }
  }
}
