import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';

class AuthService{
  final _auth = FirebaseAuth.instance;

  //for sign up
  Future<User?> createUserWithEmailAndPassword(String email,String password)async{
    try{
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return cred.user;
    }catch(e){
      log("Error : $e");
    }
    return null;
  }

  //for sign in
  Future<User?>  loginUserWithEmailAndPassword(String email,String password)async {
    // print(email);
    // print(password);
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        log('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        log('Wrong password provided for that user.');
      }
      else {
        log("Error : $e");
      }
      return null;
    }
  }

  //for log out
  Future<void>signout() async
  {
    try{
      await _auth.signOut();
    }catch(e)
    {
      log("Error : $e");
    }
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


}