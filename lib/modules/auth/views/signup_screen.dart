import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';
import '../controllers/signup_controller.dart';
import 'package:pvp_traders/core/constants/app_assets.dart';
import 'phone_login_screen.dart';
import 'email_login_screen.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get or create controller (don't delete on rebuild)
    final SignUpController controller = Get.put(SignUpController(), tag: 'signup');

    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Get.theme.iconTheme.color),
                  onPressed: () => Get.back(),
                ),
              ),
              const SizedBox(height: 24),
              // Logo
              Center(
                child: Container(
                  width: 80,
                  height: 80,
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
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_bag, size: 40, color: AppColors.primary),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Text(
                "create_account".tr,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 12),
              
              // Subtitle
              Text(
                "choose_signup_method".tr,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 48),

              // Email Signup
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Get.to(() => const EmailLoginScreen(isSignup: true)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: AppColors.primary.withOpacity(0.4),
                    elevation: 5,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.email_outlined, size: 24, color: Colors.white),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          "email_signup".tr,
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
                ),
              ),

              const SizedBox(height: 16),

              // Phone Signup
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Get.to(() => const PhoneLoginScreen(isSignup: true)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: AppColors.primary.withOpacity(0.4),
                    elevation: 5,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.phone_android, size: 24, color: Colors.white),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          "phone_signup".tr,
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
                ),
              ),

              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      "already_account".tr,
                      style: GoogleFonts.poppins(color: const Color(0xFF666666)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: controller.goToLogin,
                    child: Text(
                      "login".tr,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.blue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
