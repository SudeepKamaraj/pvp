import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/product_model.dart';
import '../controllers/home_controller.dart';
import '../controllers/wishlist_controller.dart';
import 'product_details_screen.dart';
import 'product_listing_screen.dart';
import 'product_listing_screen.dart';
import 'search_screen.dart';
import 'cart_screen.dart';
import 'wishlist_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    final WishlistController wishlistController = Get.put(WishlistController());

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 16,
        title: Row(
          children: [
            // Logo
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  AppAssets.logo,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_bag, color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Search Bar
            Expanded(
              child: GestureDetector(
                onTap: () => Get.to(() => const SearchScreen()),
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(21),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "search_hint".tr,
                          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
            onPressed: () => Get.to(() => const CartScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black87),
            onPressed: () => Get.to(() => const WishlistScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
            onPressed: () => Get.to(() => const NotificationsScreen()),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.trendingProducts.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              // Banner Carousel
              const HomeBannerCarousel(),
            
            const SizedBox(height: 24),
            
            // Categories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "shop_by_category".tr,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
                 if (controller.categories.isEmpty) return const SizedBox();
                 
                 // If limited categories, use spaced row
                 if (controller.categories.length <= 4) {
                   return Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 24),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: controller.categories.map((cat) {
                         final imageStr = cat['image'] as String? ?? '';
                         return _buildCategoryItem(imageStr, cat['name']);
                       }).toList(),
                     ),
                   );
                 }
                 
                 // Otherwise use scrollable list
                 return SizedBox(
                  height: 100,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final cat = controller.categories[index];
                      final imageStr = cat['image'] as String? ?? '';
                      return _buildCategoryItem(imageStr, cat['name']);
                    },
                  ),
                );
            }),
            
            const SizedBox(height: 24),

            // Personalized Recommendations (Hybrid Feed)
            Obx(() {
              if (controller.personalizedProducts.isEmpty) {
                return const SizedBox();
              }

              final recommended = controller.personalizedProducts.take(10).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Recommended for You",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 250,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: recommended.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final product = recommended[index];
                        final reason = controller.recommendationReasons[product.id] ?? 'Picked for you';
                        return _buildRecommendationCard(
                          product: product,
                          reason: reason,
                          wishlistController: wishlistController,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }),
            
            // Trending
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "trending_now".tr,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.to(() => ProductListingScreen(categoryName: "Trending")), 
                    child: Text("view_all".tr)
                  ),
                ],
              ),
            ),
            
            // Trending Grid
            Obx(() => GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: controller.trendingProducts.length,
              itemBuilder: (context, index) {
                final product = controller.trendingProducts[index];
                final imageStr = product.imageUrl;

                return GestureDetector(
                  onTap: () => Get.to(() => ProductDetailsScreen(product: product)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Get.theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Get.theme.scaffoldBackgroundColor,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            ),
                            child: Stack(
                              children: [
                                Hero(
                                  tag: product.id,
                                  child: (imageStr.startsWith('data:image'))
                                      ? ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                          child: Image.memory(base64Decode(imageStr.split(',').last), width: double.infinity, fit: BoxFit.cover),
                                        )
                                      : (imageStr.isNotEmpty && imageStr.startsWith('http'))
                                          ? ClipRRect(
                                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                              child: Image.network(imageStr, width: double.infinity, fit: BoxFit.cover),
                                            )
                                          : const Center(child: Icon(Icons.image, color: Colors.grey, size: 40)),
                                ),
                                // Wishlist Button
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Obx(() {
                                    final isWishlisted = wishlistController.isInWishlist(product);
                                    return GestureDetector(
                                      onTap: () => wishlistController.toggleWishlist(product),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                            )
                                          ]
                                        ),
                                        child: Icon(
                                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                                          color: isWishlisted ? Colors.red : Colors.grey,
                                          size: 18,
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                // Rating
                                if (product.rating > 0)
                                  Positioned(
                                    bottom: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            product.rating.toStringAsFixed(1),
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 2),
                                          const Icon(Icons.star, color: Colors.amber, size: 10),
                                          const SizedBox(width: 2),
                                          Text(
                                            "(${product.reviewCount})",
                                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.category.toUpperCase(), // Brand/Category Line
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _translate(product.name),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                                ),
                                const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        "₹${((product.offerPrice != null && product.offerPrice! > 0) ? product.offerPrice! : product.price).toStringAsFixed(0)}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      if ((product.offerPrice != null && product.offerPrice! > 0) || (product.originalPrice != null && product.originalPrice! > product.price)) ...[
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            "₹${((product.offerPrice != null && product.offerPrice! > 0) ? product.price : product.originalPrice!).toStringAsFixed(0)}",
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 11,
                                              decoration: TextDecoration.lineThrough,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            "${(((product.offerPrice != null && product.offerPrice! > 0) ? ((product.price - product.offerPrice!) / product.price * 100) : ((product.originalPrice! - product.price) / product.originalPrice! * 100))).round()}% ${'off'.tr}",
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                const SizedBox(height: 6),
                                if (product.stockQuantity < 10)
                                  Text(
                                    "only_few_left".tr,
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      "hot_deal".tr,
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )),
            const SizedBox(height: 24),
          ],
        ),
      );
      }),
    );
  }

  Widget _buildRecommendationCard({
    required ProductModel product,
    required String reason,
    required WishlistController wishlistController,
  }) {
    final imageStr = product.imageUrl;

    return GestureDetector(
      onTap: () => Get.to(() => ProductDetailsScreen(product: product)),
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Get.theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    child: (imageStr.startsWith('data:image'))
                        ? Image.memory(
                            base64Decode(imageStr.split(',').last),
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : (imageStr.isNotEmpty && imageStr.startsWith('http'))
                            ? Image.network(
                                imageStr,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: double.infinity,
                                color: Colors.grey[100],
                                child: const Icon(Icons.image, color: Colors.grey),
                              ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Obx(() {
                      final isWishlisted = wishlistController.isInWishlist(product);
                      return GestureDetector(
                        onTap: () => wishlistController.toggleWishlist(product),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isWishlisted ? Icons.favorite : Icons.favorite_border,
                            color: isWishlisted ? Colors.red : Colors.grey,
                            size: 16,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reason,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _translate(product.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "₹${((product.offerPrice != null && product.offerPrice! > 0) ? product.offerPrice! : product.price).toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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

  String _translate(String text) {
    if (text.isEmpty) return text;
    String cleanText = text.trim().toLowerCase();
    String translated = cleanText.tr;
    return (translated == cleanText) ? text : translated;
  }

  Widget _buildCategoryItem(String imageStr, String name) {
    return InkWell(
      onTap: () => Get.to(() => ProductListingScreen(categoryName: name)),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
             child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildImage(imageStr),
              ),
          ),
          const SizedBox(height: 8),
          Text(_translate(name), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildImage(String imageStr) {
    if (imageStr.startsWith('data:image')) {
      return Image.memory(
        base64Decode(imageStr.split(',').last),
        width: 90, height: 90,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.category, color: AppColors.primary)),
      );
    } else if (imageStr.startsWith('assets/')) {
      return Image.asset(
        imageStr,
        width: 90, height: 90,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.category, color: AppColors.primary)),
      );
    } else if (imageStr.startsWith('http')) {
       return Image.network(
        imageStr,
        width: 90, height: 90,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.category, color: AppColors.primary)),
      );
    }
    return const Center(child: Icon(Icons.category, size: 28, color: AppColors.primary));
  }
}

class HomeBannerCarousel extends StatefulWidget {
  const HomeBannerCarousel({super.key});

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<String> _banners = [
    AppAssets.banner1,
    AppAssets.banner2,
    AppAssets.banner3,
    AppAssets.banner4,
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < _banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180, // Increased height for better visibility
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    _banners[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.orange[50], // Fallback color
                      child: Center(
                        child: Icon(Icons.broken_image, color: Colors.orange[200], size: 40),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index ? AppColors.primary : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
