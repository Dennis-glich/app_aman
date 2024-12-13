import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Mendaftarkan pengguna baru
  Future<UserCredential> registerUser(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Login pengguna dengan email dan password
  Future<UserCredential> signInUser(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Login pengguna menggunakan Google
  Future<UserCredential> signInWithGoogle() async {
    // Menginisialisasi proses login Google
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(message: 'Login dengan Google dibatalkan', code: 'ERROR_ABORTED_BY_USER');
    }

    // Mendapatkan otentikasi dari Google
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Mendapatkan kredensial untuk login ke Firebase
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Masuk ke Firebase menggunakan kredensial Google
    return await _auth.signInWithCredential(credential);
  }

  // Logout pengguna
  Future<void> signOut(BuildContext context) async {
  try {
    await _googleSignIn.signOut(); // Sign out from Google
    await _auth.signOut(); // Sign out from Firebase
    print("User signed out successfully");

    // Navigasi ke halaman welcome
    Navigator.pushReplacementNamed(context, '/welcome');
    } 
    catch (e) {
    print("Error signing out: $e");
    }
  }
}
