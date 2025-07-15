import 'package:flutter/material.dart';
import '../models/medication_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class MedicationProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  List<MedicationModel> _medications = [];
  List<MedicationModel> _activeMedications = [];
  List<MedicationLog> _medicationLogs = [];
  bool _isLoading = false;
  String? _error;

  MedicationProvider(this._firestoreService);

  List<MedicationModel> get medications => _medications;
  List<MedicationModel> get activeMedications => _activeMedications;
  List<MedicationLog> get medicationLogs => _medicationLogs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMedications(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _medications = await _firestoreService.getMedicationsByUserId(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadActiveMedications(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _activeMedications = await _firestoreService.getActiveMedications(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMedicationLogs(String patientId, {int days = 30}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _medicationLogs =
          await _firestoreService.getMedicationLogs(patientId, days: days);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createMedication(MedicationModel medication) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestoreService.createMedication(medication);
      _medications.add(medication);

      // Add to active medications if it's currently active
      if (medication.isActive &&
          medication.startDate.isBefore(DateTime.now()) &&
          (medication.endDate == null ||
              medication.endDate!.isAfter(DateTime.now()))) {
        _activeMedications.add(medication);
      }

      // Schedule notification reminders
      if (medication.reminderEnabled) {
        await NotificationService().scheduleMedicationReminders(medication);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMedication(MedicationModel medication) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestoreService.updateMedication(medication);

      // Update in medications list
      final index = _medications.indexWhere((med) => med.id == medication.id);
      if (index != -1) {
        _medications[index] = medication;
      }

      // Update in active medications
      final activeIndex =
          _activeMedications.indexWhere((med) => med.id == medication.id);
      if (activeIndex != -1) {
        if (medication.isActive &&
            medication.startDate.isBefore(DateTime.now()) &&
            (medication.endDate == null ||
                medication.endDate!.isAfter(DateTime.now()))) {
          _activeMedications[activeIndex] = medication;
        } else {
          _activeMedications.removeAt(activeIndex);
        }
      } else if (medication.isActive &&
          medication.startDate.isBefore(DateTime.now()) &&
          (medication.endDate == null ||
              medication.endDate!.isAfter(DateTime.now()))) {
        _activeMedications.add(medication);
      }

      // Update notification reminders
      await NotificationService().cancelMedicationReminders(medication.id);
      if (medication.reminderEnabled) {
        await NotificationService().scheduleMedicationReminders(medication);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMedication(String medicationId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestoreService.deleteMedication(medicationId);
      _medications.removeWhere((med) => med.id == medicationId);
      _activeMedications.removeWhere((med) => med.id == medicationId);

      // Cancel notification reminders
      await NotificationService().cancelMedicationReminders(medicationId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> markMedicationTaken(
      String medicationId, String patientId) async {
    try {
      final now = DateTime.now();
      final log = MedicationLog(
        id: '${medicationId}_${now.millisecondsSinceEpoch}',
        medicationId: medicationId,
        patientId: patientId,
        scheduledTime: now,
        takenTime: now,
        taken: true,
      );

      await _firestoreService.createMedicationLog(log);
      _medicationLogs.add(log);
      _medicationLogs
          .sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> markMedicationSkipped(
      String medicationId, String patientId, String? notes) async {
    try {
      final now = DateTime.now();
      final log = MedicationLog(
        id: '${medicationId}_${now.millisecondsSinceEpoch}',
        medicationId: medicationId,
        patientId: patientId,
        scheduledTime: now,
        taken: false,
        notes: notes,
      );

      await _firestoreService.createMedicationLog(log);
      _medicationLogs.add(log);
      _medicationLogs
          .sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deactivateMedication(String medicationId) async {
    final medication = _medications.firstWhere((med) => med.id == medicationId);
    final updatedMedication = MedicationModel(
      id: medication.id,
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
      isActive: false,
      reminderEnabled: medication.reminderEnabled,
      createdAt: medication.createdAt,
      updatedAt: DateTime.now(),
    );

    return await updateMedication(updatedMedication);
  }

  List<MedicationModel> getTodaysMedications() {
    final now = DateTime.now();
    return _activeMedications.where((medication) {
      return medication.startDate.isBefore(now) &&
          (medication.endDate == null || medication.endDate!.isAfter(now));
    }).toList();
  }

  List<MedicationLog> getTodaysLogs() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _medicationLogs.where((log) {
      return log.scheduledTime.isAfter(today) &&
          log.scheduledTime.isBefore(tomorrow);
    }).toList();
  }

  List<MedicationModel> get todaysMedications {
    return _medications.where((medication) {
      if (!medication.isActive) return false;

      // Check if medication should be taken today based on frequency
      // This is a simplified check - in a real app, you'd have more sophisticated logic
      return medication.isActive;
    }).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
