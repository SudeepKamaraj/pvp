import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// THIS SCRIPT IS INTENDED TO BE RUN ONCE TO SEED THE ADMIN USER
// Call this function from main.dart temporarily or run via a separate runner if configured

Future<void> seedAdminUser() async {
  const String adminEmail = "23.sudeepk@gmail.com";
  const String adminPass = "23Csr218@";

  try {
    // 1. Check if user already exists in Auth
    UserCredential? userCredential;
    try {
      // Try simple sign in first to see if it exists
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: adminEmail,
        password: adminPass,
      );
      print("Admin user already exists in Auth.");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        // Create user if not found (or if password changed/invalid, we recreate - strictly for dev)
        // ideally we should check if email exists.
        print("Creating new admin user...");
        userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: adminEmail,
          password: adminPass,
        );
      } else {
        print("Auth Error: ${e.code}");
        return;
      }
    }

    if (userCredential?.user != null) {
      // 2. Ensure User Document exists with 'admin' role
      final uid = userCredential!.user!.uid;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists || userDoc.data()?['role'] != 'admin') {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'email': adminEmail,
          'role': 'admin',
          'name': 'System Administrator',
          'createdAt': FieldValue.serverTimestamp(),
          'isBlocked': false,
        }, SetOptions(merge: true));
        print("Admin privileges granted to $uid");
      } else {
        print("Admin role already verified.");
      }
    }
  } catch (e) {
    print("Failed to seed admin user: $e");
  }
}
