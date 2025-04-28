import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'generated_routine_page.dart';
// My code
List<List<Data?>>? _excelData1;
List<List<Data?>>? _excelData2;
List<List<Data?>>? _excelData3;
List<List<Data?>>? _excelData4;
Map<String, String> mpDays = {
  "THURSDAY": "0",
  "0": "THURSDAY",
  "FRIDAY": "1",
  "1": "FRIDAY",
  "SATURDAY": "2",
  "2": "SATURDAY",
  "SUNDAY": "3",
  "3": "SUNDAY",
  "MONDAY": "4",
  "4": "MONDAY",
  "TUESDAY": "5",
  "5": "TUESDAY",
  "WEDNESDAY": "6",
  "6": "WEDNESDAY"
};

class TimePeriod {
  int totTP = 9; // Total time periods
  Map<String, String> tp = {};
  Map<String, String> tpFriday = {};

  TimePeriod() {
    // Saturday to Thursday time periods
    tp["08:55-09:45AM"] = "0";
    tp["0"] = "08:55-09:45AM";
    tp["09:50-10:40AM"] = "1";
    tp["1"] = "09:50-10:40AM";
    tp["10:45-11:35AM"] = "2";
    tp["2"] = "10:45-11:35AM";
    tp["11:40-12:30PM"] = "3";
    tp["3"] = "11:40-12:30PM";
    tp["12:35-01:25PM"] = "4";
    tp["4"] = "12:35-01:25PM";
    tp["01:30-02:10PM"] = "5";
    tp["5"] = "01:30-02:10PM";
    tp["02:15-03:05PM"] = "6";
    tp["6"] = "02:15-03:05PM";
    tp["03:10-04:00PM"] = "7";
    tp["7"] = "03:10-04:00PM";
    tp["04:05-04:55PM"] = "8";
    tp["8"] = "04:05-04:55PM";

    // Friday time periods
    tpFriday["08:55-09:45AM"] = "0";
    tpFriday["0"] = "08:55-09:45AM";
    tpFriday["09:50-10:40AM"] = "1";
    tpFriday["1"] = "09:50-10:40AM";
    tpFriday["10:45-11:35AM"] = "2";
    tpFriday["2"] = "10:45-11:35AM";
    tpFriday["11:40-12:30PM"] = "3";
    tpFriday["3"] = "11:40-12:30PM";
    // Prayer Break and then resume periods
    tpFriday["02:15-03:05PM"] = "4";
    tpFriday["4"] = "02:15-03:05PM";
    tpFriday["03:10-04:00PM"] = "5";
    tpFriday["5"] = "03:10-04:00PM";
    tpFriday["04:05-04:55PM"] = "6";
    tpFriday["6"] = "04:05-04:55PM";
  }
}
TimePeriod timePeriod = TimePeriod(); // make a object

class Rooms {
  late List<List<List<String>>> generalRoom; // [day][slot]
  late List<List<List<String>>> labRoom; // [day][slot]
  Set<String> roomTypeG = {}, roomTypeL = {}; // for check general room, or lab room

  Rooms() {
    // Generate the room schedule based on TimePeriod
    generalRoom = List.generate(7, (_) => List.generate(timePeriod.totTP, (_) => []),);
    labRoom = List.generate(7, (_) => List.generate(timePeriod.totTP, (_) => []),);
  }

  // Populate roomTypeG and roomTypeL sets with room types
  void setGL() {
    for (var day in generalRoom) {
      for (var slot in day) {
        for (var room in slot) {
          roomTypeG.add(room);
        }
      }
    }

    for (var day in labRoom) {
      for (var slot in day) {
        for (var room in slot) {
          roomTypeL.add(room);
        }
      }
    }
  }
}
Rooms rooms = Rooms(); // make a object
// Function to set rooms
void setRoom(List<List<Data?>>? excelData) {
  // Full Time General and Lab rooms
  void setFT(String room, bool isLab) {
    for (int d = 0; d < 7; d++) {
      for (int t = 0; t < timePeriod.totTP; t++) {
        if (!isLab) {
          rooms.generalRoom[d][t].add(room);
        } else {
          rooms.labRoom[d][t].add(room);
        }
      }
    }
  }

  // Part-Time room setter
  void setPT(String room, String day, String slot, bool isLab) {
    int dayIndex = int.parse(mpDays[day] ?? "0");
    int timeSlot = 0;

    // Select time slot based on whether it's Friday or not
    if (day != "FRIDAY") {
      timeSlot = int.parse(timePeriod.tp[slot] ?? "0");
    } else {
      timeSlot = int.parse(timePeriod.tpFriday[slot] ?? "0");
    }

    // Assign room to either general or lab based on the flag
    if (!isLab) {
      rooms.generalRoom[dayIndex][timeSlot].add(room);
    } else {
      rooms.labRoom[dayIndex][timeSlot].add(room);
    }
  }

  for (int rowIndex = 1; rowIndex <= 2; rowIndex++) {
    List<Data?> row = excelData![rowIndex];
    if(rowIndex == 1) { // Full Time
      // Full Time General Rooms
      Data? cell = row[1];
      String? cellValue = cell?.value?.toString();
      List<String> words = cellValue!.split(',');
      for (String word in words) {
        word = word.replaceAll(RegExp(r'\s+'), '');  // Remove all whitespace
        // print(word); // <===
        setFT(word, false); // Set the room for generalRoom
      }

      // Full Time Lab Rooms
      cell = row[2];
      cellValue = cell?.value?.toString();
      words = cellValue!.split(',');
      for (String word in words) {
        word = word.replaceAll(RegExp(r'\s+'), '');  // Remove all whitespace
        // print(word); // <===
        setFT(word, true); // Set the room for labRoom
      }
    }
    else { // Part-Time
      // Part Time General Rooms
      Data? cell = row[1];
      String? cellValue = cell?.value?.toString();
      List<String> words = cellValue!.split(',');
      for (String word in words) {
        List<String> words2 = word.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
        words2[1] = words2[1].toUpperCase();
        setPT(words2[0], words2[1], words2[2], false); // (room, day, timeSlot, isLab)
      }

      // Part Time Lab Rooms
      cell = row[2];
      cellValue = cell?.value?.toString();
      words = cellValue!.split(',');
      for (String word in words) {
        List<String> words2 = word.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
        words2[1] = words2[1].toUpperCase();
        setPT(words2[0], words2[1], words2[2], true); // (room, day, timeSlot, isLab)
      }
    }
  }

  rooms.setGL(); // <== Temporary store all data for checking purpose
  return;
}

// Batch Section
class Batch {
  int batchNumber = 0;
  int totalSection = 0;
}
int totBatch = 0;
List<Batch> batch = [];
Map<String, String> mpBatchSection = {};
Map<String, List<String>> fullInfoBatch = {};
// Function for set batch-section
void setBatch(List<List<Data?>>? excelData) {
  int c = -1;
  for(int rowIndex = 1; rowIndex < excelData!.length; rowIndex++) {
    List<Data?> row = excelData[rowIndex];
    if(row[0]!.value.toString().isEmpty) continue;

    int b = row[0]?.value.toInt();
    Data? cell = row[1];
    String? cellValue = cell?.value?.toString();
    List<String> words = cellValue!.split(',');
    // print('------');
    // print(b);
    int sec = 0;
    for (String word in words) {
      word = word.replaceAll(RegExp(r'\s+'), ''); // Remove all whitespace
      // print(word); // <===
      String bs = b.toString() + word;
      sec = sec + 1;
      c = c + 1;
      mpBatchSection[bs] = c.toString();
      mpBatchSection[c.toString()] = bs;
    }

    // print(words);
    if (!fullInfoBatch.containsKey(b.toString())) {
      fullInfoBatch[b.toString()] = [];  // Initialize the list if it doesn't exist
    }
    fullInfoBatch[b.toString()]!.addAll(words);

    if (sec > 0) {
      Batch newBatch = Batch();
      newBatch.batchNumber = b;
      newBatch.totalSection = sec;
      batch.add(newBatch); // Add the new Batch object to the list
    }
  }

  // print('------');
  // print(mpBatchSection);
  // for(int i = 0; i < batch.length; i++) {
  //   print(batch[i].batchNumber);
  //   print(batch[i].totalSection);
  // }
  totBatchSection = mpBatchSection.length ~/ 2;
  routine = List.generate(totDay, (i) => List.generate(totBatchSection, (j) => List.generate(totSlot, (k) => "")));
  return;
}

