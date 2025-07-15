import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/health_info_model.dart';
import '../models/appointment_model.dart';
import '../models/medication_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Health Info Operations
  Future<void> createHealthInfo(HealthInfoModel healthInfo) async {
    try {
      await _firestore
          .collection('health_info')
          .doc(healthInfo.id)
          .set(healthInfo.toMap());
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

  // Appointment Operations
  Future<void> createAppointment(AppointmentModel appointment) async {
    try {
      await _firestore
          .collection('appointments')
          .doc(appointment.id)
          .set(appointment.toMap());
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
          .orderBy('appointmentDate', descending: false)
          .get();

      return query.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
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
          .where('appointmentDate', isGreaterThanOrEqualTo: now)
          .where('status', whereIn: ['scheduled', 'confirmed'])
          .orderBy('appointmentDate', descending: false)
          .get();

      return query.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Error fetching upcoming appointments: $e';
    }
  }

  // Medication Operations
  Future<void> createMedication(MedicationModel medication) async {
    try {
      await _firestore
          .collection('medications')
          .doc(medication.id)
          .set(medication.toMap());
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
          .orderBy('medicationName')
          .get();

      return query.docs
          .map((doc) => MedicationModel.fromFirestore(doc))
          .toList();
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
}
