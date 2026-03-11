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

  // Get coupon usage statistics
  Future<Map<String, dynamic>> getCouponUsageStats(String couponCode) async {
    try {
      final usageSnapshot = await _db.collection('coupon_usage')
          .where('couponCode', isEqualTo: couponCode)
          .get();
      
      final usageCount = usageSnapshot.docs.length;
      final users = usageSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'userId': data['userId'],
          'orderId': data['orderId'],
          'usedAt': data['usedAt'],
        };
      }).toList();
      
      return {
        'code': couponCode,
        'usageCount': usageCount,
        'users': users,
      };
    } catch (e) {
      print('Error fetching coupon usage: $e');
      return {
        'code': couponCode,
        'usageCount': 0,
        'users': [],
      };
    }
  }

  // Show coupon usage dialog
  void showCouponUsageDialog(String couponCode) async {
    final stats = await getCouponUsageStats(couponCode);
    
    Get.dialog(
      Dialog(
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bar_chart, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Coupon Usage: $couponCode',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people, color: Colors.blue, size: 32),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Uses', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(
                          '${stats['usageCount']} customer${stats['usageCount'] == 1 ? '' : 's'}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Usage Details:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: stats['usageCount'] > 0
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: stats['users'].length,
                        itemBuilder: (context, index) {
                          final user = stats['users'][index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green,
                                child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                              ),
                              title: Text(
                                'Order: ${user['orderId']?.toString().substring(0, 12) ?? 'N/A'}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              subtitle: Text(
                                'User ID: ${user['userId']?.toString().substring(0, 8) ?? 'N/A'}...',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              'No one has used this coupon yet',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
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