class Teacher {
  String fullName = '';
  Set<int> offDays = {}; // 0 -> Thursday, 1 -> Friday ..., 6 -> Wednesday
}
Map<String, Teacher> teacherInfo = {};

class Course {
  String courseName = '';
  String courseCode = '';
  double courseCredit = 0.0;
  String batchSection = '';
  Course(this.courseName, this.courseCode, this.courseCredit, this.batchSection);
}
List<MapEntry<String, Course>> courseDistGeneral = []; // MapEntry => pair
List<MapEntry<String, Course>> courseDistLab = []; // [shortName][courseDetails]

void setCourseDistribution(List<List<Data?>>? excelData) {
  Map<String, String> mpCourseDetails = {};
  for (int rowIndex = 1; rowIndex < excelData!.length; rowIndex++) {
    List<Data?> row = excelData[rowIndex];
    String? shortName = row[0]?.value.toString();
    String? fullName = row[1]?.value.toString();
    String? offDays = row[2]?.value.toString();
    // print(shortName); // <==
    // print(fullName); // <==
    // print(offDays); // <==
    if(offDays != null && shortName != null && shortName != '***') {
      // teacherInfo["RMS"] = {"Rumel M. S. Rahman Pir", {1, 2}};
      Teacher tc = Teacher();
      tc.fullName = fullName!;

      List<String> words = offDays.split(',');
      for (String word in words) {
        word = word.replaceAll(RegExp(r'\s+'), ''); // Remove all whitespace
        word = word.toUpperCase();
        // print(word); // <===
        int d = int.parse(mpDays[word]!);
        tc.offDays.add(d);
      }
      teacherInfo[shortName] = tc;
    }
    // Course
    for(int colIndex = 3; colIndex < row.length; colIndex++) {
      Data? col = excelData[rowIndex][colIndex];
      String? sen = col?.value.toString();
      if(sen == null) continue;
      List<String> words = sen.split('@');
      // print(words); // <==
      // Course Code
      String courseCode = words[0].replaceAll(RegExp(r'\s+'), ''); // Remove all whitespace
      // Course Name
      String courseName = words[1].trim(); // trim => removes all leading and trailing whitespace
      mpCourseDetails[courseCode] = courseName;
      // Credit
      RegExp regExp = RegExp(r'(\d+\.\d+|\d+)'); // Regular expression to find a double in the string
      String? match = regExp.stringMatch(words[2]);
      double credit = double.parse(match!);
      // BatchSection
      List<String> batchSection = words[3].split(',');
      for (int i = 0; i < batchSection.length; i++) {
        batchSection[i] = batchSection[i].trim();  // Modify by reference
      }
      // print(courseCode);
      // print(courseName);
      // print(credit);
      // print(batchSection);
      if(credit <= 1.5) { // lab course
        for(var bs in batchSection) {
          Course course1 = Course(courseName, courseCode, credit, bs);
          courseDistLab.add(MapEntry(shortName!, course1));
        }
      }
      else { // theory course
        for(var bs in batchSection) {
          Course course1 = Course(courseName, courseCode, credit, bs);
          courseDistGeneral.add(MapEntry(shortName!, course1));
        }
      }
    }
  }

  // print('----');
  // teacherInfo.forEach((key, teacher) {
  //   print("Key: $key, Teacher Name: ${teacher.fullName}, Off Days: ${teacher.offDays}");
  // });
  // for (var entry in courseDistGeneral) {
  //   print('Name: ${entry.key}, Course Name: ${entry.value.courseName}, Course Code: ${entry.value.courseCode}, Credit: ${entry.value.courseCredit}, Batch Section: ${entry.value.batchSection}');
  // }
  // for (var entry in courseDistLab) {
  //   print('Name: ${entry.key}, Course Name: ${entry.value.courseName}, Course Code: ${entry.value.courseCode}, Credit: ${entry.value.courseCredit}, Batch Section: ${entry.value.batchSection}');
  // }

  // Storing the data in FireBase
  storeTeacherInfoInFirestore(teacherInfo);
  storeCourseDetails(mpCourseDetails);
  return;
}

// Convert teacherInfo to a Map<String, String> and store it in Firestore
Future<void> storeTeacherInfoInFirestore(Map<String, Teacher> teacherInfo) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Convert teacherInfo to mpInfo (Map<String, String>)
  Map<String, String> mpInfo = {};
  for (var t in teacherInfo.entries) {
    mpInfo[t.key] = t.value.fullName;
  }

  // Store the entire mpInfo map as a document in Firestore
  await firestore.collection('teacherNames').doc('shortNameToFullNameMap').set(mpInfo);
}

Future<void> storeCourseDetails(Map<String, String> mpCourseDetails) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  await firestore.collection('courses').doc('courseCodeToCourseName').set(mpCourseDetails);
}


// GED
int totDay = 7;
int totBatchSection = (mpBatchSection.length ~/ 2);
int totSlot = (timePeriod.tp.length ~/ 2);

List<List<List<String>>> routine = List.generate(
    totDay,
        (i) => List.generate(
        totBatchSection,
            (j) => List.generate(totSlot, (k) => "")
    )
);

List<List<Set<String>>> roomAllocated = List.generate(
    totDay, (i) => List.generate(totSlot, (j) => <String>{})
);

List<List<Set<String>>> batchSectionAllocated = List.generate(
    totDay,
        (i) => List.generate(totSlot, (j) => <String>{})
);

List<List<Set<String>>> teacherAllocated = List.generate(
    totDay,
        (i) => List.generate(totSlot, (j) => <String>{})
);

