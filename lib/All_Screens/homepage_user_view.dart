import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:routine_generator/All_Screens/my_routine.dart';
import 'package:routine_generator/All_Screens/profile_setting_page_user.dart';
import '../Auth UI Controller/global_variable.dart';
import '../Auth UI Controller/sign_up_and_login_controller.dart';
import 'developer_info.dart';
import 'homepage_admin_view.dart';
import 'login.dart';
import 'other_batch_section_routine.dart';
import 'other_teacher_routine.dart';

class HomePageUserView extends StatelessWidget {
  final _auth = AuthService();
  final String? name, email;
  HomePageUserView({super.key,this.name,this.email}){
    FinalEmail = email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ClassMate",
          style: TextStyle(
            color: Colors.white,          // White text color
            fontSize: 23,                 // Larger font size
            fontWeight: FontWeight.bold,  // Bold weight to make it stand out
            letterSpacing: 1.5,           // Add some spacing between the letters
            shadows: [
              Shadow(                      // Add a subtle shadow
                offset: Offset(2.0, 2.0),
                blurRadius: 3.0,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0, // Remove shadow
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


      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(name ?? "No Name",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  )),
              accountEmail: Text(email ?? "No Email",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  )),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 35,
                child: const CircleAvatar(
                  radius: 33,
                  backgroundImage: AssetImage('assets/profile_pic.png'),
                ),
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo, Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            _buildDrawerListTile(context, Icons.home, "Home", Colors.indigo),
            _buildDrawerListTile(context, Icons.settings, "Profile Settings", Colors.orange),
            _buildDrawerListTile(context, Icons.info, "Developer Info", Colors.green),
            // const Divider(), // Optional divider between other items and logout
            _buildDrawerListTile(context, Icons.logout, "Logout", Colors.red), // Logout option
          ],
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
              const Text(
                "Welcome to ClassMate",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Lobster', // Stylish font
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black45,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              _buildGorgeousButton(
                label: "My Routines",
                onPressed: () {
                  Get.to(MyRoutinePage());
                },
                colors: [Colors.cyan, Colors.lightBlueAccent],
                icon: Icons.list_alt,
                textColor: Colors.black, // Updated text color for better visibility
              ),
              const SizedBox(height: 20),
              _buildGorgeousButton(
                label: "All Batch-Section Routine",
                onPressed: ()  {
                  // Navigate to My Routines
                  Get.to(() => OtherBatchSectionRoutine());
                },
                colors: [Colors.cyan, Colors.lightBlueAccent],
                icon: Icons.list_alt,
                textColor: Colors.black, // Updated text color for better visibility
              ),
              const SizedBox(height: 20),
              _buildGorgeousButton(
                label: "All Teacher Routine",
                onPressed: ()  {
                  // Navigate to My Routines
                  Get.to(() => OtherTeacherRoutine());
                },
                colors: [Colors.cyan, Colors.lightBlueAccent],
                icon: Icons.list_alt,
                textColor: Colors.black, // Updated text color for better visibility
              ),
              const SizedBox(height: 20),
              _buildGorgeousButton(
                label: "View Department Routine", // Updated label
                onPressed: () {
                  // Navigate to View Department Routine
                  showDepartmentRoutineExcel();
                },
                colors: [Colors.purpleAccent, Colors.deepPurpleAccent],
                icon: Icons.schedule,
                textColor: Colors.black, // Updated text color for better visibility
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerListTile(BuildContext context, IconData icon, String label, Color iconColor) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
      onTap: () async {
        Navigator.pop(context);
        if (label == "Logout") {
          await _auth.signout();
          Get.offAll(() => const Login());
        }
        else if(label == "Profile Settings"){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileSettingsPageUser()),
          );
        }
        else if(label == "Developer Info"){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DeveloperInfoPage()),
          );
        }
      },
    );
  }

  Widget _buildGorgeousButton({
    required String label,
    required VoidCallback onPressed,
    required List<Color> colors,
    required IconData icon,
    required Color textColor, // New parameter for text color
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 28, color: textColor), // Updated icon color
        onPressed: onPressed,
        label: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            color: textColor, // Updated text color
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
          backgroundColor: null, // Button has gradient now
        ),
      ),
    );
  }
}
