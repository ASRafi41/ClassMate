import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'homepage_admin_view.dart'; // Assuming this import is necessary for the app

class OtherBatchSectionRoutine extends StatefulWidget {
  @override
  _RoutineInputPageState createState() => _RoutineInputPageState();
}

class _RoutineInputPageState extends State<OtherBatchSectionRoutine> {
  final TextEditingController _batchController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();

  List<List<String>> routineData = [];

  @override
  void initState() {
    super.initState();
    _loadStoredData(); // Load stored batch and section
  }

  Future<void> _loadStoredData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? batch = prefs.getString('batch');
    String? section = prefs.getString('section');

    if (batch != null && section != null) {
      setState(() {
        _batchController.text = batch;
        _sectionController.text = section;
      });
    }
  }

  Future<void> _storeBatchAndSection(String batch, String section) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('batch', batch);
    await prefs.setString('section', section);
  }

  Widget _buildBatchSectionField(String text) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black54),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStudentInfo(String batch, String section) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBatchSectionField('Batch: $batch'),
        SizedBox(width: 16),
        _buildBatchSectionField('Section: $section'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Other Batch-Section Routine",
          style: TextStyle(
            color: Colors.white,          // White text color
            fontSize: 20,                 // Larger font size
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
                  flex: 3,
                  child: TextField(
                    controller: _batchController,
                    decoration: InputDecoration(
                      labelText: 'Batch',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Flexible(
                  flex: 3,
                  child: TextField(
                    controller: _sectionController,
                    decoration: InputDecoration(
                      labelText: 'Section',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                SizedBox(width: 16),
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
            SizedBox(height: 20), // Added spacing between the form and the table
            if (routineData.isNotEmpty) _buildStudentInfo(_batchController.text, _sectionController.text),
            if (routineData.isNotEmpty) SizedBox(height: 20), // Spacing between batch/section info and the routine table
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
    final batch = _batchController.text.trim();
    final section = _sectionController.text.trim();

    if (batch.isEmpty || section.isEmpty) {
      Get.snackbar('Error', 'Please enter both batch and section.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Store batch and section for future use
    _storeBatchAndSection(batch, section);
    // print('batch $batch Section $section');
    List<List<String>> myData = await getFullData();

    List<String> days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    List<String> slot = ['08:55-09:45AM', '09:50-10:40AM', '10:45-11:35AM', '11:40-12:30PM', '12:35-01:25PM', '01:30-02:10PM', '02:15-03:05PM', '03:10-04:00PM', '04:05-04:55PM'];

    Map<String, String> mp = {};
    for (var row in myData) {
      bool ok1 = false, ok2 = false;
      String day = '';
      for (var col in row) {
        if (ok1 == true && ok2 == true && day.isNotEmpty) break;
        col = col.trim();
        if (col.isEmpty) continue;
        List<String> tmp = col.split(' @ ');
        tmp[0] = tmp[0].trim();
        tmp[1] = tmp[1].trim();
        if (tmp[0].toUpperCase() == 'BATCH') {
          if (batch == tmp[1]) {
            ok1 = true;
          }
        } else if (tmp[0].toUpperCase() == 'SECTION') {
          if (section == tmp[1]) {
            ok2 = true;
          }
        } else {
          for (var d in days) {
            if (d.toUpperCase() == tmp[0].toUpperCase()) {
              day = tmp[0].toUpperCase();
              break;
            }
          }
        }
      }
      if (!ok1 || !ok2) continue;

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

    setState(() {
      routineData = routine;
    });
  }
}
