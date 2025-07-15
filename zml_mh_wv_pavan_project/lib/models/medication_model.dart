import 'package:cloud_firestore/cloud_firestore.dart';

enum MedicationFrequency { once, twice, thrice, fourTimes, asNeeded }

class MedicationModel {
  final String id;
  final String userId;
  final String patientId;
  final String medicationName;
  final String dosage;
  final MedicationFrequency frequency;
  final List<String> timings; // e.g., ["08:00", "14:00", "20:00"]
  final DateTime startDate;
  final DateTime? endDate;
  final String? instructions;
  final String? prescribedBy;
  final bool isActive;
  final bool reminderEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicationModel({
    required this.id,
    required this.userId,
    required this.patientId,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.timings,
    required this.startDate,
    this.endDate,
    this.instructions,
    this.prescribedBy,
    this.isActive = true,
    this.reminderEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'patientId': patientId,
      'medicationName': medicationName,
      'dosage': dosage,
      'frequency': frequency.name,
      'timings': timings,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'instructions': instructions,
      'prescribedBy': prescribedBy,
      'isActive': isActive,
      'reminderEnabled': reminderEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MedicationModel.fromMap(Map<String, dynamic> map) {
    return MedicationModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      patientId: map['patientId'] ?? '',
      medicationName: map['medicationName'] ?? '',
      dosage: map['dosage'] ?? '',
      frequency: MedicationFrequency.values.firstWhere(
        (e) => e.name == map['frequency'],
        orElse: () => MedicationFrequency.once,
      ),
      timings: List<String>.from(map['timings'] ?? []),
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      instructions: map['instructions'],
      prescribedBy: map['prescribedBy'],
      isActive: map['isActive'] ?? true,
      reminderEnabled: map['reminderEnabled'] ?? true,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  factory MedicationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MedicationModel.fromMap(data);
  }

  String get frequencyDisplay {
    switch (frequency) {
      case MedicationFrequency.once:
        return 'Once daily';
      case MedicationFrequency.twice:
        return 'Twice daily';
      case MedicationFrequency.thrice:
        return 'Three times daily';
      case MedicationFrequency.fourTimes:
        return 'Four times daily';
      case MedicationFrequency.asNeeded:
        return 'As needed';
    }
  }

  List<DateTime> getNextReminders() {
    if (!reminderEnabled || !isActive) return [];

    final now = DateTime.now();
    final reminders = <DateTime>[];

    for (final timing in timings) {
      final timeParts = timing.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final reminderTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If time has passed today, schedule for tomorrow
      if (reminderTime.isBefore(now)) {
        reminders.add(reminderTime.add(const Duration(days: 1)));
      } else {
        reminders.add(reminderTime);
      }
    }

    return reminders;
  }
}

class MedicationLog {
  final String id;
  final String medicationId;
  final String patientId;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final bool taken;
  final String? notes;

  MedicationLog({
    required this.id,
    required this.medicationId,
    required this.patientId,
    required this.scheduledTime,
    this.takenTime,
    this.taken = false,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicationId': medicationId,
      'patientId': patientId,
      'scheduledTime': scheduledTime.toIso8601String(),
      'takenTime': takenTime?.toIso8601String(),
      'taken': taken,
      'notes': notes,
    };
  }

  factory MedicationLog.fromMap(Map<String, dynamic> map) {
    return MedicationLog(
      id: map['id'] ?? '',
      medicationId: map['medicationId'] ?? '',
      patientId: map['patientId'] ?? '',
      scheduledTime: DateTime.parse(map['scheduledTime']),
      takenTime:
          map['takenTime'] != null ? DateTime.parse(map['takenTime']) : null,
      taken: map['taken'] ?? false,
      notes: map['notes'],
    );
  }
}
