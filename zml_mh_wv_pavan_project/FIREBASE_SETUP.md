# Firebase Configuration Instructions

## Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: "zml-health-platform"
4. Enable Google Analytics (optional)
5. Create project

## Step 2: Enable Authentication
1. In Firebase Console, go to "Authentication"
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password" provider
5. Click "Save"

## Step 3: Create Firestore Database
1. Go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" for now
4. Select location (closest to your users)
5. Click "Done"

## Step 4: Configure Flutter for Firebase

### For Web:
1. In Firebase Console, click "Web" icon
2. Register app with nickname: "zml-web"
3. Copy the Firebase configuration
4. Create `web/firebase-config.js` with the configuration

### For Mobile:
1. In Firebase Console, click "Android" icon
2. Register app with package name: `com.example.zml_mh_wv_pavan_project`
3. Download `google-services.json` and place in `android/app/`
4. Follow setup instructions for Android

5. Click "iOS" icon
6. Register app with bundle ID: `com.example.zmlMhWvPavanProject`
7. Download `GoogleService-Info.plist` and place in `ios/Runner/`
8. Follow setup instructions for iOS

## Step 5: Firestore Security Rules
```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Health info - users can read/write their own data
    match /health_info/{docId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    // Appointments - users can read/write their own data
    match /appointments/{docId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    // Medications - users can read/write their own data
    match /medications/{docId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    // Medication logs - users can read/write their own data
    match /medication_logs/{docId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    // Vaccination records - users can read/write their own data
    match /vaccination_records/{docId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    // Physicians can read patient data (implement proper role-based access)
    match /{document=**} {
      allow read: if request.auth != null && 
                  exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
                  get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'physician';
    }
  }
}
```

## Step 6: Add Firebase Configuration to Flutter

Create `lib/firebase_options.dart` with the Firebase configuration for your project.

## Step 7: Update Dependencies
Make sure these dependencies are in your `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.5.6
```

## Step 8: Run the Application
```bash
flutter pub get
flutter run
```

For web deployment:
```bash
flutter build web
firebase deploy --only hosting
```
