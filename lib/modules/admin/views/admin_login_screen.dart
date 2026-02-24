import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';
import '../controllers/admin_auth_controller.dart';
import 'admin_reset_password_screen.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminAuthController controller = Get.put(AdminAuthController());

    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor, // Replaced light grey bg
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Get.theme.cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1), // Adjusted light blue bg
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.security, color: Colors.blue, size: 32),
                ),
                const SizedBox(height: 24),

                Text(
                   "Admin Login",
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Get.theme.textTheme.displayLarge?.color),
                ),
                const SizedBox(height: 8),
                Text(
                  "PVP Traders Fashion",
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.blue),
                ),
                const SizedBox(height: 32),

                // Email
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Email", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: Get.theme.textTheme.bodyLarge?.color)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.emailController,
                  style: TextStyle(color: Get.theme.textTheme.bodyLarge?.color),
                  decoration: InputDecoration(
                    hintText: "batman@gmail.com",
                    hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 13),
                    filled: true,
                    fillColor: Get.theme.scaffoldBackgroundColor, // Very light grey/blue
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E5EC)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E5EC)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 20),

                // Password
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Password", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: Get.theme.textTheme.bodyLarge?.color)),
                ),
                const SizedBox(height: 8),
                Obx(() => TextField(
                  controller: controller.passwordController,
                  style: TextStyle(color: Get.theme.textTheme.bodyLarge?.color),
                  obscureText: !controller.isPasswordVisible.value,
                  decoration: InputDecoration(
                    hintText: "123456",
                    hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 13),
                    filled: true,
                    fillColor: Get.theme.scaffoldBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E5EC)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E5EC)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: () => controller.togglePasswordVisibility(),
                    ),
                  ),
                )),

                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.to(() => const AdminResetPasswordScreen()),
                    child: Text("Forgot password?", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.blue, fontSize: 13)),
                  ),
                ),
                const SizedBox(height: 20),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : () => controller.login(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF155EEF), // Bright Blue
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: controller.isLoading.value 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text("Login", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 14, color: Colors.grey),
            const SizedBox(width: 8),
            Text("AUTHORIZED ACCESS ONLY", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
