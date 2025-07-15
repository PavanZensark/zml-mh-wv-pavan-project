class ValidationUtils {
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  static String? validateConfirmPassword(
      String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Name is required';
    }
    if (name.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    return null;
  }

  static String? validatePhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return null; // Phone number is optional
    }
    if (phoneNumber.length < 10) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? validatePhone(String? phoneNumber) {
    return validatePhoneNumber(phoneNumber);
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateHeight(String? height) {
    if (height == null || height.isEmpty) {
      return 'Height is required';
    }
    final heightValue = double.tryParse(height);
    if (heightValue == null) {
      return 'Enter a valid height';
    }
    if (heightValue < 50 || heightValue > 250) {
      return 'Height must be between 50 and 250 cm';
    }
    return null;
  }

  static String? validateWeight(String? weight) {
    if (weight == null || weight.isEmpty) {
      return 'Weight is required';
    }
    final weightValue = double.tryParse(weight);
    if (weightValue == null) {
      return 'Enter a valid weight';
    }
    if (weightValue < 10 || weightValue > 500) {
      return 'Weight must be between 10 and 500 kg';
    }
    return null;
  }

  static String? validateDosage(String? dosage) {
    if (dosage == null || dosage.isEmpty) {
      return 'Dosage is required';
    }
    return null;
  }

  static String? validateMedicationName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Medication name is required';
    }
    if (name.length < 2) {
      return 'Medication name must be at least 2 characters long';
    }
    return null;
  }

  static String? validateTime(String? time) {
    if (time == null || time.isEmpty) {
      return 'Time is required';
    }
    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timeRegex.hasMatch(time)) {
      return 'Enter a valid time (HH:MM)';
    }
    return null;
  }

  static bool isValidDate(DateTime date) {
    final now = DateTime.now();
    final minDate = DateTime(1900, 1, 1);
    return date.isAfter(minDate) &&
        date.isBefore(now.add(const Duration(days: 365 * 10)));
  }

  static String? validateDateOfBirth(DateTime? date) {
    if (date == null) {
      return 'Date of birth is required';
    }
    final now = DateTime.now();
    final minDate = DateTime(1900, 1, 1);
    if (date.isAfter(now)) {
      return 'Date of birth cannot be in the future';
    }
    if (date.isBefore(minDate)) {
      return 'Date of birth cannot be before 1900';
    }
    return null;
  }

  static String? validateFutureDate(DateTime? date) {
    if (date == null) {
      return 'Date is required';
    }
    final now = DateTime.now();
    if (date.isBefore(now)) {
      return 'Date must be in the future';
    }
    return null;
  }

  static String? validateBloodPressure(String? bloodPressure) {
    if (bloodPressure == null || bloodPressure.isEmpty) {
      return 'Blood pressure is required';
    }
    final regex = RegExp(r'^\d{2,3}/\d{2,3}$');
    if (!regex.hasMatch(bloodPressure)) {
      return 'Enter valid blood pressure (e.g., 120/80)';
    }
    return null;
  }

  static String? validateHeartRate(String? heartRate) {
    if (heartRate == null || heartRate.isEmpty) {
      return 'Heart rate is required';
    }
    final rate = int.tryParse(heartRate);
    if (rate == null) {
      return 'Enter a valid heart rate';
    }
    if (rate < 30 || rate > 300) {
      return 'Heart rate must be between 30 and 300 BPM';
    }
    return null;
  }

  static String? validateTemperature(String? temperature) {
    if (temperature == null || temperature.isEmpty) {
      return 'Temperature is required';
    }
    final temp = double.tryParse(temperature);
    if (temp == null) {
      return 'Enter a valid temperature';
    }
    if (temp < 30 || temp > 45) {
      return 'Temperature must be between 30 and 45°C';
    }
    return null;
  }
}
