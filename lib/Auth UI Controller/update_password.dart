import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class Updatepassword{

  Future<void> updateUserDataByEmail(String email, String? newPassword) async {
    log(email);
    try {

      CollectionReference users = FirebaseFirestore.instance.collection('UserInfo');
      final querySnapshot = await users.where('Email', isEqualTo: email).get();

      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document (should be one if emails are unique)
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        String docId = userDoc.id;
        if(newPassword != null){
          users.doc(docId).update({"Password" : newPassword});
        }
        else{
          log("newPassword is null.");
        }
      } else {
        log('No user found with that email');
      }
    } catch (e) {
      log('Error updating user data: $e');
    }
  }
}