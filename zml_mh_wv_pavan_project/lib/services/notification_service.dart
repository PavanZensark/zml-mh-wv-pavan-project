import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/appointment_model.dart';
import '../models/medication_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    // Handle notification tap
    final payload = response.payload;
    if (payload != null) {
      // Parse payload and navigate to appropriate screen
      // This would be implemented based on your navigation structure
    }
  }

  Future<void> requestPermissions() async {
    // Request permissions for iOS
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Request permissions for Android 13+
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleAppointmentReminder(AppointmentModel appointment) async {
    // Schedule reminder 1 day before
    final reminderTime = appointment.appointmentDateTime.subtract(
      const Duration(days: 1),
    );

    if (reminderTime.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: appointment.id.hashCode,
        title: 'Appointment Reminder',
        body:
            'You have an appointment with ${appointment.doctorName} tomorrow at ${appointment.appointmentTime}',
        scheduledTime: reminderTime,
        payload: 'appointment_${appointment.id}',
      );
    }

    // Schedule reminder 1 hour before
    final hourBeforeTime = appointment.appointmentDateTime.subtract(
      const Duration(hours: 1),
    );

    if (hourBeforeTime.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: appointment.id.hashCode + 1,
        title: 'Appointment Soon',
        body: 'Your appointment with ${appointment.doctorName} is in 1 hour',
        scheduledTime: hourBeforeTime,
        payload: 'appointment_${appointment.id}',
      );
    }
  }

  Future<void> scheduleMedicationReminders(MedicationModel medication) async {
    final reminders = medication.getNextReminders();

    for (int i = 0; i < reminders.length; i++) {
      final reminderTime = reminders[i];

      await _scheduleNotification(
        id: medication.id.hashCode + i,
        title: 'Medication Reminder',
        body:
            'Time to take ${medication.medicationName} - ${medication.dosage}',
        scheduledTime: reminderTime,
        payload: 'medication_${medication.id}',
      );
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'zml_health_channel',
      'ZML Health Notifications',
      channelDescription: 'Notifications for health reminders',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      sound: 'default.wav',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      platformChannelSpecifics,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'zml_health_channel',
      'ZML Health Notifications',
      channelDescription: 'Notifications for health reminders',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      sound: 'default.wav',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelAppointmentReminders(String appointmentId) async {
    await cancelNotification(appointmentId.hashCode);
    await cancelNotification(appointmentId.hashCode + 1);
  }

  Future<void> cancelMedicationReminders(String medicationId) async {
    // Cancel multiple reminders (assuming max 4 per day)
    for (int i = 0; i < 4; i++) {
      await cancelNotification(medicationId.hashCode + i);
    }
  }
}
