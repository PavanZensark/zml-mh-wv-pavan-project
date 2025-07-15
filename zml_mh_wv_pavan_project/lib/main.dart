import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'firebase_options.dart';
import 'utils/platform_utils.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/notification_service.dart';
import 'providers/auth_provider.dart';
import 'providers/health_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/medication_provider.dart';
import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize timezone data
  tz.initializeTimeZones();

  // Initialize notifications on mobile
  if (PlatformUtils.isMobile) {
    await NotificationService().initialize();
    await NotificationService().requestPermissions();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(context.read<AuthService>()),
        ),
        ChangeNotifierProvider<HealthProvider>(
          create: (context) => HealthProvider(context.read<FirestoreService>()),
        ),
        ChangeNotifierProvider<AppointmentProvider>(
          create: (context) =>
              AppointmentProvider(context.read<FirestoreService>()),
        ),
        ChangeNotifierProvider<MedicationProvider>(
          create: (context) =>
              MedicationProvider(context.read<FirestoreService>()),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812), // iPhone 11 Pro size
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
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading spinner while AuthProvider is initializing
        if (authProvider.isLoading) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  const Text('Initializing app...'),
                ],
              ),
            ),
          );
        }

        // Show main content based on auth state
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
                const SizedBox(height: 32),
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

      final authProvider = context.read<AuthProvider>();
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

      final authProvider = context.read<AuthProvider>();
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
              context.read<AuthProvider>().signOut();
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                const SizedBox(height: 16),
                if (user?.role == UserRole.physician) ...[
                  const Text('Physician Dashboard'),
                  const Text('- Search patients'),
                  const Text('- View health summaries'),
                  const Text('- Manage patient data'),
                ] else ...[
                  const Text('Family Dashboard'),
                  const Text('- Health Information Wizard'),
                  const Text('- Health Summary Generation'),
                  const Text('- Family Health Profiles'),
                ],
              ],
            ),
          );
        },
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
              context.read<AuthProvider>().signOut();
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                const SizedBox(height: 16),
                const Text('Mobile Features:'),
                const Text('- Basic Health Information'),
                const Text('- Appointment Management'),
                const Text('- Medication Reminders'),
                const Text('- Notification Alerts'),
              ],
            ),
          );
        },
      ),
    );
  }
}
