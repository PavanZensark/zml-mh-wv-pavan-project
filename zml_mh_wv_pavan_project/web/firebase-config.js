// This file is generated by the Firebase CLI
// https://firebase.google.com/docs/web/setup#available-libraries

import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';
import { getStorage } from 'firebase/storage';

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyA0jX1_IOJw16mrACOqEFLj2iJTnUhGNVQ",
  authDomain: "zmlpavan.firebaseapp.com",
  projectId: "zmlpavan",
  storageBucket: "zmlpavan.firebasestorage.app",
  messagingSenderId: "1085692339779",
  appId: "1:1085692339779:web:61361b5ff1c15d74b1d6f6",
  measurementId: "G-T734JQKHM9"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Firebase Authentication and get a reference to the service
export const auth = getAuth(app);

// Initialize Cloud Firestore and get a reference to the service
export const db = getFirestore(app);

// Initialize Cloud Storage and get a reference to the service
export const storage = getStorage(app);
