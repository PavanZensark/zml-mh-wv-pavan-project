import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/comprehensive_health_info.dart';

class WebProfileScreen extends StatefulWidget {
  const WebProfileScreen({super.key});

  @override
  State<WebProfileScreen> createState() => _WebProfileScreenState();
}

class _WebProfileScreenState extends State<WebProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;

  // Physician assignment related state
  List<Map<String, dynamic>> _physicians = [];
  String? _selectedPhysicianId;
  String? _currentAssignedPhysicianId;
  ComprehensiveHealthInfo? _currentHealthInfo;
  bool _isLoadingPhysicians = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _emailController.text = user.email;
      // Phone field will be handled separately if needed

      // Load health info and physicians if user is not a physician
      if (user.role.toString().split('.').last != 'physician') {
        _loadHealthInfo();
        _loadPhysicians();
      }
    }
  }

  Future<void> _loadHealthInfo() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) return;

    try {
      final healthInfo =
          await FirestoreService().getComprehensiveHealthInfo(user.id);
      if (mounted) {
        setState(() {
          _currentHealthInfo = healthInfo;
          _currentAssignedPhysicianId = healthInfo?.assignedPhysicianId;
          _selectedPhysicianId = healthInfo?.assignedPhysicianId;
        });
      }
    } catch (e) {
      // Health info might not exist yet, which is fine
      print('No health info found: $e');
    }
  }

  Future<void> _loadPhysicians() async {
    setState(() {
      _isLoadingPhysicians = true;
    });

    try {
      final physicians = await FirestoreService().getAllPhysicians();
      if (mounted) {
        setState(() {
          _physicians = physicians;
          _isLoadingPhysicians = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPhysicians = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading physicians: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _assignPhysician() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // If no health info exists, we need to create a basic one first
      if (_currentHealthInfo == null) {
        // Only create if we're assigning a physician (not removing)
        if (_selectedPhysicianId != null) {
          final basicHealthInfo = ComprehensiveHealthInfo(
            id: '', // Will be set by Firestore
            userId: user.id,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            phone: '',
            dateOfBirth: '',
            gender: '',
            emergencyContactName: '',
            emergencyContactPhone: '',
            emergencyContactRelation: '',
            assignedPhysicianId: _selectedPhysicianId,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          final newHealthInfoId = await FirestoreService()
              .saveComprehensiveHealthInfo(basicHealthInfo);
          // Create the health info object with the new ID
          _currentHealthInfo = ComprehensiveHealthInfo(
            id: newHealthInfoId,
            userId: user.id,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            phone: '',
            dateOfBirth: '',
            gender: '',
            emergencyContactName: '',
            emergencyContactPhone: '',
            emergencyContactRelation: '',
            assignedPhysicianId: _selectedPhysicianId,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
      } else {
        // Update existing health info with physician assignment
        await FirestoreService().assignPhysicianToPatient(
          _currentHealthInfo!.id,
          _selectedPhysicianId ?? '', // Empty string for removing physician
        );
      }

      if (mounted) {
        setState(() {
          _currentAssignedPhysicianId = _selectedPhysicianId;
          _isLoading = false;
        });

        final message = _selectedPhysicianId == null
            ? 'Physician removed successfully!'
            : 'Physician assigned successfully!';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating physician assignment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          user != null
                              ? '${user.firstName[0]}${user.lastName[0]}'
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName ?? 'User Profile',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: user?.role.toString().split('.').last ==
                                        'physician'
                                    ? Colors.blue[100]
                                    : Colors.green[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                user?.role
                                        .toString()
                                        .split('.')
                                        .last
                                        .toUpperCase() ??
                                    'FAMILY',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      user?.role.toString().split('.').last ==
                                              'physician'
                                          ? Colors.blue[800]
                                          : Colors.green[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!_isEditing)
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isEditing = true;
                            });
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Profile'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Profile Information
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Profile Information',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (_isEditing) ...[
                          // Edit Mode
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _firstNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'First Name',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _lastNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Last Name',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            enabled: false, // Email should not be editable
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 24),

                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _isLoading ? null : _saveProfile,
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Icon(Icons.save),
                                label: const Text('Save Changes'),
                              ),
                              const SizedBox(width: 16),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isEditing = false;
                                  });
                                  _loadUserData(); // Reset to original data
                                },
                                child: const Text('Cancel'),
                              ),
                            ],
                          ),
                        ] else ...[
                          // View Mode
                          _buildInfoRow('First Name', user?.firstName ?? ''),
                          _buildInfoRow('Last Name', user?.lastName ?? ''),
                          _buildInfoRow('Email', user?.email ?? ''),
                          _buildInfoRow('Account Type',
                              user?.role.toString().split('.').last ?? ''),
                          _buildInfoRow('Member Since',
                              user?.createdAt.toString().split(' ')[0] ?? ''),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Physician Assignment (only for non-physician users)
                if (user?.role.toString().split('.').last != 'physician') ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.local_hospital,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Physician Assignment',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Select your primary physician to enable better care coordination.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_currentAssignedPhysicianId != null &&
                              _physicians.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                border: Border.all(color: Colors.green[200]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle,
                                      color: Colors.green[600]),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      () {
                                        final physician =
                                            _physicians.firstWhere(
                                          (p) =>
                                              p['id'] ==
                                              _currentAssignedPhysicianId,
                                          orElse: () => {
                                            'firstName': 'Unknown',
                                            'lastName': 'Physician'
                                          },
                                        );
                                        return 'Currently assigned to: ${physician['firstName']} ${physician['lastName']}';
                                      }(),
                                      style:
                                          TextStyle(color: Colors.green[800]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (_isLoadingPhysicians)
                            const Center(child: CircularProgressIndicator())
                          else if (_physicians.isNotEmpty) ...[
                            DropdownButtonFormField<String>(
                              value: _selectedPhysicianId,
                              decoration: const InputDecoration(
                                labelText: 'Select Physician',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('No physician assigned'),
                                ),
                                ..._physicians.map((physician) {
                                  return DropdownMenuItem<String>(
                                    value: physician['id'],
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${physician['firstName']} ${physician['lastName']}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          physician['specialty'] ??
                                              'General Practice',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedPhysicianId = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            if (_selectedPhysicianId !=
                                _currentAssignedPhysicianId)
                              ElevatedButton.icon(
                                onPressed: _isLoading ? null : _assignPhysician,
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Icon(Icons.assignment_ind),
                                label: Text(_selectedPhysicianId == null
                                    ? 'Remove Physician'
                                    : 'Assign Physician'),
                              ),
                          ] else
                            const Text(
                              'No physicians available. Please contact support.',
                              style: TextStyle(color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Account Settings
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.settings,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Account Settings',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ListTile(
                          leading: const Icon(Icons.lock),
                          title: const Text('Change Password'),
                          subtitle: const Text('Update your account password'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: _changePassword,
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.notifications),
                          title: const Text('Notification Settings'),
                          subtitle: const Text(
                              'Manage your notification preferences'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: _notificationSettings,
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.privacy_tip),
                          title: const Text('Privacy Settings'),
                          subtitle:
                              const Text('Control your data privacy options'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: _privacySettings,
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.download),
                          title: const Text('Export Data'),
                          subtitle: const Text('Download your health data'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: _exportData,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Danger Zone
                Card(
                  color: Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning,
                              color: Colors.red[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Danger Zone',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'These actions are irreversible. Please proceed with caution.',
                          style: TextStyle(
                            color: Colors.red[700],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _deleteAccount,
                          icon: const Icon(Icons.delete_forever),
                          label: const Text('Delete Account'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Here you would implement the actual profile update logic
      // For now, we'll just simulate a delay
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
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

  void _changePassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('Change password functionality would be implemented here'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _notificationSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification settings would be implemented here'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _privacySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Privacy settings would be implemented here'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data export functionality would be implemented here'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Account'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your health data will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Account deletion functionality would be implemented here'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}
