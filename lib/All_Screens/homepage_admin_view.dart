import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart'; // For getting the directory
import 'package:routine_generator/All_Screens/developer_info.dart';
import 'package:routine_generator/All_Screens/settings_for_admin.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Auth UI Controller/global_variable.dart';
import '../Auth UI Controller/sign_up_and_login_controller.dart';
import '../Image/image.dart';
import 'generate_department_routine.dart';
import 'generated_routine_page.dart';
import 'login.dart';
import 'my_routine.dart';
import 'other_batch_section_routine.dart';
import 'other_teacher_routine.dart';

class HomePageAdminView extends StatelessWidget {
  final _auth = AuthService();
  final String? name, email;
  HomePageAdminView({super.key, required this.name, required this.email}){
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
                  backgroundImage: AssetImage('assets/profile_avatar.png'),
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
            _buildDrawerListTile(context, Icons.settings, "Settings", Colors.orange),
            _buildDrawerListTile(context, Icons.info, "Developer Info", Colors.green),
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
              //Add the logo image here
              // Image.asset(
              //   ImagesPath.mainLogo,  // Path to the image
              //   width: 150,  // Adjust size as needed
              //   height: 150,
              // ),
              const SizedBox(height: 30),  // Space between image and text
              const Text(
                "Welcome to ClassMate (Admin)",
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
                label: "Generate Department Routine",
                onPressed: () {
                  // Navigate to Generate Department Routine page
                  Get.to(() => const GenerateDepartmentRoutinePage());
                },
                colors: [Colors.green, Colors.lightGreenAccent],
                icon: Icons.auto_stories,
                textColor: Colors.black, // Updated text color for better visibility
              ),
              const SizedBox(height: 20),
              _buildGorgeousButton(
                label: "View Department Routine",
                onPressed: () {
                  // Navigate to View Department Routine
                  showDepartmentRoutineExcel();
                },
                colors: [Colors.purpleAccent, Colors.deepPurpleAccent],
                icon: Icons.schedule,
                textColor: Colors.black, // Updated text color for better visibility
              ),
              const SizedBox(height: 20),
              _buildGorgeousButton(
                label: "My Routines",
                onPressed: ()  {
                  // Navigate to My Routines
                  Get.to(() => MyRoutinePage());
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
                icon: Icons.view_list,
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
        if (label == "Settings") {
          Get.to(() => const SettingsPage());
        }
        else if(label == "Logout"){
          await _auth.signout();
          Get.offAll(() => const Login());  // Redirect to LoginPage after logout
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

Future<List<List<String>>> getFullData() async {
  List<List<String>> myData = await fetchExcelDataFromFirebase();
  return myData;
}

Future<void> showDepartmentRoutineExcel() async {
  List<List<String>> myData = await getFullData();
  // print(myData);

  List<String> days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  List<String> slot = ['08:55-09:45AM', '09:50-10:40AM', '10:45-11:35AM', '11:40-12:30PM', '12:35-01:25PM', '01:30-02:10PM', '02:15-03:05PM', '03:10-04:00PM', '04:05-04:55PM'];

  Map<String, String> mp = {};
  Map<String, Set<String>> batchSection = {};
  String batch1 = '', section1 = '';

  for (var row in myData) {
    String day = '';
    for (var col in row) {
      col = col.trim();
      if (col.isEmpty) continue;
      List<String> tmp = col.split(' @ ');
      if (tmp[0].toUpperCase() == 'BATCH') {
        batch1 = tmp[1].trim();
      }
      else if (tmp[0].toUpperCase() == 'SECTION') {
        section1 = tmp[1].trim();
      }
      else {
        for (var d in days) {
          if (d.toUpperCase() == tmp[0].toUpperCase()) {
            day = tmp[0].toUpperCase();
            break;
          }
        }
      }
    }
    batchSection.putIfAbsent(batch1, () => <String>{}); // Create a new set if batch1 doesn't exist
    batchSection[batch1]!.add(section1);
    for (var col in row) {
      col = col.trim();
      if (col.isEmpty) continue;
      List<String> tmp1 = col.split(' @ ');

      String slot = tmp1[0].trim().toUpperCase();
      if(slot.endsWith('AM') || slot.endsWith('PM')) {
        mp[day + slot + batch1 + section1] = tmp1[1].trim();
      }
    }
  }
  // print(mp);
  // Sort the keys and the sets after insertion
  batchSection = Map.fromEntries(
      batchSection.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key)) // Sort by keys
  ).map((key, value) => MapEntry(key, Set<String>.from(value.toList()..sort()))); // Sort values and convert back to Set
  // print(batchSection);

  int totBS = 0;
  for (var entry in batchSection.entries) {
    totBS += entry.value.length;
  }
  // --- createAndDownloadExcel --- //
  // Request storage permission
  PermissionStatus status = await Permission.storage.request();

  if (status.isGranted) {
    try {
      // Create a new Excel workbook
      final xlsio.Workbook workbook = xlsio.Workbook();

      for (var day in days) {
        final xlsio.Worksheet sheet;
        if(day == 'Sunday') {
          sheet = workbook.worksheets[0];
          sheet.name = day; // Rename the default sheet
        }
        else sheet = workbook.worksheets.addWithName(day);

        // Merge the first column
        sheet.getRangeByIndex(1, 1, totBS + 1, 1).merge();
        sheet.getRangeByIndex(1, 1).setText(day);  // Add text in the merged cell

        _setMiddleAlignment(sheet, 1, 1); // Set middle alignment for the cell

        // Set headers
        sheet.getRangeByIndex(1, 2).setText('Batch');
        sheet.getRangeByIndex(1, 3).setText('Section');

        day = day.toUpperCase();
        int mxSlot = (day == 'FRIDAY' ? 7 : 9), col = 4;

        // Set time period headers
        for (int s = 0; s < mxSlot; s++) {
          if (day == 'FRIDAY') {
            if(s <= 3) {
              sheet.getRangeByIndex(1, col).setText(slot[s]  ?? '');  // Safeguard null
            }
            else {
              sheet.getRangeByIndex(1, col).setText(slot[s + 2] ?? '');  // Safeguard null
            }
          } else {
            sheet.getRangeByIndex(1, col).setText(slot[s] ?? '');  // Safeguard null
          }
          ++col;
        }

        int row = 2;
        for (var entry in batchSection.entries) {
          String batch = entry.key;

          Set<String> sections = entry.value;
          for (String section in sections) {
            sheet.getRangeByIndex(row, 2).setText(batch);
            sheet.getRangeByIndex(row, 3).setText(section);
            col = 4;

            for (int s = 0; s < mxSlot; s++) {
              // String value = routine[d][bs][slot] ?? '';  // Safeguard against null
              String slot1 = '';
              if(day == 'FRIDAY') {
                if(s <= 3) {
                  slot1 = slot[s]  ?? '';  // Safeguard null
                }
                else {
                  slot1 = slot[s + 2] ?? '';  // Safeguard null
                }
              }
              else slot1 = slot[s]  ?? '';  // Safeguard null

              String? value = mp[day + slot1 + batch + section];

              sheet.getRangeByIndex(row, col).setText(value);
              ++col;
            }
            ++row;
          }
        }
        adjustAllColumnsWidth(sheet, col, 23);
      }

      // Save the workbook as a byte stream
      final List<int> bytes = workbook.saveAsStream();
      // No need to dispose of the workbook

      // Get the external storage directory
      final directory = await getExternalStorageDirectory();
      final String filePath = '${directory!.path}/Output.xlsx';

      // Write the file to storage
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      saveExcelFile = file; // for save the generate propose
      isGenerated = true;

      // Open the file after saving
      OpenFile.open(filePath);
      // print('Successful');
    } catch (e) {
      print('Error creating or saving Excel file: $e');
    }
  } else if (status.isDenied) {
    print('Storage permission denied');
  } else if (status.isPermanentlyDenied) {
    openAppSettings();
  }

  return;
}

// Function to set middle alignment (both vertically and horizontally)
void _setMiddleAlignment(xlsio.Worksheet sheet, int row, int col) {
  // Set horizontal and vertical alignment to center
  var range = sheet.getRangeByIndex(row, col);
  range.cellStyle.hAlign = xlsio.HAlignType.center;
  range.cellStyle.vAlign = xlsio.VAlignType.center;
}

void adjustAllColumnsWidth(xlsio.Worksheet sheet, int totalColumns, double width) {
  for (int i = 1; i <= totalColumns; i++) {
    sheet.getRangeByIndex(1, i).columnWidth = width;
  }
}
