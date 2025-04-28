import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  // FlutterLocalNotificationsPlugin instance
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Queue to store the notifications to be processed
  final List<Map<String, dynamic>> _notificationQueue = [];

  // A unique notification ID generator (starts from 1)
  int _notificationId = 1;

  // Set to store unique class times
  final Set<DateTime> _classTimesSet = {};

  // Flag to indicate if a notification is currently being processed
  bool _isProcessingQueue = false;

  // Constructor to initialize notifications
  NotificationService() {
    _initializeNotifications();
  }

  // Initialize the notification settings
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Function to add notification to the queue only if the classTime is not already present
  void addToNotificationQueue(String className, DateTime classTime) {
    bool alreadyExists = _classTimesSet.contains(classTime);

    if (!alreadyExists) {
      // Add the classTime to the Set and queue if it's not already there
      _classTimesSet.add(classTime);
      _notificationQueue.add({'className': className, 'classTime': classTime});
      print("Notification for $className at $classTime added to the queue.");

      // Only start processing the queue if it's not already being processed
      if (!_isProcessingQueue) {
        _processNotificationQueue();
      }
    } else {
      print("Notification for $className at $classTime is already in the queue.");
    }
  }

  // Function to process notifications in the queue
  Future<void> _processNotificationQueue() async {
    if (_notificationQueue.isEmpty || _isProcessingQueue) return; // Stop if queue is empty or already processing

    // Mark that the queue is being processed
    _isProcessingQueue = true;

    while (_notificationQueue.isNotEmpty) {
      // Extract the first notification in the queue
      final notificationData = _notificationQueue.first;

      // Schedule the notification
      await scheduleClassNotification(
        notificationData['className'],
        notificationData['classTime'],
      );

      // Remove the notification from the queue after processing
      _notificationQueue.removeAt(0);
    }

    // Mark that the queue is no longer being processed
    _isProcessingQueue = false;
  }

  // Function to schedule a class notification with a unique ID
  Future<void> scheduleClassNotification(String className, DateTime classTime) async {
    print('Scheduling notification for $className at $classTime');
    final scheduledNotificationDateTime = classTime.subtract(const Duration(minutes: 5)); // Notify 5 minutes before the class
    print(scheduledNotificationDateTime);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      _notificationId++,  // Unique Notification ID for each call
      'Upcoming Class', // Notification title
      'You have $className class in 5 minutes', // Notification body
      tz.TZDateTime.from(scheduledNotificationDateTime, tz.local), // Scheduled time in the local timezone
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'class_channel', // Unique channel ID
          'Class Notifications', // Channel name
          channelDescription: 'Notification to remind you about the class', // Channel description
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true, // Allow notification even when the phone is idle
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime, // Interpret the time as a wall clock time
      matchDateTimeComponents: DateTimeComponents.time, // Match only the time component for repeating notifications
    );
  }

  // Function to clear the notification queue
  Future<void> clearNotificationQueue() async {
    // Clear the notification queue and class times set
    _notificationQueue.clear();
    _classTimesSet.clear();

    // Cancel all scheduled notifications
    await _flutterLocalNotificationsPlugin.cancelAll();

    print("Notification queue cleared and all scheduled notifications canceled.");
  }

  // Test function to send multiple notifications using classScheduleList
  void testMultipleNotifications(List<Map<String, dynamic>> classScheduleList) {
    for (var classData in classScheduleList) {
      String className = classData['subject'];
      DateTime classTime = classData['dateTime'];

      // Add each class notification to the queue if it's not already there
      addToNotificationQueue(className, classTime);
    }
  }
}
