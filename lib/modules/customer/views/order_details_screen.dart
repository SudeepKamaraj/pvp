import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/customer_order_controller.dart';
import 'package:intl/intl.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';
import '../../../../data/models/order_model.dart';
import 'order_tracking_screen.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../../data/models/review_model.dart';
import '../../../../data/services/database_service.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/models/product_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'product_details_screen.dart';
import '../../../../data/models/cart_item_model.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;
  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // Ensure status bar icons are visible (dark icons for light background)
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light, 
    ));

    // Determine active status for timeline
    final bool isPacked = order.status == "Packed" || order.status == "Shipped" || order.status == "Delivered";
    final bool isShipped = order.status == "Shipped" || order.status == "Delivered";
    final bool isDelivered = order.status == "Delivered";

    String _translate(String text) {
      if (text.isEmpty) return text;
      String cleanText = text.trim().toLowerCase();
      String translated = cleanText.tr;
      return (translated == cleanText) ? text : translated;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Column(
          children: [
            Text("order_details".tr, style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            Text("#${order.id.substring(0, 8).toUpperCase()}", style: GoogleFonts.poppins(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white, // Changed to white to ensure contrast
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        surfaceTintColor: Colors.transparent, // Disable Material 3 tint
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          "in_transit".tr,
                          style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          "${'est_arrival'.tr} : Oct 24",
                          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("${'arriving_by'.tr} ${'thursday'.tr}", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("package_in_city".tr, style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13, height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Order Progress
            Text("order_progress".tr, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            
            _buildTimelineStep(
              title: "delivered".tr,
              date: "${'expected_by'.tr} ${'thursday'.tr}, 24 Oct",
              isActive: isDelivered,
              isCompleted: isDelivered,
              isFirst: true,
            ),
            _buildTimelineStep(
              title: "shipped".tr,
              date: "${'tuesday'.tr}, 22 Oct • 10:45 AM",
              isActive: isShipped,
              isCompleted: isShipped,
              trailingWidget: Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        "${'tracking'.tr}: ${order.trackingId ?? 'PVP99120023'}",
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.copy, size: 12, color: Colors.red),
                  ],
                ),
              ),
            ),
            _buildTimelineStep(
              title: "packed".tr,
              date: "${'monday'.tr}, 21 Oct • 04:30 PM",
              isActive: isPacked,
              isCompleted: isPacked,
            ),
            _buildTimelineStep(
              title: "ordered".tr,
              date: "${'monday'.tr}, 21 Oct • 11:20 AM",
              isActive: true,
              isCompleted: true,
              isLast: true,
            ),

            const SizedBox(height: 30),

            // Items List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    "items_in_order".trParams({'count': order.items.length.toString()}),
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showReceiptDialog(context),
                  child: Text(
                    "view_receipt".tr,
                    style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              itemBuilder: (context, index) {
                final item = order.items[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      _buildProductImage(item),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("pvp_exclusive".tr, style: GoogleFonts.poppins(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(_translate(item.product.name), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text("${'size_label'.tr}: ${item.selectedSize} • ${'color_label'.tr}: Camel", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)), // Mock color
                            const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      "\$${item.product.price.toStringAsFixed(2)}",
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      "${'qty_label'.tr}: ${item.quantity}",
                                      style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (order.status == 'Delivered') ...[
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  height: 36,
                                  child: OutlinedButton(
                                    onPressed: () => _showReviewDialog(context, item.product),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.red),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: Text("write_review".tr, style: GoogleFonts.poppins(fontSize: 12, color: Colors.red)),
                                  ),
                                ),
                              ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

             // Shipping Details
            Text("shipping_details".tr, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle),
                    child: const Icon(Icons.location_on, color: Colors.red),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Jonathan Sterling", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)), // Mock Name
                        const SizedBox(height: 4),
                        Text(
                          "${order.address}\n${order.city}, ${order.zip}", 
                          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13, height: 1.4)
                        ),
                        const SizedBox(height: 4),
                        Text("+1 (555) 012-3456", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)), // Mock Phone
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),


             // Payment Method
            Text("payment_method".tr, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.credit_card, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Apple Pay", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text("Visa ending in •••• 9921", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                   _buildSummaryRow("subtotal".tr, "\$${order.totalAmount.toStringAsFixed(2)}"),
                   _buildSummaryRow("shipping_fee".tr, "FREE", isGreen: true),
                   _buildSummaryRow("estimated_tax".tr, "\$82.15"),
                   const SizedBox(height: 12),
                   _buildSummaryRow("total_amount".tr, "\$${(order.totalAmount + 82.15).toStringAsFixed(2)}", isTotal: true),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Bottom Buttons
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => Get.find<CustomerOrderController>().contactSupport(),
                icon: const Icon(Icons.support_agent, color: Colors.white),
                label: Text("customer_support".tr, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF1728), // Red
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                  shadowColor: Colors.red.withOpacity(0.3),
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            Center(child: Text("PVP TRADERS PREMIUM FASHION RETAIL GROUP", style: GoogleFonts.poppins(color: Colors.grey[300], fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5))),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showReceiptDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text("receipt".tr, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Order #${order.id}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("At: ${DateFormat('dd MMM yyyy, hh:mm a').format(order.date)}", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 16),
              const Divider(),
              ...order.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text("${item.quantity}x ${item.product.name}", style: GoogleFonts.poppins(fontSize: 13))),
                    Text("\$${(item.product.price * item.quantity).toStringAsFixed(2)}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              )).toList(),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  Text("\$${order.totalAmount.toStringAsFixed(2)}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.red)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(), 
            child: Text("close".tr, style: const TextStyle(color: Colors.grey))
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildTimelineStep({required String title, required String date, required bool isActive, required bool isCompleted, Widget? trailingWidget, bool isFirst = false, bool isLast = false}) {
    // Logic for connector lines based on position
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline indicator column
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Top line
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 20,
                    color: Colors.red.withOpacity(0.2),
                  ),
                // Dot
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.red : Colors.grey[200],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: isCompleted ? [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                  ),
                  child: isCompleted ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                ),
                // Bottom line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted ? Colors.red : Colors.grey[200],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content column
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0), // Spacing between items
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: isCompleted ? Colors.black : Colors.grey)),
                  const SizedBox(height: 4),
                  Text(date, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                  if (trailingWidget != null) trailingWidget,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isGreen = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.poppins(color: isTotal ? Colors.black : Colors.grey, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.poppins(color: isTotal ? Colors.red : (isGreen ? Colors.green : Colors.black), fontWeight: FontWeight.bold, fontSize: isTotal ? 18 : 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(BuildContext context, ProductModel product) {
    final ratingController = 0.0.obs;
    final commentController = TextEditingController();
    final isLoading = false.obs;
    final selectedImages = <XFile>[].obs;
    final ImagePicker picker = ImagePicker();

    Get.dialog(
      AlertDialog(
        title: Text("rate_review".tr, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name, style: GoogleFonts.poppins(fontSize: 14)),
              const SizedBox(height: 16),
              Center(
                child: RatingBar.builder(
                  initialRating: 0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (rating) {
                    ratingController.value = rating;
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: "write_review".tr + "...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Add Photos", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_a_photo, color: Colors.red),
                        onPressed: () async {
                          final List<XFile> images = await picker.pickMultiImage();
                          if (images.isNotEmpty) {
                            selectedImages.addAll(images);
                          }
                        },
                      ),
                    ],
                   ),
                   if (selectedImages.isNotEmpty)
                    SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedImages.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(selectedImages[index].path),
                                  width: 80, height: 80, fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                right: 0, top: 0,
                                child: InkWell(
                                  onTap: () => selectedImages.removeAt(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                ],
              )),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text("cancel".tr, style: const TextStyle(color: Colors.grey))),
          Obx(() => ElevatedButton(
            onPressed: isLoading.value ? null : () async {
              if (ratingController.value == 0) {
                Get.snackbar("error".tr, "select_rating".tr, snackPosition: SnackPosition.BOTTOM);
                return;
              }
              
              isLoading.value = true;
              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  List<String> imageUrls = [];
                  if (selectedImages.isNotEmpty) {
                    for (var file in selectedImages) {
                      final ref = FirebaseStorage.instance
                          .ref()
                          .child('reviews')
                          .child(product.id)
                          .child('${DateTime.now().millisecondsSinceEpoch}_${file.name}');
                      
                      await ref.putFile(File(file.path));
                      final url = await ref.getDownloadURL();
                      imageUrls.add(url);
                    }
                  }

                  final review = ReviewModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    productId: product.id,
                    userId: user.uid,
                    userName: user.displayName ?? 'Anonymous',
                    rating: ratingController.value,
                    comment: commentController.text.trim(),
                    date: DateTime.now(),
                    images: imageUrls,
                  );
                  
                  await DatabaseService().addReview(review);
                  Get.back();
                  Get.snackbar("success".tr, "review_submitted".tr, snackPosition: SnackPosition.BOTTOM);
                }
              } catch (e) {
                Get.snackbar("error".tr, "failed_to_submit".tr + ": $e", snackPosition: SnackPosition.BOTTOM);
              } finally {
                isLoading.value = false;
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: isLoading.value 
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
              : Text("submit".tr, style: const TextStyle(color: Colors.white)),
          )),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildProductImage(CartItemModel item) {
    return FutureBuilder<ProductModel?>(
      future: _fetchProductData(item.product.id),
      builder: (context, snapshot) {
        String imageUrl = '';
        
        // Try to get image URL from the live product data first
        if (snapshot.hasData && snapshot.data != null) {
          final liveProduct = snapshot.data!;
          
          // Priority 1: Check imageUrl field
          if (liveProduct.imageUrl.isNotEmpty) {
            imageUrl = liveProduct.imageUrl;
            print("Using live product imageUrl: $imageUrl");
          }
          // Priority 2: Check images array
          else if (liveProduct.images.isNotEmpty) {
            imageUrl = liveProduct.images.first;
            print("Using live product images[0]: $imageUrl");
          }
        }
        
        // If no live data or no image found, fall back to item's product data
        if (imageUrl.isEmpty) {
          if (item.product.imageUrl.isNotEmpty) {
            imageUrl = item.product.imageUrl;
            print("Using cached product imageUrl: $imageUrl");
          } else if (item.product.images.isNotEmpty) {
            imageUrl = item.product.images.first;
            print("Using cached product images[0]: $imageUrl");
          }
        }
        
        print("Final imageUrl for ${item.product.name}: '$imageUrl' (isEmpty: ${imageUrl.isEmpty})");

        return GestureDetector(
          onTap: () {
            if (snapshot.hasData && snapshot.data != null) {
              Get.to(() => ProductDetailsScreen(product: snapshot.data!));
            } else {
              Get.to(() => ProductDetailsScreen(product: item.product));
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 80,
              height: 80,
              color: Colors.white,
              child: _buildImageWidget(imageUrl, item.product.name, snapshot.connectionState),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageWidget(String imageUrl, String productName, ConnectionState connectionState) {
    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: connectionState == ConnectionState.waiting
            ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
            : const Icon(Icons.image_not_supported, color: Colors.grey, size: 20),
      );
    }

    // Handle base64 images
    if (imageUrl.startsWith('data:image')) {
      try {
        final base64String = imageUrl.split(',').last;
        return Image.memory(
          base64Decode(base64String),
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print("Base64 image decode error for $productName: $error");
            return Container(
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image, color: Colors.grey, size: 20),
            );
          },
        );
      } catch (e) {
        print("Base64 image error for $productName: $e");
        return Container(
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey, size: 20),
        );
      }
    }

    // Handle network images
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[100],
          child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
        ),
        errorWidget: (context, url, error) {
          print("Image load error for $productName: $url - $error");
          return Container(
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey, size: 20),
          );
        },
      );
    }

    // Unknown format
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 20),
    );
  }

  Future<ProductModel?> _fetchProductData(String productId) async {
    try {
      print("Fetching product data for ID: $productId");
      final doc = await DatabaseService().getProductById(productId);
      if (doc != null) {
        print("Product fetched: ${doc.name}, Image: ${doc.imageUrl}");
      } else {
        print("Product not found for ID: $productId");
      }
      return doc;
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }
}
