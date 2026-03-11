import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';
import '../controllers/admin_product_controller.dart';
import 'add_product_screen.dart';

class AdminProductManagementScreen extends StatelessWidget {
  const AdminProductManagementScreen({super.key});

  String _translate(String text) {
    if (text.isEmpty) return text;
    String cleanText = text.trim().toLowerCase();
    String translated = cleanText.tr;
    return (translated == cleanText) ? text : translated;
  }

  @override
  Widget build(BuildContext context) {
    final AdminProductController controller = Get.find<AdminProductController>();

    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Products", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24, color: Get.theme.textTheme.displayLarge?.color)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search & Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: Get.theme.cardColor, borderRadius: BorderRadius.circular(30)),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Search products...",
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Get.theme.cardColor, shape: BoxShape.circle),
                  child: Icon(Icons.tune, color: Get.theme.iconTheme.color),
                )
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("PRODUCT DETAILS", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                Text("INVENTORY & STATUS", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
              ],
            ),
          ),
          
          const SizedBox(height: 10),

          // List
          Expanded(
            child: Obx(() {
              if (controller.products.isEmpty) {
                return const Center(child: Text("No products found"));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.products.length,
                itemBuilder: (context, index) {
                  final product = controller.products[index];
                  final imageStr = product.imageUrl;
                  
                  int stock = product.stockQuantity;
                  String status = stock > 10 ? "IN STOCK" : (stock > 0 ? "LOW STOCK" : "SOLD OUT");
                  Color statusColor = stock > 10 ? Colors.green : (stock > 0 ? Colors.orange : Colors.red);
                  Color statusBg = statusColor.withOpacity(0.1);
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Get.theme.cardColor, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: (imageStr.startsWith('data:image'))
                            ? Image.memory(base64Decode(imageStr.split(',').last), width: 60, height: 60, fit: BoxFit.cover)
                            : (imageStr.isNotEmpty && imageStr.startsWith('http'))
                                ? Image.network(imageStr, width: 60, height: 60, fit: BoxFit.cover)
                                : Container(color: Get.theme.scaffoldBackgroundColor, width: 60, height: 60, child: const Icon(Icons.image, color: Colors.grey)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_translate(product.name), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Get.theme.textTheme.displayLarge?.color)),
                              Text("${_translate(product.category)} • ₹${product.price.toStringAsFixed(0)}", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildAction(Icons.edit, "EDIT", Colors.red, () {
                                    controller.setProductForEdit(product);
                                    Get.to(() => const AddProductScreen());
                                  }),
                                  const SizedBox(width: 16),
                                  _buildAction(Icons.delete_outline, "DEL", Colors.grey, () {
                                    Get.defaultDialog(
                                      title: "Delete Product",
                                      middleText: "Are you sure you want to delete this product?",
                                      onCancel: () {},
                                      onConfirm: () {
                                        controller.deleteProduct(product.id);
                                        Get.back();
                                      },
                                      confirmTextColor: Colors.white,
                                      buttonColor: Colors.red,
                                    );
                                  }),
                                ],
                              )
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Get.theme.scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.inventory_2, size: 14, color: Get.theme.textTheme.bodyLarge?.color),
                                  const SizedBox(width: 4),
                                  Text("$stock", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Get.theme.textTheme.bodyLarge?.color)),
                                  const SizedBox(width: 4),
                                  Text("units", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
                              child: Text(status, style: GoogleFonts.poppins(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                            )
                          ],
                        )
                      ],
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 80), // To avoid sheet overlapping
        ],
      ),
      bottomSheet: Container(
        margin: const EdgeInsets.all(16),
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Obx(() {
           double totalValue = 0;
           for(var p in controller.products) {
             totalValue += (p.price * p.stockQuantity);
           }
           return Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("INVENTORY VALUE", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10, letterSpacing: 1)),
                    Text("₹${totalValue.toStringAsFixed(0)}", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(width: 1, height: 30, color: Colors.white24),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("TOTAL SKUS", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10, letterSpacing: 1)),
                    Text("${controller.products.length}", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton(
          onPressed: () {
            controller.clearControllers();
            Get.to(() => const AddProductScreen());
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.poppins(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
