import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:routine_generator/Auth%20UI%20Controller/global_variable.dart';
import '../Auth UI Controller/notification.dart';
import 'generate_department_routine.dart';

String batch = '', section = '', teacherAcronym = '';
bool isTeacher = false;
class MyRoutinePage extends StatefulWidget {
  @override
  _MyRoutinePageState createState() => _MyRoutinePageState();
}

class _MyRoutinePageState extends State<MyRoutinePage> {
  final _notficationService = NotificationService();

  List<List<String>> myRoutine = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();  // Call the async method here
  }
  //notification

  void scheduleRoutineNotification(String className, DateTime classTime) {
    // Schedule notification 5 minutes before classTime
    // DateTime notificationTime = classTime.subtract(Duration(minutes: 5));
    _notficationService.scheduleClassNotification(className, classTime);
  }
  //notification
  DateTime _convertToDateTime(String day, String timeSlot) {
    List<String> days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

    // Splitting the time range by '-'
    List<String> times = timeSlot.split('-');
    String startTime = times[0].trim(); // Use the start time and trim any spaces

    // Parse the time and convert to 24-hour format if necessary
    final timeRegex = RegExp(r'(\d{2}):(\d{2})(AM|PM)'); // Match hours, minutes, and AM/PM
    final match = timeRegex.firstMatch(startTime);
    if (match == null) {
      throw FormatException("Invalid time format: $startTime");
    }

    // Extract the time components
    int hour = int.parse(match.group(1)!);
    int minute = int.parse(match.group(2)!);
    String period = match.group(3)!;

    // Convert to 24-hour format
    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    // Get the current date and adjust it to the target day of the week
    DateTime now = DateTime.now();
    int dayIndex = days.indexOf(day);
    int todayIndex = now.weekday % 7; // Convert Flutter's weekday (Monday=1) to (Sunday=0)

    DateTime classDay = now.add(Duration(days: (dayIndex - todayIndex + 7) % 7));

    // Combine the date with the parsed time to create a DateTime object
    DateTime classTime = DateTime(classDay.year, classDay.month, classDay.day, hour, minute);

    // If the classTime has already passed, add 7 days to get the next week's time
    if (classTime.isBefore(now)) {
      classTime = classTime.add(Duration(days: 7));
    }

    return classTime;
  }

  //nofication

  Future<void> _fetchUserData() async {
    CollectionReference users = FirebaseFirestore.instance.collection('UserInfo');
    final querySnapshot = await users.where('Email', isEqualTo: FinalEmail).get();

    if (querySnapshot.docs.isNotEmpty) {
      final userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
      isTeacher = userData['is_teacher'] ?? "No Teacher";

      if (isTeacher == true) {
        setState(() {
          teacherAcronym = userData['Name Acronym'] ?? "No Acronym";
        });
        routineMakerTeacher();
        // Do something with teacherAcronym
      } else {
        setState(() {
          batch = userData['Batch'] ?? "No Batch";
          section = userData['Section'] ?? "No Section";
        });
        routineMakerStudent();
      }
    } else {
      Get.snackbar("Error", "User data not found", snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Soft light grey background
      appBar: AppBar(
        title: const Text(
          "Class Schedule",
          style: TextStyle(
            color: Colors.white,          // White text color
            fontSize: 23,                 // Larger font size
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

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Conditionally render based on whether the user is a teacher or a student
            isTeacher ? _buildTeacherInfo() : _buildStudentInfo(),

            SizedBox(height: 20),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : myRoutine.isNotEmpty
                ? _buildRoutineTable()
                : Center(child: Text('No data available')),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentInfo() {
    // This widget shows Batch and Section if the user is a student
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBatchSectionField('Batch: $batch'),
        SizedBox(width: 16),
        _buildBatchSectionField('Section: $section'),
      ],
    );
  }

  Widget _buildTeacherInfo() {
    // This widget shows "Class Routine of <Teacher's Acronym>" if the user is a teacher
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.teal.shade50, // Muted teal background
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Text(
        'Class Routine of $teacherAcronym',  // Display the teacher's acronym here
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.teal.shade900, // Dark teal for text
        ),
      ),
    );
  }


  Widget _buildBatchSectionField(String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.teal.shade50, // Muted teal background
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.teal.shade900, // Dark teal for text
        ),
      ),
    );
  }

  Widget _buildRoutineTable() {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              // borderRadius: BorderRadius.horizontal(),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  offset: Offset(3, 3),
                  blurRadius: 10,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: DataTable(
              headingRowColor: MaterialStateColor.resolveWith((states) => Colors.teal.shade400),
              columns: myRoutine[0]
                  .map((heading) => DataColumn(
                label: Align(
                  alignment: Alignment.center, // Center the header text
                  child: Text(
                    heading,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ))
                  .toList(),
              rows: myRoutine.sublist(1).map((row) {
                return DataRow(
                  cells: row.map((cell) {
                    return DataCell(
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: cell.isEmpty ? Colors.grey.shade100 : Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          cell,
                          style: TextStyle(
                            fontSize: 16,
                            color: cell.isEmpty ? Colors.grey.shade400 : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Future<List<List<String>>> getFullData() async {
    List<List<String>> myData = await fetchExcelDataFromFirebase();
    return myData;
  }

  Future<void> routineMakerStudent() async {

    List<List<String>> myData = await getFullData();

    List<String> days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    List<String> slot = ['08:55-09:45AM', '09:50-10:40AM', '10:45-11:35AM', '11:40-12:30PM', '12:35-01:25PM', '01:30-02:10PM', '02:15-03:05PM', '03:10-04:00PM', '04:05-04:55PM'];
    List<String> slot1 = ['08:55AM-09:45AM', '09:50AM-10:40AM', '10:45AM-11:35AM', '11:40AM-12:30PM', '12:35PM-01:25PM', '01:30PM-02:10PM', '02:15PM-03:05PM', '03:10PM-04:00PM', '04:05PM-04:55PM'];
    // List<String> temp = ['07:30PM-09:45AM', '07:30PM-10:40AM', '07:30PM-11:35AM', '07:30PM-12:30PM', '07:30PM-01:25PM', '07:30PM-02:10PM', '07:30PM-03:05PM', '07:30PM-04:00PM', '07:30PM-04:55PM'];

    // print(myData);

    Map<String, String> mp = {};
    for (var row in myData) {
      bool ok1 = false, ok2 = false;
      String day = '';
      for (var col in row) {
        if (ok1 == true && ok2 == true && day.isNotEmpty) break;
        col = col.trim();
        if (col.isEmpty) continue;
        List<String> tmp = col.split(' @ ');
        if (tmp[0].toUpperCase() == 'BATCH') {
          if (batch == tmp[1]) {
            ok1 = true;
          }
        }
        else if (tmp[0].toUpperCase() == 'SECTION') {
          if (section == tmp[1]) {
            ok2 = true;
          }
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
      if (ok1 == false || ok2 == false) continue;

      for (var col in row) {
        col = col.trim();
        if (col.isEmpty) continue;
        List<String> tmp = col.split(' @ ');
        if (slot.contains(tmp[0].trim())) {
          mp[day + tmp[0].trim()] = tmp[1].trim();
        }
      }
    }

    List<List<String>> routine = List.generate(
      days.length + 1, (i) => List.generate(slot.length + 1, (j) => ''),
    );

    routine[0][0] = 'Day/Time';
    for (int i = 0; i < slot.length; i++) {
      routine[0][i + 1] = '       ' + slot[i];
    }
    for (int i = 0; i < days.length; i++) {
      routine[i + 1][0] = days[i];
    }

    for (int i = 0; i < days.length; i++) {
      for (int j = 0; j < slot.length; j++) {
        String dd = days[i].toUpperCase();
        routine[i + 1][j + 1] = mp[dd + slot[j]] ?? '';
      }
    }



    List<Map<String, dynamic>> classScheduleList = []; // Create a list to store DateTime and subject
    for (int i = 0; i < days.length; i++) {
      for (int j = 0; j < slot.length; j++) {
        String subject = routine[i + 1][j + 1];
        List<String>temp = subject.split(' ');
        String sub = temp[0];
        if (subject.isNotEmpty) {
          String day = days[i];
          String timeSlot = slot1[i];
          DateTime classDateTime = _convertToDateTime(day, timeSlot);

          // Add the classDateTime and subject to the list as a map
          classScheduleList.add({
            'dateTime': classDateTime,
            'subject': sub,
          });
        }
      }
    }

    // // print(classDateTimeList);
    // NotificationService notificationService = NotificationService();
    // notificationService.clearNotificationQueue();
    // notificationService.testMultipleNotifications(classScheduleList);
    // // //end notification part

    setState(() {
      myRoutine = routine;
      isLoading = false;

      // print(classDateTimeList);
      NotificationService notificationService = NotificationService();
      notificationService.clearNotificationQueue();
      notificationService.testMultipleNotifications(classScheduleList);
      // //end notification part
    });
  }

  Future<void> routineMakerTeacher() async {
    List<List<String>> myData = await getFullData();

    List<String> days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    List<String> slot = ['08:55-09:45AM', '09:50-10:40AM', '10:45-11:35AM', '11:40-12:30PM', '12:35-01:25PM', '01:30-02:10PM', '02:15-03:05PM', '03:10-04:00PM', '04:05-04:55PM'];
    List<String> slot1 = ['08:55AM-09:45AM', '09:50AM-10:40AM', '10:45AM-11:35AM', '11:40AM-12:30PM', '12:35PM-01:25PM', '01:30PM-02:10PM', '02:15PM-03:05PM', '03:10PM-04:00PM', '04:05PM-04:55PM'];

    Map<String, String> mp = {};
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
      for (var col in row) {
        col = col.trim();
        if (col.isEmpty) continue;
        List<String> tmp1 = col.split(' @ ');
        for(var val in tmp1) {
          val.trim();
          List<String> tmp2 = val.split(' ');
          if(tmp2.length >= 2 && tmp2[1] == teacherAcronym) {
            mp[day + tmp1[0].trim()] = '${tmp2[0].trim()} $batch1$section1 ${tmp2[2].trim()}';
          }
        }
      }
    }
    List<List<String>> routine = List.generate(
      days.length + 1, (i) => List.generate(slot.length + 1, (j) => ''),
    );

    routine[0][0] = 'Day/Time';
    for (int i = 0; i < slot.length; i++) {
      routine[0][i + 1] = '       ' + slot[i];
    }
    for (int i = 0; i < days.length; i++) {
      routine[i + 1][0] = days[i];
    }

    for (int i = 0; i < days.length; i++) {
      for (int j = 0; j < slot.length; j++) {
        String dd = days[i].toUpperCase();
        routine[i + 1][j + 1] = mp[dd + slot[j]] ?? '';
      }
    }

    List<Map<String, dynamic>> classScheduleList = []; // Create a list to store DateTime and subject
    DateTime now = DateTime.now();

    for (int i = 0; i < days.length; i++) {
      for (int j = 0; j < slot.length; j++) {
        String subject = routine[i + 1][j + 1];
        List<String>temp = subject.split(' ');
        String sub = temp[0];
        if (subject.isNotEmpty) {
          String day = days[i];
          String timeSlot = slot1[j];
          DateTime classDateTime = _convertToDateTime(day, timeSlot);

          // Add the classDateTime and subject to the list as a map
          classScheduleList.add({
            'dateTime': classDateTime,
            'subject': sub,
          });
        }
      }
    }

    // // Now you have all the classDateTime values in classDateTimeList
    // // print(classDateTimeList);
    // NotificationService notificationService = NotificationService();
    // notificationService.clearNotificationQueue();
    // notificationService.testMultipleNotifications(classScheduleList);
    // //end notification part

    setState(() {
      myRoutine = routine;
      isLoading = false;

      // Now you have all the classDateTime values in classDateTimeList
      // print(classDateTimeList);
      NotificationService notificationService = NotificationService();
      notificationService.clearNotificationQueue();
      notificationService.testMultipleNotifications(classScheduleList);
      //end notification part
    });
  }
}


