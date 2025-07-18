import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/comprehensive_health_info.dart';
import '../../services/firestore_service.dart';
import '../../widgets/theme_toggle_button.dart';

class PhysicianDashboardScreen extends StatefulWidget {
  const PhysicianDashboardScreen({super.key});

  @override
  State<PhysicianDashboardScreen> createState() =>
      _PhysicianDashboardScreenState();
}

class _PhysicianDashboardScreenState extends State<PhysicianDashboardScreen> {
  List<ComprehensiveHealthInfo> _allPatients = [];
  List<ComprehensiveHealthInfo> _filteredPatients = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  ComprehensiveHealthInfo? _selectedPatient;

  @override
  void initState() {
    super.initState();
    _loadAllPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllPatients() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // For now, we'll get all patients. In a real app, you'd want to implement
      // proper patient-physician relationships and only show assigned patients
      final patients = await _getAllPatientsHealthInfo();
      setState(() {
        _allPatients = patients;
        _filteredPatients = patients;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading patients: $e'),
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

  Future<List<ComprehensiveHealthInfo>> _getAllPatientsHealthInfo() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.user;

      if (currentUser == null) return [];

      // Get patients assigned to this physician
      final patients =
          await FirestoreService().getPatientsByPhysicianId(currentUser.id);

      // If no patients assigned, get all patients for demo purposes
      if (patients.isEmpty) {
        return await FirestoreService().getAllPatientsHealthInfo();
      }

      return patients;
    } catch (e) {
      print('Error loading patients: $e');
      return [];
    }
  }

  void _filterPatients(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPatients = _allPatients;
      } else {
        _filteredPatients = _allPatients.where((patient) {
          final name = '${patient.firstName} ${patient.lastName}'.toLowerCase();
          final email = patient.email.toLowerCase();
          final searchQuery = query.toLowerCase();
          return name.contains(searchQuery) ||
              email.contains(searchQuery) ||
              patient.id.toLowerCase().contains(searchQuery);
        }).toList();
      }
    });
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
                      Icons.dashboard,
                      size: 32,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Physician Dashboard',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Review patient health summaries and manage care',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(
                                0xFF616161), // Colors.grey[700] for better contrast
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const ThemeToggleButton(showText: true),
                    const SizedBox(width: 16),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        final user = authProvider.user;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Dr. ${user?.fullName ?? 'Physician'}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Licensed Physician',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(
                                    0xFF757575), // Colors.grey[600] for better contrast
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    const ThemeToggleButton(), // Add the theme toggle button here
                  ],
                ),
                const SizedBox(height: 24),

                // Search Bar
                Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search patients by name, email, or ID...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: _filterPatients,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPatients.isEmpty
                    ? _buildEmptyState()
                    : Row(
                        children: [
                          // Patient List
                          Container(
                            width: 350,
                            color: Colors.white,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    border: Border(
                                      bottom:
                                          BorderSide(color: Colors.grey[400]!),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.people,
                                          size: 20, color: Colors.black87),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Patients (${_filteredPatients.length})',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _filteredPatients.length,
                                    itemBuilder: (context, index) {
                                      final patient = _filteredPatients[index];
                                      final isSelected =
                                          patient.id == _selectedPatient?.id;

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
                                            '${patient.firstName[0]}${patient.lastName[0]}',
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.grey[800],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          patient.fullName,
                                          style: TextStyle(
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(patient.email),
                                            Text(
                                              'DOB: ${patient.dateOfBirth}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        trailing: patient.currentConditions
                                                    ?.isNotEmpty ==
                                                true
                                            ? Icon(
                                                Icons.warning,
                                                color: Colors.orange[600],
                                                size: 20,
                                              )
                                            : null,
                                        onTap: () {
                                          setState(() {
                                            _selectedPatient = patient;
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Patient Details
                          Expanded(
                            child: _selectedPatient != null
                                ? _buildPatientDetails(_selectedPatient!)
                                : _buildSelectPatientPrompt(),
                          ),
                        ],
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadAllPatients,
        tooltip: 'Refresh Patient List',
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
            Icons.people_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No patients found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Patients with health profiles will appear here',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF757575), // Colors.grey[600] for better contrast
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadAllPatients,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectPatientPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Select a patient to view their health summary',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Patient health information will be displayed here',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF757575), // Colors.grey[600] for better contrast
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientDetails(ComprehensiveHealthInfo patient) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.1),
                    Theme.of(context).primaryColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      '${patient.firstName[0]}${patient.lastName[0]}',
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
                          patient.fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'DOB: ${patient.dateOfBirth} • Gender: ${patient.gender}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Contact: ${patient.email} • ${patient.phone}',
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PATIENT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last Updated: ${patient.updatedAt.toString().split(' ')[0]}',
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

            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Blood Group',
                    patient.bloodGroup ?? 'Not provided',
                    Icons.water_drop,
                    Colors.red[100]!,
                    Colors.red[600]!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Height',
                    patient.height ?? 'Not provided',
                    Icons.height,
                    Colors.blue[100]!,
                    Colors.blue[600]!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Weight',
                    patient.weight ?? 'Not provided',
                    Icons.fitness_center,
                    Colors.green[100]!,
                    Colors.green[600]!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Allergies',
                    patient.allergies?.isNotEmpty == true ? 'Yes' : 'None',
                    Icons.warning,
                    Colors.orange[100]!,
                    Colors.orange[600]!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Medical Information Sections
            if (patient.allergies?.isNotEmpty == true)
              _buildAlertSection(
                'Allergies',
                patient.allergies!,
                Icons.warning,
                Colors.red,
              ),

            if (patient.currentConditions?.isNotEmpty == true)
              _buildAlertSection(
                'Current Medical Conditions',
                patient.currentConditions!,
                Icons.medical_services,
                Colors.orange,
              ),

            // Current Medications
            if (patient.currentMedications?.isNotEmpty == true)
              _buildInfoSection(
                'Current Medications',
                patient.currentMedications!,
                Icons.medication,
              ),

            // Medical History
            if (patient.pastConditions?.isNotEmpty == true)
              _buildInfoSection(
                'Past Medical Conditions',
                patient.pastConditions!,
                Icons.history,
              ),

            if (patient.surgeries?.isNotEmpty == true)
              _buildInfoSection(
                'Previous Surgeries',
                patient.surgeries!,
                Icons.healing,
              ),

            // Emergency Contacts
            _buildContactSection(patient),

            // Healthcare Providers
            if (patient.primaryPhysicianName?.isNotEmpty == true)
              _buildPhysicianSection(patient),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _printPatientSummary(patient),
                  icon: const Icon(Icons.print),
                  label: const Text('Print Summary'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _exportPatientPDF(patient),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Export PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _sendSecureMessage(patient),
                  icon: const Icon(Icons.message),
                  label: const Text('Send Message'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon,
      Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertSection(
      String title, String content, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(ComprehensiveHealthInfo patient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emergency,
                    color: Theme.of(context).primaryColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildContactInfo(
              'Primary Contact',
              patient.emergencyContactName,
              patient.emergencyContactPhone,
              patient.emergencyContactRelation,
            ),
            if (patient.secondaryContactName?.isNotEmpty == true)
              _buildContactInfo(
                'Secondary Contact',
                patient.secondaryContactName!,
                patient.secondaryContactPhone ?? '',
                patient.secondaryContactRelation ?? '',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(
      String label, String name, String phone, String relation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(
                      0xFF757575)), // Colors.grey[600] for better contrast
            ),
          ),
          Expanded(
            child: Text('$name ($relation) - $phone'),
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicianSection(ComprehensiveHealthInfo patient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_hospital,
                    color: Theme.of(context).primaryColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Primary Physician',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Name: ${patient.primaryPhysicianName}'),
            if (patient.primaryPhysicianSpecialty?.isNotEmpty == true)
              Text('Specialty: ${patient.primaryPhysicianSpecialty}'),
            if (patient.primaryPhysicianPhone?.isNotEmpty == true)
              Text('Phone: ${patient.primaryPhysicianPhone}'),
            if (patient.primaryPhysicianEmail?.isNotEmpty == true)
              Text('Email: ${patient.primaryPhysicianEmail}'),
          ],
        ),
      ),
    );
  }

  void _printPatientSummary(ComprehensiveHealthInfo patient) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Printing summary for ${patient.fullName}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _exportPatientPDF(ComprehensiveHealthInfo patient) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting PDF for ${patient.fullName}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _sendSecureMessage(ComprehensiveHealthInfo patient) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Send secure message to ${patient.fullName}'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
