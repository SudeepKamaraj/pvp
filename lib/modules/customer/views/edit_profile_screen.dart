import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:io';
import '../controllers/profile_controller.dart';
import '../../../../core/utils/image_helper.dart';

class EditProfileController extends GetxController {
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  
  var selectedSize = "M".obs;
  final sizes = ["XS", "S", "M", "L", "XL"];
  var isLoading = false.obs;
  var profileImage = ''.obs;
  final ImageHelper _imageHelper = ImageHelper();

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUserData();
  }

  void _loadCurrentUserData() {
    final profileController = Get.find<ProfileController>();
    final data = profileController.userProfile;
    
    fullNameController.text = data['fullName'] ?? data['name'] ?? "";
    phoneController.text = data['phone'] ?? "";
    emailController.text = data['email'] ?? "";
    selectedSize.value = data['sizePreference'] ?? "M";
    profileImage.value = data['profileImage'] ?? "";
  }

  Future<void> pickImage() async {
    final String? base64Image = await _imageHelper.pickImageAndConvertToBase64();
    if (base64Image != null) {
      profileImage.value = base64Image;
    }
  }

  Future<void> saveChanges() async {
    if (fullNameController.text.isEmpty) {
      Get.snackbar("error".tr, "name_empty_error".tr);
      return;
    }
    
    isLoading.value = true;
    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      print("Saving profile image: ${profileImage.value.isEmpty ? 'EMPTY' : profileImage.value.substring(0, 50)}...");
      
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fullName': fullNameController.text.trim(),
        'name': fullNameController.text.trim(), // Keep both for safety across collections
        'phone': phoneController.text.trim(),
        'sizePreference': selectedSize.value,
        'profileImage': profileImage.value,
      });
      
      print("Profile saved successfully to Firestore");
      
      // Refresh global profile state
      await Get.find<ProfileController>().fetchUserProfile();
      
      print("Profile controller refreshed");
      
      Get.back();
      Get.snackbar("success".tr, "profile_update_success".tr);
    } catch (e) {
      print("Error saving profile: $e");
      Get.snackbar("error".tr, "${"profile_update_failed".tr}: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text("edit_profile".tr, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Obx(() {
                  ImageProvider? imageProvider;
                  if (controller.profileImage.value.startsWith('data:image')) {
                    imageProvider = MemoryImage(base64Decode(controller.profileImage.value.split(',').last));
                  } else if (controller.profileImage.value.startsWith('http')) {
                    imageProvider = NetworkImage(controller.profileImage.value);
                  }

                  return CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFFEEDCC6),
                    backgroundImage: imageProvider,
                    child: imageProvider == null 
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                  );
                }),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: controller.pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "premium_member".tr,
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 32),

            _buildLabel("full_name_label".tr),
            _buildTextField(controller.fullNameController, icon: Icons.person_outline),
            
            const SizedBox(height: 20),
            
            _buildLabel("phone_number_label".tr),
            _buildTextField(controller.phoneController, icon: Icons.phone_android),

            const SizedBox(height: 20),
            
            _buildLabel("email_address_label".tr),
            _buildTextField(controller.emailController, icon: Icons.email_outlined, isReadOnly: true),

            const SizedBox(height: 32),
            
            Row(
              children: [
                const Icon(Icons.straighten, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  "size_preferences".tr,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("top_wear".tr, style: GoogleFonts.poppins(color: Colors.grey[600])),
            ),
            const SizedBox(height: 12),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: controller.sizes.map((size) {
                 final isSelected = controller.selectedSize.value == size;
                 return GestureDetector(
                   onTap: () => controller.selectedSize.value = size,
                   child: Container(
                     width: 50,
                     height: 50,
                     decoration: BoxDecoration(
                       shape: BoxShape.circle,
                       color: isSelected ? AppColors.primary : Colors.white,
                       border: Border.all(
                         color: isSelected ? AppColors.primary : Colors.grey[300]!,
                       ),
                       boxShadow: [
                          if (!isSelected)
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 4,
                            )
                       ],
                     ),
                     child: Center(
                       child: Text(
                         size,
                         style: GoogleFonts.poppins(
                           color: isSelected ? Colors.white : Colors.grey[600],
                           fontWeight: FontWeight.w600,
                         ),
                       ),
                     ),
                   ),
                 );
              }).toList(),
            )),

            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: controller.saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 5,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                ),
                child: Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: controller.isLoading.value 
                  ? [const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))]
                  : [
                    Text(
                      "save_changes".tr,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  ],
                )),
              ),
            ),
             const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[500],
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, {required IconData icon, bool isReadOnly = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isReadOnly ? Colors.grey[100] : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          if (!isReadOnly)
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: isReadOnly,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: "Enter value",
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          prefixIcon: Icon(icon, color: Colors.grey[400]),
          suffixIcon: isReadOnly ? Icon(Icons.lock, color: Colors.grey[300], size: 18) : null,
        ),
      ),
    );
  }
}
