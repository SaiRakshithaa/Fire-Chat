import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> saveUserToFirestore(User user) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = firestore.collection('users');

  await users.doc(user.uid).set({
    "uid": user.uid,              // Unique User ID
    "name": user.displayName ?? "No Name",
    "email": user.email,
    "profilePic": "",             // Default empty, update later
    "createdAt": FieldValue.serverTimestamp()
  });
}