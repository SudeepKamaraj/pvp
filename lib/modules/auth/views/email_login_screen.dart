import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';
import 'package:pvp_traders/core/constants/app_assets.dart';
import '../controllers/email_auth_controller.dart';
import 'signup_screen.dart';

class EmailLoginScreen extends StatelessWidget {
  final bool isSignup;
  
  const EmailLoginScreen({super.key, this.isSignup = false});

  @override
  Widget build(BuildContext context) {
    // Get or create controller (don't delete on rebuild)
    final EmailAuthController controller = Get.put(
      EmailAuthController(),
      permanent: true,
    );
    
    // Password controller for login
    final passwordController = TextEditingController();
    final RxBool obscurePassword = true.obs;
    
    // Initialize the signup flow flag
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.isSignupFlow.value != isSignup) {
        controller.isSignupFlow.value = isSignup;
      }
    });

    return WillPopScope(
      onWillPop: () async {
        // Don't delete controller on back - let it persist for OTP screen
        return true;
      },
      child: Scaffold(
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        body: SafeArea(
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
                    onPressed: () {
                      Get.back();
                    },
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
                        errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.email_outlined, size: 50, color: AppColors.primary),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                
                // Title
                Text(
                  isSignup ? "email_otp_signup".tr : "email_otp_login".tr,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                
                const SizedBox(height: 12),
                
                // Subtitle
                Text(
                  isSignup ? "enter_email_otp_desc".tr : "enter_email_password_desc".tr,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                
                const SizedBox(height: 48),

                // Full Name Field (only for signup)
                if (isSignup) ...[
                  _buildLabel("full_name".tr),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.fullNameController,
                    style: Get.theme.textTheme.bodyLarge,
                    decoration: _inputDecoration(Icons.person_outline),
                  ),
                  const SizedBox(height: 24),
                ],

                // Email Field
                _buildLabel("email".tr),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.emailController,
                  style: Get.theme.textTheme.bodyLarge,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(Icons.email_outlined),
                ),
                
                const SizedBox(height: 24),
                
                // Password Field (only for login)
                if (!isSignup) ...[
                  _buildLabel("password".tr),
                  const SizedBox(height: 8),
                  Obx(() => TextField(
                    controller: passwordController,
                    style: Get.theme.textTheme.bodyLarge,
                    obscureText: obscurePassword.value,
                    decoration: _inputDecoration(Icons.lock_outline).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword.value 
                            ? Icons.visibility_outlined 
                            : Icons.visibility_off_outlined,
                          color: Colors.grey[600],
                        ),
                        onPressed: () => obscurePassword.value = !obscurePassword.value,
                      ),
                    ),
                  )),
                ],
                
                const SizedBox(height: 32),

                // Button - Send OTP for signup, Login for login
                SizedBox(
                  height: 56,
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value 
                      ? null 
                      : () {
                          if (isSignup) {
                            controller.sendOTP(isSignup: true);
                          } else {
                            controller.loginWithEmailPassword(
                              email: controller.emailController.text.trim(),
                              password: passwordController.text,
                            );
                          }
                        },
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
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isSignup ? Icons.mail_outline : Icons.login,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              isSignup ? "send_otp".tr : "login".tr,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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

                // Switch to regular Email Login
                SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.password_outlined, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            isSignup ? "use_email_password_signup".tr : "use_email_password_login".tr,
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

                const SizedBox(height: 24),

                // Login/Signup Toggle
                if (isSignup)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          "have_account".tr,
                          style: GoogleFonts.poppins(color: const Color(0xFF666666)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          Get.back();
                        },
                        child: Text(
                          "login".tr,
                          style: GoogleFonts.poppins(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  )
                else
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
                        onPressed: () {
                          Get.back();
                          Get.to(() => const SignUpScreen());
                        },
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
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF666666),
      ),
    );
  }

  InputDecoration _inputDecoration(IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      filled: true,
      fillColor: Get.theme.cardColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }
}
