import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/services/database_service.dart';

class AdminMarketingController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final DatabaseService _databaseService = DatabaseService();

  // Coupons
  var coupons = <Map<String, dynamic>>[].obs;
  final couponCodeController = TextEditingController();
  final discountController = TextEditingController();
  var isLoading = false.obs;

  // Notifications
  final notifTitleController = TextEditingController();
  final notifBodyController = TextEditingController();
  var selectedAudience = "All Users".obs;

  @override
  void onInit() {
    super.onInit();
    fetchCoupons();
  }

  void fetchCoupons() async {
    try {
      final snapshot = await _db.collection('coupons').get();
      coupons.value = snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print("Error fetching coupons: $e");
    }
  }

  Future<void> createCoupon() async {
    if (couponCodeController.text.isEmpty || discountController.text.isEmpty) {
      Get.snackbar("Error", "Code and Discount are required");
      return;
    }

    isLoading.value = true;
    try {
      await _db.collection('coupons').add({
        'code': couponCodeController.text.toUpperCase(),
        'discount': double.tryParse(discountController.text) ?? 0.0,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      couponCodeController.clear();
      discountController.clear();
      fetchCoupons();
      Get.back();
      Get.snackbar("Success", "Coupon created successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to create coupon");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCoupon(String id) async {
    await _db.collection('coupons').doc(id).delete();
    fetchCoupons();
  }

  Future<void> sendBroadcastNotification() async {
    if (notifTitleController.text.isEmpty || notifBodyController.text.isEmpty) {
      Get.snackbar("Error", "Title and Body are required");
      return;
    }

    isLoading.value = true;
    try {
      // Create notifications for all users
      await _databaseService.createNotificationForAllUsers(
        title: notifTitleController.text,
        body: notifBodyController.text,
        type: 'offer',
      );

      // Also store in broadcast_notifications for history
      await _db.collection('broadcast_notifications').add({
        'title': notifTitleController.text,
        'body': notifBodyController.text,
        'audience': selectedAudience.value,
        'sentAt': FieldValue.serverTimestamp(),
      });

      notifTitleController.clear();
      notifBodyController.clear();
      Get.snackbar(
        "Success", 
        "Notification sent to all users!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to send notification: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