void setGEDRoutine(List<List<Data?>>? excelData) {
  // print(roomAllocated);
  // print(timePeriod.tp);
  totBatchSection = (mpBatchSection.length ~/ 2);
  List<Data?> r0 = excelData![0];
  List<String> slots = r0.map((data) => data?.value.toString() ?? "").toList();
  // print(slots); // <===
  for (int rowIndex = 1; rowIndex < excelData.length; rowIndex++) {
    List<Data?> row = excelData[rowIndex];
    List<String> values = row.map((data) => data?.value.toString() ?? "").toList();
    if(values[0].isEmpty) continue;
    values[0] = values[0].toUpperCase();
    int d = int.parse(mpDays[values[0]]!); // Days
    for (int colIndex = 1; colIndex < row.length; colIndex++) {
      // print('rowIndex = $rowIndex, colIndex = $colIndex');
      // if(values[colIndex] == null) continue;
      List<String> words = values[colIndex].split(',');
      for(int i = 0; i < words.length; i++) { // extra begin and end space erase
        words[i] = words[i].trim();
      }
      // print(words); // <====
      for(var word in words) {
        List<String> words2 = word.split(RegExp(r'\s+')); // multiple space split
        if(words2.length != 3) continue;
        // print(words2); // <===
        // print('${mpBatchSection[words2[2]]}');
        int bs = int.parse(mpBatchSection[words2[2]]!);
        int slot = int.parse(timePeriod.tp[slots[colIndex]]!);

        // print(words2);
        // print('day = $d, batchSection = $bs, slot = $slot');

        // Assign to routine
        routine[d][bs][slot] = words2[0] + ' ' + words2[1];// "GED-1262 ACL-1";
        // print('ok393');
        // Allocate room, batch, and section
        roomAllocated[d][slot].add(words2[1]);
        // print('ok396');
        batchSectionAllocated[d][slot].add(words2[2]);
        // Remove room if exists
        String rm = words2[1];
        // print('ok398');
        var it = rooms.generalRoom[d][slot].indexOf(rm);
        if (it != -1) {
          rooms.generalRoom[d][slot].removeAt(it);
        } else {
          it = rooms.labRoom[d][slot].indexOf(rm);
          if (it != -1) {
            rooms.labRoom[d][slot].removeAt(it);
          }
        }
        // print('ok408');
      }
    }
    // print('End of Row $rowIndex');
  }
  // print(routine); // <==
  return;
}

class Pair { // Helper class for Pair<int, int> in C++
  int first = 0;
  int second = 0;

