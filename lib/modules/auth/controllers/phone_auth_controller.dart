import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../customer/views/dashboard_screen.dart';
import '../../admin/views/admin_dashboard_screen.dart';
import '../views/otp_verification_screen.dart';

class PhoneAuthController extends GetxController {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  
  var isLoading = false.obs;
  var verificationId = ''.obs;
  var resendToken = 0.obs;
  var canResend = false.obs;
  var countdown = 60.obs;
  Timer? _timer;
  var completePhoneNumber = ''.obs;
  var forceResendingToken = Rxn<int>();
  
  // For signup flow
  var isSignupFlow = false.obs;

  @override
  void onClose() {
    _timer?.cancel();
    phoneController.dispose();
    fullNameController.dispose();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    super.onClose();
  }
  
  @override
  void onInit() {
    super.onInit();
    // Initialize controllers here if needed
  }

  void startCountdown() {
    canResend.value = false;
    countdown.value = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  Future<void> sendOTP({bool isSignup = false}) async {
    isSignupFlow.value = isSignup;
    
    // Validate full name for signup
    if (isSignup && fullNameController.text.trim().isEmpty) {
      Get.snackbar("error".tr, "enter_full_name".tr);
      return;
    }

    String phoneNumber = completePhoneNumber.value;
    if (phoneNumber.isEmpty) {
      Get.snackbar("error".tr, "enter_phone_number".tr);
      return;
    }

    isLoading.value = true;

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;
          Get.snackbar(
            "verification_failed".tr,
            e.message ?? "error".tr,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        },
        codeSent: (String verId, int? resendTok) {
          isLoading.value = false;
          verificationId.value = verId;
          forceResendingToken.value = resendTok;
          startCountdown();
          
          Get.to(() => OTPVerificationScreen(
            phoneNumber: phoneNumber,
            isSignupFlow: isSignup,
          ));
          
          Get.snackbar(
            "otp_sent".tr,
            "otp_sent_to".trParams({'phone': phoneNumber}),
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId.value = verId;
        },
        forceResendingToken: forceResendingToken.value,
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("error".tr, e.toString());
    }
  }

  Future<void> verifyOTP() async {
    String otpCode = otpControllers.map((c) => c.text).join();
    
    if (otpCode.length != 6) {
      Get.snackbar("error".tr, "enter_complete_otp".tr);
      return;
    }

    isLoading.value = true;

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: otpCode,
      );

      await _signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      if (e.code == 'invalid-verification-code') {
        Get.snackbar(
          "invalid_otp".tr,
          "otp_incorrect".tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar("verification_failed".tr, e.message ?? "error".tr);
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("error".tr, e.toString());
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Check if user exists in Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        String role = 'customer';
        
        if (!userDoc.exists) {
          // New user - create document
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'fullName': isSignupFlow.value 
                ? fullNameController.text.trim() 
                : (user.displayName ?? 'User'),
            'phone': user.phoneNumber,
            'role': 'customer',
            'createdAt': FieldValue.serverTimestamp(),
            'cart': [],
            'wishlist': [],
          });
          
          Get.snackbar(
            "success".tr,
            "account_created_success".tr,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          role = userDoc.data()?['role'] ?? 'customer';
          Get.snackbar(
            "success".tr,
            "logged_in_success".tr,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }

        isLoading.value = false;

        // Navigate based on role
        if (role == 'admin') {
          Get.offAll(() => const AdminDashboardScreen());
        } else {
          Get.offAll(() => const DashboardScreen());
        }
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("error".tr, e.toString());
    }
  }

  void resendOTP() {
    if (canResend.value) {
      sendOTP(isSignup: isSignupFlow.value);
    }
  }

  void clearOTP() {
    for (var controller in otpControllers) {
      controller.clear();
    }
  }
}
