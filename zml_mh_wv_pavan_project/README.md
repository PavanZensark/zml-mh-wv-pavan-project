# Zoom My Life - Family Health Information Platform

A comprehensive Flutter application for managing family health information with both mobile and web interfaces.

## 🏥 Project Overview

**Zoom My Life (ZML-MH-WV)** is a Family Health Information Platform that helps families and physicians securely manage and track health data. The platform provides:

- **Mobile Application**: For families to manage basic health information, appointments, and medications
- **Web Application**: For comprehensive health profiles, structured data collection, and physician dashboard

## 🚀 Features

### Mobile Application (Family Interface)
- ✅ Secure Firebase authentication
- ✅ Basic health information management
- ✅ Appointment management with reminders
- ✅ Medication management with reminders
- ✅ Local notifications for appointments and medications

### Web Application (Family & Physician Interfaces)
- ✅ Secure authentication with role-based access
- ✅ Health Information Wizard for structured data collection
- ✅ Health Summary generation
- ✅ Physician Dashboard for patient management
- ✅ Patient search functionality

## 🛠️ Technology Stack

- **Frontend**: Flutter Mobile & Flutter Web
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **State Management**: Provider
- **UI Framework**: Material Design
- **Notifications**: Flutter Local Notifications
- **Database**: Cloud Firestore

## 📱 Platform Support

- ✅ iOS
- ✅ Android
- ✅ Web (Chrome, Firefox, Safari, Edge)
- ✅ Desktop (Windows, macOS, Linux)

## 🏗️ Project Structure

```
lib/
├── common/                 # Shared utilities and services
├── mobile/                 # Mobile-specific screens and widgets
│   ├── auth/              # Mobile authentication screens
│   ├── health_info/       # Health information management
│   ├── appointments/      # Appointment management
│   └── medications_reminders/ # Medication reminders
├── web/                   # Web-specific screens and widgets
│   ├── auth/              # Web authentication screens
│   ├── health_wizard/     # Health information wizard
│   ├── health_summary/    # Health summary generation
│   └── physician_dashboard/ # Physician dashboard
├── services/              # Backend services
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── notification_service.dart
├── providers/             # State management providers
├── models/                # Data models
├── widgets/               # Reusable widgets
├── utils/                 # Utility functions
└── main.dart             # Application entry point
```

## 🔧 Setup Instructions

### Prerequisites
- Flutter SDK (latest stable version)
- Firebase CLI
- Android Studio / VS Code
- Git

### 1. Clone the Repository
```bash
git clone <repository-url>
cd zml_mh_wv_pavan_project
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup
Follow the detailed instructions in [FIREBASE_SETUP.md](FIREBASE_SETUP.md)

### 4. Run the Application

#### Mobile Development
```bash
# For iOS
flutter run -d ios

# For Android
flutter run -d android
```

#### Web Development
```bash
flutter run -d web-server --web-port 8080
```

## 📊 Database Schema

### Users Collection
```json
{
  "id": "string",
  "email": "string",
  "firstName": "string",
  "lastName": "string",
  "role": "family|physician",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "phoneNumber": "string?",
  "specialization": "string?" // For physicians
}
```

### Health Info Collection
```json
{
  "id": "string",
  "userId": "string",
  "firstName": "string",
  "lastName": "string",
  "dateOfBirth": "timestamp",
  "gender": "string",
  "bloodGroup": "enum",
  "height": "number",
  "weight": "number",
  "allergies": ["string"],
  "medicalConditions": ["string"],
  "emergencyContact": "string?",
  "primaryPhysician": "string?",
  "insuranceProvider": "string?",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Appointments Collection
```json
{
  "id": "string",
  "userId": "string",
  "patientId": "string",
  "doctorName": "string",
  "doctorSpecialization": "string",
  "appointmentDate": "timestamp",
  "appointmentTime": "string",
  "reason": "string",
  "status": "scheduled|confirmed|cancelled|completed",
  "reminderSet": "boolean",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Medications Collection
```json
{
  "id": "string",
  "userId": "string",
  "patientId": "string",
  "medicationName": "string",
  "dosage": "string",
  "frequency": "enum",
  "timings": ["string"],
  "startDate": "timestamp",
  "endDate": "timestamp?",
  "isActive": "boolean",
  "reminderEnabled": "boolean",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

## 🎯 Key Features Implementation

### Authentication
- Firebase Auth with email/password
- Role-based access control (Family vs Physician)
- Secure session management
- Password reset functionality

### Health Information Management
- Structured data collection wizard
- Personal health profiles
- Medical history tracking
- Vaccination records
- Insurance information

### Appointment Management
- Schedule and manage appointments
- Local notification reminders
- Appointment status tracking
- Doctor information management

### Medication Management
- Medication scheduling
- Dosage tracking
- Medication reminders
- Compliance monitoring

### Physician Dashboard
- Patient search functionality
- Health summary viewing
- Secure patient data access
- Role-based permissions

## 📱 Responsive Design

The application is fully responsive and adapts to different screen sizes:

- **Mobile**: Optimized for phones and tablets
- **Web**: Desktop-friendly interface with responsive layout
- **Tablet**: Adaptive UI for tablet devices

## 🔒 Security Features

- Firebase Authentication
- Firestore security rules
- Role-based access control
- Data encryption in transit
- Secure session management

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Generate test coverage
flutter test --coverage
```

## 🚀 Deployment

### Web Deployment
```bash
flutter build web
firebase deploy --only hosting
```

### Mobile Deployment
```bash
# Android
flutter build appbundle
# Upload to Google Play Store

# iOS
flutter build ipa
# Upload to App Store Connect
```

## 📋 Future Enhancements

- [ ] PDF export of health summaries
- [ ] Real-time dashboard updates
- [ ] Push notifications
- [ ] Telemedicine integration
- [ ] Health data analytics
- [ ] Multi-language support
- [ ] Biometric authentication
- [ ] Health device integration

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Full Stack Developer**: Pavan (Candidate)
- **Platform**: Flutter Mobile & Web
- **Backend**: Firebase

## 📞 Support

For support and questions, please create an issue in the GitHub repository.

---

**Built with ❤️ using Flutter and Firebase**