  Pair(this.first, this.second);
}
// Main Algo
bool createRoutine() {
  // print('totalDay $totDay');
  // print('totalBatchSection $totBatchSection');
  // print('totSlot $totSlot');
  // print(roomAllocated);
  int seed = DateTime.now().millisecondsSinceEpoch; // Get current time for seed
  var rng = Random(seed); // Using secure random number generator

  List<List<String>> tmpCDG = [];
  List<List<String>> tmpCDL = [];

  for (var entry in courseDistGeneral) {
    int cls = entry.value.courseCredit.toInt(); // access courseCredit from the value
    while (cls-- > 0) {
      tmpCDG.add([
        entry.key, // teacherShortName (MapEntry key)
        entry.value.courseCode, // Course Code (MapEntry value)
        entry.value.batchSection // Batch Section (MapEntry value)
      ]);
    }
  }
  for (var entry in courseDistLab) {
    tmpCDL.add([
      entry.key, // teacherShortName (MapEntry key)
      entry.value.courseCode, // Course Code (MapEntry value)
      entry.value.batchSection // Batch Section (MapEntry value)
    ]);
    tmpCDL.add([
      entry.key, // teacherShortName (MapEntry key)
      entry.value.courseCode, // Course Code (MapEntry value)
      entry.value.batchSection // Batch Section (MapEntry value)
    ]);
    if (entry.value.courseCredit > 1.00) {
      tmpCDL.add([
        entry.key, // teacherShortName (MapEntry key)
        entry.value.courseCode, // Course Code (MapEntry value)
        entry.value.batchSection // Batch Section (MapEntry value)
      ]);
    }
  }
  // for(var vv in tmpCDG) print(vv);
  // for(var vv in tmpCDL) print(vv);

  // Loop over each day of the week (0-6)
  for (int d1 = 0; d1 < 7; d1++) {
    // Loop over each teacher and their off days
    teacherInfo.forEach((teacherAcronym, teacher) {
      for (int d2 in teacher.offDays) {
        if (d1 == d2) {
          int mxSlot;

          // If it's Friday, set the half-day slot limit using tpFriday, otherwise use tp for normal days
          if (mpDays[d1.toString()] == 'FRIDAY') {
            mxSlot = timePeriod.tpFriday.length ~/ 2;
          } else {
            mxSlot = timePeriod.tp.length ~/ 2;
          }

          // Allocate the teacher to off-day slots
          for (int slot = 0; slot < mxSlot; slot++) {
            teacherAllocated[d1][slot].add(teacherAcronym);
          }
        }
      }
    });
  }

  // Based on GED course
  List<List<bool>> fixedBatchSectionDay = List.generate(totDay, (d) => List.generate(totBatchSection, (bs) => false));

  for (int d = 0; d < totDay; d++) {
    for (int bs = 0; bs < totBatchSection; bs++) {
      int mxSlot;

      // Check if it's Friday
      if (mpDays[d.toString()] == "FRIDAY") {
        mxSlot = timePeriod.tpFriday.length ~/ 2; // Half the size
      } else {
        mxSlot = timePeriod.tp.length ~/ 2;
      }

      for (int slot = 0; slot < mxSlot; slot++) {
        if (routine[d][bs][slot].isNotEmpty) {
          fixedBatchSectionDay[d][bs] = true;
          break; // Exit the loop once condition is met
        }
      }
    }
  }
  // Main Code
  int totGClassHaveToAssign = tmpCDG.length;
  int totLClassHaveToAssign = tmpCDL.length;

  int perDayGeneralClass = (totGClassHaveToAssign / 6.3).toInt(); // <===
  int perFridayGeneralClass = totGClassHaveToAssign - (perDayGeneralClass * 6);

  int perDayLabClass = (totLClassHaveToAssign / 6.3).toInt(); // <===
  int perFridayLabClass = totLClassHaveToAssign - (perDayLabClass * 6);

  int res, NotPoss;
  for (int d = 0; d < totDay; d++) {
    String Dayy = d.toString();
    int tmp = 0;

    if (mpDays[Dayy] == "FRIDAY") {
      tmp = perFridayGeneralClass;
      totSlot = (timePeriod.tpFriday.length ~/ 2).toInt();
    } else {
      tmp = perDayGeneralClass;
      totSlot = (timePeriod.tp.length ~/ 2).toInt();
    }

    for (int slot = 0; slot < totSlot; slot++) {
      int perSlotClass = (tmp ~/ (totSlot - slot)).toInt();
      tmp -= perSlotClass;
      while (perSlotClass-- > 0) {
        int x = -1;
        int time = 500;
        while (time-- > 0) {
          int sz = tmpCDG.length;
          if (sz == 0) {
            time = -1;
            break;
          }
          x = rng.nextInt(sz);
          String nm = tmpCDG[x][0];
          String crs = tmpCDG[x][1];
          String bs = tmpCDG[x][2];
          if (batchSectionAllocated[d][slot].contains(bs)) continue;
          if (nm != "***" && teacherAllocated[d][slot].contains(nm)) continue;
          break;
        }

        if (time <= 0) {
          tmp += 1;
          continue;
        }

        String nm = tmpCDG[x][0];
        String crs = tmpCDG[x][1];
        String bs = tmpCDG[x][2];
        // print('$nm $crs $bs');
        if (nm == "***") {
          bool notGiven = true;
          if (x + 1 < tmpCDG.length && tmpCDG[x + 1][1] == crs && slot + 1 < totSlot) {
            if (!batchSectionAllocated[d][slot + 1].contains(bs)) {
              routine[d][int.parse(mpBatchSection[bs]!)][slot + 1] =
              "$crs $nm ";
              batchSectionAllocated[d][slot + 1].add(bs);
              teacherAllocated[d][slot + 1].add(nm);
              tmpCDG.removeAt(x + 1);
              notGiven = false;
            }
          }

          routine[d][int.parse(mpBatchSection[bs]!)][slot] = "$crs $nm ";
          batchSectionAllocated[d][slot].add(bs);
          teacherAllocated[d][slot].add(nm);
          tmpCDG.removeAt(x);

          if (notGiven && x - 1 >= 0 && tmpCDG[x - 1][1] == crs &&
              slot + 1 < totSlot) {
            if (!batchSectionAllocated[d][slot + 1].contains(bs)) {
              routine[d][int.parse(mpBatchSection[bs]!)][slot + 1] =
              "$crs $nm ";
              batchSectionAllocated[d][slot + 1].add(bs);
              teacherAllocated[d][slot + 1].add(nm);
              tmpCDG.removeAt(x - 1);
            }
          }
          continue;
        }
        int r = -1;
        time = 500;
        while (time-- > 0) {
          int sz = rooms.generalRoom[d][slot].length;
          if (sz == 0) {
            time = -1;
            break;
          }
          r = rng.nextInt(sz);
          if (roomAllocated[d][slot].contains(rooms.generalRoom[d][slot][r])) continue;
          break;
        }

        if (time <= 0) {
          tmp += 1;
          continue;
        }
        // print('r = $r -> ${rooms.generalRoom[d][slot][r]} mxSz = ${rooms.generalRoom[d][slot].length}, time = $time');

        bool notGiven = true;
        if (x + 1 < tmpCDG.length && tmpCDG[x + 1][1] == crs && slot + 1 < totSlot) {
          if (rooms.generalRoom[d][slot + 1].contains(rooms.generalRoom[d][slot][r])) {
            if (!roomAllocated[d][slot + 1].contains(rooms.generalRoom[d][slot][r])) {
              if (!teacherAllocated[d][slot + 1].contains(nm)) {
                if (!batchSectionAllocated[d][slot + 1].contains(bs)) {
                  routine[d][int.parse(mpBatchSection[bs]!)][slot + 1] = "$crs $nm ${rooms.generalRoom[d][slot][r]}";
                  roomAllocated[d][slot + 1].add(rooms.generalRoom[d][slot][r]);
                  batchSectionAllocated[d][slot + 1].add(bs);
                  teacherAllocated[d][slot + 1].add(nm);
                  tmpCDG.removeAt(x + 1);
                  rooms.generalRoom[d][slot + 1].remove(rooms.generalRoom[d][slot][r]);
                  notGiven = false;
                }
              }
            }
          }
        }
        routine[d][int.parse(mpBatchSection[bs]!)][slot] = "$crs $nm ${rooms.generalRoom[d][slot][r]}";
        roomAllocated[d][slot].add(rooms.generalRoom[d][slot][r]);
        batchSectionAllocated[d][slot].add(bs);
        teacherAllocated[d][slot].add(nm);
        tmpCDG.removeAt(x);
        // rooms.generalRoom[d][slot].removeAt(r);
        // print('x = $x, slot = $slot, r = $r');
        if (notGiven && x - 1 >= 0 && tmpCDG[x - 1][1] == crs && slot + 1 < totSlot) {
          if (rooms.generalRoom[d][slot + 1].contains(rooms.generalRoom[d][slot][r])) {
            if (!roomAllocated[d][slot + 1].contains(rooms.generalRoom[d][slot][r])) {
              if (!teacherAllocated[d][slot + 1].contains(nm)) {
                if (!batchSectionAllocated[d][slot + 1].contains(bs)) {
                  routine[d][int.parse(mpBatchSection[bs]!)][slot + 1] =
                  "$crs $nm ${rooms.generalRoom[d][slot][r]}";
                  roomAllocated[d][slot + 1].add(rooms.generalRoom[d][slot][r]);
                  batchSectionAllocated[d][slot + 1].add(bs);
                  teacherAllocated[d][slot + 1].add(nm);
                  tmpCDG.removeAt(x - 1);
                  rooms.generalRoom[d][slot + 1].remove(
                      rooms.generalRoom[d][slot][r]);
                }
              }
            }
          }
        }
        rooms.generalRoom[d][slot].removeAt(r);
      }
    }
  }

  NotPoss = 10000;
  while (tmpCDG.isNotEmpty && NotPoss-- > 0) {
    String nm = tmpCDG.last[0]; // teacherShortName
    String crs = tmpCDG.last[1]; // CourseCode
    String bs = tmpCDG.last[2]; // batchSection
    // print('nm = $nm, crs = $crs, bs = $bs');
    int d = rng.nextInt(7);
    String Dayy = d.toString();
    int totSlot = (mpDays[Dayy] == "FRIDAY") ? (timePeriod.tpFriday.length ~/ 2).toInt() : (timePeriod.tp.length ~/ 2).toInt();

    for (int slot = 0; slot < totSlot; slot++) {
      if (batchSectionAllocated[d][slot].contains(bs)) continue;
      if (nm != "***" && teacherAllocated[d][slot].contains(nm)) continue;

      if (nm == "***") {
        routine[d][int.parse(mpBatchSection[bs]!)][slot] = '$crs $nm ';
        batchSectionAllocated[d][slot].add(bs);
        teacherAllocated[d][slot].add(nm);
        tmpCDG.removeLast();
        break;
      }

      if (rooms.generalRoom[d][slot].isEmpty) continue;

      int r = -1;
      int time = 500;
      while (time-- > 0) {
        int sz = rooms.generalRoom[d][slot].length;
        if (sz == 0) {
          time = -1;
          break;
        }
        r = rng.nextInt(sz);
        if (roomAllocated[d][slot].contains(rooms.generalRoom[d][slot][r])) continue;
        break;
      }

      if (time <= 0) continue;

      routine[d][int.parse(mpBatchSection[bs]!)][slot] =
      '$crs $nm ${rooms.generalRoom[d][slot][r]}';
      roomAllocated[d][slot].add(rooms.generalRoom[d][slot][r]);
      batchSectionAllocated[d][slot].add(bs);
      teacherAllocated[d][slot].add(nm);
      tmpCDG.removeLast();
      rooms.generalRoom[d][slot].removeAt(r);
      break;
    }
  }

  if (tmpCDG.isNotEmpty) {
    // print("General Room Allocation Not Possible :)");
    return false;
  }

  /// ===> for Lab Class ///
  for (int d = 0; d < totDay; d++) {
    String Dayy = d.toString();
    int tmp = 0;
    int totSlot = 0;

    if (mpDays[Dayy] == "FRIDAY") {
      tmp = perFridayLabClass;
      totSlot = (timePeriod.tpFriday.length ~/ 2).toInt();
    } else {
      tmp = perDayLabClass;
      totSlot = (timePeriod.tp.length ~/ 2).toInt();
    }

    for (int slot = 0; slot < totSlot; slot++) {
      int perSlotClass = tmp ~/ (totSlot - slot);
      tmp -= perSlotClass;

      while (perSlotClass-- > 0) {
        int x = -1;
        int time = 500;

        while (time-- > 0) {
          int sz = tmpCDL.length;
          if (sz == 0) {
            time = -1;
            break;
          }
          x = rng.nextInt(sz);
          String nm = tmpCDL[x][0]; // teacherShortName
          String crs = tmpCDL[x][1]; // CourseCode
          String bs = tmpCDL[x][2]; // batchSection

          if (batchSectionAllocated[d][slot].contains(bs)) continue;
          if (nm != "***" && teacherAllocated[d][slot].contains(nm)) continue;
          break;
        }

        if (time <= 0) {
          tmp += 1;
          continue;
        }

        String nm = tmpCDL[x][0];
        String crs = tmpCDL[x][1];
        String bs = tmpCDL[x][2];

        if (nm == "***") {
          bool notGiven = true;
          if (x + 1 < tmpCDL.length && tmpCDL[x + 1][1] == crs && slot + 1 < totSlot) {
            if (!batchSectionAllocated[d][slot + 1].contains(bs)) {
              routine[d][int.parse(mpBatchSection[bs]!)][slot + 1] = "$crs $nm ";
              batchSectionAllocated[d][slot + 1].add(bs);
              teacherAllocated[d][slot + 1].add(nm);
              tmpCDL.removeAt(x + 1);
              notGiven = false;
            }
          }

          routine[d][int.parse(mpBatchSection[bs]!)][slot] = "$crs $nm ";
          batchSectionAllocated[d][slot].add(bs);
          teacherAllocated[d][slot].add(nm);
          tmpCDL.removeAt(x);

          if (notGiven &&
              x - 1 >= 0 &&
              tmpCDL[x - 1][1] == crs &&
              slot + 1 < totSlot) {
            if (!batchSectionAllocated[d][slot + 1].contains(bs)) {
              routine[d][int.parse(mpBatchSection[bs]!)][slot + 1] = "$crs $nm ";
              batchSectionAllocated[d][slot + 1].add(bs);
              teacherAllocated[d][slot + 1].add(nm);
              tmpCDL.removeAt(x - 1);
            }
          }
          continue;
        }

        int r = -1;
        time = 500;

        while (time-- > 0) {
          int sz = rooms.labRoom[d][slot].length;
          if (sz == 0) {
            time = -1;
            break;
          }
          r = rng.nextInt(sz);
          if (roomAllocated[d][slot].contains(rooms.labRoom[d][slot][r])) continue;
          break;
        }

        if (time <= 0) {
          tmp += 1;
          continue;
        }

        bool notGiven = true;
        if (x + 1 < tmpCDL.length && tmpCDL[x + 1][1] == crs && slot + 1 < totSlot) {
          var itRoom = rooms.labRoom[d][slot + 1].indexOf(rooms.labRoom[d][slot][r]);
          if (itRoom != -1 &&
              !roomAllocated[d][slot + 1].contains(rooms.labRoom[d][slot][r]) &&
              !teacherAllocated[d][slot + 1].contains(nm) &&
              !batchSectionAllocated[d][slot + 1].contains(bs)) {
            routine[d][int.parse(mpBatchSection[bs]!)][slot + 1] = "$crs $nm ${rooms.labRoom[d][slot][r]}";
            roomAllocated[d][slot + 1].add(rooms.labRoom[d][slot][r]);
            batchSectionAllocated[d][slot + 1].add(bs);
            teacherAllocated[d][slot + 1].add(nm);
            tmpCDL.removeAt(x + 1);
            rooms.labRoom[d][slot + 1].removeAt(itRoom);
            notGiven = false;
          }
        }

        routine[d][int.parse(mpBatchSection[bs]!)][slot] = "$crs $nm ${rooms.labRoom[d][slot][r]}";
        roomAllocated[d][slot].add(rooms.labRoom[d][slot][r]);
        batchSectionAllocated[d][slot].add(bs);
        teacherAllocated[d][slot].add(nm);
        tmpCDL.removeAt(x);
        // rooms.labRoom[d][slot].removeAt(r);

        if (notGiven && x - 1 >= 0 && tmpCDL[x - 1][1] == crs && slot + 1 < totSlot) {
          var itRoom = rooms.labRoom[d][slot + 1].indexOf(rooms.labRoom[d][slot][r]);
          if (itRoom != -1 &&
              !roomAllocated[d][slot + 1].contains(rooms.labRoom[d][slot][r]) &&
              !teacherAllocated[d][slot + 1].contains(nm) &&
              !batchSectionAllocated[d][slot + 1].contains(bs)) {
            routine[d][int.parse(mpBatchSection[bs]!)][slot + 1] = "$crs $nm ${rooms.labRoom[d][slot][r]}";
            roomAllocated[d][slot + 1].add(rooms.labRoom[d][slot][r]);
            batchSectionAllocated[d][slot + 1].add(bs);
            teacherAllocated[d][slot + 1].add(nm);
            tmpCDL.removeAt(x - 1);
            rooms.labRoom[d][slot + 1].removeAt(itRoom);
          }
        }
        rooms.labRoom[d][slot].removeAt(r);
      }
    }
  }

  NotPoss = 10000;
  while (tmpCDL.isNotEmpty && NotPoss-- > 0) {
    String nm = tmpCDL.last[0]; // teacherShortName
    String crs = tmpCDL.last[1]; // CourseCode
    String bs = tmpCDL.last[2]; // batchSection

    int d = rng.nextInt(7);
    String dayy = d.toString();
    int totSlot = (mpDays[dayy] == 'FRIDAY') ? (timePeriod.tpFriday.length ~/ 2) : (timePeriod.tp.length ~/ 2);

    for (int slot = 0; slot < totSlot; slot++) {
      if (batchSectionAllocated[d][slot].contains(bs)) continue;
      if (nm != '***' && teacherAllocated[d][slot].contains(nm)) continue;

      if (nm == '***') {
        routine[d][int.parse(mpBatchSection[bs]!)][slot] = '$crs $nm ';
        batchSectionAllocated[d][slot].add(bs);
        teacherAllocated[d][slot].add(nm);
        tmpCDL.removeLast();
        break;
      }

      if (rooms.labRoom[d][slot].isEmpty) continue;

      int r = -1;
      int time = 500;
      while (time-- > 0) {
        int sz = rooms.labRoom[d][slot].length;
        if (sz == 0) {
          time = -1;
          break;
        }
        r = rng.nextInt(sz);
        if (roomAllocated[d][slot].contains(rooms.labRoom[d][slot][r])) continue;
        break;
      }
      if (time <= 0) continue;

      // valid
      routine[d][int.parse(mpBatchSection[bs]!)][slot] =
      '$crs $nm ${rooms.labRoom[d][slot][r]}';
      roomAllocated[d][slot].add(rooms.labRoom[d][slot][r]);
      batchSectionAllocated[d][slot].add(bs);
      teacherAllocated[d][slot].add(nm);
      tmpCDL.removeLast();
      rooms.labRoom[d][slot].removeAt(r);

      break;
    }
  }

  if (tmpCDL.isNotEmpty) {
    // print("Lab Room Allocation Not Possible :)");
    return false;
  }

  /// --- Optimize batchSection day --- ///
  List<List<Pair>> fixedDayClassCount = List.generate(totBatchSection, (_) => []);
  List<List<Pair>> nonFixedDayClassCount = List.generate(totBatchSection, (_) => []);

  for (int bs = 0; bs < totBatchSection; bs++) {
    for (int d = 0; d < 7; d++) {
      int cnt = 0;
      if (mpDays[d.toString()] == "FRIDAY") totSlot = timePeriod.tpFriday.length ~/ 2;
      else totSlot = timePeriod.tp.length ~/ 2;

      for (int slot = 0; slot < totSlot; slot++) {
        if (routine[d][bs][slot].isNotEmpty) cnt++;
      }

      if (fixedBatchSectionDay[d][bs]) {
        fixedDayClassCount[bs].add(Pair(cnt, d));
      } else {
        nonFixedDayClassCount[bs].add(Pair(cnt, d));
      }
    }

    fixedDayClassCount[bs].sort((a, b) => a.first.compareTo(b.first));
    nonFixedDayClassCount[bs].sort((a, b) => a.first.compareTo(b.first));
  }

  // optimized fixedDay batchSection
  for (int bs = 0; bs < totBatchSection; bs++) {
    int dayPerWeek = fixedDayClassCount[bs].length + nonFixedDayClassCount[bs].length;
    if (fixedDayClassCount[bs].isNotEmpty && nonFixedDayClassCount[bs].isNotEmpty && dayPerWeek > 5) {
      int pos = 0;
      for (pos = 0; pos < nonFixedDayClassCount[bs].length && pos < dayPerWeek - 5; pos++) {
        int d = nonFixedDayClassCount[bs][pos].second;
        if (mpDays[d.toString()] == "FRIDAY") totSlot = timePeriod.tpFriday.length ~/ 2;
        else totSlot = timePeriod.tp.length ~/ 2;

        for (int slot = 0; slot < totSlot; slot++) {
          if (routine[d][bs][slot].isNotEmpty) {
            List<String> tmp = routine[d][bs][slot].split(' ');
            if(tmp.length < 2) continue;
            String crs = tmp[0];
            String nm = tmp[1];
            String rm = tmp.length == 3 ? tmp[2] : '';

            bool ok = true;
            for (int pos2 = 0; pos2 < fixedDayClassCount[bs].length && ok; pos2++) {
              int d2 = fixedDayClassCount[bs][pos2].second;
              int tmpTotSlot = mpDays[d2.toString()] == "FRIDAY" ? timePeriod.tpFriday.length ~/ 2 : timePeriod.tp.length ~/ 2;

              for (int slot2 = 0; slot2 < tmpTotSlot; slot2++) {
                if (!batchSectionAllocated[d2][slot2].contains(mpBatchSection[bs.toString()])) {
                  if (rm.isEmpty) {
                    routine[d2][bs][slot2] = routine[d][bs][slot];
                    batchSectionAllocated[d2][slot2].add(mpBatchSection[bs.toString()]!);
                    routine[d][bs][slot] = '';
                    batchSectionAllocated[d][slot].remove(mpBatchSection[bs.toString()]);
                    fixedDayClassCount[bs][pos2].first++;
                    nonFixedDayClassCount[bs][pos].first--;
                    ok = false;
                    break;
                  }

                  if (!teacherAllocated[d2][slot2].contains(nm)) {
                    bool op = rooms.roomTypeL.contains(rm) ? false : true;
                    int r = -1;
                    int time = 100;

                    while (time-- > 0) {
                      int sz;
                      if (op) {
                        sz = rooms.generalRoom[d2][slot2].length;
                      } else {
                        sz = rooms.labRoom[d2][slot2].length;
                      }
                      if (sz == 0) {
                        time = -1;
                        break;
                      }
                      r = rng.nextInt(sz);

                      if (op && roomAllocated[d2][slot2].contains(rooms.generalRoom[d2][slot2][r])) continue;
                      if (!op && roomAllocated[d2][slot2].contains(rooms.labRoom[d2][slot2][r])) continue;
                      break;
                    }
                    if (time <= 0) continue;
                    if (op) {
                      routine[d2][bs][slot2] = '$crs $nm ${rooms.generalRoom[d2][slot2][r]}';
                      roomAllocated[d2][slot2].add(rooms.generalRoom[d2][slot2][r]);
                    } else {
                      routine[d2][bs][slot2] = '$crs $nm ${rooms.labRoom[d2][slot2][r]}';
                      roomAllocated[d2][slot2].add(rooms.labRoom[d2][slot2][r]);
                    }
                    batchSectionAllocated[d2][slot2].add(mpBatchSection[bs.toString()]!);
                    teacherAllocated[d2][slot2].add(nm);
                    routine[d][bs][slot] = '';
                    batchSectionAllocated[d][slot].remove(mpBatchSection[bs.toString()]);
                    roomAllocated[d][slot].remove(rm);
                    teacherAllocated[d][slot].remove(nm);
                    if (op) {
                      rooms.generalRoom[d][slot].add(rm);
                    } else {
                      rooms.labRoom[d][slot].add(rm);
                    }

                    ok = false;
                    fixedDayClassCount[bs][pos2].first++;
                    nonFixedDayClassCount[bs][pos].first--;
                    break;
                  }
                }
              }
            }
          }
        }
      }
      nonFixedDayClassCount[bs].removeWhere((p) => p.first == 0);
    }
  }
  // optimized fixedDay batchSection
  for (int bs = 0; bs < totBatchSection; bs++) {
    int dayPerWeek = fixedDayClassCount[bs].length + nonFixedDayClassCount[bs].length;
    if (dayPerWeek > 5) {
      int mx = dayPerWeek - 5;
      for (int pos = 0; pos < mx; pos++) {
        int d = nonFixedDayClassCount[bs][pos].second;
        if (mpDays[d.toString()] == "FRIDAY") {
          totSlot = timePeriod.tpFriday.length ~/ 2;
        } else {
          totSlot = timePeriod.tp.length ~/ 2;
        }
        for (int slot = 0; slot < totSlot; slot++) {
          if (routine[d][bs][slot].isNotEmpty) {
            List<String> tmp = []; // {courseCode, teacherName, Room}
            tmp = routine[d][bs][slot].split(' ');

            String crs = tmp[0]; // CourseCode
            String nm = tmp[1]; // teacherShortName
            String rm = ""; // room
            if (tmp.length == 3) {
              // CSE subject
              rm = tmp[2];
            }

            bool ok = true;
            for (int pos2 = mx; pos2 < nonFixedDayClassCount[bs].length && ok; pos2++) {
              int d2 = nonFixedDayClassCount[bs][pos2].second;
              int tmpTotSlot;
              if (mpDays[d2.toString()] == "FRIDAY") {
                tmpTotSlot = timePeriod.tpFriday.length ~/ 2;
              } else {
                tmpTotSlot = timePeriod.tp.length ~/ 2;
              }
              for (int slot2 = 0; slot2 < tmpTotSlot; slot2++) {
                // => Check batchSection free and teacher free. Then Find Room
                // Check BatchSection
                if (batchSectionAllocated[d2][slot2].contains(mpBatchSection[bs.toString()])) continue;
                if (rm.isEmpty) {
                  // other department subject
                  // Set
                  routine[d2][bs][slot2] = routine[d][bs][slot];
                  batchSectionAllocated[d2][slot2].add(mpBatchSection[bs.toString()]!);
                  // Clear
                  routine[d][bs][slot] = "";
                  batchSectionAllocated[d][slot].remove(mpBatchSection[bs.toString()]);
                  ok = false;
                  nonFixedDayClassCount[bs][pos2].first += 1;
                  nonFixedDayClassCount[bs][pos].first -= 1;
                  break;
                }
                // Check Teacher
                if (teacherAllocated[d2][slot2].contains(nm)) continue;

                // Find Room
                int r = -1;
                int time = 100;
                bool op = true; // generalRoom = 1, labRoom = 0;
                if (rooms.roomTypeL.contains(rm)) op = false;
                while (time-- > 0) {
                  int sz;
                  if (op) {
                    sz = rooms.generalRoom[d2][slot2].length;
                  } else {
                    sz = rooms.labRoom[d2][slot2].length;
                  }
                  if (sz == 0) {
                    time = -1;
                    break;
                  }
                  r = rng.nextInt(sz);
                  if (op == true && roomAllocated[d2][slot2].contains(rooms.generalRoom[d2][slot2][r])) continue;
                  if (op == false && roomAllocated[d2][slot2].contains(rooms.labRoom[d2][slot2][r])) continue;
                  break;
                }
                if (time <= 0) continue;

                // => Set
                if (op) {
                  routine[d2][bs][slot2] = "$crs $nm ${rooms.generalRoom[d2][slot2][r]}";
                  roomAllocated[d2][slot2].add(rooms.generalRoom[d2][slot2][r]);
                } else {
                  routine[d2][bs][slot2] = "$crs $nm ${rooms.labRoom[d2][slot2][r]}";
                  roomAllocated[d2][slot2].add(rooms.labRoom[d2][slot2][r]);
                }
                batchSectionAllocated[d2][slot2].add(mpBatchSection[bs.toString()]!);
                teacherAllocated[d2][slot2].add(nm);

                // => Clear
                routine[d][bs][slot] = "";
                batchSectionAllocated[d][slot].remove(mpBatchSection[bs.toString()]);
                roomAllocated[d][slot].remove(rm);
                teacherAllocated[d][slot].remove(nm);
                if (op) {
                  rooms.generalRoom[d][slot].add(rm);
                } else {
                  rooms.labRoom[d][slot].add(rm);
                }

                ok = false;
                nonFixedDayClassCount[bs][pos2].first += 1;
                nonFixedDayClassCount[bs][pos].first -= 1;
                break;
              }
            }
          }
        }
      }
    }
  }
  return true;
}

