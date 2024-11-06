import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseReference _realtimeDatabase = FirebaseDatabase.instance.ref();

  // Save data to Firestore
  Future<void> saveUserDataToFirestore(String uid, String fullName, String email, String encryptedPassword) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'encryptedPassword': encryptedPassword,
    });
  }

  // Save data to Realtime Database
  Future<void> saveDataToRealtimeDatabase(String uid, String fullName, String email) async {
    await _realtimeDatabase.child('users').child(uid).set({
      'uid': uid,
      'fullName': fullName,
      'email': email,
    });
  }
}