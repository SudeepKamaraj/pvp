import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';
import '../../auth/views/login_screen.dart';
import '../controllers/settings_controller.dart';
import 'about_us_screen.dart'; 

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Get.theme.iconTheme.color, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: const NetworkImage("https://i.pravatar.cc/150?u=a042581f4e29026704d"), // Placeholder
              backgroundColor: Colors.grey[200],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "settings".tr,
              style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Get.theme.textTheme.displayLarge?.color),
            ),
            const SizedBox(height: 30),
            
            _buildSectionHeader("preferences".tr),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Get.theme.cardColor, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Obx(() => _buildSwitchTile(
                    icon: Icons.notifications_active, 
                    title: "push_notifications".tr, 
                    value: controller.pushNotifications.value, 
                    onChanged: (val) => controller.pushNotifications.value = val,
                    iconColor: Colors.red,
                    iconBg: Colors.red[50]!
                  )),
                ],
              ),
            ),

            const SizedBox(height: 30),
            _buildSectionHeader("language".tr),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Get.theme.cardColor, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                   Obx(() => _buildLanguageTile("english".tr, controller.selectedLanguage.value == "English", () => controller.changeLanguage("English"))),
                   const Divider(),
                   Obx(() => _buildLanguageTile("tamil".tr, controller.selectedLanguage.value == "Tamil", () => controller.changeLanguage("Tamil"))),
                   const Divider(),
                   Obx(() => _buildLanguageTile("hindi".tr, controller.selectedLanguage.value == "Hindi", () => controller.changeLanguage("Hindi"))),
                ],
              ),
            ),

            const SizedBox(height: 30),
            _buildSectionHeader("legal_support".tr),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Get.theme.cardColor, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  _buildLinkTile(Icons.gavel, "privacy_policy".tr, onTap: () => _showLegalDialog("privacy_policy".tr, "privacy_desc".tr)),
                  const Divider(),
                  _buildLinkTile(Icons.description, "terms_conditions".tr, onTap: () => _showLegalDialog("terms_conditions".tr, "terms_desc".tr)),
                  const Divider(),
                  _buildLinkTile(Icons.info, "about_us".tr, onTap: () => Get.to(() => const AboutUsScreen())),
                ],
              ),
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _showLogoutDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.08),
                  foregroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout),
                    const SizedBox(width: 8),
                    Text("sign_out".tr, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                   Container(
                     padding: const EdgeInsets.all(12),
                     decoration: const BoxDecoration(
                       color: AppColors.primary,
                       shape: BoxShape.circle,
                     ),
                     child: const Text("PT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                   ),
                   const SizedBox(height: 12),
                   Text("PVP TRADERS PREMIUM FASHION", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[400], letterSpacing: 1)),
                   Text("App Version 1.4.2 (2024)", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[300])),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavPlaceholder(),
    );
  }

  // Quick placeholder for bottom nav to match design (just static for visual)
  Widget _buildBottomNavPlaceholder() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Icon(Icons.home, color: Colors.grey),
          const Icon(Icons.search, color: Colors.grey),
          const Icon(Icons.shopping_bag, color: Colors.grey),
          const Icon(Icons.settings, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSwitchTile({required IconData icon, required String title, required bool value, required Function(bool) onChanged, required Color iconColor, required Color iconBg}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(child: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500))),
        Switch(
          value: value, 
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildLanguageTile(String language, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Text(language, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: isSelected ? Get.theme.textTheme.bodyLarge?.color : Colors.grey)),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkTile(IconData icon, String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Get.theme.scaffoldBackgroundColor, shape: BoxShape.circle),
              child: Icon(icon, color: Get.theme.iconTheme.color?.withOpacity(0.7) ?? Colors.grey, size: 18),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500))),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red[50], // Light pink bg from design
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout, color: AppColors.primary, size: 30),
              ),
              const SizedBox(height: 20),
              Text("logging_out_q".tr, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                "logout_message".tr,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Get.offAll(() => const LoginScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: Text("logout".tr, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    side: BorderSide(color: Colors.grey[200]!),
                    foregroundColor: Colors.black,
                  ),
                  child: Text("cancel".tr, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLegalDialog(String title, String content) {
    Get.defaultDialog(
      title: title,
      titleStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          content,
          style: GoogleFonts.poppins(fontSize: 14),
          textAlign: TextAlign.justify,
        ),
      ),
      textConfirm: "OK",
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primary,
      onConfirm: () => Get.back(),
    );
  }
}