void reset() {
  totDay = 7;
  totSlot = timePeriod.totTP;
  rooms = Rooms();
  batch.clear();
  mpBatchSection.clear();
  fullInfoBatch.clear();
  teacherInfo.clear();
  courseDistGeneral.clear();
  courseDistLab.clear();
  // routine = List.generate(totDay, (i) => List.generate(totBatchSection, (j) => List.generate(totSlot, (k) => "")));
  roomAllocated = List.generate(totDay, (i) => List.generate(totSlot, (j) => <String>{}));
  batchSectionAllocated = List.generate(totDay, (i) => List.generate(totSlot, (j) => <String>{}));
  teacherAllocated = List.generate(totDay, (i) => List.generate(totSlot, (j) => <String>{}));
}

Future<void> printPerWeekClass(List<List<List<String>>> routine) async {
  // Print Cnt of Per week class
  Map<String, int> cntDayBatchSection = {};
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

}

// Function to show a SnackBar
mySnackBar(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

// Function to pick Excel file using file_picker
Future<File?> _pickExcelFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['xlsx', 'xls'],
  );

  if (result != null) {
    return File(result.files.single.path!);
  }
  return null;
}

// Function to read Excel file content using excel package
Future<List<List<Data?>>?> _readExcel(File file) async {
  var bytes = file.readAsBytesSync();
  var excel = Excel.decodeBytes(bytes);
  return excel.sheets.values.first.rows;
}

