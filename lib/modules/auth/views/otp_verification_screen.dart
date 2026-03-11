import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';
import '../controllers/phone_auth_controller.dart';

class OTPVerificationScreen extends StatelessWidget {
  final String phoneNumber;
  final bool isSignupFlow;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.isSignupFlow = false,
  });

  @override
  Widget build(BuildContext context) {
    // Try to find existing controller, or create new one if not found
    late final PhoneAuthController controller;
    try {
      controller = Get.find<PhoneAuthController>();
    } catch (e) {
      // If controller doesn't exist, navigate back to avoid errors
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        Get.snackbar("error".tr, "Session expired. Please try again.");
      });
      controller = PhoneAuthController(); // Temporary controller to avoid null
    }

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Get.theme.textTheme.bodyLarge?.color,
      ),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.primary, width: 2),
      borderRadius: BorderRadius.circular(12),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: AppColors.primary.withOpacity(0.1),
        border: Border.all(color: AppColors.primary),
      ),
    );

    return Scaffold(
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
              
              // Logo/Icon
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
                    Icons.message_outlined,
                    size: 50,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 32),
              
              // Title
              Text(
                "verify_phone".tr,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              
              const SizedBox(height: 12),
              
              // Subtitle with phone number
              Text(
                "otp_sent_to".trParams({'phone': phoneNumber}),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Edit phone number
              Center(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    "edit_phone_number".tr,
                    style: GoogleFonts.poppins(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),

              // OTP Input
              Center(
                child: Pinput(
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: submittedPinTheme,
                  showCursor: true,
                  onCompleted: (pin) {
                    // Auto-verify when all 6 digits entered
                    for (int i = 0; i < 6; i++) {
                      controller.otpControllers[i].text = pin[i];
                    }
                    controller.verifyOTP();
                  },
                  onChanged: (value) {
                    // Update individual controllers
                    for (int i = 0; i < value.length && i < 6; i++) {
                      controller.otpControllers[i].text = value[i];
                    }
                  },
                  hapticFeedbackType: HapticFeedbackType.lightImpact,
                  cursor: Container(
                    width: 2,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),

              // Verify Button
              SizedBox(
                height: 56,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value 
                    ? null 
                    : controller.verifyOTP,
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
                      "verify_otp".tr,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                )),
              ),

              const SizedBox(height: 32),

              // Resend OTP Section
              Obx(() {
                if (controller.canResend.value) {
                  return Center(
                    child: TextButton(
                      onPressed: controller.resendOTP,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.refresh, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "resend_otp".tr,
                              style: GoogleFonts.poppins(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: RichText(
                      text: TextSpan(
                        text: "resend_in".tr + " ",
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: "${controller.countdown.value}s",
                            style: GoogleFonts.poppins(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }),

              const SizedBox(height: 24),

              // Help text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "otp_help_text".tr,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
