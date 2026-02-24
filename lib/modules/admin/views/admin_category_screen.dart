import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';
import '../controllers/admin_category_controller.dart';

class AdminCategoryScreen extends StatelessWidget {
  const AdminCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminCategoryController controller = Get.put(AdminCategoryController());

    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Manage Categories", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Get.theme.textTheme.displayLarge?.color)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Get.theme.iconTheme.color, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Text(controller.isEditing.value ? "EDIT CATEGORY" : "CREATE NEW", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5))),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Get.theme.cardColor, borderRadius: BorderRadius.circular(30)),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => controller.pickImage(),
                    child: Obx(() => Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        color: Get.theme.scaffoldBackgroundColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.withOpacity(0.2), style: BorderStyle.solid, width: 2),
                        image: controller.uploadedImageBase64.isNotEmpty
                          ? DecorationImage(
                              image: MemoryImage(base64Decode(controller.uploadedImageBase64.value.split(',').last)),
                              fit: BoxFit.cover,
                            )
                          : null,
                      ),
                      child: controller.uploadedImageBase64.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.camera_alt, color: Colors.grey),
                              Text("UPLOAD", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey))
                            ],
                          )
                        : null,
                    )),
                  ),
                  const SizedBox(height: 24),
                  
                  TextField(
                    controller: controller.nameController,
                    style: TextStyle(color: Get.theme.textTheme.bodyLarge?.color),
                    decoration: InputDecoration(
                      hintText: "Category Name (e.g. Winter Wear)",
                      filled: true,
                      fillColor: Get.theme.scaffoldBackgroundColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      if (controller.isEditing.value) 
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: OutlinedButton(
                              onPressed: () => controller.clearFields(),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                side: const BorderSide(color: Colors.grey),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 50,
                          child: Obx(() => ElevatedButton.icon(
                            onPressed: controller.isLoading.value ? null : () => controller.saveCategory(),
                            icon: Icon(controller.isEditing.value ? Icons.update : Icons.add_circle_outline, color: Colors.white),
                            label: Text(controller.isEditing.value ? "Update" : "Add Category", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                              elevation: 5,
                              shadowColor: AppColors.primary.withOpacity(0.4),
                            ),
                          )),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Get.theme.cardColor, borderRadius: BorderRadius.circular(30)),
              child: TextField(
                style: TextStyle(color: Get.theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: "Search categories...",
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text("EXISTING CATEGORIES (${controller.categories.length})", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5))),
                Text("View All", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
            const SizedBox(height: 16),
            
            Obx(() => Column(
              children: controller.categories.map((cat) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Get.theme.cardColor, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: Get.theme.scaffoldBackgroundColor,
                        shape: BoxShape.circle,
                        image: (cat['image'] != null && cat['image'].toString().isNotEmpty)
                           ? DecorationImage(
                               image: MemoryImage(base64Decode(cat['image'].toString().split(',').last)),
                               fit: BoxFit.cover
                             )
                           : null
                      ),
                      child: (cat['image'] == null || cat['image'].toString().isEmpty)
                          ? const Icon(Icons.category, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cat['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Get.theme.textTheme.displayLarge?.color)),
                          Text("${cat['itemCount'] ?? 0} Items", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey, size: 20), 
                      onPressed: () => controller.setCategoryForEdit(cat)
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20), 
                      onPressed: () {
                         Get.defaultDialog(
                           title: "Delete Category",
                           middleText: "Are you sure? This action cannot be undone.",
                           onCancel: () {},
                           onConfirm: () {
                             controller.deleteCategory(cat['id']);
                             Get.back();
                           },
                           confirmTextColor: Colors.white,
                           buttonColor: Colors.red,
                         );
                      }
                    ),
                  ],
                ),
              )).toList(),
            )),
          ],
        ),
      ),
    );
  }
}