void adjustAllColumnsWidth(xlsio.Worksheet sheet, int totalColumns, double width) {
  for (int i = 1; i <= totalColumns; i++) {
    sheet.getRangeByIndex(1, i).columnWidth = width;
  }
}

// Function to output the excel file in console
Future<void> displayExcel(List<List<Data?>>? excelData) async {
  if (excelData == null) return;

  for (int rowIndex = 0; rowIndex < excelData.length; rowIndex++) {
    List<Data?> row = excelData[rowIndex];
    for (int colIndex = 0; colIndex < row.length; colIndex++) {
      Data? cell = row[colIndex];
      print(cell?.value ?? 'null');
    }
    print('End of Row $rowIndex');
  }
}
// End Code

// Future<void> readExcelAndUploadToFirebase(File excelFile) async {
//   var bytes = excelFile.readAsBytesSync();
//   var excel = Excel.decodeBytes(bytes);
//
//   Map<String, dynamic> excelData = {};
//
//   // Iterate through each sheet
//   for (var sheet in excel.tables.keys) {
//     var table = excel.tables[sheet];
//
//     List<List<dynamic>> sheetData = [];
//     // Read rows
//     for (var row in table!.rows) {
//       List<dynamic> rowData = row.map((cell) => cell?.value).toList();
//       sheetData.add(rowData);
//     }
//
//     excelData[sheet] = sheetData; // Store sheet data in a map
//   }
//
//   // Upload data to Firebase
//   await FirebaseFirestore.instance.collection("FinalRoutine").doc("FCHbqyBcRNfaWnuqMYls").set(excelData);
// }

