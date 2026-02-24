import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = Get.put(OnboardingController());

    final List<Map<String, String>> onboardingData = [
      {
        "title": "all_styles".tr,
        "desc": "all_styles_desc".tr,
        "image": AppAssets.onboarding1
      },
      {
        "title": "for_all".tr,
        "desc": "for_all_desc".tr,
        "image": AppAssets.onboarding2
      },
      {
        "title": "smart_simple".tr,
        "desc": "smart_simple_desc".tr,
        "image": AppAssets.onboarding3
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: controller.skip,
                child: Text(
                  "skip".tr,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF666666),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            
            Expanded(
              flex: 6,
              child: PageView.builder(
                controller: controller.pageController,
                itemCount: onboardingData.length,
                onPageChanged: controller.onPageChanged,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 400, // Taller specific for poster images
                        width: 300,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            onboardingData[index]["image"]!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Icon(Icons.image, size: 80, color: Colors.grey[400]),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          onboardingData[index]["title"]!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontSize: 24,
                            color: AppColors.text,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          onboardingData[index]["desc"]!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF666666),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: controller.pageIndex.value == index ? 20 : 8,
                        decoration: BoxDecoration(
                          color: controller.pageIndex.value == index
                              ? AppColors.primary
                              : const Color(0xFFCCCCCC),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  )),
                  
                  const Spacer(),
                  
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: SizedBox(
                      width: 160,
                      height: 52,
                      child: Obx(() => ElevatedButton(
                        onPressed: controller.nextPage,
                        style: ElevatedButton.styleFrom(
                           elevation: 4,
                           shadowColor: AppColors.primary.withOpacity(0.4),
                           backgroundColor: AppColors.primary,
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(26),
                           )
                        ),
                        child: Text(
                          controller.pageIndex.value == 2 ? "get_started".tr : "next".tr,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      )),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
