import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class AppointmentProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  List<AppointmentModel> _appointments = [];
  List<AppointmentModel> _upcomingAppointments = [];
  bool _isLoading = false;
  String? _error;

  AppointmentProvider(this._firestoreService);

  List<AppointmentModel> get appointments => _appointments;
  List<AppointmentModel> get upcomingAppointments => _upcomingAppointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAppointments(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _appointments = await _firestoreService.getAppointmentsByUserId(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUpcomingAppointments(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _upcomingAppointments =
          await _firestoreService.getUpcomingAppointments(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAppointment(AppointmentModel appointment) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      String id = await _firestoreService.createAppointment(appointment);

      // Create the appointment with the generated ID
      final appointmentWithId = AppointmentModel(
        id: id,
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

      _appointments.add(appointmentWithId);

      // Add to upcoming if it's in the future
      if (appointmentWithId.appointmentDateTime.isAfter(DateTime.now())) {
        _upcomingAppointments.add(appointmentWithId);
        _upcomingAppointments.sort(
            (a, b) => a.appointmentDateTime.compareTo(b.appointmentDateTime));
      }

      // Schedule notification reminder
      if (appointment.reminderSet) {
        await NotificationService().scheduleAppointmentReminder(appointment);
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

  Future<bool> updateAppointment(AppointmentModel appointment) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestoreService.updateAppointment(appointment);

      // Update in appointments list
      final index = _appointments.indexWhere((app) => app.id == appointment.id);
      if (index != -1) {
        _appointments[index] = appointment;
      }

      // Update in upcoming appointments
      final upcomingIndex =
          _upcomingAppointments.indexWhere((app) => app.id == appointment.id);
      if (upcomingIndex != -1) {
        if (appointment.appointmentDateTime.isAfter(DateTime.now())) {
          _upcomingAppointments[upcomingIndex] = appointment;
          _upcomingAppointments.sort(
              (a, b) => a.appointmentDateTime.compareTo(b.appointmentDateTime));
        } else {
          _upcomingAppointments.removeAt(upcomingIndex);
        }
      }

      // Update notification reminder
      await NotificationService().cancelAppointmentReminders(appointment.id);
      if (appointment.reminderSet) {
        await NotificationService().scheduleAppointmentReminder(appointment);
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

  Future<bool> deleteAppointment(String appointmentId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestoreService.deleteAppointment(appointmentId);
      _appointments.removeWhere((app) => app.id == appointmentId);
      _upcomingAppointments.removeWhere((app) => app.id == appointmentId);

      // Cancel notification reminder
      await NotificationService().cancelAppointmentReminders(appointmentId);

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

  Future<bool> cancelAppointment(String appointmentId) async {
    final appointment =
        _appointments.firstWhere((app) => app.id == appointmentId);
    final updatedAppointment = AppointmentModel(
      id: appointment.id,
      userId: appointment.userId,
      patientId: appointment.patientId,
      doctorName: appointment.doctorName,
      doctorSpecialization: appointment.doctorSpecialization,
      appointmentDate: appointment.appointmentDate,
      appointmentTime: appointment.appointmentTime,
      reason: appointment.reason,
      notes: appointment.notes,
      status: AppointmentStatus.cancelled,
      location: appointment.location,
      contactNumber: appointment.contactNumber,
      reminderSet: appointment.reminderSet,
      createdAt: appointment.createdAt,
      updatedAt: DateTime.now(),
    );

    return await updateAppointment(updatedAppointment);
  }

  Future<bool> markAsCompleted(String appointmentId) async {
    final appointment =
        _appointments.firstWhere((app) => app.id == appointmentId);
    final updatedAppointment = AppointmentModel(
      id: appointment.id,
      userId: appointment.userId,
      patientId: appointment.patientId,
      doctorName: appointment.doctorName,
      doctorSpecialization: appointment.doctorSpecialization,
      appointmentDate: appointment.appointmentDate,
      appointmentTime: appointment.appointmentTime,
      reason: appointment.reason,
      notes: appointment.notes,
      status: AppointmentStatus.completed,
      location: appointment.location,
      contactNumber: appointment.contactNumber,
      reminderSet: appointment.reminderSet,
      createdAt: appointment.createdAt,
      updatedAt: DateTime.now(),
    );

    return await updateAppointment(updatedAppointment);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
