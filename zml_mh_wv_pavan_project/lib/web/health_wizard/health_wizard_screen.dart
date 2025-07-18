import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/comprehensive_health_info.dart';
import '../../services/firestore_service.dart';

class HealthWizardScreen extends StatefulWidget {
  const HealthWizardScreen({super.key});

  @override
  State<HealthWizardScreen> createState() => _HealthWizardScreenState();
}

class _HealthWizardScreenState extends State<HealthWizardScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;

  // Form controllers
  final _personalDetailsFormKey = GlobalKey<FormState>();
  final _medicalHistoryFormKey = GlobalKey<FormState>();
  final _medicationsFormKey = GlobalKey<FormState>();
  final _emergencyContactsFormKey = GlobalKey<FormState>();
  final _physicianInfoFormKey = GlobalKey<FormState>();

  // Personal Details Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _addressController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  // Medical History Controllers
  final _allergiesController = TextEditingController();
  final _currentConditionsController = TextEditingController();
  final _pastConditionsController = TextEditingController();
  final _surgeriesController = TextEditingController();
  final _vaccinationsController = TextEditingController();

  // Medications Controllers
  final _currentMedicationsController = TextEditingController();
  final _vitaminSupplementsController = TextEditingController();

  // Emergency Contacts Controllers
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();
  final _emergencyContactRelationController = TextEditingController();
  final _secondaryContactNameController = TextEditingController();
  final _secondaryContactPhoneController = TextEditingController();
  final _secondaryContactRelationController = TextEditingController();

  // Physician Info Controllers
  final _primaryPhysicianNameController = TextEditingController();
  final _primaryPhysicianSpecialtyController = TextEditingController();
  final _primaryPhysicianPhoneController = TextEditingController();
  final _primaryPhysicianEmailController = TextEditingController();
  final _insuranceProviderController = TextEditingController();
  final _insurancePolicyController = TextEditingController();

  String _selectedGender = 'Male';
  bool _isLoading = false;

  final List<String> _stepTitles = [
    'Personal Details',
    'Medical History',
    'Current Medications',
    'Emergency Contacts',
    'Physician & Insurance Info',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    _addressController.dispose();
    _bloodGroupController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _allergiesController.dispose();
    _currentConditionsController.dispose();
    _pastConditionsController.dispose();
    _surgeriesController.dispose();
    _vaccinationsController.dispose();
    _currentMedicationsController.dispose();
    _vitaminSupplementsController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    _emergencyContactRelationController.dispose();
    _secondaryContactNameController.dispose();
    _secondaryContactPhoneController.dispose();
    _secondaryContactRelationController.dispose();
    _primaryPhysicianNameController.dispose();
    _primaryPhysicianSpecialtyController.dispose();
    _primaryPhysicianPhoneController.dispose();
    _primaryPhysicianEmailController.dispose();
    _insuranceProviderController.dispose();
    _insurancePolicyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.assignment,
                      size: 32,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Family Health Information Wizard',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Complete comprehensive health profile for family members',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF616161), // Colors.grey[700]
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Progress Indicator
                Row(
                  children: [
                    for (int i = 0; i < _totalSteps; i++) ...[
                      _buildStepIndicator(i),
                      if (i < _totalSteps - 1)
                        Expanded(
                          child: Container(
                            height: 2,
                            color: i < _currentStep
                                ? Theme.of(context).primaryColor
                                : Colors.grey[300],
                          ),
                        ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Step ${_currentStep + 1} of $_totalSteps: ${_stepTitles[_currentStep]}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Form Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildPersonalDetailsStep(),
                _buildMedicalHistoryStep(),
                _buildMedicationsStep(),
                _buildEmergencyContactsStep(),
                _buildPhysicianInfoStep(),
              ],
            ),
          ),

          // Navigation Buttons
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _currentStep > 0
                    ? ElevatedButton.icon(
                        onPressed: _previousStep,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Previous'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[600],
                          foregroundColor: Colors.white,
                        ),
                      )
                    : const SizedBox.shrink(),
                Row(
                  children: [
                    TextButton(
                      onPressed: _saveAsDraft,
                      child: const Text('Save as Draft'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _nextStep,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(_currentStep == _totalSteps - 1
                              ? Icons.check
                              : Icons.arrow_forward),
                      label: Text(_currentStep == _totalSteps - 1
                          ? 'Complete Profile'
                          : 'Next'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step) {
    final isCompleted = step < _currentStep;
    final isCurrent = step == _currentStep;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? Theme.of(context).primaryColor
            : isCurrent
                ? Theme.of(context).primaryColor
                : Colors.grey[300],
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : Text(
                '${step + 1}',
                style: TextStyle(
                  color: isCurrent ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildPersonalDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _personalDetailsFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Personal Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter first name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter last name';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dateOfBirthController,
                        decoration: const InputDecoration(
                          labelText: 'Date of Birth *',
                          border: OutlineInputBorder(),
                          hintText: 'MM/DD/YYYY',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter date of birth';
                          }
                          return null;
                        },
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now()
                                .subtract(const Duration(days: 365 * 30)),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            _dateOfBirthController.text =
                                '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
                          }
                        },
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: const InputDecoration(
                          labelText: 'Gender *',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Male', 'Female', 'Other']
                            .map((gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _bloodGroupController,
                        decoration: const InputDecoration(
                          labelText: 'Blood Group',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., A+, B-, O+',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _heightController,
                        decoration: const InputDecoration(
                          labelText: 'Height',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., 5\'8", 170 cm',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _weightController,
                        decoration: const InputDecoration(
                          labelText: 'Weight',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., 150 lbs, 70 kg',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedicalHistoryStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _medicalHistoryFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Medical History',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _allergiesController,
                  decoration: const InputDecoration(
                    labelText: 'Known Allergies',
                    border: OutlineInputBorder(),
                    hintText:
                        'List any known allergies (food, medication, environmental)',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _currentConditionsController,
                  decoration: const InputDecoration(
                    labelText: 'Current Medical Conditions',
                    border: OutlineInputBorder(),
                    hintText: 'List any ongoing medical conditions',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pastConditionsController,
                  decoration: const InputDecoration(
                    labelText: 'Past Medical Conditions',
                    border: OutlineInputBorder(),
                    hintText: 'List any past medical conditions or illnesses',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _surgeriesController,
                  decoration: const InputDecoration(
                    labelText: 'Previous Surgeries/Procedures',
                    border: OutlineInputBorder(),
                    hintText:
                        'List any previous surgeries or medical procedures',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _vaccinationsController,
                  decoration: const InputDecoration(
                    labelText: 'Vaccination History',
                    border: OutlineInputBorder(),
                    hintText: 'List recent vaccinations and dates',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedicationsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _medicationsFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Medications & Supplements',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _currentMedicationsController,
                  decoration: const InputDecoration(
                    labelText: 'Current Medications',
                    border: OutlineInputBorder(),
                    hintText:
                        'List all current medications with dosages and frequency',
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _vitaminSupplementsController,
                  decoration: const InputDecoration(
                    labelText: 'Vitamins & Supplements',
                    border: OutlineInputBorder(),
                    hintText:
                        'List any vitamins, supplements, or herbal remedies',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyContactsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _emergencyContactsFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Emergency Contacts',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Primary Emergency Contact',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emergencyContactNameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter emergency contact name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _emergencyContactPhoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emergencyContactRelationController,
                  decoration: const InputDecoration(
                    labelText: 'Relationship *',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., Spouse, Parent, Sibling',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter relationship';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Secondary Emergency Contact',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _secondaryContactNameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _secondaryContactPhoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _secondaryContactRelationController,
                  decoration: const InputDecoration(
                    labelText: 'Relationship',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., Friend, Relative',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhysicianInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _physicianInfoFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Physician & Insurance Information',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Primary Physician',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _primaryPhysicianNameController,
                        decoration: const InputDecoration(
                          labelText: 'Physician Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _primaryPhysicianSpecialtyController,
                        decoration: const InputDecoration(
                          labelText: 'Specialty',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., Family Medicine, Cardiology',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _primaryPhysicianPhoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _primaryPhysicianEmailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Insurance Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _insuranceProviderController,
                        decoration: const InputDecoration(
                          labelText: 'Insurance Provider',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., Blue Cross, Aetna, Kaiser',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _insurancePolicyController,
                        decoration: const InputDecoration(
                          labelText: 'Policy/Member ID',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _nextStep() {
    // Validate current step
    bool isValid = false;
    switch (_currentStep) {
      case 0:
        isValid = _personalDetailsFormKey.currentState?.validate() ?? false;
        break;
      case 1:
        isValid = _medicalHistoryFormKey.currentState?.validate() ?? false;
        break;
      case 2:
        isValid = _medicationsFormKey.currentState?.validate() ?? false;
        break;
      case 3:
        isValid = _emergencyContactsFormKey.currentState?.validate() ?? false;
        break;
      case 4:
        isValid = _physicianInfoFormKey.currentState?.validate() ?? false;
        break;
    }

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeProfile();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Create comprehensive health info
      final healthInfo = ComprehensiveHealthInfo(
        id: '', // Will be set by Firestore
        userId: userId,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        dateOfBirth: _dateOfBirthController.text,
        gender: _selectedGender.toLowerCase(),
        address: _addressController.text,
        bloodGroup: _bloodGroupController.text,
        height: _heightController.text,
        weight: _weightController.text,
        allergies: _allergiesController.text,
        currentConditions: _currentConditionsController.text,
        pastConditions: _pastConditionsController.text,
        surgeries: _surgeriesController.text,
        vaccinations: _vaccinationsController.text,
        currentMedications: _currentMedicationsController.text,
        supplements: _vitaminSupplementsController.text,
        emergencyContactName: _emergencyContactNameController.text,
        emergencyContactPhone: _emergencyContactPhoneController.text,
        emergencyContactRelation: _emergencyContactRelationController.text,
        secondaryContactName: _secondaryContactNameController.text,
        secondaryContactPhone: _secondaryContactPhoneController.text,
        secondaryContactRelation: _secondaryContactRelationController.text,
        primaryPhysicianName: _primaryPhysicianNameController.text,
        primaryPhysicianSpecialty: _primaryPhysicianSpecialtyController.text,
        primaryPhysicianPhone: _primaryPhysicianPhoneController.text,
        primaryPhysicianEmail: _primaryPhysicianEmailController.text,
        insuranceProvider: _insuranceProviderController.text,
        insurancePolicy: _insurancePolicyController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirestoreService().saveComprehensiveHealthInfo(healthInfo);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Health profile completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form or navigate away
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveAsDraft() async {
    // Implementation for saving as draft
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draft saved successfully!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _currentStep = 0;
    });
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // Clear all controllers
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _dateOfBirthController.clear();
    _addressController.clear();
    _bloodGroupController.clear();
    _heightController.clear();
    _weightController.clear();
    _allergiesController.clear();
    _currentConditionsController.clear();
    _pastConditionsController.clear();
    _surgeriesController.clear();
    _vaccinationsController.clear();
    _currentMedicationsController.clear();
    _vitaminSupplementsController.clear();
    _emergencyContactNameController.clear();
    _emergencyContactPhoneController.clear();
    _emergencyContactRelationController.clear();
    _secondaryContactNameController.clear();
    _secondaryContactPhoneController.clear();
    _secondaryContactRelationController.clear();
    _primaryPhysicianNameController.clear();
    _primaryPhysicianSpecialtyController.clear();
    _primaryPhysicianPhoneController.clear();
    _primaryPhysicianEmailController.clear();
    _insuranceProviderController.clear();
    _insurancePolicyController.clear();
  }
}
