import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';
import '../controllers/signup_controller.dart';
import 'package:pvp_traders/core/constants/app_assets.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SignUpController controller = Get.put(SignUpController());

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
              const SizedBox(height: 32),

              _buildTextField("full_name".tr, controller.fullNameController, Icons.person_outline),
              const SizedBox(height: 16),
              _buildTextField("email".tr, controller.emailController, Icons.email_outlined),
              const SizedBox(height: 16),
              _buildTextField("phone_number".tr, controller.phoneController, Icons.phone_android),
              const SizedBox(height: 16),
              
              _buildLabel("password".tr),
              const SizedBox(height: 8),
              Obx(() => TextField(
                controller: controller.passwordController,
                style: TextStyle(color: Get.theme.textTheme.bodyLarge?.color),
                obscureText: !controller.isPasswordVisible.value,
                decoration: _inputDecoration(Icons.lock_outline).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                ),
              )),
              
              const SizedBox(height: 16),
              
              _buildLabel("confirm_password".tr),
              const SizedBox(height: 8),
              Obx(() => TextField(
                controller: controller.confirmPasswordController,
                style: TextStyle(color: Get.theme.textTheme.bodyLarge?.color),
                obscureText: !controller.isConfirmPasswordVisible.value,
                decoration: _inputDecoration(Icons.lock_outline).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isConfirmPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: controller.toggleConfirmPasswordVisibility,
                  ),
                ),
              )),
              
              const SizedBox(height: 16),
              
              Obx(() => Row(
                children: [
                  Checkbox(
                    value: controller.agreedToTerms.value,
                    onChanged: controller.toggleTerms,
                    activeColor: AppColors.primary,
                  ),
                  Text(
                    "agree_terms".tr,
                    style: GoogleFonts.poppins(fontSize: 14, color: Get.theme.textTheme.bodyLarge?.color),
                  ),
                ],
              )),
              
              const SizedBox(height: 24),

              SizedBox(
                height: 52,
                child: Obx(() => ElevatedButton(
                  onPressed: (controller.isLoading.value) ? null : controller.signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isLoading.value 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                      "create_account".tr,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                )),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("already_account".tr, style: GoogleFonts.poppins(color: const Color(0xFF666666))),
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

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: TextStyle(color: Get.theme.textTheme.bodyLarge?.color),
          decoration: _inputDecoration(icon),
        ),
      ],
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
