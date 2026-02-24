import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/home_controller.dart'; 
import 'product_listing_screen.dart';
import 'cart_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  String _translate(String text) {
    if (text.isEmpty) return text;
    String cleanText = text.trim().toLowerCase();
    String translated = cleanText.tr;
    return (translated == cleanText) ? text : translated;
  }

  Widget _buildImage(String imageStr) {
    if (imageStr.startsWith('data:image')) {
      return Image.memory(
        base64Decode(imageStr.split(',').last),
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.category, size: 40, color: AppColors.primary)),
      );
    } else if (imageStr.startsWith('assets/')) {
      return Image.asset(
        imageStr,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.category, size: 40, color: AppColors.primary)),
      );
    } else if (imageStr.startsWith('http')) {
       return Image.network(
        imageStr,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.category, size: 40, color: AppColors.primary)),
      );
    }
    return const Center(child: Icon(Icons.category, size: 40, color: AppColors.primary));
  }

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>(); 

    return Scaffold(
      appBar: AppBar(
        title: Text("categories_title".tr),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
            onPressed: () => Get.to(() => const CartScreen()),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.categories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.categories.isEmpty) {
          return const Center(child: Text("No categories found"));
        }

        // Custom Sorting: Kids, Women, Men, then others
        final List<Map<String, dynamic>> sortedCategories = List.from(controller.categories);
        sortedCategories.sort((a, b) {
          final order = {'Kids': 0, 'Women': 1, 'Men': 2};
          int orderA = order[a['name']] ?? 99;
          int orderB = order[b['name']] ?? 99;
          return orderA.compareTo(orderB);
        });

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: sortedCategories.length,
          separatorBuilder: (context, index) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            final cat = sortedCategories[index];
            final imageStr = cat['image'] as String? ?? '';
            
            return InkWell(
              onTap: () {
                Get.to(() => ProductListingScreen(categoryName: cat['name']));
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 200, // Fixed height for full-width cards
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: _buildImage(imageStr),
                    ),
                    // Gradient Overlay for text readability
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                    ),
                    // Category Name
                    Positioned(
                      bottom: 20,
                      left: 0, 
                      right: 0,
                      child: Text(
                        _translate(cat['name']),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins', 
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
