## ClassMate

**Smart Scheduling of Classes**  
An Android app to automate weekly class routine generation for the CSE Department at Leading University.

---

### 📖 Table of Contents

1. [Overview](#-overview)  
2. [Features](#-features)
3. [Tech Stack](#-tech-stack)  
4. [Download APK](#-download-apk)
5. [Usage](#-usage)  
6. [App Preview](#-app-preview)  
7. [Project Structure](#-project-structure)  
8. [Limitations & Future Work](#-limitations--future-work)  
9. [Contributors](#-contributors)  

---

### 🌟 Overview

Manual creation of university class schedules is time-consuming and error-prone, especially when balancing teacher availability, room assignments, and pre-fixed other routines.
**ClassMate** automates this process using a greedy algorithm to produce conflict-free weekly routines, with an admin interface for tweaks and OTP-secure login for users.

---

### 🚀 Features

- **Automated routine generation** using a greedy algorithm to allocate time-slots without conflicts while optimizing student workload balance (avoiding days with too many or too few classes).
- **Input via Excel**:  
  1. Course distribution (teacher assignments + day-offs)  
  2. Room availability  
  3. Fixed GED schedule  
  4. Batch & section info  
- **Admin panel** to review and manually adjust schedules.  
- **Teacher & student views** with weekly routine and class reminders.  
- **Secure OTP-based login** to protect data.  
- **Real-time backend** powered by Firebase.

---

### 🛠 Tech Stack

- **Flutter** (frontend)  
- **Dart** (business logic & greedy algorithm)  
- **Firebase** (realtime database, authentication)  
- **Excel file processing** for bulk input handling

---

### 📥 Download APK

You can install the latest ClassMate Android build directly:

[Download the APK](https://drive.google.com/file/d/1OamQ184axKycCmrUFNbxKOQ4m_PiLVjT/view?usp=drive_link)

> **Note:** You may need to enable “Install unknown apps” in your device settings.

---

### 👻 Usage

1. **Admin** uploads the four Excel input files via the “Upload Data” screen.  
2. Tap **Generate Routine** to run the greedy-algorithm scheduler.  
3. Review the auto-generated timetable; drag-and-drop to resolve any edge-case conflicts.  
4. **Teachers/Students** log in via OTP to view their personalized weekly schedule and receive reminders.

---

### 📱 App Preview

![Picture 1](screenshots/pic1.png)  

![Picture 2](screenshots/pic2.png)  

![Picture 3](screenshots/pic3.png)  

![Picture 4](screenshots/pic4.png)  

---

### 📁 Project Structure

```
lib/
├── main.dart            # App entry point
├── models/              # Data models: Teacher, Room, Batch, GED
├── services/            # Firebase, Excel-parser, Scheduler logic
├── ui/
│   ├── admin/           # Admin screens (upload, review)
│   └── user/            # Teacher & student screens
└── utils/               # Helper functions (OTP, notifications)
android/                 # Android native config (including google-services.json)
screenshots/             # UI screenshots referenced in README
```

---

### ⚠️ Limitations & Future Work

- Currently tailored to CSE Department, Leading University. Porting requires re-configuring constraints.  
- Requires stable internet (Firebase-backed).  
- Edge-case room/teacher changes may need manual fixes.  

**Planned enhancements:**  
- Scalability across departments/institutions  
- Offline mode for schedule viewing  
- Exam scheduling, AI-based optimization  
- Deeper integration with university MIS & push-notifications  

---

### 👥 Contributors

- **Muhammad Nadim** (ID: 2122020018)  
- **Abu Sufian Rafi** (ID: 2122020041)  
- **Abid Hussen** (ID: 2122020052)  

Supervised by Dipta Chandra Paul, Department of CSE, Leading University.
