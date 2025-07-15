import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/health_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/health_info_model.dart';
import '../../../utils/validation_utils.dart';

class AddHealthInfoScreen extends StatefulWidget {
  const AddHealthInfoScreen({super.key});

  @override
  State<AddHealthInfoScreen> createState() => _AddHealthInfoScreenState();
}

class _AddHealthInfoScreenState extends State<AddHealthInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicalConditionsController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();
  final _primaryPhysicianController = TextEditingController();
  final _primaryPhysicianPhoneController = TextEditingController();
  final _insuranceProviderController = TextEditingController();
  final _insuranceNumberController = TextEditingController();

  DateTime? _selectedDateOfBirth;
  String? _selectedGender;
  BloodGroup? _selectedBloodGroup;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final Map<String, BloodGroup> _bloodGroupMap = {
    'A+': BloodGroup.aPositive,
    'A-': BloodGroup.aNegative,
    'B+': BloodGroup.bPositive,
    'B-': BloodGroup.bNegative,
    'O+': BloodGroup.oPositive,
    'O-': BloodGroup.oNegative,
    'AB+': BloodGroup.abPositive,
    'AB-': BloodGroup.abNegative,
  };

  @override
  void initState() {
    super.initState();
    // Pre-fill with user data if available
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _allergiesController.dispose();
    _medicalConditionsController.dispose();
    _emergencyContactController.dispose();
    _emergencyContactPhoneController.dispose();
    _primaryPhysicianController.dispose();
    _primaryPhysicianPhoneController.dispose();
    _insuranceProviderController.dispose();
    _insuranceNumberController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> _saveHealthInfo() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date of birth')),
      );
      return;
    }

    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select gender')),
      );
      return;
    }

    if (_selectedBloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select blood group')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);

    final user = authProvider.user;
    if (user == null) return;

    final healthInfo = HealthInfoModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user.id,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      dateOfBirth: _selectedDateOfBirth!,
      gender: _selectedGender!,
      bloodGroup: _selectedBloodGroup!,
      height: double.tryParse(_heightController.text) ?? 0.0,
      weight: double.tryParse(_weightController.text) ?? 0.0,
      allergies: _allergiesController.text.isNotEmpty
          ? _allergiesController.text.split(',').map((e) => e.trim()).toList()
          : [],
      medicalConditions: _medicalConditionsController.text.isNotEmpty
          ? _medicalConditionsController.text
              .split(',')
              .map((e) => e.trim())
              .toList()
          : [],
      emergencyContact: _emergencyContactController.text.isNotEmpty
          ? _emergencyContactController.text
          : null,
      emergencyContactPhone: _emergencyContactPhoneController.text.isNotEmpty
          ? _emergencyContactPhoneController.text
          : null,
      primaryPhysician: _primaryPhysicianController.text.isNotEmpty
          ? _primaryPhysicianController.text
          : null,
      primaryPhysicianPhone: _primaryPhysicianPhoneController.text.isNotEmpty
          ? _primaryPhysicianPhoneController.text
          : null,
      insuranceProvider: _insuranceProviderController.text.isNotEmpty
          ? _insuranceProviderController.text
          : null,
      insuranceNumber: _insuranceNumberController.text.isNotEmpty
          ? _insuranceNumberController.text
          : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await healthProvider.createHealthProfile(healthInfo);

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Health profile created successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Health Profile'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<HealthProvider>(
        builder: (context, healthProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade600),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Create a comprehensive health profile to track your medical information.',
                            style: TextStyle(color: Colors.blue.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Basic Information Section
                  Text(
                    'Basic Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // First Name
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: ValidationUtils.validateName,
                  ),
                  const SizedBox(height: 16),

                  // Last Name
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: ValidationUtils.validateName,
                  ),
                  const SizedBox(height: 16),

                  // Date of Birth
                  GestureDetector(
                    onTap: _selectDateOfBirth,
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: const OutlineInputBorder(),
                          hintText: _selectedDateOfBirth == null
                              ? 'Select date of birth'
                              : '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}',
                        ),
                        controller: TextEditingController(
                          text: _selectedDateOfBirth == null
                              ? ''
                              : '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Gender
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    items: _genders.map((gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Physical Information Section
                  Text(
                    'Physical Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Height
                  TextFormField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Height (cm)',
                      prefixIcon: Icon(Icons.height),
                      border: OutlineInputBorder(),
                    ),
                    validator: ValidationUtils.validateHeight,
                  ),
                  const SizedBox(height: 16),

                  // Weight
                  TextFormField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      prefixIcon: Icon(Icons.monitor_weight),
                      border: OutlineInputBorder(),
                    ),
                    validator: ValidationUtils.validateWeight,
                  ),
                  const SizedBox(height: 16),

                  // Blood Group
                  DropdownButtonFormField<BloodGroup>(
                    value: _selectedBloodGroup,
                    decoration: const InputDecoration(
                      labelText: 'Blood Group',
                      prefixIcon: Icon(Icons.bloodtype),
                      border: OutlineInputBorder(),
                    ),
                    items: _bloodGroupMap.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.value,
                        child: Text(entry.key),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBloodGroup = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Medical Information Section
                  Text(
                    'Medical Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Allergies
                  TextFormField(
                    controller: _allergiesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Allergies',
                      prefixIcon: Icon(Icons.warning),
                      border: OutlineInputBorder(),
                      helperText: 'Separate multiple allergies with commas',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Medical Conditions
                  TextFormField(
                    controller: _medicalConditionsController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Medical Conditions',
                      prefixIcon: Icon(Icons.medical_services),
                      border: OutlineInputBorder(),
                      helperText: 'Separate multiple conditions with commas',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Emergency Contact Section
                  Text(
                    'Emergency Contact',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Emergency Contact Name
                  TextFormField(
                    controller: _emergencyContactController,
                    decoration: const InputDecoration(
                      labelText: 'Emergency Contact Name',
                      prefixIcon: Icon(Icons.contact_emergency),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Emergency Contact Phone
                  TextFormField(
                    controller: _emergencyContactPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Emergency Contact Phone',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Healthcare Provider Section
                  Text(
                    'Healthcare Provider',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Primary Physician
                  TextFormField(
                    controller: _primaryPhysicianController,
                    decoration: const InputDecoration(
                      labelText: 'Primary Physician',
                      prefixIcon: Icon(Icons.local_hospital),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Primary Physician Phone
                  TextFormField(
                    controller: _primaryPhysicianPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Primary Physician Phone',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Insurance Information Section
                  Text(
                    'Insurance Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Insurance Provider
                  TextFormField(
                    controller: _insuranceProviderController,
                    decoration: const InputDecoration(
                      labelText: 'Insurance Provider',
                      prefixIcon: Icon(Icons.business),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Insurance Number
                  TextFormField(
                    controller: _insuranceNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Insurance Number',
                      prefixIcon: Icon(Icons.confirmation_number),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Error Message
                  if (healthProvider.error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red.shade600),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              healthProvider.error!,
                              style: TextStyle(color: Colors.red.shade600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (healthProvider.error != null) const SizedBox(height: 16),

                  // Save Button
                  ElevatedButton(
                    onPressed:
                        healthProvider.isLoading ? null : _saveHealthInfo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: healthProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Create Health Profile',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
