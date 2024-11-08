import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyDKWsestoZU_d3Y-2q64dpmgtXfZe3MpUE",
            authDomain: "blackbox-87e24.firebaseapp.com",
            projectId: "blackbox-87e24",
            storageBucket: "blackbox-87e24.firebasestorage.app",
            messagingSenderId: "974701337498",
            appId: "1:974701337498:web:c673f52b0e22da8c1db823",
            measurementId: "G-NQ2FKB801S"));
  } else {
    await Firebase.initializeApp();
  }
}
