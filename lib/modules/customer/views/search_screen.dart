import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/services/database_service.dart';
import '../controllers/home_controller.dart';
import 'cart_screen.dart';
import 'product_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  
  List<ProductModel> _allProducts = [];
  List<ProductModel> _searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadAllProducts();
  }

  void _loadAllProducts() async {
    try {
      final products = await _databaseService.getProducts();
      setState(() {
        _allProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = _allProducts
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()) || 
                         p.category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "search_collections".tr,
            border: InputBorder.none,
            hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
          ),
          onChanged: _onSearchChanged,
          style: GoogleFonts.poppins(color: Colors.black, fontSize: 14),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
            onPressed: () => Get.to(() => const CartScreen()),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.black, size: 20),
              onPressed: () {
                _searchController.clear();
                _onSearchChanged('');
              },
            ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _isSearching
          ? _searchResults.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text("no_matches".tr, style: GoogleFonts.poppins(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _searchResults.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final product = _searchResults[index];
                    final imageStr = product.imageUrl;

                    return Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: (imageStr.startsWith('data:image'))
                            ? Image.memory(base64Decode(imageStr.split(',').last), width: 50, height: 50, fit: BoxFit.cover)
                            : (imageStr.isNotEmpty && imageStr.startsWith('http'))
                                ? Image.network(imageStr, width: 50, height: 50, fit: BoxFit.cover)
                                : Container(width: 50, height: 50, color: Colors.grey[100], child: const Icon(Icons.image, color: Colors.grey)),
                        ),
                        title: Text(
                          product.name.toLowerCase().tr.isNotEmpty && product.name.toLowerCase().tr != product.name.toLowerCase() 
                            ? product.name.toLowerCase().tr 
                            : product.name, 
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "₹${product.price.toStringAsFixed(0)}",
                                  style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.bold),
                                ),
                                if (product.originalPrice != null && product.originalPrice! > product.price) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    "₹${product.originalPrice!.toStringAsFixed(0)}",
                                    style: GoogleFonts.poppins(color: Colors.grey, fontSize: 10, decoration: TextDecoration.lineThrough),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${((product.originalPrice! - product.price) / product.originalPrice! * 100).round()}% off",
                                    style: GoogleFonts.poppins(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ],
                            ),
                            if (product.rating > 0)
                              Row(
                                children: [
                                  Text(
                                    product.rating.toStringAsFixed(1),
                                    style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                  const Icon(Icons.star, color: Colors.amber, size: 10),
                                  Text(
                                    " (${product.reviewCount})",
                                    style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                        onTap: () => Get.to(() => ProductDetailsScreen(product: product)),
                      ),
                    );
                  },
                )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("trending_searches".tr, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      "Sarees", "Formal Shirts", "Summer Wear", "Jackets", "Denim", "Footwear"
                    ].map((term) => ActionChip(
                      label: Text(
                        term.toLowerCase().tr.isNotEmpty && term.toLowerCase().tr != term.toLowerCase() ? term.toLowerCase().tr : term,
                        style: GoogleFonts.poppins(fontSize: 12)
                      ),
                      backgroundColor: Colors.white,
                      elevation: 0,
                      side: BorderSide(color: Colors.grey[200]!),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      onPressed: () {
                        _searchController.text = term;
                        _onSearchChanged(term);
                      },
                    )).toList(),
                  ),
                ],
              ),
            ),
    );
  }
}
