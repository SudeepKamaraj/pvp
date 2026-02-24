import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/services/database_service.dart';
import '../controllers/wishlist_controller.dart';
import 'product_details_screen.dart';
import 'cart_screen.dart';

class ProductListingScreen extends StatefulWidget {
  final String categoryName;
  const ProductListingScreen({super.key, required this.categoryName});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  String _sortBy = 'Rating'; // Rating, Price Low, Price High

  final List<String> _categories = ['All', 'Men', 'Women', 'Kids'];
  final List<String> _sortOptions = ['Rating', 'Price: Low to High', 'Price: High to Low'];

  @override
  void initState() {
    super.initState();
    // Set the selected category to match the incoming category
    _selectedCategory = widget.categoryName;
    _fetchProducts();
  }

  void _fetchProducts({String? category}) async {
    setState(() => _isLoading = true);
    try {
      List<ProductModel> fetched;
      
      final categoryToFetch = category ?? widget.categoryName;
      
      // If category is "Trending" or "All", get all products
      if (categoryToFetch.toLowerCase() == 'trending' || categoryToFetch.toLowerCase() == 'all') {
        fetched = await _databaseService.getProducts();
      } else {
        // Fetch only products from the specific category
        fetched = await _databaseService.getProductsByCategory(categoryToFetch);
      }
      
      setState(() {
        _allProducts = fetched;
      });
      _applyFilters();
    } catch (e) {
      Get.snackbar("Error", "Failed to load products");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    List<ProductModel> filtered = List.from(_allProducts);

    // Apply category filter when "All" or "Trending" is selected
    // For specific category pages, products may be pre-filtered or filter dynamically
    if (_selectedCategory.toLowerCase() == 'all' || _selectedCategory.toLowerCase() == 'trending') {
      // Show all products, no filtering by category
    } else {
      // Filter by selected category if it's different from what was initially loaded
      filtered = filtered.where((p) => 
        p.category.toLowerCase() == _selectedCategory.toLowerCase()
      ).toList();
    }

    // Apply sorting
    if (_sortBy == 'Rating') {
      filtered.sort((a, b) {
        final ratingCompare = b.rating.compareTo(a.rating);
        if (ratingCompare != 0) return ratingCompare;
        return b.reviewCount.compareTo(a.reviewCount);
      });
    } else if (_sortBy == 'Price: Low to High') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'Price: High to Low') {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    }

    setState(() {
      _filteredProducts = filtered;
    });
  }

  String _translate(String text) {
    if (text.isEmpty) return text;
    String cleanText = text.trim().toLowerCase();
    String translated = cleanText.tr;
    return (translated == cleanText) ? text : translated;
  }

  @override
  Widget build(BuildContext context) {
    final wishlistController = Get.put(WishlistController());
    
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text(
          _translate(widget.categoryName),
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
            onPressed: () => Get.to(() => const CartScreen()),
          ),
          // Sort Button
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.black),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
              _applyFilters();
            },
            itemBuilder: (context) => _sortOptions.map((option) {
              return PopupMenuItem(
                value: option,
                child: Row(
                  children: [
                    Icon(
                      _sortBy == option ? Icons.check : Icons.sort,
                      size: 18,
                      color: _sortBy == option ? AppColors.primary : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(option, style: GoogleFonts.poppins(fontSize: 13)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Chips
          Container(
            height: 60,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // When viewing "All", show it as selected
                if (_selectedCategory.toLowerCase() == 'all' || _selectedCategory.toLowerCase() == 'trending') ...[
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        'All',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      selected: true,
                      onSelected: null,
                      backgroundColor: Colors.grey[100],
                      selectedColor: AppColors.primary,
                      checkmarkColor: Colors.white,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ] else ...[
                  // Show "All" button when on a specific category page
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        'All',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      selected: false,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = 'All';
                        });
                        _fetchProducts(category: 'All');
                      },
                      backgroundColor: Colors.grey[100],
                      selectedColor: AppColors.primary,
                      checkmarkColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  // Show the current category chip as selected
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        _selectedCategory,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      selected: true,
                      onSelected: null,
                      backgroundColor: Colors.grey[100],
                      selectedColor: AppColors.primary,
                      checkmarkColor: Colors.white,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Products Grid
          Expanded(
            child: Builder(
              builder: (context) {
                if (_isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

                if (_filteredProducts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        "No products found",
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

                return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = _filteredProducts[index];
                  final imageStr = product.imageUrl;

                  return GestureDetector(
                    onTap: () => Get.to(() => ProductDetailsScreen(product: product)),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image with Wishlist & Rating
                          Expanded(
                            flex: 3,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
                                              color: Colors.grey[100],
                                              width: double.infinity,
                                              child: const Icon(Icons.image, color: Colors.grey),
                                            ),
                                  ),
                                  // Wishlist Button
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Obx(() {
                                      final isFavorite = wishlistController.isInWishlist(product);
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
                                            ],
                                          ),
                                          child: Icon(
                                            isFavorite ? Icons.favorite : Icons.favorite_border,
                                            size: 18,
                                            color: isFavorite ? Colors.red : Colors.grey,
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
                          // Product Details
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.category.toUpperCase(),
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
              );
              },
            ),
          ),
        ],
      ),
    );
  }
}
