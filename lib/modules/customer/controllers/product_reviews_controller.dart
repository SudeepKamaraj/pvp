import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../data/models/review_model.dart';
import '../../../../data/services/database_service.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProductReviewsController extends GetxController {
  final DatabaseService _databaseService = DatabaseService();
  final String productId;

  var reviews = <ReviewModel>[].obs;
  var isLoading = false.obs;
  var userHasReviewed = false.obs;
  var averageRating = 0.0.obs;
  var reviewCount = 0.obs;

  ProductReviewsController(this.productId);

  @override
  void onInit() {
    super.onInit();
    fetchReviews();
    checkIfUserReviewed();
  }

  Future<void> fetchReviews() async {
    isLoading.value = true;
    try {
      reviews.value = await _databaseService.getReviewsForProduct(productId);
      
      // Update local stats from reviews if needed, but better rely on product model updates
      if (reviews.isNotEmpty) {
        averageRating.value = reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
        reviewCount.value = reviews.length;
      }
    } catch (e) {
      print("Error fetching reviews: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkIfUserReviewed() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userHasReviewed.value = await _databaseService.hasUserReviewedProduct(user.uid, productId);
    }
  }

  Future<void> addReview(double rating, String comment, List<XFile> imageFiles) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar("Error", "You must be logged in to review");
      return;
    }

    if (userHasReviewed.value) {
      Get.snackbar("Error", "You have already reviewed this product");
      return;
    }

    try {
      List<String> imageUrls = [];
      
      // Upload images if any
      if (imageFiles.isNotEmpty) {
        for (var file in imageFiles) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('reviews')
              .child(productId)
              .child('${DateTime.now().millisecondsSinceEpoch}_${file.name}');
          
          await ref.putFile(File(file.path));
          final url = await ref.getDownloadURL();
          imageUrls.add(url);
        }
      }

      final review = ReviewModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple ID
        productId: productId,
        userId: user.uid,
        userName: user.displayName ?? 'Anonymous',
        rating: rating,
        comment: comment,
        date: DateTime.now(),
        images: imageUrls,
      );

      await _databaseService.addReview(review);
      
      // Refresh
      await fetchReviews();
      userHasReviewed.value = true;
      Get.back(); // Close dialog if open
      Get.snackbar("Success", "Review added successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to add review: $e");
    }
  }
}
