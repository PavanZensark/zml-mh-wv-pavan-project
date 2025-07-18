import 'package:flutter/material.dart';
import '../models/health_info_model.dart';
import '../services/firestore_service.dart';

class HealthProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  List<HealthInfoModel> _healthProfiles = [];
  HealthInfoModel? _selectedProfile;
  bool _isLoading = false;
  String? _error;

  HealthProvider(this._firestoreService);

  List<HealthInfoModel> get healthProfiles => _healthProfiles;
  HealthInfoModel? get selectedProfile => _selectedProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadHealthProfiles(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _healthProfiles = await _firestoreService.getHealthInfoByUserId(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHealthProfile(String profileId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _selectedProfile = await _firestoreService.getHealthInfo(profileId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createHealthProfile(HealthInfoModel healthInfo) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      String id = await _firestoreService.createHealthInfo(healthInfo);

      // Create the health info with the generated ID
      final healthInfoWithId = HealthInfoModel(
        id: id,
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

      _healthProfiles.add(healthInfoWithId);
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

  Future<bool> updateHealthProfile(HealthInfoModel healthInfo) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestoreService.updateHealthInfo(healthInfo);

      // Update in local list
      final index =
          _healthProfiles.indexWhere((profile) => profile.id == healthInfo.id);
      if (index != -1) {
        _healthProfiles[index] = healthInfo;
      }

      // Update selected profile if it matches
      if (_selectedProfile?.id == healthInfo.id) {
        _selectedProfile = healthInfo;
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

  Future<List<HealthInfoModel>> searchPatients(String query) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final results = await _firestoreService.searchPatients(query);
      _isLoading = false;
      notifyListeners();
      return results;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  void selectProfile(HealthInfoModel profile) {
    _selectedProfile = profile;
    notifyListeners();
  }

  void clearSelectedProfile() {
    _selectedProfile = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
