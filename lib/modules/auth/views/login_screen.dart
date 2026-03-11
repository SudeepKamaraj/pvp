import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';
import '../controllers/login_controller.dart';
import 'package:pvp_traders/core/constants/app_assets.dart';

import '../../admin/views/admin_login_screen.dart';
import 'phone_login_screen.dart';
import 'email_login_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get or create controller (don't delete on rebuild)
    final LoginController controller = Get.put(LoginController(), tag: 'login');

    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  // Back Button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Get.theme.iconTheme.color),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Logo
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          AppAssets.logo,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_bag, size: 50, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  
                  // Title
                  Text(
                    "welcome_back".tr,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  
                  const SizedBox(height: 48),

                  // Email Field
                  _buildLabel("email_phone".tr),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.emailController,
                    style: Get.theme.textTheme.bodyLarge,
                    decoration: _inputDecoration(Icons.email_outlined),
                  ),
                  
                  const SizedBox(height: 24),

                  // Password Field
                  _buildLabel("password".tr),
                  const SizedBox(height: 8),
                  Obx(() => TextField(
                    controller: controller.passwordController,
                    style: Get.theme.textTheme.bodyLarge, // Applied theme-based text style
                    obscureText: !controller.isPasswordVisible.value,
                    decoration: _inputDecoration(Icons.lock_outline).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordVisible.value 
                            ? Icons.visibility 
                            : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                    ),
                  )),
                  
                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: controller.goToForgotPassword,
                      child: Text(
                        "forgot_password_q".tr,
                        style: GoogleFonts.poppins(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // Login Button
                  SizedBox(
                    height: 52,
                    child: Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadowColor: AppColors.primary.withOpacity(0.4),
                        elevation: 5,
                      ),
                      child: controller.isLoading.value 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                          "login".tr,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                    )),
                  ),

                  const SizedBox(height: 32),

                  // OR Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text("or".tr, style: TextStyle(color: Colors.grey[500])),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ],
                  ),
                  
                  const SizedBox(height: 32),

                  // Google Login
                  SizedBox(
                    height: 52,
                    child: Obx(() => OutlinedButton(
                      onPressed: controller.isLoading.value ? null : controller.googleLogin,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: controller.isLoading.value 
                      ? const CircularProgressIndicator(color: AppColors.primary)
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.g_mobiledata, size: 32, color: Colors.blue), 
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              "google_login".tr,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Get.theme.textTheme.bodyLarge?.color,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )),
                  ),
                                    const SizedBox(height: 16),

                  // Phone Login
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Get.to(() => const PhoneLoginScreen(isSignup: false)),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.phone_android, size: 24, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              "phone_login".tr,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Get.theme.textTheme.bodyLarge?.color,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email OTP Login
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Get.to(() => const EmailLoginScreen(isSignup: false)),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.email_outlined, size: 24, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              "email_otp_login".tr,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Get.theme.textTheme.bodyLarge?.color,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                                    const SizedBox(height: 32),

                  // Sign Up Prompt
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          "no_account".tr,
                          style: GoogleFonts.poppins(color: const Color(0xFF666666)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: controller.goToSignUp,
                        child: Text(
                          "sign_up".tr,
                          style: GoogleFonts.poppins(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: GestureDetector(
              onTap: () => Get.to(() => const AdminLoginScreen()),
              child: Container(
                width: 60,
                height: 60,
                color: Colors.transparent, // Invisible touch target
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: Color(0xFF666666),
      ),
    );
  }

  InputDecoration _inputDecoration(IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      filled: true,
      fillColor: Get.theme.cardColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    );
  }
}
