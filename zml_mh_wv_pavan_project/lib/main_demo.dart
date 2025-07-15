import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'utils/platform_utils.dart';
import 'models/user_model.dart';

// Mock services for testing without Firebase
class MockAuthService {
  bool isLoggedIn = false;
  UserModel? currentUser;

  Stream<UserModel?> get authStateChanges => Stream.value(currentUser);

  Future<bool> signIn(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email == 'test@example.com' && password == 'password') {
      currentUser = UserModel(
        id: 'test_user_id',
        email: email,
        firstName: 'Test',
        lastName: 'User',
        role: UserRole.family,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      isLoggedIn = true;
      return true;
    }
    return false;
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
    String? specialization,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    currentUser = UserModel(
      id: 'new_user_id',
      email: email,
      firstName: firstName,
      lastName: lastName,
      role: role,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      specialization: specialization,
    );
    isLoggedIn = true;
    return true;
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    currentUser = null;
    isLoggedIn = false;
  }
}

class MockAuthProvider with ChangeNotifier {
  final MockAuthService _authService = MockAuthService();

  UserModel? get user => _authService.currentUser;
  bool get isLoggedIn => _authService.isLoggedIn;
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.signIn(email, password);
      if (!success) {
        _error = 'Invalid credentials';
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
    String? specialization,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        role: role,
        specialization: specialization,
      );
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    await _authService.signOut();
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MockAuthProvider>(
          create: (_) => MockAuthProvider(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'Zoom My Life - Health Platform',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF0D47A1),
                brightness: Brightness.light,
              ),
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF0D47A1),
                brightness: Brightness.dark,
              ),
            ),
            debugShowCheckedModeBanner: false,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MockAuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoggedIn) {
          return PlatformUtils.isWeb
              ? const WebDashboard()
              : const MobileDashboard();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showRegister = false;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isPhysician = false;
  final _specializationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill with demo credentials
    _emailController.text = 'test@example.com';
    _passwordController.text = 'password';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zoom My Life - Health Platform'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.health_and_safety,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                Card(
                  color: Colors.blue.shade50,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Demo Mode',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Email: test@example.com',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Password: password',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_showRegister) ...[
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
                  SwitchListTile(
                    title: const Text('I am a Physician'),
                    value: _isPhysician,
                    onChanged: (value) {
                      setState(() {
                        _isPhysician = value;
                      });
                    },
                  ),
                  if (_isPhysician) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _specializationController,
                      decoration: const InputDecoration(
                        labelText: 'Specialization',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (_isPhysician && (value == null || value.isEmpty)) {
                          return 'Please enter your specialization';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading ? null : (_showRegister ? _signUp : _signIn),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : Text(_showRegister ? 'Sign Up' : 'Sign In'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showRegister = !_showRegister;
                    });
                  },
                  child: Text(_showRegister
                      ? 'Already have an account? Sign In'
                      : 'Don\'t have an account? Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = context.read<MockAuthProvider>();
      final success = await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authProvider.error ?? 'Sign in failed')),
          );
        }
      }
    }
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = context.read<MockAuthProvider>();
      final success = await authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        role: _isPhysician ? UserRole.physician : UserRole.family,
        specialization:
            _isPhysician ? _specializationController.text.trim() : null,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authProvider.error ?? 'Sign up failed')),
          );
        }
      }
    }
  }
}

class WebDashboard extends StatelessWidget {
  const WebDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZML Health Platform - Web'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<MockAuthProvider>().signOut();
            },
          ),
        ],
      ),
      body: Consumer<MockAuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.web,
                          size: 80,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Welcome, ${user?.fullName ?? 'User'}!',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Role: ${user?.role.name.toUpperCase() ?? 'Unknown'}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (user?.specialization != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Specialization: ${user!.specialization}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (user?.role == UserRole.physician) ...[
                  _buildFeatureCard(
                    'Physician Dashboard',
                    [
                      'Search patients by name or ID',
                      'View comprehensive health summaries',
                      'Access patient medical history',
                      'Review vaccination records',
                      'Monitor medication compliance',
                    ],
                    Icons.local_hospital,
                    Colors.red,
                  ),
                ] else ...[
                  _buildFeatureCard(
                    'Family Health Management',
                    [
                      'Health Information Wizard',
                      'Create family health profiles',
                      'Generate health summaries',
                      'Track medical history',
                      'Manage insurance information',
                    ],
                    Icons.family_restroom,
                    Colors.green,
                  ),
                ],
                const SizedBox(height: 16),
                _buildFeatureCard(
                  'Platform Features',
                  [
                    'Secure Firebase authentication',
                    'Real-time data synchronization',
                    'Responsive web interface',
                    'PDF health summary export',
                    'Role-based access control',
                  ],
                  Icons.security,
                  Colors.blue,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatureCard(
      String title, List<String> features, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: color, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(feature)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class MobileDashboard extends StatelessWidget {
  const MobileDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZML Health Platform'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<MockAuthProvider>().signOut();
            },
          ),
        ],
      ),
      body: Consumer<MockAuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.phone_android,
                          size: 80,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Welcome, ${user?.fullName ?? 'User'}!',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Role: ${user?.role.name.toUpperCase() ?? 'Unknown'}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildMobileFeatureCard(
                  'Health Information',
                  'Manage personal health profiles',
                  Icons.person,
                  Colors.green,
                ),
                const SizedBox(height: 16),
                _buildMobileFeatureCard(
                  'Appointments',
                  'Schedule and track medical appointments',
                  Icons.calendar_today,
                  Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildMobileFeatureCard(
                  'Medications',
                  'Manage medications and set reminders',
                  Icons.medication,
                  Colors.orange,
                ),
                const SizedBox(height: 16),
                _buildMobileFeatureCard(
                  'Notifications',
                  'Receive appointment and medication alerts',
                  Icons.notifications,
                  Colors.purple,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileFeatureCard(
      String title, String description, IconData icon, Color color) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color, size: 40),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Navigate to feature screen
        },
      ),
    );
  }
}
