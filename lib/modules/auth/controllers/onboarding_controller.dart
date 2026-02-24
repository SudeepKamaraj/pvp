import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../views/login_screen.dart';
import '../../customer/views/dashboard_screen.dart';

class OnboardingController extends GetxController {
  var pageIndex = 0.obs;
  final PageController pageController = PageController();

  void onPageChanged(int index) {
    pageIndex.value = index;
  }

  void nextPage() {
    if (pageIndex.value < 2) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      finishOnboarding();
    }
  }

  void skip() {
    finishOnboarding();
  }

  void finishOnboarding() {
    Get.off(() => const DashboardScreen());
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