Future<List<List<String>>> fetchExcelDataFromFirebase() async {
  try {
    // Fetch the document from Firestore
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("FinalRoutine")
        .doc("FullRoutine")
        .get();

    // Check if the document exists and has data
    if (documentSnapshot.exists) {
      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;

      // Print the fetched data for debugging
      // print("Fetched data from Firestore: $data");

      // Initialize an empty 3D list
      // List<List<List<dynamic>>> excelData3D = [];
      List<List<String>> MyData = [];
      // Iterate through each sheet in the Firestore document
      data.forEach((sheetName, sheetData) {
        // List<List<dynamic>> sheetRows = [];

        // Debug: Print the type of sheetData
        // print("Sheet: $sheetName, Type of sheetData: ${sheetData.runtimeType}");

        if (sheetData is List<dynamic>) {
          for (var row in sheetData) {
            // print("Processing row: $row, Type of row: ${row.runtimeType}");
            // If row is a map, convert it to a list of its values
            if (row is Map<String, dynamic>) {
              // Convert the map's key-value pairs to the "key @ value" format with the required condition
              List<String> rowValues = row.entries
                  .where((e) {
                // Check if the key ends with AM/PM (case insensitive) and if the value is not null
                String key = e.key.toLowerCase();
                if ((key.endsWith('am') || key.endsWith('pm')) && (e.value == null || e.value.trim().length == 0)) {
                  return false;  // Skip this entry
                }
                return true;  // Include this entry
              })
                  .map((e) => "${e.key} @ ${e.value}")
                  .toList();

              // Add the filtered and formatted row values to MyData
              MyData.add(rowValues);
            }
            // If row is already a list, add it directly
            else if (row is List<dynamic>) {
              // Convert the List<dynamic> to List<String>
              List<String> rowValues = row.map((e) => e.toString()).toList();

              // Add the converted row values to MyData
              MyData.add(rowValues);
            } else {
              print("Unexpected row type: $row");
            }
          }
        } else {
          print("Unexpected sheetData type: $sheetData");
        }

        // Add the sheetRows (sheet) to excelData3D
        // excelData3D.add(sheetRows);
      });

      // Return the 3D list containing all the sheets, rows, and cell data
      // return excelData3D;
      return MyData;
    } else {
      print("Document does not exist.");
      return [];
    }
  } catch (e) {
    print("Error fetching data: $e");
    return [];
  }
}


bool ok1 = false, ok2 = false, ok3 = false, ok4 = false;
class GenerateDepartmentRoutinePage extends StatefulWidget {
  const GenerateDepartmentRoutinePage({Key? key}) : super(key: key);

