import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screen/auth.dart';
import 'screen/homescreen.dart';
import 'screen/profil.dart';
import 'screen/dashbord.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Inisialisasi Firebase dengan instance berbeda untuk mobile dan web
  final Future<FirebaseApp> _initialization = initializeFirebase();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        // Periksa apakah ada error
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Error initializing Firebase')),
            ),
          );
        }

        // Jika Firebase telah berhasil diinisialisasi
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: AuthWrapper(), // Wraps the logic for checking authentication
            routes: {
              '/home': (context) => HomeScreen(),
              '/register': (context) => RegisterPage(),
              '/signin': (context) => SignInPage(),
              '/profil': (context) => ProfilePage(),
              '/dashboard': (context) => DashboardPage(),
            },
          );
        }

        // Jika masih memuat, tampilkan loading indicator
        return MaterialApp(
          home: Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }

  // Fungsi untuk inisialisasi Firebase berdasarkan platform
  static Future<FirebaseApp> initializeFirebase() async {
    if (kIsWeb) {
      // Untuk Web, gunakan instance default
      return Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else if (Platform.isAndroid || Platform.isIOS) {
      // Untuk Android dan iOS, gunakan instance dengan nama khusus "Zero"
      return Firebase.initializeApp(
        name: "Zero",
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      // Platform lainnya jika diperlukan
      return Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // Listen to auth state changes
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator())); // Show loading while checking auth
        } else if (snapshot.hasData) {
          // If user is logged in, navigate to Dashboard
          return DashboardPage();
        } else {
          // If no user is logged in, show SignInPage
          return SignInPage();
        }
      },
    );
  }
}
