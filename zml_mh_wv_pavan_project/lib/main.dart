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
import 'providers/theme_provider.dart';
import 'models/user_model.dart';
import 'mobile/screens/mobile_dashboard.dart';
import 'web/dashboard/web_home_screen.dart';
import 'web/dashboard/web_profile_screen.dart';
import 'web/health_wizard/health_wizard_screen.dart';
import 'web/health_summary/health_summary_screen.dart';
import 'web/physician_dashboard/physician_dashboard_screen.dart';
import 'web/physician_dashboard/patient_search_screen.dart';

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
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
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
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                title: 'Zoom My Life - Health Platform',
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                  useMaterial3: true,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: const Color(0xFF0D47A1),
                    brightness: Brightness.light,
                  ).copyWith(
                    surface: Colors.white,
                    onSurface: Colors.black87,
                    primary: const Color(0xFF0D47A1),
                    onPrimary: Colors.white,
                    secondary: const Color(0xFF1976D2),
                    onSecondary: Colors.white,
                  ),
                  // Enhanced text theme with better contrast
                  textTheme: const TextTheme(
                    displayLarge: TextStyle(color: Colors.black87),
                    displayMedium: TextStyle(color: Colors.black87),
                    displaySmall: TextStyle(color: Colors.black87),
                    headlineLarge: TextStyle(color: Colors.black87),
                    headlineMedium: TextStyle(color: Colors.black87),
                    headlineSmall: TextStyle(color: Colors.black87),
                    titleLarge: TextStyle(color: Colors.black87),
                    titleMedium: TextStyle(color: Colors.black87),
                    titleSmall: TextStyle(color: Colors.black87),
                    bodyLarge: TextStyle(color: Colors.black87),
                    bodyMedium: TextStyle(color: Colors.black87),
                    bodySmall: TextStyle(
                        color: Color(
                            0xFF616161)), // Darker grey for better contrast
                    labelLarge: TextStyle(color: Colors.black87),
                    labelMedium: TextStyle(color: Colors.black87),
                    labelSmall: TextStyle(
                        color: Color(
                            0xFF757575)), // Darker grey for better contrast
                  ),
                  // Card theme with proper contrast
                  cardTheme: const CardTheme(
                    color: Colors.white,
                    surfaceTintColor: Colors.white,
                    elevation: 2,
                  ),
                  // App bar theme
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    elevation: 1,
                    surfaceTintColor: Colors.white,
                  ),
                  // Input decoration theme
                  inputDecorationTheme: const InputDecorationTheme(
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                    labelStyle: TextStyle(color: Color(0xFF616161)),
                    hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
                    prefixIconColor: Color(0xFF757575),
                    suffixIconColor: Color(0xFF757575),
                  ),
                ),
                darkTheme: ThemeData(
                  primarySwatch: Colors.blue,
                  useMaterial3: true,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: const Color(0xFF0D47A1),
                    brightness: Brightness.dark,
                  ).copyWith(
                    surface: const Color(0xFF121212),
                    onSurface: Colors.white,
                    primary: const Color(0xFF1976D2),
                    onPrimary: Colors.white,
                    secondary: const Color(0xFF42A5F5),
                    onSecondary: Colors.black,
                  ),
                  // Enhanced text theme for dark mode
                  textTheme: const TextTheme(
                    displayLarge: TextStyle(color: Colors.white),
                    displayMedium: TextStyle(color: Colors.white),
                    displaySmall: TextStyle(color: Colors.white),
                    headlineLarge: TextStyle(color: Colors.white),
                    headlineMedium: TextStyle(color: Colors.white),
                    headlineSmall: TextStyle(color: Colors.white),
                    titleLarge: TextStyle(color: Colors.white),
                    titleMedium: TextStyle(color: Colors.white),
                    titleSmall: TextStyle(color: Colors.white),
                    bodyLarge: TextStyle(color: Colors.white),
                    bodyMedium: TextStyle(color: Colors.white),
                    bodySmall: TextStyle(
                        color: Color(0xFFBDBDBD)), // Light grey for dark mode
                    labelLarge: TextStyle(color: Colors.white),
                    labelMedium: TextStyle(color: Colors.white),
                    labelSmall: TextStyle(
                        color: Color(0xFF9E9E9E)), // Medium grey for dark mode
                  ),
                  // Card theme for dark mode
                  cardTheme: const CardTheme(
                    color: Color(0xFF1E1E1E),
                    surfaceTintColor: Color(0xFF1E1E1E),
                    elevation: 2,
                  ),
                  // App bar theme for dark mode
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Color(0xFF121212),
                    foregroundColor: Colors.white,
                    elevation: 1,
                    surfaceTintColor: Color(0xFF121212),
                  ),
                  // Input decoration theme for dark mode
                  inputDecorationTheme: const InputDecorationTheme(
                    filled: true,
                    fillColor: Color(0xFF2C2C2C),
                    labelStyle: TextStyle(color: Color(0xFFBDBDBD)),
                    hintStyle: TextStyle(color: Color(0xFF757575)),
                    prefixIconColor: Color(0xFF9E9E9E),
                    suffixIconColor: Color(0xFF9E9E9E),
                  ),
                ),
                themeMode: themeProvider.themeMode,
                debugShowCheckedModeBanner: false,
                home: const AuthWrapper(),
              );
            },
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

class WebDashboard extends StatefulWidget {
  const WebDashboard({super.key});

  @override
  State<WebDashboard> createState() => _WebDashboardState();
}

class _WebDashboardState extends State<WebDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        if (user == null) {
          return const LoginScreen();
        }

        final isPhysician = user.role == UserRole.physician;

        final familyScreens = [
          const WebHomeScreen(),
          const HealthWizardScreen(),
          const HealthSummaryScreen(),
          const WebProfileScreen(),
        ];

        final physicianScreens = [
          const PhysicianDashboardScreen(),
          const PatientSearchScreen(),
          const WebProfileScreen(),
        ];

        final screens = isPhysician ? physicianScreens : familyScreens;

        return Scaffold(
          body: Row(
            children: [
              // Sidebar Navigation
              Container(
                width: 250,
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.health_and_safety,
                            size: 40,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'ZML Health Platform',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isPhysician ? 'Physician Portal' : 'Family Portal',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),

                    // Navigation Items
                    Expanded(
                      child: ListView(
                        children: [
                          if (isPhysician) ...[
                            _buildNavItem(0, Icons.dashboard, 'Dashboard'),
                            _buildNavItem(1, Icons.search, 'Patient Search'),
                            _buildNavItem(2, Icons.person, 'Profile'),
                          ] else ...[
                            _buildNavItem(0, Icons.home, 'Home'),
                            _buildNavItem(1, Icons.assignment, 'Health Wizard'),
                            _buildNavItem(
                                2, Icons.description, 'Health Summary'),
                            _buildNavItem(3, Icons.person, 'Profile'),
                          ],
                        ],
                      ),
                    ),

                    const Divider(),

                    // User Info & Logout
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                '${user.firstName[0]}${user.lastName[0]}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              user.fullName,
                              style: const TextStyle(fontSize: 14),
                            ),
                            subtitle: Text(
                              user.email,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                authProvider.signOut();
                              },
                              icon: const Icon(Icons.logout, size: 16),
                              label: const Text('Logout'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: screens[_selectedIndex],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[800],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }
}

// Web screens are imported from separate files
