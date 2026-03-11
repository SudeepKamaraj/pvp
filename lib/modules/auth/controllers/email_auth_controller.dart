import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../../../core/config/email_config.dart';
import '../../customer/views/dashboard_screen.dart';
import '../../admin/views/admin_dashboard_screen.dart';
import '../views/email_otp_verification_screen.dart';
import '../views/email_password_screen.dart';

class EmailAuthController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  
  var isLoading = false.obs;
  var canResend = false.obs;
  var countdown = 120.obs;
  Timer? _timer;
  var generatedOTP = ''.obs;
  var userEmail = ''.obs;
  
  // For signup flow
  var isSignupFlow = false.obs;

  @override
  void onClose() {
    _timer?.cancel();
    emailController.dispose();
    fullNameController.dispose();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    super.onClose();
  }
  
  @override
  void onInit() {
    super.onInit();
  }

  void startCountdown() {
    canResend.value = false;
    countdown.value = 120;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        canResend.value = true;
        _timer?.cancel();
        timer.cancel();
      }
    });
  }
  
  // Check and restart timer if needed (e.g., after screen rebuild)
  void ensureTimerRunning() {
    // If countdown should be active but might not have a running timer
    if (countdown.value > 0 && !canResend.value) {
      // Cancel any existing timer and start fresh
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (countdown.value > 0) {
          countdown.value--;
        } else {
          canResend.value = true;
          _timer?.cancel();
          timer.cancel();
        }
      });
    }
  }

  String _generateOTP() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  Future<bool> _sendEmailOTP(String recipientEmail, String otp) async {
    // Check if email sending is enabled
    if (!EmailConfig.ENABLE_EMAIL_SENDING) {
      return false; // Fall back to dialog
    }
    
    // Validate email configuration
    if (EmailConfig.SENDER_EMAIL == 'your-email@gmail.com' || 
        EmailConfig.APP_PASSWORD == 'your-app-password-here') {
      print('⚠️ Email not configured! Please update lib/core/config/email_config.dart');
      return false; // Fall back to dialog
    }
    
    try {
      final smtpServer = gmail(EmailConfig.SENDER_EMAIL, EmailConfig.APP_PASSWORD);
      
      final message = Message()
        ..from = Address(EmailConfig.SENDER_EMAIL, EmailConfig.SENDER_NAME)
        ..recipients.add(recipientEmail)
        ..subject = EmailConfig.OTP_SUBJECT
        ..html = '''
          <div style="font-family: Arial, sans-serif; padding: 20px; max-width: 600px;">
            <div style="text-align: center; margin-bottom: 30px;">
              <h1 style="color: #7B1FA2;">PVP TRADERS</h1>
            </div>
            
            <h2 style="color: #333;">Your Verification Code</h2>
            
            <p style="color: #666; font-size: 16px;">
              Hello! You requested a verification code to login to your PVP Traders account.
            </p>
            
            <div style="background-color: #f5f5f5; padding: 20px; border-radius: 8px; text-align: center; margin: 30px 0;">
              <p style="color: #999; font-size: 14px; margin: 0 0 10px 0;">Your OTP Code:</p>
              <h1 style="color: #7B1FA2; font-size: 36px; letter-spacing: 8px; margin: 10px 0;">$otp</h1>
            </div>
            
            <p style="color: #666; font-size: 14px;">
              This code will expire in <strong>${EmailConfig.OTP_EXPIRY_MINUTES} minutes</strong>.
            </p>
            
            <p style="color: #666; font-size: 14px;">
              If you didn't request this code, please ignore this email.
            </p>
            
            <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
            
            <p style="color: #999; font-size: 12px; text-align: center;">
              © 2026 PVP Traders. All rights reserved.
            </p>
          </div>
        ''';
      
      final sendReport = await send(message, smtpServer);
      print('✅ Email sent successfully: ${sendReport.toString()}');
      return true;
      
    } on MailerException catch (e) {
      print('❌ Failed to send email: $e');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      return false;
    } catch (e) {
      print('❌ Error sending email: $e');
      return false;
    }
  }

  Future<void> sendOTP({bool isSignup = false}) async {
    isSignupFlow.value = isSignup;
    
    // Validate and sanitize email
    String email = sanitizeEmail(emailController.text);
    String? emailError = validateEmail(email);
    if (emailError != null) {
      Get.snackbar("error".tr, emailError);
      return;
    }

    // Validate full name for signup
    if (isSignup) {
      String fullName = sanitizeFullName(fullNameController.text);
      String? nameError = validateFullName(fullName);
      if (nameError != null) {
        Get.snackbar("error".tr, nameError);
        return;
      }
    }

    isLoading.value = true;

    try {
      // Generate OTP
      String otp = _generateOTP();
      generatedOTP.value = otp;
      userEmail.value = email;

      // Store OTP in Firestore with expiration (2 minutes)
      await FirebaseFirestore.instance
          .collection('email_otps')
          .doc(email)
          .set({
        'otp': otp,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(minutes: 2)),
        ),
      }, SetOptions(merge: true));

      // Send OTP via email
      bool emailSent = await _sendEmailOTP(email, otp);
      
      isLoading.value = false;
      startCountdown();

      // Navigate to OTP screen
      Get.to(() => EmailOTPVerificationScreen(
        email: email,
        isSignupFlow: isSignup,
      ));

      if (emailSent) {
        Get.snackbar(
          "otp_sent".tr,
          "Check your email inbox for the OTP code",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        // Fallback: Show OTP in dialog if email sending fails
        _showOTPDialog(otp, email);
        Get.snackbar(
          "info".tr,
          "Email not configured. OTP shown in dialog (Dev Mode)",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }

    } catch (e) {
      isLoading.value = false;
      Get.snackbar("error".tr, e.toString());
    }
  }

  void _showOTPDialog(String otp, String email) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.developer_mode, color: Colors.orange),
            const SizedBox(width: 8),
            Text("dev_mode".tr, style: const TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "email_otp_dev_note".tr,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Email:", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      Text(email, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("OTP Code:", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      Text(
                        otp,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: otp));
                      Get.snackbar("copied".tr, "otp_copied".tr);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("ok".tr),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  Future<void> verifyOTP() async {
    String otpCode = otpControllers.map((c) => c.text).join();
    
    if (otpCode.length != 6) {
      Get.snackbar("error".tr, "enter_complete_otp".tr);
      return;
    }

    isLoading.value = true;

    try {
      // Retrieve stored OTP from Firestore
      final otpDoc = await FirebaseFirestore.instance
          .collection('email_otps')
          .doc(userEmail.value)
          .get();

      if (!otpDoc.exists) {
        isLoading.value = false;
        Get.snackbar(
          "error".tr,
          "otp_expired_or_invalid".tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final data = otpDoc.data()!;
      final storedOTP = data['otp'] as String;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();

      // Check if OTP is expired
      if (DateTime.now().isAfter(expiresAt)) {
        isLoading.value = false;
        Get.snackbar(
          "error".tr,
          "otp_expired".tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        // Delete expired OTP
        await FirebaseFirestore.instance
            .collection('email_otps')
            .doc(userEmail.value)
            .delete();
        return;
      }

      // Verify OTP
      if (otpCode != storedOTP) {
        isLoading.value = false;
        Get.snackbar(
          "invalid_otp".tr,
          "otp_incorrect".tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // OTP is valid
      // Delete used OTP
      await FirebaseFirestore.instance
          .collection('email_otps')
          .doc(userEmail.value)
          .delete();

      // For signup flow, navigate to password screen
      // For login flow, authenticate directly (passwordless)
      if (isSignupFlow.value) {
        // Check if email already exists
        final userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: userEmail.value)
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          isLoading.value = false;
          Get.snackbar(
            "error".tr,
            "email_already_registered".tr,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        // Email verified, navigate to password screen
        isLoading.value = false;
        Get.off(() => EmailPasswordScreen(
          email: userEmail.value,
          fullName: fullNameController.text.trim(),
        ));
      } else {
        // Login flow - authenticate existing user
        await _authenticateExistingUser();
      }

    } catch (e) {
      isLoading.value = false;
      Get.snackbar("error".tr, e.toString());
    }
  }

  Future<void> _authenticateExistingUser() async {
    try {
      // Check if user exists
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: userEmail.value)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        // User doesn't exist
        isLoading.value = false;
        Get.snackbar(
          "error".tr,
          "email_not_registered".tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Existing user - sign in
      final userData = userQuery.docs.first.data();
      final userId = userQuery.docs.first.id;

      // Check if user already authenticated
      final currentUser = FirebaseAuth.instance.currentUser;
      
      // If user is already signed in with the correct account, proceed
      if (currentUser != null && currentUser.uid == userId) {
        // User already signed in, just navigate
      } else {
        // User exists in Firestore but not signed in with Firebase Auth
        // Generate a random password and sign in
        try {
          final randomPassword = _generateOTP() + _generateOTP();
          
          // Try to sign in with email/password
          try {
            await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: userEmail.value,
              password: randomPassword,
            );
          } catch (signInError) {
            // If sign-in fails, create a new auth account for this existing Firestore user
            // This handles cases where Firestore user exists but Firebase Auth doesn't
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: userEmail.value,
              password: randomPassword,
            );
            
            // Link the Firebase Auth UID with existing Firestore document
            final newUser = FirebaseAuth.instance.currentUser;
            if (newUser != null && newUser.uid != userId) {
              // Update the user document with new UID
              final oldData = userData;
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(newUser.uid)
                  .set({
                ...oldData,
                'uid': newUser.uid,
              });
              
              // Delete old document
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .delete();
            }
          }
        } catch (e) {
          Get.snackbar(
            "error".tr,
            "email_already_registered_different_method".tr,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          isLoading.value = false;
          return;
        }
      }

      String role = userData['role'] ?? 'customer';
      
      isLoading.value = false;
      Get.snackbar(
        "success".tr,
        "logged_in_success".tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Clean up controller before navigating
      Get.delete<EmailAuthController>(force: true);
      
      if (role == 'admin') {
        Get.offAll(() => const AdminDashboardScreen());
      } else {
        Get.offAll(() => const DashboardScreen());
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("error".tr, e.toString());
    }
  }

  // New method for creating account with password after email verification
  Future<void> createAccountWithPassword({
    required String email,
    required String fullName,
    required String password,
  }) async {
    // Validate inputs
    String? passwordError = validatePassword(password);
    if (passwordError != null) {
      Get.snackbar("error".tr, passwordError);
      return;
    }

    String? emailError = validateEmail(email);
    if (emailError != null) {
      Get.snackbar("error".tr, emailError);
      return;
    }

    String? nameError = validateFullName(fullName);
    if (nameError != null) {
      Get.snackbar("error".tr, nameError);
      return;
    }

    isLoading.value = true;

    try {
      // Create user with email and password
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: sanitizeEmail(email),
        password: password,
      );

      // Create user document in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'uid': userCredential.user!.uid,
        'fullName': sanitizeFullName(fullName),
        'email': sanitizeEmail(email),
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
        'cart': [],
        'wishlist': [],
        'authMethod': 'email_password',
      });

      isLoading.value = false;
      Get.snackbar(
        "success".tr,
        "account_created_success".tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Clean up controller before navigating
      Get.delete<EmailAuthController>(force: true);
      
      // Navigate to dashboard
      Get.offAll(() => const DashboardScreen());
    } catch (e) {
      isLoading.value = false;
      
      // Handle specific Firebase Auth errors
      String errorMessage = e.toString();
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'email_already_registered'.tr;
            break;
          case 'weak-password':
            errorMessage = 'password_min_length'.tr;
            break;
          case 'invalid-email':
            errorMessage = 'enter_valid_email'.tr;
            break;
          default:
            errorMessage = e.message ?? errorMessage;
        }
      }
      
      Get.snackbar("error".tr, errorMessage);
    }
  }

  // Login with email and password (traditional login - no OTP)
  Future<void> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    // Validate inputs
    String? emailError = validateEmail(email);
    if (emailError != null) {
      Get.snackbar("error".tr, emailError);
      return;
    }

    String? passwordError = validatePassword(password);
    if (passwordError != null) {
      Get.snackbar("error".tr, passwordError);
      return;
    }

    isLoading.value = true;

    try {
      // Sign in with email and password
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: sanitizeEmail(email),
        password: password,
      );

      // Get user data from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // User authenticated but no Firestore document
        isLoading.value = false;
        Get.snackbar(
          "error".tr,
          "User data not found. Please contact support.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        await FirebaseAuth.instance.signOut();
        return;
      }

      final userData = userDoc.data()!;
      String role = userData['role'] ?? 'customer';
      
      isLoading.value = false;
      Get.snackbar(
        "success".tr,
        "logged_in_success".tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Clean up controller before navigating
      Get.delete<EmailAuthController>(force: true);
      
      // Navigate based on role
      if (role == 'admin') {
        Get.offAll(() => const AdminDashboardScreen());
      } else {
        Get.offAll(() => const DashboardScreen());
      }
    } catch (e) {
      isLoading.value = false;
      
      // Handle specific Firebase Auth errors
      String errorMessage = e.toString();
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'email_not_registered'.tr;
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password. Please try again.';
            break;
          case 'invalid-email':
            errorMessage = 'enter_valid_email'.tr;
            break;
          case 'user-disabled':
            errorMessage = 'This account has been disabled.';
            break;
          case 'too-many-requests':
            errorMessage = 'Too many failed attempts. Please try again later.';
            break;
          default:
            errorMessage = e.message ?? errorMessage;
        }
      }
      
      Get.snackbar("error".tr, errorMessage);
    }
  }

  void resendOTP() {
    if (canResend.value) {
      // Ensure email is set in controller before sending OTP
      if (userEmail.value.isNotEmpty) {
        emailController.text = userEmail.value;
      }
      sendOTP(isSignup: isSignupFlow.value);
    }
  }

  void clearOTP() {
    for (var controller in otpControllers) {
      controller.clear();
    }
  }

  // Validation helper methods
  bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    // Standard email validation regex
    final emailRegex = RegExp(
      r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$'
    );
    return emailRegex.hasMatch(email);
  }

  bool isValidFullName(String name) {
    if (name.isEmpty || name.trim().isEmpty) return false;
    if (name.trim().length < 2) return false;
    // Check if name contains at least some letters
    final hasLetters = RegExp(r'[a-zA-Z]').hasMatch(name);
    return hasLetters;
  }

  bool isValidPassword(String password) {
    if (password.isEmpty) return false;
    if (password.length < 6) return false;
    return true;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) {
      return "enter_password".tr;
    }
    if (password.length < 6) {
      return "password_min_length".tr;
    }
    if (password.contains(' ')) {
      return "Password cannot contain spaces";
    }
    return null; // Valid
  }

  String? validateEmail(String email) {
    if (email.isEmpty) {
      return "enter_valid_email".tr;
    }
    if (!isValidEmail(email)) {
      return "enter_valid_email".tr;
    }
    return null; // Valid
  }

  String? validateFullName(String name) {
    if (name.isEmpty || name.trim().isEmpty) {
      return "enter_full_name".tr;
    }
    if (name.trim().length < 2) {
      return "Name must be at least 2 characters";
    }
    if (!RegExp(r'[a-zA-Z]').hasMatch(name)) {
      return "Name must contain letters";
    }
    return null; // Valid
  }

  // Sanitize inputs
  String sanitizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  String sanitizeFullName(String name) {
    return name.trim();
  }
}
