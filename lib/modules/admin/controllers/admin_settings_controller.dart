import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../data/services/database_service.dart';
import 'dart:convert';
import 'dart:io';
import '../../../../core/utils/image_helper.dart';
import '../../auth/views/login_screen.dart';

class AdminSettingsController extends GetxController {
  final DatabaseService _databaseService = DatabaseService();
  
  var isLoading = false.obs;
  var taxRate = 12.5.obs;
  
  // Admin Data
  var adminName = 'Alexander Pierce'.obs;
  var adminRole = 'System Administrator'.obs;
  var adminProfileImage = ''.obs;
  final ImageHelper _imageHelper = ImageHelper();

  @override
  void onInit() {
    super.onInit();
    fetchSettings();
    fetchAdminProfile();
  }

  Future<void> fetchSettings() async {
    isLoading.value = true;
    try {
      final settings = await _databaseService.getAppSettings();
      taxRate.value = (settings['taxRate'] ?? 12.5).toDouble();
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch settings: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAdminProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          adminName.value = data['fullName'] ?? data['name'] ?? "Admin";
          adminRole.value = doc.data()?['role']?.toUpperCase() == 'ADMIN' ? 'System Administrator' : 'Staff';
          adminProfileImage.value = data['profileImage'] ?? '';
        }
      } catch (e) {
        print("Error fetching admin profile: $e");
      }
    }
  }


  Future<void> pickAdminImage() async {
    final String? base64Image = await _imageHelper.pickImageAndConvertToBase64();
    if (base64Image != null) {
      adminProfileImage.value = base64Image;
      // Update immediately
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'profileImage': base64Image
          });
          Get.snackbar("Success", "Profile photo updated");
        } catch (e) {
          Get.snackbar("Error", "Failed to update profile photo: $e");
        }
      }
    }
  }

  Future<void> updateTaxRate(double newRate) async {
    taxRate.value = newRate;
    await _saveSettings();
  }

  Future<void> _saveSettings() async {
    try {
      await _databaseService.updateAppSettings({
        'taxRate': taxRate.value,
      });
      Get.snackbar("Success", "Settings updated successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to update settings: $e");
    }
  }

  void changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
        Get.snackbar("Success", "Password reset email sent to ${user.email}");
      } catch (e) {
        Get.snackbar("Error", "Failed to send reset email: $e");
      }
    } else {
      Get.snackbar("Error", "No user email found");
    }
  }

  void editProfile() {
    final nameController = TextEditingController(text: adminName.value);
    Get.defaultDialog(
      title: "Edit Profile",
      titleStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      contentPadding: const EdgeInsets.all(20),
      content: TextField(
        controller: nameController,
        decoration: InputDecoration(
          labelText: "Full Name",
          labelStyle: GoogleFonts.poppins(),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      textConfirm: "SAVE",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        if (nameController.text.isNotEmpty) {
          try {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                'fullName': nameController.text.trim(),
              });
              adminName.value = nameController.text.trim();
              Get.back();
              Get.snackbar("Success", "Profile updated successfully");
            }
          } catch (e) {
            Get.snackbar("Error", "Failed to update profile: $e");
          }
        }
      }
    );
  }

  Future<void> logout() async {
    print("Logout initiated...");
    try {
      await FirebaseAuth.instance.signOut();
      print("User signed out successfully.");
      Get.offAll(() => LoginScreen());
      Get.snackbar("Success", "Logged out successfully");
    } catch (e) {
      print("Logout failed: $e");
      Get.snackbar("Error", "Logout failed: $e");
    }
  }
}