  @override
  _GenerateDepartmentRoutinePageState createState() => _GenerateDepartmentRoutinePageState();
}
class _GenerateDepartmentRoutinePageState extends State<GenerateDepartmentRoutinePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Generate Routine",
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

      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.purpleAccent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // const Text(
              //   "Department Routine Generator",
              //   style: TextStyle(
              //     fontSize: 28,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.white,
              //   ),
              // ),
              const SizedBox(height: 100),

              // Button 1: Room Info
              _buildGorgeousButton(
                label: "Room Info",
                onPressed: () async {
                  // Navigate to Room Info
                  File? file = await _pickExcelFile();
                  if (file != null) {
                    var data = await _readExcel(file);

                    setState(() {
                      _excelData1 = data;
                      ok1 = true;
                    });


                    // displayExcel(data); // <== Console Based display
                    // mySnackBar("Room Info Excel File Read Successfully!", context);
                    Get.snackbar("Successful", "Room Info Excel File Read Successfully!", snackPosition: SnackPosition.BOTTOM);
                  } else {
                    // mySnackBar("No File Selected!", context);
                    Get.snackbar("Error", "No File Selected!", snackPosition: SnackPosition.BOTTOM);
                  }
                },
                colors: [Colors.green, Colors.lightGreenAccent],
                icon: Icons.upload,
                textColor: Colors.black,
                isWide: true, // Add this flag
              ),
              const SizedBox(height: 20),

              // Button 2: Batch & Section Info
              _buildGorgeousButton(
                label: "Batch & Section Info",
                onPressed: () async {
                  // Navigate to Batch & Section Info
                  File? file = await _pickExcelFile();
                  if (file != null) {
                    var data = await _readExcel(file);

                    setState(() {
                      _excelData2 = data;
                      ok2 = true;
                    });

                    // displayExcel(data); // <== Console Based display
                    // mySnackBar("Batch and Section Info Excel File Read Successfully!", context);
                    Get.snackbar("Successful", "Batch and Section Info Excel File Read Successfully!", snackPosition: SnackPosition.BOTTOM);
                  } else {
                    // mySnackBar("No File Selected!", context);
                    Get.snackbar("Error", "No File Selected!", snackPosition: SnackPosition.BOTTOM);
                  }
                },
                colors: [Colors.blueAccent, Colors.lightBlueAccent],
                icon: Icons.upload,
                textColor: Colors.black,
                isWide: true, // Add this flag
              ),
              const SizedBox(height: 20),

              // Button 3: Course Distribution
              _buildGorgeousButton(
                label: "Course Distribution",
                onPressed: () async {
                  // Navigate to Course Distribution
                  File? file = await _pickExcelFile();
                  if (file != null) {
                    var data = await _readExcel(file);

                    setState(() {
                      _excelData4 = data;
                      ok4 = true;
                    });

                    // displayExcel(data); // <== Console Based display
                    // mySnackBar("Course Distribution Excel File Read Successfully!", context);
                    Get.snackbar("Successful", "Course Distribution Excel File Read Successfully!", snackPosition: SnackPosition.BOTTOM);
                  } else {
                    // mySnackBar("No File Selected!", context);
                    Get.snackbar("Error", "No File Selected!", snackPosition: SnackPosition.BOTTOM);
                  }
                },
                colors: [Colors.purpleAccent, Colors.deepPurpleAccent],
                icon: Icons.upload,
                textColor: Colors.black,
                isWide: true, // Add this flag
              ),
              const SizedBox(height: 20),

              // Button 4: GED Routine
              _buildGorgeousButton(
                label: "GED Routine",
                onPressed: () async {
                  // Navigate to GED Routine
                  File? file = await _pickExcelFile();
                  if (file != null) {
                    var data = await _readExcel(file);
                    setState(() {
                      _excelData3 = data;
                      ok3 = true;
                    });
                    // displayExcel(data); // <== Console Based display
                    // mySnackBar("GED Routine Excel File Read Successfully!", context);
                    Get.snackbar("Successful", "GED Routine Excel File Read Successfully!", snackPosition: SnackPosition.BOTTOM);
                  } else {
                    // mySnackBar("No File Selected!", context);
                    Get.snackbar("Error", "No File Selected!", snackPosition: SnackPosition.BOTTOM);
                  }
                },
                colors: [Colors.cyan, Colors.lightBlueAccent],
                icon: Icons.upload,
                textColor: Colors.black,
                isWide: true, // Add this flag
              ),
              const SizedBox(height: 70),

              // Button 5: Generate
              _buildGorgeousButton(
                label: "Generate",
                onPressed: () {
                  // Perform Generate action
                  if(ok1 == true && ok2 == true && ok3 == true && ok4 == true) {
                    // reset(); // <===
                    // print('Building Room...');
                    // setRoom(_excelData1);
                    // print('Building BatchSection...');
                    // setBatch(_excelData2);
                    // print('Building CourseDistribution...');
                    // setCourseDistribution(_excelData4);
                    // print('Building GED Routine...');
                    // setGEDRoutine(_excelData3);
                    //
                    // print('----Build Success----');
                    // Creating a SplayTreeMap (sorted by keys)
                    SplayTreeMap<String, List<List<List<String>>>> mp = SplayTreeMap();
                    int time = 100;
                    while(time-- > 0) {
                      reset(); // <===
                      setRoom(_excelData1);
                      setBatch(_excelData2);
                      setCourseDistribution(_excelData4);
                      setGEDRoutine(_excelData3);

                      if(createRoutine()) {
                        Map<String, int> cntDayBatchSection = {};
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
                        String str = '';
                        cntDayBatchSection.forEach((key, value) {
                          str += value.toString();
                        });

                        // String Reverse sort
                        List<String> charList = str.split(''); // Sort the list in reverse order using the `sort` method and a custom comparator
                        charList.sort((a, b) => b.compareTo(a)); // Join the sorted list back into a String
                        str = charList.join('');

                        mp[str] = routine;
                      }
                    }

                    if(mp.isEmpty)  {
                      // mySnackBar("There is some issues in files :(", context);
                      Get.snackbar("Error", "There is some issues in files :(", snackPosition: SnackPosition.BOTTOM);
                    }
                    else {
                      // mySnackBar("Successful!", context);
                      Get.snackbar("Successful", "Routine Generated Successfully.", snackPosition: SnackPosition.BOTTOM);
                      routine = mp[mp.firstKey()!]!;
                      // printPerWeekClass(routine);
                      // createAndDownloadExcel(routine); // for Excel Sheet
                      // Navigate to the GeneratedRoutinePage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GeneratedRoutinePage(routineData: routine),
                        ),
                      );
                    }
                  }
                  else {
                    // mySnackBar("Not Successful! Push all the data", context);
                    Get.snackbar("Error", "Push all the data", snackPosition: SnackPosition.BOTTOM);
                  }
                },
                colors: [Colors.orange, Colors.deepOrangeAccent],
                icon: Icons.calendar_today,
                textColor: Colors.indigo,
                isWide: false, // Narrower button for Generate
              ),

              const SizedBox(height: 20),

              _buildGorgeousButton(
                label: "Update",
                onPressed: () async {
                  // Pick the Excel file
                  File? file = await _pickExcelFile();
                  if (file != null) {
                    await readExcelAndUploadToFirebase(file);  // Wait for the file to be uploaded
                    Get.snackbar("Successful", "Routine Uploaded Successfully in Database.", snackPosition: SnackPosition.BOTTOM);
                  } else {
                    // mySnackBar("No File Selected!", context);
                    Get.snackbar("Error", "No File Selected!", snackPosition: SnackPosition.BOTTOM);
                  }

                  // Fetch the uploaded data from Firebase
                  var val = await fetchExcelDataFromFirebase();  // Await the fetch

                  // if (val == null || val.isEmpty) {
                  //   print("No data found!");
                  // } else {
                  //   print("Here we go Hurreh.");
                  //   // print("Fetched data: $val");
                  // }
                },
                colors: [Colors.orange, Colors.deepOrangeAccent],
                icon: Icons.cloud_upload_outlined,
                textColor: Colors.redAccent,
                isWide: false, // Narrower button for Generate
              )

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGorgeousButton({
    required String label,
    required VoidCallback onPressed,
    required List<Color> colors,
    required IconData icon,
    required Color textColor,
    required bool isWide, // New parameter to control button width
  }) {
    return SizedBox(
      width: isWide ? 300 : 200, // Wider for the first four, narrower for Generate
      child: ElevatedButton.icon(
          icon: Icon(icon, size: 28, color: textColor),
          onPressed: onPressed,
          label: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              color: textColor,
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
            backgroundColor: null,
          )
      ),
    );
  }
}
