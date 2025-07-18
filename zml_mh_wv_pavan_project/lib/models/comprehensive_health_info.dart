import 'package:cloud_firestore/cloud_firestore.dart';
import 'health_info_model.dart';

/// Extended health information model for the web health wizard
/// Contains comprehensive health data beyond the basic mobile health info
class ComprehensiveHealthInfo {
  final String id;
  final String userId;

  // Personal Details
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String dateOfBirth;
  final String gender;
  final String? address;
  final String? bloodGroup;
  final String? height;
  final String? weight;

  // Medical History
  final String? allergies;
  final String? currentConditions;
  final String? pastConditions;
  final String? surgeries;
  final String? vaccinations;

  // Medications & Supplements
  final String? currentMedications;
  final String? supplements;

  // Emergency Contacts
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String emergencyContactRelation;
  final String? secondaryContactName;
  final String? secondaryContactPhone;
  final String? secondaryContactRelation;

  // Physician & Insurance Info
  final String? primaryPhysicianName;
  final String? primaryPhysicianSpecialty;
  final String? primaryPhysicianPhone;
  final String? primaryPhysicianEmail;
  final String? assignedPhysicianId; // Link to physician user account
  final String? insuranceProvider;
  final String? insurancePolicy;

  final DateTime createdAt;
  final DateTime updatedAt;

  ComprehensiveHealthInfo({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.gender,
    this.address,
    this.bloodGroup,
    this.height,
    this.weight,
    this.allergies,
    this.currentConditions,
    this.pastConditions,
    this.surgeries,
    this.vaccinations,
    this.currentMedications,
    this.supplements,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.emergencyContactRelation,
    this.secondaryContactName,
    this.secondaryContactPhone,
    this.secondaryContactRelation,
    this.primaryPhysicianName,
    this.primaryPhysicianSpecialty,
    this.primaryPhysicianPhone,
    this.primaryPhysicianEmail,
    this.assignedPhysicianId,
    this.insuranceProvider,
    this.insurancePolicy,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'address': address,
      'bloodGroup': bloodGroup,
      'height': height,
      'weight': weight,
      'allergies': allergies,
      'currentConditions': currentConditions,
      'pastConditions': pastConditions,
      'surgeries': surgeries,
      'vaccinations': vaccinations,
      'currentMedications': currentMedications,
      'supplements': supplements,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'emergencyContactRelation': emergencyContactRelation,
      'secondaryContactName': secondaryContactName,
      'secondaryContactPhone': secondaryContactPhone,
      'secondaryContactRelation': secondaryContactRelation,
      'primaryPhysicianName': primaryPhysicianName,
      'primaryPhysicianSpecialty': primaryPhysicianSpecialty,
      'primaryPhysicianPhone': primaryPhysicianPhone,
      'primaryPhysicianEmail': primaryPhysicianEmail,
      'assignedPhysicianId': assignedPhysicianId,
      'insuranceProvider': insuranceProvider,
      'insurancePolicy': insurancePolicy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ComprehensiveHealthInfo.fromMap(Map<String, dynamic> map) {
    return ComprehensiveHealthInfo(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      dateOfBirth: map['dateOfBirth'] ?? '',
      gender: map['gender'] ?? '',
      address: map['address'],
      bloodGroup: map['bloodGroup'],
      height: map['height'],
      weight: map['weight'],
      allergies: map['allergies'],
      currentConditions: map['currentConditions'],
      pastConditions: map['pastConditions'],
      surgeries: map['surgeries'],
      vaccinations: map['vaccinations'],
      currentMedications: map['currentMedications'],
      supplements: map['supplements'],
      emergencyContactName: map['emergencyContactName'] ?? '',
      emergencyContactPhone: map['emergencyContactPhone'] ?? '',
      emergencyContactRelation: map['emergencyContactRelation'] ?? '',
      secondaryContactName: map['secondaryContactName'],
      secondaryContactPhone: map['secondaryContactPhone'],
      secondaryContactRelation: map['secondaryContactRelation'],
      primaryPhysicianName: map['primaryPhysicianName'],
      primaryPhysicianSpecialty: map['primaryPhysicianSpecialty'],
      primaryPhysicianPhone: map['primaryPhysicianPhone'],
      primaryPhysicianEmail: map['primaryPhysicianEmail'],
      assignedPhysicianId: map['assignedPhysicianId'],
      insuranceProvider: map['insuranceProvider'],
      insurancePolicy: map['insurancePolicy'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  factory ComprehensiveHealthInfo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ComprehensiveHealthInfo.fromMap(data);
  }

  String get fullName => '$firstName $lastName';

  /// Convert to basic HealthInfoModel for compatibility
  HealthInfoModel toBasicHealthInfo() {
    final dateOfBirthParsed = DateTime.tryParse(dateOfBirth) ??
        DateTime.now().subtract(const Duration(days: 365 * 30));
    final heightDouble =
        double.tryParse(height?.replaceAll(RegExp(r'[^\d.]'), '') ?? '0') ??
            0.0;
    final weightDouble =
        double.tryParse(weight?.replaceAll(RegExp(r'[^\d.]'), '') ?? '0') ??
            0.0;

    // Parse blood group
    BloodGroup bloodGroupEnum = BloodGroup.oPositive;
    if (bloodGroup != null) {
      switch (bloodGroup!.toLowerCase()) {
        case 'a+':
          bloodGroupEnum = BloodGroup.aPositive;
          break;
        case 'a-':
          bloodGroupEnum = BloodGroup.aNegative;
          break;
        case 'b+':
          bloodGroupEnum = BloodGroup.bPositive;
          break;
        case 'b-':
          bloodGroupEnum = BloodGroup.bNegative;
          break;
        case 'o+':
          bloodGroupEnum = BloodGroup.oPositive;
          break;
        case 'o-':
          bloodGroupEnum = BloodGroup.oNegative;
          break;
        case 'ab+':
          bloodGroupEnum = BloodGroup.abPositive;
          break;
        case 'ab-':
          bloodGroupEnum = BloodGroup.abNegative;
          break;
      }
    }

    return HealthInfoModel(
      id: id,
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirthParsed,
      gender: gender,
      bloodGroup: bloodGroupEnum,
      height: heightDouble,
      weight: weightDouble,
      allergies: allergies?.split(',').map((e) => e.trim()).toList() ?? [],
      medicalConditions:
          currentConditions?.split(',').map((e) => e.trim()).toList() ?? [],
      emergencyContact: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
      primaryPhysician: primaryPhysicianName,
      primaryPhysicianPhone: primaryPhysicianPhone,
      insuranceProvider: insuranceProvider,
      insuranceNumber: insurancePolicy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
