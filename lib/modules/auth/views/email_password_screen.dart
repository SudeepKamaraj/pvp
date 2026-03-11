import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';
import '../controllers/email_auth_controller.dart';

class EmailPasswordScreen extends StatelessWidget {
  final String email;
  final String fullName;

  const EmailPasswordScreen({
    super.key,
    required this.email,
    required this.fullName,
  });

  @override
  Widget build(BuildContext context) {
    late final EmailAuthController controller;
    try {
      controller = Get.find<EmailAuthController>();
    } catch (e) {
      // If controller doesn't exist, create a new one
      print('Controller not found in password screen, creating new one...');
      controller = Get.put(EmailAuthController(), permanent: true);
    }
    
    // Ensure controller has correct values
    controller.userEmail.value = email;
    controller.fullNameController.text = fullName;
    controller.emailController.text = email;
    
    final formKey = GlobalKey<FormState>();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final RxBool obscurePassword = true.obs;
    final RxBool obscureConfirmPassword = true.obs;

    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: formKey,
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
                
                // Icon
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.1),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      size: 50,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                
                // Title
                Text(
                  "create_password".tr,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                
                const SizedBox(height: 12),
                
                // Subtitle
                Text(
                  "create_password_subtitle".tr,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 40),

                // Email display
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "email_verified".tr,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              email,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.green[900],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Password Field
                Obx(() => TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword.value,
                  validator: (value) => controller.validatePassword(value ?? ''),
                  decoration: InputDecoration(
                    labelText: "password".tr,
                    hintText: "enter_password".tr,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword.value 
                          ? Icons.visibility_off 
                          : Icons.visibility,
                      ),
                      onPressed: () => obscurePassword.value = !obscurePassword.value,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                )),

                const SizedBox(height: 20),

                // Confirm Password Field
                Obx(() => TextFormField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword.value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "enter_password_again".tr;
                    }
                    if (value != passwordController.text) {
                      return "passwords_dont_match".tr;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "confirm_password".tr,
                    hintText: "enter_password_again".tr,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword.value 
                          ? Icons.visibility_off 
                          : Icons.visibility,
                      ),
                      onPressed: () => obscureConfirmPassword.value = !obscureConfirmPassword.value,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                )),

                const SizedBox(height: 24),

                // Password requirements
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              "password_requirements".tr,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildRequirement("• At least 6 characters"),
                      _buildRequirement("• Mix of letters and numbers recommended"),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Create Account Button
                SizedBox(
                  height: 56,
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value 
                      ? null 
                      : () {
                          if (formKey.currentState!.validate()) {
                            controller.createAccountWithPassword(
                              email: email,
                              fullName: fullName,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, top: 4),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}
