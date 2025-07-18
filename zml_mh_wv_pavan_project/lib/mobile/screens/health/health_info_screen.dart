import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/health_provider.dart';
import '../../../models/health_info_model.dart';
import '../../../utils/date_utils.dart' as app_date_utils;

class HealthInfoScreen extends StatefulWidget {
  const HealthInfoScreen({super.key});

  @override
  State<HealthInfoScreen> createState() => _HealthInfoScreenState();
}

class _HealthInfoScreenState extends State<HealthInfoScreen> {
  @override
  void initState() {
    super.initState();
    // Load health info when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final healthProvider = context.read<HealthProvider>();
      if (authProvider.user != null) {
        healthProvider.loadHealthProfiles(authProvider.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Information'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddHealthInfoScreen(),
                ),
              );

              // Refresh the health profiles when returning from add screen
              if (result == true && mounted) {
                final authProvider = context.read<AuthProvider>();
                final healthProvider = context.read<HealthProvider>();
                if (authProvider.user != null) {
                  healthProvider.loadHealthProfiles(authProvider.user!.id);
                }
              }
            },
          ),
        ],
      ),
      body: Consumer2<AuthProvider, HealthProvider>(
        builder: (context, authProvider, healthProvider, child) {
          final user = authProvider.user;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show loading indicator while loading health profiles
          if (healthProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error if there's an error loading health profiles
          if (healthProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading health information',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    healthProvider.error!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      healthProvider.loadHealthProfiles(user.id);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final healthInfo = healthProvider.healthProfiles.isNotEmpty
              ? healthProvider.healthProfiles.first
              : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Summary Card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                '${user.firstName[0]}${user.lastName[0]}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${user.firstName} ${user.lastName}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                  Text(
                                    user.email,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const EditHealthInfoScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Health Information
                if (healthInfo != null) ...[
                  _buildHealthInfoSection(context, healthInfo),
                ] else ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.health_and_safety,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No health information added yet',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your basic health information to get started.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AddHealthInfoScreen(),
                                ),
                              );
                            },
                            child: const Text('Add Health Information'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHealthInfoSection(
      BuildContext context, HealthInfoModel healthInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Information',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),

        // Basic Info
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Basic Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                    'Date of Birth',
                    app_date_utils.DateUtils.formatDate(
                        healthInfo.dateOfBirth)),
                _buildInfoRow('Gender', healthInfo.gender),
                _buildInfoRow('Blood Group', healthInfo.bloodGroup.name),
                _buildInfoRow('Height', '${healthInfo.height} cm'),
                _buildInfoRow('Weight', '${healthInfo.weight} kg'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Allergies
        if (healthInfo.allergies.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Allergies',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: healthInfo.allergies.map((allergy) {
                      return Chip(
                        label: Text(allergy),
                        backgroundColor: Colors.red[100],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],

        // Emergency Contact
        if (healthInfo.emergencyContact != null) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emergency Contact',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.contact_phone, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              healthInfo.emergencyContact!,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (healthInfo.emergencyContactPhone != null)
                              Text(
                                healthInfo.emergencyContactPhone!,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}

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
  final _emergencyContactController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();

  DateTime? _dateOfBirth;
  String _gender = 'Male';
  BloodGroup _bloodGroup = BloodGroup.aPositive;
  final List<String> _allergies = [];
  final List<String> _medicalConditions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Health Information'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveHealthInfo,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First Name
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Last Name
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date of Birth
              Text(
                'Date of Birth',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate:
                        DateTime.now().subtract(const Duration(days: 365 * 25)),
                    firstDate: DateTime.now()
                        .subtract(const Duration(days: 365 * 100)),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _dateOfBirth = date;
                    });
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 8),
                      Text(
                        _dateOfBirth != null
                            ? app_date_utils.DateUtils.formatDate(_dateOfBirth!)
                            : 'Select Date of Birth',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Gender
              Text(
                'Gender',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: ['Male', 'Female', 'Other'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _gender = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Blood Group
              Text(
                'Blood Group',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<BloodGroup>(
                value: _bloodGroup,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: BloodGroup.values.map((BloodGroup value) {
                  return DropdownMenuItem<BloodGroup>(
                    value: value,
                    child: Text(_getBloodGroupDisplayText(value)),
                  );
                }).toList(),
                onChanged: (BloodGroup? newValue) {
                  setState(() {
                    _bloodGroup = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Height
              TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your height';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Weight
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your weight';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Allergies
              Text(
                'Allergies',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _allergiesController,
                decoration: const InputDecoration(
                  labelText: 'Enter allergy (press Enter to add)',
                  border: OutlineInputBorder(),
                ),
                onFieldSubmitted: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      _allergies.add(value);
                      _allergiesController.clear();
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allergies.map((allergy) {
                  return Chip(
                    label: Text(allergy),
                    backgroundColor: Colors.red[100],
                    onDeleted: () {
                      setState(() {
                        _allergies.remove(allergy);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Emergency Contact
              TextFormField(
                controller: _emergencyContactController,
                decoration: const InputDecoration(
                  labelText: 'Emergency Contact Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emergencyContactPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Emergency Contact Phone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveHealthInfo,
                  child: const Text('Save Health Information'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveHealthInfo() async {
    if (_formKey.currentState!.validate() && _dateOfBirth != null) {
      final authProvider = context.read<AuthProvider>();
      final healthProvider = context.read<HealthProvider>();

      print(
          'Creating health info for user: ${authProvider.user!.id}'); // Debug log

      final healthInfo = HealthInfoModel(
        id: '',
        userId: authProvider.user!.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        dateOfBirth: _dateOfBirth!,
        gender: _gender,
        bloodGroup: _bloodGroup,
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        allergies: _allergies,
        medicalConditions: _medicalConditions,
        emergencyContact: _emergencyContactController.text.trim().isNotEmpty
            ? _emergencyContactController.text.trim()
            : null,
        emergencyContactPhone:
            _emergencyContactPhoneController.text.trim().isNotEmpty
                ? _emergencyContactPhoneController.text.trim()
                : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print(
          'Health info created: ${healthInfo.firstName} ${healthInfo.lastName}'); // Debug log

      try {
        bool success = await healthProvider.createHealthProfile(healthInfo);
        print('Save result: $success'); // Debug log

        if (mounted) {
          if (success) {
            print('Successfully saved health info'); // Debug log
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Health information saved successfully')),
            );
            Navigator.pop(context, true); // Return true to indicate success
          } else {
            print(
                'Failed to save health info: ${healthProvider.error}'); // Debug log
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Error saving health information: ${healthProvider.error ?? 'Unknown error'}')),
            );
          }
        }
      } catch (e) {
        print('Exception while saving health info: $e'); // Debug log
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving health information: $e')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
    }
  }

  String _getBloodGroupDisplayText(BloodGroup bloodGroup) {
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

class EditHealthInfoScreen extends StatefulWidget {
  const EditHealthInfoScreen({super.key});

  @override
  State<EditHealthInfoScreen> createState() => _EditHealthInfoScreenState();
}

class _EditHealthInfoScreenState extends State<EditHealthInfoScreen> {
  // Similar implementation to AddHealthInfoScreen but with pre-filled data
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Health Information'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Edit Health Information - To be implemented'),
      ),
    );
  }
}
