import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'generate_department_routine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart'; // For getting the directory
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

File? saveExcelFile;
bool isGenerated = false;

class GeneratedRoutinePage extends StatefulWidget {
  final List<List<List<String>>> routineData;  // Accept 3D list

  GeneratedRoutinePage({required this.routineData});

  @override
  _GeneratedRoutinePageState createState() => _GeneratedRoutinePageState();
}

class _GeneratedRoutinePageState extends State<GeneratedRoutinePage> {
  // Example to create Map<String, int> from routineData
  Map<String, int> cntDayBatchSection = {};

  @override
  void initState() {
    super.initState();

    cntDayBatchSection.clear();
    for (int d = 0; d < totDay; d++) {
      if (mpDays[d.toString()] == "FRIDAY") {
        totSlot = timePeriod.tpFriday.length ~/ 2;
      } else {
        totSlot = timePeriod.tp.length ~/ 2;
      }

      for (int bs = 0; bs < totBatchSection; bs++) {
        for (int ts = 0; ts < totSlot; ts++) {
          if (routine[d][bs][ts].isNotEmpty) {
            cntDayBatchSection[mpBatchSection[bs.toString()]!] = (cntDayBatchSection[mpBatchSection[bs.toString()]] ?? 0) + 1;
            break;
          }
        }
      }
    }
    // cntDayBatchSection.forEach((key, value) {
    //   print('$key => $value');
    // });
    cntDayBatchSection = Map.fromEntries(
      cntDayBatchSection.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)),
    );
    createAndDownloadExcel(routine, false); // <===
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Generated Routine',
          style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      headingRowColor: MaterialStateColor.resolveWith((states) => Colors.indigo),
                      columns: [
                        DataColumn(
                          label: Text(
                            'Batch-Section',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Class Per Week',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                      rows: cntDayBatchSection.entries.map((entry) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                entry.key,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            DataCell(
                              Center(
                                child: Text(
                                  entry.value.toString(),
                                  textAlign: TextAlign.center, // Center the text
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _openData,
                  child: Text(
                    'Open',
                    style: TextStyle(fontSize: 18, color: Colors.deepPurple, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white70,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _saveData,
                  child: Text(
                    'Save to Database',
                    style: TextStyle(fontSize: 18, color: Colors.deepPurple, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white70,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openData() {
    // Add your open logic here
    print("Open button pressed");
    createAndDownloadExcel(routine, true); // for Excel Sheet
  }

  void _saveData() {
    // Add your save logic here
    print("Save button pressed");
    createAndDownloadExcel(routine, false); // for Excel Sheet
    if(isGenerated) {
      readExcelAndUploadToFirebase(saveExcelFile!);
      // mySnackBar("Successfully Saved", context);
      Get.snackbar("Successful", "Successfully Saved", snackPosition: SnackPosition.BOTTOM);
    }
    else {
      Get.snackbar("Error", "Failed", snackPosition: SnackPosition.BOTTOM);
    }
  }
}

// Function to set middle alignment (both vertically and horizontally)
void _setMiddleAlignment(xlsio.Worksheet sheet, int row, int col) {
  // Set horizontal and vertical alignment to center
  var range = sheet.getRangeByIndex(row, col);
  range.cellStyle.hAlign = xlsio.HAlignType.center;
  range.cellStyle.vAlign = xlsio.VAlignType.center;
}

Future<void> createAndDownloadExcel(List<List<List<String>>> routine, bool open) async { // Output Excel
  // Request storage permission
  PermissionStatus status = await Permission.storage.request();

  if (status.isGranted) {
    try {
      // Create a new Excel workbook
      final xlsio.Workbook workbook = xlsio.Workbook();

      List<String> seqDay = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      for (var day in seqDay) {
        final xlsio.Worksheet sheet;
        if(day == 'Sunday') {
          sheet = workbook.worksheets[0];
          sheet.name = day; // Rename the default sheet
        }
        else sheet = workbook.worksheets.addWithName(day);

        // Merge the first column
        sheet.getRangeByIndex(1, 1, totBatchSection + 1, 1).merge();
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
            sheet.getRangeByIndex(1, col).setText(timePeriod.tpFriday[s.toString()] ?? '');  // Safeguard null
          } else {
            sheet.getRangeByIndex(1, col).setText(timePeriod.tp[s.toString()] ?? '');  // Safeguard null
          }
          ++col;
        }

        int row = 2;
        for (var entry in fullInfoBatch.entries) {
          String batch = entry.key;

          List<String> sections = entry.value;
          for (String section in sections) {
            sheet.getRangeByIndex(row, 2).setText(batch);
            sheet.getRangeByIndex(row, 3).setText(section);
            col = 4;

            for (int s = 0; s < mxSlot; s++) {
              int d = int.tryParse(mpDays[day] ?? '') ?? -1;  // Handle potential null or invalid value
              if (d == -1) {
                print('Error: Day not found in mpDays');
                continue;
              }

              String bsKey = batch.trim() + section.trim();
              // print('bsKey = $bsKey, ${mpBatchSection[bsKey]}');
              int bs = int.tryParse(mpBatchSection[bsKey] ?? '') ?? -1;  // Handle potential null or invalid value
              if (bs == -1) {
                print('Error: Batch-Section not found in mpBatchSection');
                continue;
              }

              int slot = s;
              // print('d = $d, bs = $bs, slot = $slot == ${routine[d][bs][slot] ?? ''}');

              String value = routine[d][bs][slot] ?? '';  // Safeguard against null
              sheet.getRangeByIndex(row, col).setText(value);
              ++col;
            }
            ++row;
          }
        }
        adjustAllColumnsWidth(sheet, col, 23);
      }

      // print(seqDay);
      // fullInfoBatch.forEach((batch, students) {
      //   print('Batch: $batch');
      //   print('Students: ${students.join(', ')}');
      // });
      // // End

      // Save the workbook as a byte stream
      final List<int> bytes = workbook.saveAsStream();
      // No need to dispose of the workbook

      // Get the external storage directory
      final directory = await getExternalStorageDirectory();
      final String filePath = '${directory!.path}/Output.xlsx';

      // Write the file to storage
      final File file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      saveExcelFile = file; // for save the generate propose
      isGenerated = true;

      // Open the file after saving
      if(open) OpenFile.open(filePath);
    } catch (e) {
      print('Error creating or saving Excel file: $e');
    }
  } else if (status.isDenied) {
    print('Storage permission denied');
  } else if (status.isPermanentlyDenied) {
    openAppSettings();
  }
}

Future<void> readExcelAndUploadToFirebase(File excelFile) async {
  try {
    // Read the Excel file bytes
    var bytes = excelFile.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    Map<String, dynamic> excelData = {};

    // Iterate through each sheet
    for (var sheet in excel.tables.keys) {
      var table = excel.tables[sheet];

      List<Map<String, dynamic>> sheetData = [];
      if (table != null) {
        // Assuming first row is headers
        List<String?> headers = table.rows.first.map((cell) => cell?.value.toString()).toList();

        // Start iterating from the second row (index 1) for actual data
        for (var rowIndex = 1; rowIndex < table.rows.length; rowIndex++) {
          var row = table.rows[rowIndex];
          Map<String, dynamic> rowData = {};

          // Map each cell to the corresponding header
          for (var cellIndex = 0; cellIndex < row.length; cellIndex++) {
            var cell = row[cellIndex];
            var header = headers[cellIndex] ?? 'Column_$cellIndex';
            // Handle different cell types
            if (cell != null) {
              var value = cell.value;
              if (value is SharedString) {
                rowData[header] = value.toString(); // Convert SharedString to plain String
              } else if (value is DateTime) {
                rowData[header] = value.toIso8601String(); // Handle DateTime
              } else {
                rowData[header] = value.toInt(); // Store other values as they are
              }
            } else {
              rowData[header] = null; // Handle null cells
            }
          }

          sheetData.add(rowData); // Add row data as a map (object)
        }

        excelData[sheet] = sheetData; // Store sheet data in a map
      } else {
        print("Sheet $sheet is empty or null.");
      }
    }


    // Upload data to Firebase
    await FirebaseFirestore.instance
        .collection("FinalRoutine")
        .doc("FullRoutine")
        .set(excelData)
        .then((_) {
      print("Excel data successfully uploaded to Firebase!");
    }).catchError((error) {
      print("Error uploading data: $error");
    });
  } catch (e) {
    print("Error occurred: $e");
  }
}

