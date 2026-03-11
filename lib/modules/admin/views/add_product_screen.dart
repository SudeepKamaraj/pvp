import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';
import '../controllers/admin_product_controller.dart';

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminProductController controller = Get.find<AdminProductController>();

    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Obx(() => Text(controller.isEditing.value ? "Edit Product" : "Add Product", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Get.theme.textTheme.displayLarge?.color))),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Get.theme.iconTheme.color, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel("PRODUCT IMAGES"),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: Obx(() => ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.uploadedImages.length + 1,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                   if (index == controller.uploadedImages.length) {
                     return _buildUploadButton(() => controller.pickImages(), "IMAGE");
                   }
                   return _buildImagePreview(controller.uploadedImages[index], () => controller.removeImage(index));
                },
              )),
            ),
            
            const SizedBox(height: 30),
            
            _buildSectionLabel("PRODUCT VIDEOS"),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: Obx(() => ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.uploadedVideos.length + 1,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                   if (index == controller.uploadedVideos.length) {
                     return _buildUploadButton(() => controller.pickVideos(), "VIDEO");
                   }
                   return _buildVideoPreview(controller.uploadedVideos[index], () => controller.removeVideo(index));
                },
              )),
            ),
            
            const SizedBox(height: 30),
            
            _buildSectionLabel("PRODUCT DETAILS"),
            const SizedBox(height: 16),
            
            _buildTextField("Product Name", "e.g. Summer Linen Blazer", controller.nameController),
            const SizedBox(height: 16),
            _buildDropdown("Category", controller),
            
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField("Selling Price (₹)", "1290", controller.priceController, isNumber: true)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField("Offer Price (₹)", "Optional", controller.offerPriceController, isNumber: true)),
              ],
            ),
            
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text("Buying Price (₹)", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF6B7280))),
                          const SizedBox(width: 4),
                          Icon(Icons.info_outline, size: 14, color: AppColors.primary),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text("Required for profit calculation", style: GoogleFonts.poppins(fontSize: 9, color: AppColors.primary, fontStyle: FontStyle.italic)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withOpacity(0.3))),
                        child: TextField(
                          controller: controller.buyingPriceController,
                          style: TextStyle(color: Get.theme.textTheme.bodyLarge?.color),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Cost price",
                            hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField("Stock Quantity", "45", controller.stockController, isNumber: true)),
              ],
            ),
            
            const SizedBox(height: 30),
            _buildSectionLabel("AVAILABLE SIZES"),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                   _buildSizeChip("XS", controller),
                   const SizedBox(width: 8),
                   _buildSizeChip("S", controller),
                   const SizedBox(width: 8),
                   _buildSizeChip("M", controller),
                   const SizedBox(width: 8),
                   _buildSizeChip("L", controller),
                   const SizedBox(width: 8),
                   _buildSizeChip("XL", controller),
                ],
              ),
            ),

            const SizedBox(height: 30),
            _buildSectionLabel("COLORS"),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildColorChip(Colors.black, "Black", controller),
                  const SizedBox(width: 12),
                  _buildColorChip(Colors.orange[100]!, "Beige", controller),
                  const SizedBox(width: 12),
                  _buildColorChip(Colors.blue[900]!, "Navy", controller),
                  const SizedBox(width: 12),
                  _buildColorChip(Colors.red, "Red", controller),
                  const SizedBox(width: 12),
                  _buildColorChip(Colors.white, "White", controller),
                ],
              ),
            ),

            const SizedBox(height: 30),
            _buildSectionLabel("Description"),
            const SizedBox(height: 12),
            Container(
              height: 120,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Get.theme.cardColor, borderRadius: BorderRadius.circular(16)),
              child: const TextField(
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "Tell a story about this product...",
                  border: InputBorder.none,
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Obx(() => ElevatedButton.icon(
                onPressed: controller.isLoading.value ? null : () => controller.saveProduct(),
                icon: controller.isLoading.value 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : const Icon(Icons.save, color: Colors.white),
                label: Text(controller.isEditing.value ? "Update Product" : "Save Product", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  shadowColor: AppColors.primary.withOpacity(0.4),
                  elevation: 8,
                ),
              )),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Get.back(), 
                child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.bold))
              )
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(text, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey));
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF6B7280))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: TextField(
            controller: controller,
            style: TextStyle(color: Get.theme.textTheme.bodyLarge?.color),
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, AdminProductController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF6B7280))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Obx(() {
            final List<String> categories = ["Men", "Women", "Kids", "Electronics", "Accessories", "Outerwear", "Footwear"];
            if (controller.selectedCategory.value.isNotEmpty && !categories.contains(controller.selectedCategory.value)) {
              categories.add(controller.selectedCategory.value);
            }
            return DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedCategory.value.isNotEmpty ? controller.selectedCategory.value : null,
                isExpanded: true,
                items: categories
                    .map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.poppins(color: Get.theme.textTheme.bodyLarge?.color)))).toList(),
                onChanged: (val) {
                  if(val != null) controller.selectedCategory.value = val;
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSizeChip(String label, AdminProductController controller) {
    return Obx(() {
      final isSelected = controller.selectedSizes.contains(label);
      return GestureDetector(
        onTap: () => controller.toggleSize(label),
        child: Container(
          width: 50, height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Get.theme.cardColor,
            shape: BoxShape.circle,
            border: isSelected ? null : Border.all(color: Colors.grey[200]!),
          ),
          child: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Get.theme.textTheme.bodyLarge?.color)),
        ),
      );
    });
  }

  Widget _buildColorChip(Color color, String label, AdminProductController controller) {
    return Obx(() {
      final isSelected = controller.selectedColors.contains(label);
      return GestureDetector(
        onTap: () => controller.toggleColor(label),
        child: Container(
          padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
          decoration: BoxDecoration(
            color: Get.theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: isSelected ? Border.all(color: AppColors.primary, width: 2) : Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: label == "White" ? Border.all(color: Colors.grey[300]!) : null,
                ),
              ),
              const SizedBox(width: 8),
              Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Get.theme.textTheme.bodyLarge?.color)),
              if (isSelected) ...[
                const SizedBox(width: 4),
                Icon(Icons.check_circle, color: AppColors.primary, size: 16),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAddColorButton() {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.add, color: Colors.grey, size: 20),
    );
  }

  Widget _buildImagePreview(String imagePath, VoidCallback onRemove) {
    ImageProvider imageProvider;
    if (imagePath.startsWith('data:image')) {
      imageProvider = MemoryImage(base64Decode(imagePath.split(',').last));
    } else if (imagePath.startsWith('http')) {
      imageProvider = NetworkImage(imagePath);
    } else {
      imageProvider = const AssetImage(AppColors.placeholderImage);
    }

    return Stack(
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover
            ),
          ),
        ),
        Positioned(
          top: 0, right: 0,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 12),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildUploadButton(VoidCallback onTap, String label) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          color: Get.theme.cardColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[200]!, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle),
              child: Icon(label == "VIDEO" ? Icons.videocam : Icons.add, color: AppColors.primary, size: 20),
            ),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.poppins(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPreview(String videoPath, VoidCallback onRemove) {
    return Stack(
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.play_circle_outline, color: Colors.white, size: 40),
        ),
        Positioned(
          top: 0, right: 0,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 80, height: 80,
      decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
    );
  }
}
