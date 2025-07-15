import 'package:cloud_firestore/cloud_firestore.dart';

enum BloodGroup {
  aPositive,
  aNegative,
  bPositive,
  bNegative,
  oPositive,
  oNegative,
  abPositive,
  abNegative
}

class HealthInfoModel {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;
  final BloodGroup bloodGroup;
  final double height; // in cm
  final double weight; // in kg
  final List<String> allergies;
  final List<String> medicalConditions;
  final String? emergencyContact;
  final String? emergencyContactPhone;
  final String? primaryPhysician;
  final String? primaryPhysicianPhone;
  final String? insuranceProvider;
  final String? insuranceNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  HealthInfoModel({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.bloodGroup,
    required this.height,
    required this.weight,
    required this.allergies,
    required this.medicalConditions,
    this.emergencyContact,
    this.emergencyContactPhone,
    this.primaryPhysician,
    this.primaryPhysicianPhone,
    this.insuranceProvider,
    this.insuranceNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'bloodGroup': bloodGroup.name,
      'height': height,
      'weight': weight,
      'allergies': allergies,
      'medicalConditions': medicalConditions,
      'emergencyContact': emergencyContact,
      'emergencyContactPhone': emergencyContactPhone,
      'primaryPhysician': primaryPhysician,
      'primaryPhysicianPhone': primaryPhysicianPhone,
      'insuranceProvider': insuranceProvider,
      'insuranceNumber': insuranceNumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory HealthInfoModel.fromMap(Map<String, dynamic> map) {
    return HealthInfoModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      dateOfBirth: DateTime.parse(map['dateOfBirth']),
      gender: map['gender'] ?? '',
      bloodGroup: BloodGroup.values.firstWhere(
        (e) => e.name == map['bloodGroup'],
        orElse: () => BloodGroup.oPositive,
      ),
      height: map['height']?.toDouble() ?? 0.0,
      weight: map['weight']?.toDouble() ?? 0.0,
      allergies: List<String>.from(map['allergies'] ?? []),
      medicalConditions: List<String>.from(map['medicalConditions'] ?? []),
      emergencyContact: map['emergencyContact'],
      emergencyContactPhone: map['emergencyContactPhone'],
      primaryPhysician: map['primaryPhysician'],
      primaryPhysicianPhone: map['primaryPhysicianPhone'],
      insuranceProvider: map['insuranceProvider'],
      insuranceNumber: map['insuranceNumber'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  factory HealthInfoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HealthInfoModel.fromMap(data);
  }

  String get fullName => '$firstName $lastName';

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  double get bmi => weight / ((height / 100) * (height / 100));

  String get bloodGroupDisplay {
    switch (bloodGroup) {
      case BloodGroup.aPositive:
        return 'A+';
      case BloodGroup.aNegative:
        return 'A-';
      case BloodGroup.bPositive:
        return 'B+';
      case BloodGroup.bNegative:
        return 'B-';
      case BloodGroup.oPositive:
        return 'O+';
      case BloodGroup.oNegative:
        return 'O-';
      case BloodGroup.abPositive:
        return 'AB+';
      case BloodGroup.abNegative:
        return 'AB-';
    }
  }
}

class VaccinationRecord {
  final String id;
  final String patientId;
  final String vaccineName;
  final DateTime dateAdministered;
  final String? batchNumber;
  final String? administeredBy;
  final DateTime? nextDue;

  VaccinationRecord({
    required this.id,
    required this.patientId,
    required this.vaccineName,
    required this.dateAdministered,
    this.batchNumber,
    this.administeredBy,
    this.nextDue,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'vaccineName': vaccineName,
      'dateAdministered': dateAdministered.toIso8601String(),
      'batchNumber': batchNumber,
      'administeredBy': administeredBy,
      'nextDue': nextDue?.toIso8601String(),
    };
  }

  factory VaccinationRecord.fromMap(Map<String, dynamic> map) {
    return VaccinationRecord(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      vaccineName: map['vaccineName'] ?? '',
      dateAdministered: DateTime.parse(map['dateAdministered']),
      batchNumber: map['batchNumber'],
      administeredBy: map['administeredBy'],
      nextDue: map['nextDue'] != null ? DateTime.parse(map['nextDue']) : null,
    );
  }
}
