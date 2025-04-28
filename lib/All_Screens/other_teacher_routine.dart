import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage_admin_view.dart';

class OtherTeacherRoutine extends StatefulWidget {
  @override
  _RoutineInputPageState createState() => _RoutineInputPageState();
}

class _RoutineInputPageState extends State<OtherTeacherRoutine> {
  final TextEditingController _teacherAcronymController = TextEditingController();

  List<List<String>> routineData = [];

  @override
  void initState() {
    super.initState();
    _loadStoredData(); // Load stored Teacher Acronym
  }

  Future<void> _loadStoredData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? teacherAcronym = prefs.getString('teacherAcronym');

    if (teacherAcronym != null) {
      setState(() {
        _teacherAcronymController.text = teacherAcronym;
      });
    }
  }

  Future<void> _storeTeacherAcronym(String teacherAcronym) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('teacherAcronym', teacherAcronym);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Other Teacher Routine",
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  flex: 6,
                  child: TextField(
                    controller: _teacherAcronymController,
                    decoration: InputDecoration(
                      labelText: 'Teacher Acronym',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Flexible(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    child: Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: routineData.isNotEmpty
                  ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateColor.resolveWith((states) => Colors.teal.shade400),
                  columns: routineData[0]
                      .map((heading) => DataColumn(
                    label: Align(
                      alignment: Alignment.center,
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
                  rows: routineData.sublist(1).map((row) {
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
              )
                  : Center(
                child: Text(
                  'No data available',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final teacherAcronym = _teacherAcronymController.text.trim();

    if (teacherAcronym.isEmpty) {
      Get.snackbar('Error', 'Please enter a teacher acronym.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Store the teacher acronym for future use
    _storeTeacherAcronym(teacherAcronym);

    List<List<String>> myData = await getFullData();

    List<String> days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    List<String> slot = ['08:55-09:45AM', '09:50-10:40AM', '10:45-11:35AM', '11:40-12:30PM', '12:35-01:25PM', '01:30-02:10PM', '02:15-03:05PM', '03:10-04:00PM', '04:05-04:55PM'];

    Map<String, String> mp = {};
    String batch1 = '', section1 = '';
    // print(teacherAcronym);

    for (var row in myData) {
      String day = '';
      for (var col in row) {
        col = col.trim();
        if (col.isEmpty) continue;
        List<String> tmp = col.split(' @ ');
        tmp[0] = tmp[0].trim();
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

    setState(() {
      routineData = routine;
    });
  }
}
