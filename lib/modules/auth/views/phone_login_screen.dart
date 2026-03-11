import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';
import 'package:pvp_traders/core/constants/app_assets.dart';
import '../controllers/phone_auth_controller.dart';
import 'signup_screen.dart';

class PhoneLoginScreen extends StatelessWidget {
  final bool isSignup;
  
  const PhoneLoginScreen({super.key, this.isSignup = false});

  @override
  Widget build(BuildContext context) {
    // Get or create controller (don't delete on rebuild)
    final PhoneAuthController controller = Get.put(
      PhoneAuthController(),
      tag: 'phone_auth',
    );
    
    // Initialize the signup flow flag
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.isSignupFlow.value != isSignup) {
        controller.isSignupFlow.value = isSignup;
      }
    });

    return WillPopScope(
      onWillPop: () async {
        // Clean up controller when leaving
        Get.delete<PhoneAuthController>(tag: 'phone_auth');
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
                      errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.phone_android, size: 50, color: AppColors.primary),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              
              // Title
              Text(
                isSignup ? "phone_signup".tr : "phone_login".tr,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              
              const SizedBox(height: 12),
              
              // Subtitle
              Text(
                "enter_phone_otp_desc".tr,
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

              // Phone Number Field
              _buildLabel("phone_number".tr),
              const SizedBox(height: 8),
              IntlPhoneField(
                controller: controller.phoneController,
                decoration: InputDecoration(
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
                  hintText: "1234567890",
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                ),
                style: Get.theme.textTheme.bodyLarge,
                initialCountryCode: 'IN',
                dropdownTextStyle: Get.theme.textTheme.bodyLarge,
                onChanged: (phone) {
                  controller.completePhoneNumber.value = phone.completeNumber;
                },
              ),
              
              const SizedBox(height: 32),

              // Send OTP Button
              SizedBox(
                height: 56,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value 
                    ? null 
                    : () => controller.sendOTP(isSignup: isSignup),
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
                        const Icon(Icons.sms_outlined, color: Colors.white),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            "send_otp".tr,
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

              // Switch to Email Login/Signup
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Get.delete<PhoneAuthController>(tag: 'phone_auth');
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
                      const Icon(Icons.email_outlined, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          isSignup ? "use_email_signup".tr : "use_email_login".tr,
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
                        Get.delete<PhoneAuthController>(tag: 'phone_auth');
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
                        Get.delete<PhoneAuthController>(tag: 'phone_auth');
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
