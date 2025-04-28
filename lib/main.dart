import 'package:flutter/material.dart';
import 'package:routine_generator/All_Screens/auth_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize the timezone data
  tz.initializeTimeZones();
  runApp(
    const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: AuthCheck(),
      ),
    ),
  );
}
