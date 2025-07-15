import 'package:cloud_firestore/cloud_firestore.dart';

enum AppointmentStatus { scheduled, confirmed, cancelled, completed }

class AppointmentModel {
  final String id;
  final String userId;
  final String patientId;
  final String doctorName;
  final String doctorSpecialization;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String reason;
  final String? notes;
  final AppointmentStatus status;
  final String? location;
  final String? contactNumber;
  final bool reminderSet;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppointmentModel({
    required this.id,
    required this.userId,
    required this.patientId,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.reason,
    this.notes,
    required this.status,
    this.location,
    this.contactNumber,
    this.reminderSet = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'patientId': patientId,
      'doctorName': doctorName,
      'doctorSpecialization': doctorSpecialization,
      'appointmentDate': appointmentDate.toIso8601String(),
      'appointmentTime': appointmentTime,
      'reason': reason,
      'notes': notes,
      'status': status.name,
      'location': location,
      'contactNumber': contactNumber,
      'reminderSet': reminderSet,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      patientId: map['patientId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      doctorSpecialization: map['doctorSpecialization'] ?? '',
      appointmentDate: DateTime.parse(map['appointmentDate']),
      appointmentTime: map['appointmentTime'] ?? '',
      reason: map['reason'] ?? '',
      notes: map['notes'],
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AppointmentStatus.scheduled,
      ),
      location: map['location'],
      contactNumber: map['contactNumber'],
      reminderSet: map['reminderSet'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppointmentModel.fromMap(data);
  }

  String get statusDisplay {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Scheduled';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.completed:
        return 'Completed';
    }
  }

  DateTime get appointmentDateTime {
    // Parse time string and combine with date
    final timeParts = appointmentTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    return DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
      hour,
      minute,
    );
  }
}
