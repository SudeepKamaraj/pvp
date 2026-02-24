import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';
import '../controllers/admin_auth_controller.dart';

class AdminResetPasswordScreen extends StatelessWidget {
  const AdminResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminAuthController controller = Get.find<AdminAuthController>();
    final TextEditingController emailController = TextEditingController();

    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Get.theme.iconTheme.color, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.lock_reset, color: Colors.red, size: 32),
            ),
            const SizedBox(height: 24),
            Text("Reset Password", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Get.theme.textTheme.displayLarge?.color)),
            const SizedBox(height: 12),
            Text(
              "Enter your admin email to receive a recovery link.",
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),

            Text("REGISTERED EMAIL", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              style: TextStyle(color: Get.theme.textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                hintText: "admin@pvptraders.com",
                prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                filled: true,
                fillColor: Get.theme.cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => controller.resetPassword(emailController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, // Red
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 5,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Send Reset Link", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                    const SizedBox(width: 8),
                    const Icon(Icons.send, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Check your email for reset instructions. We'll send a secure link to authorize your password change.",
                      style: GoogleFonts.poppins(color: Get.theme.textTheme.bodyLarge?.color, fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            Center(
              child: TextButton.icon(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.login, color: Colors.grey, size: 18),
                label: Text("Return to Login", style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
