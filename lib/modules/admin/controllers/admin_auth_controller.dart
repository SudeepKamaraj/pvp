import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pvp_traders/modules/admin/views/admin_main_layout.dart';

class AdminAuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Pre-fill for demo/dev purposes
    emailController.text = "batman@gmail.com";
    passwordController.text = "123456";
  }

  var isLoading = false.obs;
  var isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar("Error", "Please enter valid credentials", backgroundColor: Colors.red[100], colorText: Colors.red[900]);
      return;
    }

    try {
      isLoading.value = true;
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Verify Admin Role
      DocumentSnapshot userDoc = await _db.collection('users').doc(userCredential.user!.uid).get();
      if (userDoc.exists && userDoc['role'] == 'admin') {
        Get.offAll(() => const AdminMainLayout());
      } else {
        await _auth.signOut();
        Get.snackbar("Access Denied", "You do not have admin privileges.", backgroundColor: Colors.red[100], colorText: Colors.red[900]);
      }

    } on FirebaseAuthException catch (e) {
      Get.snackbar("Login Failed", e.message ?? "Unknown error", backgroundColor: Colors.red[100], colorText: Colors.red[900]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(String email) async {
    if (email.isEmpty) {
      Get.snackbar("Error", "Please enter your email", backgroundColor: Colors.red[100], colorText: Colors.red[900]);
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      Get.snackbar("Success", "Password reset link sent!", backgroundColor: Colors.green[100], colorText: Colors.green[900]);
    } catch (e) {
      Get.snackbar("Error", "Failed to send reset link", backgroundColor: Colors.red[100], colorText: Colors.red[900]);
    }
  }
}
