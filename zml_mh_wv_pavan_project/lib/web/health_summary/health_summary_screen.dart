import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/comprehensive_health_info.dart';
import '../../services/firestore_service.dart';

class HealthSummaryScreen extends StatefulWidget {
  const HealthSummaryScreen({super.key});

  @override
  State<HealthSummaryScreen> createState() => _HealthSummaryScreenState();
}

class _HealthSummaryScreenState extends State<HealthSummaryScreen> {
  List<ComprehensiveHealthInfo> _healthProfiles = [];
  bool _isLoading = true;
  String? _selectedProfileId;

  @override
  void initState() {
    super.initState();
    _loadHealthProfiles();
  }

  Future<void> _loadHealthProfiles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId != null) {
        final profiles =
            await FirestoreService().getComprehensiveHealthInfoByUserId(userId);
        setState(() {
          _healthProfiles = profiles;
          if (profiles.isNotEmpty && _selectedProfileId == null) {
            _selectedProfileId = profiles.first.id;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading health profiles: $e'),
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

  ComprehensiveHealthInfo? get _selectedProfile {
    if (_selectedProfileId == null) return null;
    try {
      return _healthProfiles
          .firstWhere((profile) => profile.id == _selectedProfileId);
    } catch (e) {
      return null;
    }
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
            child: Row(
              children: [
                Icon(
                  Icons.description,
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Summary Reports',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Generate and view comprehensive health summaries',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(
                            0xFF616161), // Colors.grey[700] for better contrast
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (_selectedProfile != null) ...[
                  ElevatedButton.icon(
                    onPressed: _printSummary,
                    icon: const Icon(Icons.print),
                    label: const Text('Print'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _exportPDF,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Export PDF'),
                  ),
                ],
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _healthProfiles.isEmpty
                    ? _buildEmptyState()
                    : Row(
                        children: [
                          // Profile Selector
                          Container(
                            width: 300,
                            color: Colors.white,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    border: Border(
                                      bottom:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.people, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Family Members',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _healthProfiles.length,
                                    itemBuilder: (context, index) {
                                      final profile = _healthProfiles[index];
                                      final isSelected =
                                          profile.id == _selectedProfileId;

                                      return ListTile(
                                        selected: isSelected,
                                        selectedTileColor: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.1),
                                        leading: CircleAvatar(
                                          backgroundColor: isSelected
                                              ? Theme.of(context).primaryColor
                                              : Colors.grey[400],
                                          child: Text(
                                            '${profile.firstName[0]}${profile.lastName[0]}',
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.grey[800],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          profile.fullName,
                                          style: TextStyle(
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        subtitle: Text(profile.email),
                                        onTap: () {
                                          setState(() {
                                            _selectedProfileId = profile.id;
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Summary Display
                          Expanded(
                            child: _selectedProfile != null
                                ? _buildHealthSummary(_selectedProfile!)
                                : const Center(
                                    child: Text(
                                        'Select a family member to view their health summary'),
                                  ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadHealthProfiles,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No health profiles found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete the Health Wizard to create health profiles',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF757575), // Colors.grey[600] for better contrast
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthSummary(ComprehensiveHealthInfo profile) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      '${profile.firstName[0]}${profile.lastName[0]}',
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
                          profile.fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Date of Birth: ${profile.dateOfBirth}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Gender: ${profile.gender}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Health Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Text(
                        'Generated: ${DateTime.now().toString().split(' ')[0]}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(
                              0xFF757575), // Colors.grey[600] for better contrast
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Personal Information
            _buildSectionCard(
              'Personal Information',
              Icons.person,
              [
                _buildInfoRow('Full Name', profile.fullName),
                _buildInfoRow('Email', profile.email),
                _buildInfoRow('Phone', profile.phone),
                _buildInfoRow('Date of Birth', profile.dateOfBirth),
                _buildInfoRow('Gender', profile.gender),
                if (profile.address?.isNotEmpty == true)
                  _buildInfoRow('Address', profile.address!),
                if (profile.bloodGroup?.isNotEmpty == true)
                  _buildInfoRow('Blood Group', profile.bloodGroup!),
                if (profile.height?.isNotEmpty == true)
                  _buildInfoRow('Height', profile.height!),
                if (profile.weight?.isNotEmpty == true)
                  _buildInfoRow('Weight', profile.weight!),
              ],
            ),

            // Medical History
            if (_hasAnyMedicalHistory(profile))
              _buildSectionCard(
                'Medical History',
                Icons.medical_services,
                [
                  if (profile.allergies?.isNotEmpty == true)
                    _buildInfoRow('Allergies', profile.allergies!),
                  if (profile.currentConditions?.isNotEmpty == true)
                    _buildInfoRow(
                        'Current Conditions', profile.currentConditions!),
                  if (profile.pastConditions?.isNotEmpty == true)
                    _buildInfoRow('Past Conditions', profile.pastConditions!),
                  if (profile.surgeries?.isNotEmpty == true)
                    _buildInfoRow('Previous Surgeries', profile.surgeries!),
                  if (profile.vaccinations?.isNotEmpty == true)
                    _buildInfoRow('Vaccination History', profile.vaccinations!),
                ],
              ),

            // Current Medications
            if (_hasAnyMedications(profile))
              _buildSectionCard(
                'Current Medications & Supplements',
                Icons.medication,
                [
                  if (profile.currentMedications?.isNotEmpty == true)
                    _buildInfoRow('Medications', profile.currentMedications!),
                  if (profile.supplements?.isNotEmpty == true)
                    _buildInfoRow('Supplements', profile.supplements!),
                ],
              ),

            // Emergency Contacts
            _buildSectionCard(
              'Emergency Contacts',
              Icons.emergency,
              [
                _buildInfoRow('Primary Contact',
                    '${profile.emergencyContactName} (${profile.emergencyContactRelation})'),
                _buildInfoRow('Primary Phone', profile.emergencyContactPhone),
                if (profile.secondaryContactName?.isNotEmpty == true) ...[
                  _buildInfoRow('Secondary Contact',
                      '${profile.secondaryContactName!} (${profile.secondaryContactRelation ?? 'Not specified'})'),
                  if (profile.secondaryContactPhone?.isNotEmpty == true)
                    _buildInfoRow(
                        'Secondary Phone', profile.secondaryContactPhone!),
                ],
              ],
            ),

            // Healthcare Providers
            if (_hasAnyHealthcareInfo(profile))
              _buildSectionCard(
                'Healthcare Providers & Insurance',
                Icons.local_hospital,
                [
                  if (profile.primaryPhysicianName?.isNotEmpty == true) ...[
                    _buildInfoRow(
                        'Primary Physician', profile.primaryPhysicianName!),
                    if (profile.primaryPhysicianSpecialty?.isNotEmpty == true)
                      _buildInfoRow(
                          'Specialty', profile.primaryPhysicianSpecialty!),
                    if (profile.primaryPhysicianPhone?.isNotEmpty == true)
                      _buildInfoRow(
                          'Physician Phone', profile.primaryPhysicianPhone!),
                    if (profile.primaryPhysicianEmail?.isNotEmpty == true)
                      _buildInfoRow(
                          'Physician Email', profile.primaryPhysicianEmail!),
                  ],
                  if (profile.insuranceProvider?.isNotEmpty == true) ...[
                    _buildInfoRow(
                        'Insurance Provider', profile.insuranceProvider!),
                    if (profile.insurancePolicy?.isNotEmpty == true)
                      _buildInfoRow('Policy Number', profile.insurancePolicy!),
                  ],
                ],
              ),

            const SizedBox(height: 32),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Important Notice',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This health summary is for informational purposes only and should not replace professional medical advice. Please consult with healthcare providers for medical decisions.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last updated: ${profile.updatedAt.toString().split(' ')[0]}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
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
              value.isNotEmpty ? value : 'Not provided',
              style: TextStyle(
                color: value.isNotEmpty ? Colors.black87 : Colors.grey[400],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasAnyMedicalHistory(ComprehensiveHealthInfo profile) {
    return (profile.allergies?.isNotEmpty == true) ||
        (profile.currentConditions?.isNotEmpty == true) ||
        (profile.pastConditions?.isNotEmpty == true) ||
        (profile.surgeries?.isNotEmpty == true) ||
        (profile.vaccinations?.isNotEmpty == true);
  }

  bool _hasAnyMedications(ComprehensiveHealthInfo profile) {
    return (profile.currentMedications?.isNotEmpty == true) ||
        (profile.supplements?.isNotEmpty == true);
  }

  bool _hasAnyHealthcareInfo(ComprehensiveHealthInfo profile) {
    return (profile.primaryPhysicianName?.isNotEmpty == true) ||
        (profile.insuranceProvider?.isNotEmpty == true);
  }

  void _printSummary() {
    // Implementation for printing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Print functionality would be implemented here'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _exportPDF() {
    // Implementation for PDF export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF export functionality would be implemented here'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
