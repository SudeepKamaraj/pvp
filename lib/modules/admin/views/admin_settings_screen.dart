import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pvp_traders/modules/auth/views/login_screen.dart';
import 'package:pvp_traders/modules/auth/controllers/login_controller.dart';
import '../controllers/admin_settings_controller.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminSettingsController controller = Get.find<AdminSettingsController>();

    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Settings", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Get.theme.textTheme.displayLarge?.color)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: Get.theme.iconTheme.color), onPressed: () => Get.back()),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Admin Profile Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Get.theme.cardColor, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Obx(() {
                            ImageProvider? imageProvider;
                            if (controller.adminProfileImage.value.startsWith('data:image')) {
                                imageProvider = MemoryImage(base64Decode(controller.adminProfileImage.value.split(',').last));
                            } else if (controller.adminProfileImage.value.startsWith('http')) {
                                imageProvider = NetworkImage(controller.adminProfileImage.value);
                            }

                            return CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.orange,
                                backgroundImage: imageProvider,
                                child: imageProvider == null ? const Icon(Icons.person, color: Colors.white, size: 30) : null,
                            );
                        }),
                        Positioned(
                          right: 0, bottom: 0,
                          child: GestureDetector(
                            onTap: controller.pickAdminImage,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: const Icon(Icons.edit, color: Colors.white, size: 12),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(controller.adminName.value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Get.theme.textTheme.displayLarge?.color)),
                        Text(controller.adminRole.value, style: GoogleFonts.poppins(color: Colors.grey)),
                      ],
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: controller.editProfile, 
                      child: Text("Edit", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold))
                    )
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Account Security
              _buildSectionHeader("ACCOUNT SECURITY"),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    InkWell(
                      onTap: controller.changePassword,
                      child: _buildSettingItem(Icons.lock, "Change Password", trailer: const Icon(Icons.chevron_right, color: Colors.grey)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // App Configs
              _buildSectionHeader("APP CONFIGURATIONS"),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        // Show simple tax rate dialog
                        final taxController = TextEditingController(text: controller.taxRate.value.toString());
                        Get.defaultDialog(
                          title: "Global Tax Rate",
                          titleStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                          backgroundColor: Get.theme.cardColor,
                          radius: 15,
                          contentPadding: const EdgeInsets.all(20),
                          content: Column(
                            children: [
                              Text("Enter the new global tax percentage", style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
                              const SizedBox(height: 15),
                              TextField(
                                controller: taxController,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  suffixText: "%",
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                ),
                              ),
                            ],
                          ),
                          textConfirm: "UPDATE",
                          confirmTextColor: Colors.white,
                          buttonColor: Colors.red,
                          onConfirm: () {
                            double? rate = double.tryParse(taxController.text);
                            if (rate != null) {
                              controller.updateTaxRate(rate);
                              Get.back();
                            } else {
                              Get.snackbar("Invalid Input", "Please enter a valid number");
                            }
                          }
                        );
                      },
                      child: _buildSettingItem(Icons.receipt_long, "Global Tax Rate", trailer: _buildValueTrailer("${controller.taxRate.value}%")),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Support & Info
              _buildSectionHeader("SUPPORT & INFO"),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    _buildSettingItem(Icons.info, "Version", trailer: Text("2.4.0-stable", style: GoogleFonts.poppins(color: Colors.grey))),
                    const Divider(height: 1),
                    GestureDetector(
                      onTap: () {
                        print("Logout button tapped");
                        controller.logout();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout, color: Colors.white),
                            const SizedBox(width: 8),
                            Text("Logout from System", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
               const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }


  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(title, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, {String? subtitle, Widget? trailer}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: Colors.red, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 16, color: Get.theme.textTheme.bodyLarge?.color)),
                if (subtitle != null) Text(subtitle, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (trailer != null) trailer
        ],
      ),
    );
  }

  Widget _buildValueTrailer(String value) {
    return Row(
      children: [
        Text(value, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
      ],
    );
  }
}
