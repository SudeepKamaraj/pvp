import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../../data/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/services/database_service.dart';
import 'cart_controller.dart';
import '../../../../core/constants/app_assets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeController extends GetxController {
  var isLoading = false.obs;
  final DatabaseService _databaseService = DatabaseService();

  var trendingProducts = <ProductModel>[].obs;
  var personalizedProducts = <ProductModel>[].obs;
  var recommendationReasons = <String, String>{}.obs;
  var categories = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchProducts(),
        fetchCategories(),
        checkActiveOffer(), // Check for promo
      ]);
      
      await Get.find<CartController>().checkAbandonedCartRecovery();
    } catch (e) {
      print("Error in fetchData: $e");
      // Don't show error to user, just use fallback data
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkActiveOffer() async {
    try {
      // Check if user is admin - don't show offer to admin
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;
      
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      if (userDoc.exists) {
        final role = userDoc.data()?['role']?.toString().toLowerCase();
        if (role == 'admin') {
          return; // Don't show offer to admin users
        }
      }
      
      final offer = await _databaseService.getCurrentOffer();
      if (offer != null) {
        // Fetch user's personal coupon code
        final couponSnapshot = await FirebaseFirestore.instance
            .collection('coupons')
            .where('userId', isEqualTo: currentUser.uid)
            .where('offerId', isEqualTo: 'current_offer')
            .where('isActive', isEqualTo: true)
            .where('isUsed', isEqualTo: false)
            .limit(1)
            .get();
        
        if (couponSnapshot.docs.isNotEmpty) {
          final couponData = couponSnapshot.docs.first.data();
          final personalCode = couponData['code'] as String;
          
          // Delay slightly to let UI build, then show dialog
          Future.delayed(const Duration(seconds: 2), () {
            if (Get.context != null) {
              _showFestivalOfferDialog(offer, personalCode);
            }
          });
        }
      }
    } catch (e) {
      print("Error checking offer: $e");
    }
  }

  void _showFestivalOfferDialog(Map<String, dynamic> offer, String personalCouponCode) {
    final discountPercent = offer['discount']?.toStringAsFixed(0) ?? '10';
    final title = offer['title'] ?? 'diwali';
    final description = offer['description'] ?? '$discountPercent.0% OFF! Limited Time Offer.';
    
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Main Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFA726),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFA726).withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.celebration,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Title
                    Text(
                      title.toLowerCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFE53935),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Description
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Coupon Code Box with Copy Button (Highlighted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFFF3E0),
                            const Color(0xFFFFE0B2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFA726),
                          width: 2.5,
                          style: BorderStyle.solid,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFA726).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.card_giftcard,
                                size: 18,
                                color: Color(0xFFE65100),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'YOUR CODE:',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFE65100),
                                width: 1.5,
                              ),
                            ),
                            child: SelectableText(
                              personalCouponCode,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFE65100),
                                letterSpacing: 2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: personalCouponCode));
                              Get.snackbar(
                                '✓ Copied!',
                                'Coupon code copied to clipboard',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                                duration: const Duration(seconds: 2),
                                margin: const EdgeInsets.all(10),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFA726), Color(0xFFFF9800)],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFA726).withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.copy, size: 16, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                    'COPY CODE',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    
                    // Shop Now Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                          elevation: 8,
                          shadowColor: const Color(0xFFE53935).withOpacity(0.4),
                        ),
                        child: Text(
                          'SHOP NOW',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Close Button
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.grey[400], size: 24),
                  onPressed: () => Get.back(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Future<void> fetchCategories() async {
    try {
      var cats = await _databaseService.getCategories();
      
      // If DB is empty, provide defaults for Men, Women, Kids
      if (cats.isEmpty) {
        print("No categories found in database, using defaults");
        cats = [
          {'name': 'Men', 'image': AppAssets.menCategory, 'id': 'men'},
          {'name': 'Women', 'image': AppAssets.womenCategory, 'id': 'women'},
          {'name': 'Kids', 'image': AppAssets.kidsCategory, 'id': 'kids'},
          {'name': 'Electronics', 'image': '', 'id': 'electronics'},
        ];
      }

      if (cats.isNotEmpty) {
        // 1. Filter out 'Sarees'
        var filteredCats = cats.where((c) {
          final name = c['name']?.toString().toLowerCase() ?? '';
          return name != 'sarees' && name != 'saree';
        }).toList();

         // 2. Ensure Men, Women, Kids exist
        final requiredCategories = ['Men', 'Women', 'Kids'];
        for (var req in requiredCategories) {
          bool exists = filteredCats.any((c) => c['name']?.toString().toLowerCase() == req.toLowerCase());
          if (!exists) {
            String image = '';
            if (req == 'Kids') image = AppAssets.kidsCategory;
            if (req == 'Men') image = AppAssets.menCategory;
            if (req == 'Women') image = AppAssets.womenCategory;
            filteredCats.add({'name': req, 'image': image, 'id': req.toLowerCase()});
          }
        }
        // 3. Force update images for local assets ensuring they are used
        for (int i = 0; i < filteredCats.length; i++) {
          var cat = Map<String, dynamic>.from(filteredCats[i]); // Create modifiable copy
          String name = cat['name']?.toString() ?? '';
          
          if (name.toLowerCase() == 'men') {
             cat['image'] = AppAssets.menCategory;
          } else if (name.toLowerCase() == 'women') {
             cat['image'] = AppAssets.womenCategory;
          } else if (name.toLowerCase() == 'kids') {
             cat['image'] = AppAssets.kidsCategory;
          }
          
          filteredCats[i] = cat;
        }

        // 2. Sort: Men, Women, Kids first
        filteredCats.sort((a, b) {
          final nameA = a['name'].toString().toLowerCase();
          final nameB = b['name'].toString().toLowerCase();

          int priority(String name) {
            if (name == 'men') return 1;
            if (name == 'women') return 2;
            if (name == 'kids') return 3;
            return 4; // Others
          }

          final pA = priority(nameA);
          final pB = priority(nameB);

          if (pA != pB) return pA.compareTo(pB);
          return nameA.compareTo(nameB);
        });

        categories.assignAll(filteredCats);
      }
    } catch (e) {
      print("Error fetching categories: $e");
      // Provide default categories on error
      if (categories.isEmpty) {
        categories.assignAll([
          {'name': 'Men', 'image': AppAssets.menCategory, 'id': 'men'},
          {'name': 'Women', 'image': AppAssets.womenCategory, 'id': 'women'},
          {'name': 'Kids', 'image': AppAssets.kidsCategory, 'id': 'kids'},
        ]);
      }
    }
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    try {
      final products = await _databaseService.getProducts();
      if (products.isNotEmpty) {
        final sortedTrending = List<ProductModel>.from(products)
          ..sort((a, b) => _trendingScore(b).compareTo(_trendingScore(a)));

        trendingProducts.assignAll(sortedTrending);
        await _buildPersonalizedFeed(products);
      } else {
        print("No products found in database, using fallback data");
        // Fallback to dummy data if DB is empty
        trendingProducts.assignAll(_dummyProducts);
        personalizedProducts.assignAll(_dummyProducts);
        recommendationReasons.clear();
      }
    } catch (e) {
      print("Error fetching products: $e");
      // Always provide fallback data on error
      if (trendingProducts.isEmpty) {
        trendingProducts.assignAll(_dummyProducts);
      }
      if (personalizedProducts.isEmpty) {
        personalizedProducts.assignAll(_dummyProducts);
        recommendationReasons.clear();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPersonalizedFeedFromCurrentProducts() async {
    if (trendingProducts.isEmpty) return;
    await _buildPersonalizedFeed(trendingProducts.toList());
  }

  double _trendingScore(ProductModel product) {
    final normalizedOrders = (product.orderCount / 100).clamp(0.0, 1.0);
    final normalizedRating = (product.rating / 5).clamp(0.0, 1.0);
    final normalizedReviews = (product.reviewCount / 200).clamp(0.0, 1.0);
    final offerBoost = (product.offerPrice != null && product.offerPrice! > 0) ? 0.08 : 0.0;
    final stockPenalty = product.stockQuantity <= 0 ? -1.0 : 0.0;

    return (normalizedOrders * 0.45) +
        (normalizedRating * 0.30) +
        (normalizedReviews * 0.17) +
        offerBoost +
        stockPenalty;
  }

  Future<void> _buildPersonalizedFeed(List<ProductModel> allProducts) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      personalizedProducts.assignAll(
        allProducts
            .where((p) => p.stockQuantity > 0)
            .toList()
          ..sort((a, b) => _trendingScore(b).compareTo(_trendingScore(a))),
      );
      recommendationReasons.clear();
      return;
    }

    final signals = await _databaseService.getUserRecommendationSignals(user.uid);
    final wishlistIds = Set<String>.from(signals['wishlistIds'] ?? <String>[]);
    final viewedProductIds = Set<String>.from(signals['recentViewedProductIds'] ?? <String>[]);
    final categoryViewScore = Map<String, int>.from(signals['categoryViewScore'] ?? <String, int>{});
    final productViewScore = Map<String, int>.from(signals['productViewScore'] ?? <String, int>{});

    final wishlistProducts = allProducts.where((p) => wishlistIds.contains(p.id)).toList();
    final wishlistCategories = wishlistProducts.map((p) => p.category.toLowerCase()).toSet();
    final preferredSizes = <String>{};
    for (final item in wishlistProducts) {
      preferredSizes.addAll(item.sizes.map((s) => s.toUpperCase()));
    }

    final avgWishlistPrice = wishlistProducts.isEmpty
        ? null
        : wishlistProducts.map((p) => p.price).reduce((a, b) => a + b) / wishlistProducts.length;

    final maxCategoryView = categoryViewScore.values.isEmpty
        ? 1
        : categoryViewScore.values.reduce((a, b) => a > b ? a : b);
    final maxProductView = productViewScore.values.isEmpty
        ? 1
        : productViewScore.values.reduce((a, b) => a > b ? a : b);

    final scored = <MapEntry<ProductModel, double>>[];
    final reasons = <String, String>{};

    for (final product in allProducts) {
      if (product.stockQuantity <= 0) continue;
      if (wishlistIds.contains(product.id)) continue;

      final categoryKey = product.category
          .trim()
          .toLowerCase()
          .replaceAll('.', '_')
          .replaceAll('/', '_')
          .replaceAll(' ', '_');

      final trend = _trendingScore(product).clamp(0.0, 1.0);
      final categoryMatch = ((categoryViewScore[categoryKey] ?? 0) / maxCategoryView).clamp(0.0, 1.0);
      final productAffinity = ((productViewScore[product.id] ?? 0) / maxProductView).clamp(0.0, 1.0);

      double wishlistCategorySignal = wishlistCategories.contains(product.category.toLowerCase()) ? 1.0 : 0.0;

      double sizeSignal = 0.0;
      if (preferredSizes.isNotEmpty && product.sizes.isNotEmpty) {
        final overlap = product.sizes.where((s) => preferredSizes.contains(s.toUpperCase())).length;
        sizeSignal = (overlap / preferredSizes.length).clamp(0.0, 1.0);
      }

      double priceAffinitySignal = 0.0;
      if (avgWishlistPrice != null && avgWishlistPrice > 0) {
        final distance = (product.price - avgWishlistPrice).abs() / avgWishlistPrice;
        priceAffinitySignal = (1 - distance).clamp(0.0, 1.0);
      }

      final recentlyViewedBoost = viewedProductIds.contains(product.id) ? 0.12 : 0.0;
      final offerBoost = (product.offerPrice != null && product.offerPrice! > 0) ? 0.06 : 0.0;

      // Keep rankings from getting stale by introducing a tiny deterministic exploration factor.
      final daySeed = DateTime.now().difference(DateTime(2024, 1, 1)).inDays;
      final exploration = (((product.id.hashCode ^ daySeed) & 1023) / 1023.0) * 0.03;

      final score =
          (trend * 0.30) +
          (categoryMatch * 0.24) +
          (productAffinity * 0.16) +
          (wishlistCategorySignal * 0.12) +
          (sizeSignal * 0.08) +
          (priceAffinitySignal * 0.08) +
          recentlyViewedBoost +
          offerBoost +
          exploration;

      scored.add(MapEntry(product, score));

      if (categoryMatch >= 0.7) {
        reasons[product.id] = 'Based on your recent browsing';
      } else if (wishlistCategorySignal > 0) {
        reasons[product.id] = 'Matches items in your wishlist';
      } else if (productAffinity >= 0.5) {
        reasons[product.id] = 'Because you viewed this type often';
      } else if (trend >= 0.6) {
        reasons[product.id] = 'Trending with other shoppers';
      } else if (offerBoost > 0) {
        reasons[product.id] = 'Recommended deal for you';
      } else {
        reasons[product.id] = 'Picked for you';
      }
    }

    scored.sort((a, b) => b.value.compareTo(a.value));

    // Re-rank for diversity so recommendations do not over-cluster in one category.
    final categoryQuota = <String, int>{};
    final diversified = <ProductModel>[];
    for (final item in scored) {
      final key = item.key.category.toLowerCase();
      final used = categoryQuota[key] ?? 0;
      if (used >= 3) continue;
      diversified.add(item.key);
      categoryQuota[key] = used + 1;
      if (diversified.length >= 12) break;
    }

    if (diversified.length < 12) {
      for (final item in scored) {
        if (diversified.contains(item.key)) continue;
        diversified.add(item.key);
        if (diversified.length >= 12) break;
      }
    }

    if (diversified.isEmpty) {
      personalizedProducts.assignAll(trendingProducts.take(12).toList());
      recommendationReasons.clear();
    } else {
      personalizedProducts.assignAll(diversified);
      recommendationReasons.assignAll(reasons);
    }
  }

  final List<ProductModel> _dummyProducts = [
    ProductModel(
      id: '1',
      name: 'Kanjivaram Silk Saree',
      category: 'Women',
      price: 4999.0,
      originalPrice: 8999.0,
      imageUrl: 'https://images.unsplash.com/photo-1618932260643-eee4a2f652a6?auto=format&fit=crop&q=80&w=1000',
      rating: 4.9,
      isTrending: true,
    ),
    // ... other dummy items can stay as fallback
  ];
}
