import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';
import '../../../../data/models/product_model.dart';
import '../controllers/cart_controller.dart';
import 'cart_screen.dart';
import '../controllers/wishlist_controller.dart';
import '../../../../core/utils/auth_guard.dart';
import '../../../../data/models/review_model.dart';
import '../controllers/product_reviews_controller.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math' as math;
import 'checkout_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> with SingleTickerProviderStateMixin {
  int _selectedSizeIndex = -1;
  late final List<String> _sizes;
  final CartController _cartController = Get.find<CartController>();
  late final ProductReviewsController _reviewsController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _sizes = widget.product.sizes.isNotEmpty 
        ? widget.product.sizes 
        : ['S', 'M', 'L', 'XL', 'XXL']; // Fallback
        
    _reviewsController = Get.put(ProductReviewsController(widget.product.id), tag: widget.product.id);
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _shakeController, 
        curve: Curves.elasticIn,
      ),
    ).drive(TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: -1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -1.0, end: 0.0), weight: 1),
    ]));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    Get.delete<ProductReviewsController>(tag: widget.product.id);
    super.dispose();
  }

  String _translate(String text) {
    if (text.isEmpty) return text;
    String cleanText = text.trim().toLowerCase();
    String translated = cleanText.tr;
    return (translated == cleanText) ? text : translated;
  }

  @override
  Widget build(BuildContext context) {
    print("DEBUG: Product Details - Name: ${widget.product.name}");
    print("DEBUG: Product Details - Price: ${widget.product.price}");
    print("DEBUG: Product Details - Original Price: ${widget.product.originalPrice}");
    print("DEBUG: Product Details - Offer Price: ${widget.product.offerPrice}");
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.grey[200],
                child: Stack(
                  children: [
                    PageView.builder(
                      itemCount: widget.product.images.isNotEmpty ? widget.product.images.length : 1,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        String imageUrl = widget.product.images.isNotEmpty 
                            ? widget.product.images[index] 
                            : widget.product.imageUrl;

                        if (imageUrl.startsWith('data:image')) {
                          return Image.memory(
                            base64Decode(imageUrl.split(',').last),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          );
                        } else if (imageUrl.startsWith('http')) {
                          return Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                          );
                        } else {
                          return Center(
                            child: Icon(Icons.image, size: 100, color: Colors.grey[400]),
                          );
                        }
                      },
                    ),
                    if (widget.product.images.length > 1)
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            widget.product.images.length,
                            (index) => Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentImageIndex == index
                                    ? AppColors.primary
                                    : Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.arrow_back, color: Colors.black),
              ),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                icon: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.shopping_cart_outlined, color: Colors.black),
                ),
                onPressed: () => Get.to(() => const CartScreen()),
              ),
              const SizedBox(width: 8),
              Obx(() {
                final isFavorite = Get.find<WishlistController>().isInWishlist(widget.product);
                return IconButton(
                  icon: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.black,
                    ),
                  ),
                  onPressed: () {
                    if (AuthGuard.checkAuth(message: "Login to save items to your wishlist.")) {
                      Get.find<WishlistController>().toggleWishlist(widget.product);
                    }
                  },
                );
              }),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _translate(widget.product.name),
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Obx(() => Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              _reviewsController.averageRating.value > 0 
                                  ? _reviewsController.averageRating.value.toStringAsFixed(1) 
                                  : "New",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (_reviewsController.reviewCount.value > 0)
                              Text(
                                " (${_reviewsController.reviewCount.value})",
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                          ],
                        )),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _translate(widget.product.category),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        "₹${((widget.product.offerPrice != null && widget.product.offerPrice! > 0) ? widget.product.offerPrice! : widget.product.price).toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      if ((widget.product.offerPrice != null && widget.product.offerPrice! > 0) || widget.product.originalPrice != null) ...[
                        const SizedBox(width: 12),
                        Text(
                          "₹${((widget.product.offerPrice != null && widget.product.offerPrice! > 0) ? widget.product.price : widget.product.originalPrice!).toStringAsFixed(0)}",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        if ((widget.product.offerPrice != null && widget.product.offerPrice! > 0)) ...[
                           const SizedBox(width: 8),
                           Container(
                             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                             decoration: BoxDecoration(
                               color: Colors.red[50],
                               borderRadius: BorderRadius.circular(4),
                               border: Border.all(color: Colors.red.withOpacity(0.5)),
                             ),
                             child: Text(
                               "Offer Price",
                               style: GoogleFonts.poppins(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                             ),
                           )
                        ]
                      ],
                    ],
                  ),
                    const SizedBox(height: 24),
                    AnimatedBuilder(
                      animation: _shakeController,
                      builder: (context, child) {
                        final offset =  _shakeController.isAnimating 
                            ? (5 * (0.5 - (0.5 - _shakeController.value).abs()) * 4 * ( _shakeController.value > 0.5 ? -1 : 1 )) // Simple shake math
                            : 0.0;
                        // Better shake implementation using sine
                        final shake = 10 *  ( _shakeController.value > 0 ?  (1 - _shakeController.value) *  (0.5 - (0.5 - _shakeController.value).abs()) * 20 : 0);
                        // Simplified Shake:
                        double dx = 0;
                        if (_shakeController.isAnimating) {
                           dx = 10 * (1 - _shakeController.value) *  math.sin(_shakeController.value * 30); // Decay sine wave
                        }

                        return Transform.translate(
                          offset: Offset(dx, 0),
                          child: child,
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "select_size".tr,
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 16,
                              color: _selectedSizeIndex == -1 ? Colors.red : Colors.black, // Highlight error
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: List.generate(
                              _sizes.length,
                              (index) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedSizeIndex = index;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _selectedSizeIndex == index
                                          ? AppColors.primary
                                          : (_selectedSizeIndex == -1 && _shakeController.isAnimating ? Colors.red : Colors.grey[300]!),
                                    ),
                                    color: _selectedSizeIndex == index
                                        ? AppColors.primary
                                        : Colors.transparent,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _sizes[index],
                                      style: TextStyle(
                                        color: _selectedSizeIndex == index
                                            ? Colors.white
                                            : Get.theme.textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "description".tr,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "premium_quality_desc".trParams({
                        'name': _translate(widget.product.name).toLowerCase()
                      }),
                      style: TextStyle(color: Colors.grey[600], height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    _buildReviewsSection(),
                    const SizedBox(height: 80), // Space for bottom button
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    if (!AuthGuard.checkAuth(message: "login_add_cart".tr)) return;
                    
                    if (_selectedSizeIndex == -1) {
                      _shakeController.forward(from: 0.0);
                      Get.snackbar("Select Size", "Please select a size to continue", 
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red.withOpacity(0.1),
                        colorText: Colors.red,
                        duration: const Duration(milliseconds: 1500),
                      );
                      return;
                    }
                    _cartController.addToCart(widget.product, _sizes[_selectedSizeIndex]);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "add_to_cart".tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (!AuthGuard.checkAuth(message: "Login to continue")) return;
                    
                    if (_selectedSizeIndex == -1) {
                      _shakeController.forward(from: 0.0);
                      Get.snackbar("Select Size", "Please select a size to continue", 
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red.withOpacity(0.1),
                        colorText: Colors.red,
                        duration: const Duration(milliseconds: 1500),
                      );
                      return;
                    }
                    _cartController.addToCart(widget.product, _sizes[_selectedSizeIndex]);
                    Get.to(() => const CheckoutScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "buy_now".tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                "ratings_and_reviews".tr,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: () => _showReviewDialog(Get.context!, widget.product),
              child: Text("write_review".tr),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (_reviewsController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (_reviewsController.reviews.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text("no_reviews".tr),
              ),
            );
          }

          return Column(
            children: [
              // Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      _reviewsController.averageRating.value.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RatingBarIndicator(
                          rating: _reviewsController.averageRating.value,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 20.0,
                          direction: Axis.horizontal,
                        ),
                        Text("${_reviewsController.reviewCount.value} ${'reviews'.tr}", style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Reviews List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _reviewsController.reviews.length > 3 ? 3 : _reviewsController.reviews.length, // Show top 3
                separatorBuilder: (context, index) => const Divider(height: 32),
                itemBuilder: (context, index) {
                  final review = _reviewsController.reviews[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              review.userName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "${review.date.day}/${review.date.month}/${review.date.year}",
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      RatingBarIndicator(
                        rating: review.rating,
                        itemBuilder: (context, index) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 14.0,
                        direction: Axis.horizontal,
                      ),
                      const SizedBox(height: 8),
                      Text(review.comment),
                        if (review.images.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 60,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: review.images.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (context, imgIndex) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    review.images[imgIndex],
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                    ],
                  );
                },
              ),
              if (_reviewsController.reviews.length > 3)
                TextButton(
                  onPressed: () {
                    // Navigate to all reviews screen if implemented
                  },
                  child: Text("view_all_reviews".tr),
                ),
            ],
          );
        }),
      ],
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
        title: Text("rate_review".tr, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name, style: const TextStyle(fontSize: 14)),
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
                  hintText: "Write your review here...",
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
                      Flexible(
                        child: Text(
                          "add_photos".tr,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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
                Get.snackbar("Error", "Please select a rating", snackPosition: SnackPosition.BOTTOM);
                return;
              }
              
              isLoading.value = true;
              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                   await _reviewsController.addReview(
                     ratingController.value, 
                     commentController.text.trim(),
                     selectedImages
                   );
                   // Controller handles success snackbar and closing dialog
                } else {
                   Get.snackbar("Error", "You must be logged in to review", snackPosition: SnackPosition.BOTTOM);
                   isLoading.value = false;
                }
              } catch (e) {
                Get.snackbar("Error", "Failed to submit: $e", snackPosition: SnackPosition.BOTTOM);
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
}
