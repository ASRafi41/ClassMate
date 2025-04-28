import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Import Firestore package
import 'package:routine_generator/All_Screens/welcome_page.dart';
import 'homepage_admin_view.dart';  // Assuming you have a HomePageAdminView
import 'homepage_user_view.dart';   // Assuming you have a HomePageUserView

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // Listens to auth state
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading screen while checking the auth status
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          // If user is signed in, retrieve user information from Firestore
          final user = snapshot.data;

          // Return a FutureBuilder to wait for the Firestore query result
          return FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('UserInfo')
                .where('Email', isEqualTo: user?.email)
                .get(),
            builder: (context, querySnapshot) {
              if (querySnapshot.connectionState == ConnectionState.waiting) {
                // Show a loading indicator while Firestore query is processing
                return const Center(child: CircularProgressIndicator());
              }

              if (querySnapshot.hasData) {
                if (querySnapshot.data!.docs.isNotEmpty) {
                  final userData = querySnapshot.data?.docs.first.data() as Map<String, dynamic>?;

                  if (userData != null) {
                    log("User Data: $userData");

                    // Check if the user is an admin or not
                    final bool isAdmin = userData['is_admin'] ?? false;

                    // Navigate to HomePageAdminView if user is admin, otherwise to HomePageUserView
                    if (isAdmin) {
                      return HomePageAdminView(
                        name: userData['Full Name']  ?? "Guest",  // Display name from Firestore or Firebase
                        email: user?.email,
                      );
                    } else {
                      return HomePageUserView(
                        name: userData['Full Name'] ?? "Guest",  // Display name from Firestore or Firebase
                        email: user?.email,
                      );
                    }
                  }
                }
              }

              // If no data is found or document is empty, fallback to WelcomePage or show an error
              return const WelcomePage();
            },
          );
        } else {
          // If no user is signed in, navigate to WelcomePage
          return const WelcomePage();
        }
      },
    );
  }
}
