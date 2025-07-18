import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/health_info_model.dart';
import '../models/appointment_model.dart';
import '../models/medication_model.dart';
import '../models/comprehensive_health_info.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Health Info Operations
  Future<String> createHealthInfo(HealthInfoModel healthInfo) async {
    try {
      // Generate a new document reference to get an auto-generated ID
      DocumentReference docRef = _firestore.collection('health_info').doc();

      // Create a new health info with the generated ID
      final healthInfoWithId = HealthInfoModel(
        id: docRef.id,
        userId: healthInfo.userId,
        firstName: healthInfo.firstName,
        lastName: healthInfo.lastName,
        dateOfBirth: healthInfo.dateOfBirth,
        gender: healthInfo.gender,
        bloodGroup: healthInfo.bloodGroup,
        height: healthInfo.height,
        weight: healthInfo.weight,
        allergies: healthInfo.allergies,
        medicalConditions: healthInfo.medicalConditions,
        emergencyContact: healthInfo.emergencyContact,
        emergencyContactPhone: healthInfo.emergencyContactPhone,
        createdAt: healthInfo.createdAt,
        updatedAt: healthInfo.updatedAt,
      );

      await docRef.set(healthInfoWithId.toMap());
      return docRef.id;
    } catch (e) {
      throw 'Error creating health info: $e';
    }
  }

  Future<void> updateHealthInfo(HealthInfoModel healthInfo) async {
    try {
      await _firestore
          .collection('health_info')
          .doc(healthInfo.id)
          .update(healthInfo.toMap());
    } catch (e) {
      throw 'Error updating health info: $e';
    }
  }

  Future<HealthInfoModel?> getHealthInfo(String id) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('health_info').doc(id).get();

      if (doc.exists) {
        return HealthInfoModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Error fetching health info: $e';
    }
  }

  Future<List<HealthInfoModel>> getHealthInfoByUserId(String userId) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('health_info')
          .where('userId', isEqualTo: userId)
          .get();

      return query.docs
          .map((doc) => HealthInfoModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Error fetching health info: $e';
    }
  }

  // Comprehensive Health Info Operations
  Future<String> saveComprehensiveHealthInfo(
      ComprehensiveHealthInfo healthInfo) async {
    try {
      // Generate a new document reference to get an auto-generated ID
      DocumentReference docRef =
          _firestore.collection('comprehensive_health_info').doc();

      // Create a new health info with the generated ID
      final healthInfoWithId = ComprehensiveHealthInfo(
        id: docRef.id,
        userId: healthInfo.userId,
        firstName: healthInfo.firstName,
        lastName: healthInfo.lastName,
        email: healthInfo.email,
        phone: healthInfo.phone,
        dateOfBirth: healthInfo.dateOfBirth,
        gender: healthInfo.gender,
        address: healthInfo.address,
        bloodGroup: healthInfo.bloodGroup,
        height: healthInfo.height,
        weight: healthInfo.weight,
        allergies: healthInfo.allergies,
        currentConditions: healthInfo.currentConditions,
        pastConditions: healthInfo.pastConditions,
        surgeries: healthInfo.surgeries,
        vaccinations: healthInfo.vaccinations,
        currentMedications: healthInfo.currentMedications,
        supplements: healthInfo.supplements,
        emergencyContactName: healthInfo.emergencyContactName,
        emergencyContactPhone: healthInfo.emergencyContactPhone,
        emergencyContactRelation: healthInfo.emergencyContactRelation,
        secondaryContactName: healthInfo.secondaryContactName,
        secondaryContactPhone: healthInfo.secondaryContactPhone,
        secondaryContactRelation: healthInfo.secondaryContactRelation,
        primaryPhysicianName: healthInfo.primaryPhysicianName,
        primaryPhysicianSpecialty: healthInfo.primaryPhysicianSpecialty,
        primaryPhysicianPhone: healthInfo.primaryPhysicianPhone,
        primaryPhysicianEmail: healthInfo.primaryPhysicianEmail,
        insuranceProvider: healthInfo.insuranceProvider,
        insurancePolicy: healthInfo.insurancePolicy,
        createdAt: healthInfo.createdAt,
        updatedAt: DateTime.now(),
      );

      await docRef.set(healthInfoWithId.toMap());

      // Also save basic health info for mobile compatibility
      final basicHealthInfo = healthInfoWithId.toBasicHealthInfo();
      await createHealthInfo(basicHealthInfo);

      return docRef.id;
    } catch (e) {
      throw 'Error saving comprehensive health info: $e';
    }
  }

  Future<List<ComprehensiveHealthInfo>> getComprehensiveHealthInfoByUserId(
      String userId) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('comprehensive_health_info')
          .where('userId', isEqualTo: userId)
          .get();

      return query.docs
          .map((doc) => ComprehensiveHealthInfo.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Error fetching comprehensive health info: $e';
    }
  }

  Future<ComprehensiveHealthInfo?> getComprehensiveHealthInfo(String id) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('comprehensive_health_info')
          .doc(id)
          .get();

      if (doc.exists) {
        return ComprehensiveHealthInfo.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Error fetching comprehensive health info: $e';
    }
  }

  // Physician-Patient Relationship Operations
  Future<List<ComprehensiveHealthInfo>> getPatientsByPhysicianId(
      String physicianId) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('comprehensive_health_info')
          .where('assignedPhysicianId', isEqualTo: physicianId)
          .get();

      return query.docs
          .map((doc) => ComprehensiveHealthInfo.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Error fetching patients by physician: $e';
    }
  }

  Future<List<ComprehensiveHealthInfo>> getAllPatientsHealthInfo() async {
    try {
      QuerySnapshot query =
          await _firestore.collection('comprehensive_health_info').get();

      return query.docs
          .map((doc) => ComprehensiveHealthInfo.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Error fetching all patients health info: $e';
    }
  }

  Future<void> assignPhysicianToPatient(
      String patientHealthInfoId, String physicianId) async {
    try {
      await _firestore
          .collection('comprehensive_health_info')
          .doc(patientHealthInfoId)
          .update({
        'assignedPhysicianId': physicianId,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Error assigning physician to patient: $e';
    }
  }

  // Appointment Operations
  Future<String> createAppointment(AppointmentModel appointment) async {
    try {
      // Generate a new document reference to get an auto-generated ID
      DocumentReference docRef = _firestore.collection('appointments').doc();

      // Create a new appointment with the generated ID
      final appointmentWithId = AppointmentModel(
        id: docRef.id,
        userId: appointment.userId,
        patientId: appointment.patientId,
        doctorName: appointment.doctorName,
        doctorSpecialization: appointment.doctorSpecialization,
        appointmentDate: appointment.appointmentDate,
        appointmentTime: appointment.appointmentTime,
        reason: appointment.reason,
        notes: appointment.notes,
        status: appointment.status,
        location: appointment.location,
        contactNumber: appointment.contactNumber,
        reminderSet: appointment.reminderSet,
        createdAt: appointment.createdAt,
        updatedAt: appointment.updatedAt,
      );

      await docRef.set(appointmentWithId.toMap());
      return docRef.id;
    } catch (e) {
      throw 'Error creating appointment: $e';
    }
  }

  Future<void> updateAppointment(AppointmentModel appointment) async {
    try {
      await _firestore
          .collection('appointments')
          .doc(appointment.id)
          .update(appointment.toMap());
    } catch (e) {
      throw 'Error updating appointment: $e';
    }
  }

  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).delete();
    } catch (e) {
      throw 'Error deleting appointment: $e';
    }
  }

  Future<List<AppointmentModel>> getAppointmentsByUserId(String userId) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('appointments')
          .where('userId', isEqualTo: userId)
          .get();

      final appointments =
          query.docs.map((doc) => AppointmentModel.fromFirestore(doc)).toList();

      // Sort by appointment date in Dart instead of Firestore
      appointments
          .sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));

      return appointments;
    } catch (e) {
      throw 'Error fetching appointments: $e';
    }
  }

  Future<List<AppointmentModel>> getUpcomingAppointments(String userId) async {
    try {
      final now = DateTime.now();
      QuerySnapshot query = await _firestore
          .collection('appointments')
          .where('userId', isEqualTo: userId)
          .get();

      final appointments = query.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .where((appointment) =>
              appointment.appointmentDate.isAfter(now) &&
              (appointment.status == AppointmentStatus.scheduled ||
                  appointment.status == AppointmentStatus.confirmed))
          .toList();

      // Sort by appointment date in Dart instead of Firestore
      appointments
          .sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));

      return appointments;
    } catch (e) {
      throw 'Error fetching upcoming appointments: $e';
    }
  }

  // Medication Operations
  Future<String> createMedication(MedicationModel medication) async {
    try {
      // Generate a new document reference to get an auto-generated ID
      DocumentReference docRef = _firestore.collection('medications').doc();

      // Create a new medication with the generated ID
      final medicationWithId = MedicationModel(
        id: docRef.id,
        userId: medication.userId,
        patientId: medication.patientId,
        medicationName: medication.medicationName,
        dosage: medication.dosage,
        frequency: medication.frequency,
        timings: medication.timings,
        startDate: medication.startDate,
        endDate: medication.endDate,
        instructions: medication.instructions,
        prescribedBy: medication.prescribedBy,
        isActive: medication.isActive,
        reminderEnabled: medication.reminderEnabled,
        createdAt: medication.createdAt,
        updatedAt: medication.updatedAt,
      );

      await docRef.set(medicationWithId.toMap());
      return docRef.id;
    } catch (e) {
      throw 'Error creating medication: $e';
    }
  }

  Future<void> updateMedication(MedicationModel medication) async {
    try {
      await _firestore
          .collection('medications')
          .doc(medication.id)
          .update(medication.toMap());
    } catch (e) {
      throw 'Error updating medication: $e';
    }
  }

  Future<void> deleteMedication(String medicationId) async {
    try {
      await _firestore.collection('medications').doc(medicationId).delete();
    } catch (e) {
      throw 'Error deleting medication: $e';
    }
  }

  Future<List<MedicationModel>> getMedicationsByUserId(String userId) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('medications')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      final medications =
          query.docs.map((doc) => MedicationModel.fromFirestore(doc)).toList();

      // Sort by medication name in Dart instead of Firestore
      medications.sort((a, b) => a.medicationName.compareTo(b.medicationName));

      return medications;
    } catch (e) {
      throw 'Error fetching medications: $e';
    }
  }

  Future<List<MedicationModel>> getActiveMedications(String userId) async {
    try {
      final now = DateTime.now();
      QuerySnapshot query = await _firestore
          .collection('medications')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .where('startDate', isLessThanOrEqualTo: now)
          .get();

      return query.docs
          .map((doc) => MedicationModel.fromFirestore(doc))
          .where((med) => med.endDate == null || med.endDate!.isAfter(now))
          .toList();
    } catch (e) {
      throw 'Error fetching active medications: $e';
    }
  }

  // Medication Log Operations
  Future<void> createMedicationLog(MedicationLog log) async {
    try {
      await _firestore
          .collection('medication_logs')
          .doc(log.id)
          .set(log.toMap());
    } catch (e) {
      throw 'Error creating medication log: $e';
    }
  }

  Future<void> updateMedicationLog(MedicationLog log) async {
    try {
      await _firestore
          .collection('medication_logs')
          .doc(log.id)
          .update(log.toMap());
    } catch (e) {
      throw 'Error updating medication log: $e';
    }
  }

  Future<List<MedicationLog>> getMedicationLogs(String patientId,
      {int days = 30}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));
      QuerySnapshot query = await _firestore
          .collection('medication_logs')
          .where('patientId', isEqualTo: patientId)
          .where('scheduledTime', isGreaterThanOrEqualTo: startDate)
          .orderBy('scheduledTime', descending: true)
          .get();

      return query.docs
          .map((doc) =>
              MedicationLog.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Error fetching medication logs: $e';
    }
  }

  // Search Operations (for physician dashboard)
  Future<List<HealthInfoModel>> searchPatients(String query) async {
    try {
      // Search by first name
      QuerySnapshot firstNameQuery = await _firestore
          .collection('health_info')
          .where('firstName', isGreaterThanOrEqualTo: query)
          .where('firstName', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      // Search by last name
      QuerySnapshot lastNameQuery = await _firestore
          .collection('health_info')
          .where('lastName', isGreaterThanOrEqualTo: query)
          .where('lastName', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      final results = <HealthInfoModel>[];
      final addedIds = <String>{};

      for (final doc in firstNameQuery.docs) {
        final healthInfo = HealthInfoModel.fromFirestore(doc);
        if (!addedIds.contains(healthInfo.id)) {
          results.add(healthInfo);
          addedIds.add(healthInfo.id);
        }
      }

      for (final doc in lastNameQuery.docs) {
        final healthInfo = HealthInfoModel.fromFirestore(doc);
        if (!addedIds.contains(healthInfo.id)) {
          results.add(healthInfo);
          addedIds.add(healthInfo.id);
        }
      }

      return results;
    } catch (e) {
      throw 'Error searching patients: $e';
    }
  }

  // Search Operations for Web (Comprehensive Health Info)
  Future<List<ComprehensiveHealthInfo>> searchPatientsWeb(String query) async {
    try {
      // Search by first name
      QuerySnapshot firstNameQuery = await _firestore
          .collection('comprehensive_health_info')
          .where('firstName', isGreaterThanOrEqualTo: query)
          .where('firstName', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      // Search by last name
      QuerySnapshot lastNameQuery = await _firestore
          .collection('comprehensive_health_info')
          .where('lastName', isGreaterThanOrEqualTo: query)
          .where('lastName', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      final results = <ComprehensiveHealthInfo>[];
      final addedIds = <String>{};

      for (final doc in firstNameQuery.docs) {
        final healthInfo =
            ComprehensiveHealthInfo.fromMap(doc.data() as Map<String, dynamic>);
        if (!addedIds.contains(healthInfo.id)) {
          results.add(healthInfo);
          addedIds.add(healthInfo.id);
        }
      }

      for (final doc in lastNameQuery.docs) {
        final healthInfo =
            ComprehensiveHealthInfo.fromMap(doc.data() as Map<String, dynamic>);
        if (!addedIds.contains(healthInfo.id)) {
          results.add(healthInfo);
          addedIds.add(healthInfo.id);
        }
      }

      return results;
    } catch (e) {
      throw 'Error searching patients: $e';
    }
  }

  // Vaccination Records
  Future<void> createVaccinationRecord(VaccinationRecord record) async {
    try {
      await _firestore
          .collection('vaccination_records')
          .doc(record.id)
          .set(record.toMap());
    } catch (e) {
      throw 'Error creating vaccination record: $e';
    }
  }

  Future<List<VaccinationRecord>> getVaccinationRecords(
      String patientId) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('vaccination_records')
          .where('patientId', isEqualTo: patientId)
          .orderBy('dateAdministered', descending: true)
          .get();

      return query.docs
          .map((doc) =>
              VaccinationRecord.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Error fetching vaccination records: $e';
    }
  }

  // Get all physicians for patient selection
  Future<List<Map<String, dynamic>>> getAllPhysicians() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'physician')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'firstName': data['firstName'] ?? '',
          'lastName': data['lastName'] ?? '',
          'email': data['email'] ?? '',
          'specialty': data['specialty'] ?? 'General Practice',
        };
      }).toList();
    } catch (e) {
      throw 'Error fetching physicians: $e';
    }
  }
}
