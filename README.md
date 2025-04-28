## ClassMate

**Smart Scheduling of Classes**  
An Android app to automate weekly class routine generation for the CSE Department at Leading University.

---

### 📖 Table of Contents

1. [Overview](#overview)  
2. [Features](#features)  
3. [Tech Stack](#tech-stack)  
4. [Getting Started](#getting-started)  
   - [Prerequisites](#prerequisites)  
   - [Installation](#installation)  
   - [Running the App](#running-the-app)  
5. [Usage](#usage)  
6. [Project Structure](#project-structure)  
7. [Limitations & Future Work](#limitations--future-work)  
8. [Contributors](#contributors)  
9. [License](#license)  

---

### 🌟 Overview

Manual creation of university class schedules is time-consuming and error-prone, especially when balancing teacher availability, room assignments, and fixed General Education (GED) slots.  
**ClassMate** automates this process using a greedy algorithm to produce conflict-free weekly routines, with an admin interface for tweaks and OTP-secure login for users.

---

### 🚀 Features

- **Automated routine generation** using a greedy algorithm to allocate time-slots without conflicts.  
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
- **Firebase** (real-time database, authentication)  
- **Excel file processing** for bulk input handling

---

### 🏁 Getting Started

#### Prerequisites

- Flutter SDK ≥ 3.x  
- Android Studio (or VS Code + Android toolchain)  
- A Firebase project with Realtime Database & Authentication enabled  

#### Installation

1. **Clone** this repo  
   ```bash
   git clone https://github.com/<your-username>/ClassMate.git
   cd ClassMate
