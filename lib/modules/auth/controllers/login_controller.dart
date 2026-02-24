import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../customer/views/dashboard_screen.dart';
import '../../customer/controllers/cart_controller.dart';
import '../../admin/views/admin_dashboard_screen.dart';
import '../views/signup_screen.dart';
import '../views/login_screen.dart';

class LoginController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar("error".tr, "enter_email_pass".tr);
      return;
    }

    isLoading.value = true;
    
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Retrieve JWT (ID Token)
      String? jwtToken = await userCredential.user?.getIdToken();
      print("========= JWT TOKEN (ID TOKEN) =========");
      print(jwtToken);
      print("========================================");

      // Check user role in Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      String role = userDoc.data()?['role'] ?? 'customer';

      Get.snackbar("success".tr, "logged_in_success".tr);
      
      if (role == 'admin') {
        Get.offAll(() => const AdminDashboardScreen());
      } else {
        Get.offAll(() => const DashboardScreen());
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar("login_failed".tr, e.message ?? "error".tr);
    } catch (e) {
      Get.snackbar("error".tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      
      // Clear personal cart data on logout
      if (Get.isRegistered<CartController>()) {
        Get.find<CartController>().clearCart();
      }
      
      Get.offAll(() => const DashboardScreen());
      Get.snackbar("success".tr, "logged_out_success".tr);
    } catch (e) {
      Get.snackbar("error".tr, "${"logout_failed".tr}: $e");
    }
  }

  Future<void> googleLogin() async {
    isLoading.value = true;
    try {
      // Force account picker by signing out first
      await GoogleSignIn().signOut();
      
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        isLoading.value = false;
        return; // User cancelled
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Check if user exists in Firestore, if not create them
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        
        String role = 'customer';
        if (!userDoc.exists) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'fullName': user.displayName ?? 'Google User',
            'email': user.email,
            'role': 'customer',
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          role = userDoc.data()?['role'] ?? 'customer';
        }

        Get.snackbar("success".tr, "google_login_success".tr);

        if (role == 'admin') {
          Get.offAll(() => const AdminDashboardScreen());
        } else {
          Get.offAll(() => const DashboardScreen());
        }
      }
    } catch (e) {
      print("Google Login Error: $e");
      Get.snackbar("error".tr, "${"google_login_failed".tr}: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void goToSignUp() {
    Get.to(() => SignUpScreen());
  }
  
  void goToForgotPassword() {
    if (emailController.text.isNotEmpty) {
      _sendPasswordResetEmail(emailController.text.trim());
    } else {
      Get.defaultDialog(
        title: "reset_password".tr,
        content: Column(
          children: [
            Text("enter_reset_email".tr),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: "email".tr,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        textConfirm: "send".tr,
        textCancel: "cancel".tr,
        onConfirm: () {
          Get.back(); // Close dialog
          if (emailController.text.isNotEmpty) {
            _sendPasswordResetEmail(emailController.text.trim());
          }
        },
      );
    }
  }

  Future<void> _sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Get.snackbar("success".tr, "reset_email_sent".tr);
    } on FirebaseAuthException catch (e) {
      Get.snackbar("error".tr, e.message ?? "reset_failed".tr);
    } catch (e) {
       Get.snackbar("error".tr, e.toString());
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
