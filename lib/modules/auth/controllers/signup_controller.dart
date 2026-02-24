import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../customer/views/dashboard_screen.dart';

class SignUpController extends GetxController {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;
  var agreedToTerms = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  void toggleTerms(bool? value) {
    agreedToTerms.value = value ?? false;
  }

  Future<void> signUp() async {
    // Validation
    if (fullNameController.text.trim().isEmpty) {
      Get.snackbar("error".tr, "enter_full_name".tr);
      return;
    }
    if (emailController.text.trim().isEmpty || !GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar("error".tr, "enter_valid_email".tr);
      return;
    }
    if (phoneController.text.trim().isEmpty) {
      Get.snackbar("error".tr, "enter_phone_number".tr);
      return;
    }
    if (passwordController.text.length < 6) {
      Get.snackbar("error".tr, "pass_min_length".tr);
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar("error".tr, "pass_not_match".tr);
      return;
    }
    if (!agreedToTerms.value) {
      Get.snackbar("error".tr, "agree_to_terms_error".tr);
      return;
    }
    
    isLoading.value = true;
    
    try {
      // 1. Create User in Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // 2. Create User Document in Firestore
      if (userCredential.user != null) {
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'fullName': fullNameController.text.trim(),
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
          'role': 'customer',
          'createdAt': FieldValue.serverTimestamp(),
          'cart': [],
          'wishlist': [],
        });
        
        Get.snackbar("success".tr, "account_created_success".tr);
        Get.offAll(() => const DashboardScreen()); // Directly to dashboard
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar("signup_failed".tr, e.message ?? "error".tr);
    } catch (e) {
      Get.snackbar("error".tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() {
    Get.back();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
