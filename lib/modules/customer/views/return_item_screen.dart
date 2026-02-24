import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/cart_item_model.dart';

class ReturnItemController extends GetxController {
  var selectedReason = "".obs;
  var additionalDetails = "".obs;
  
  final reasons = [
    "Size issue (Too small/large)",
    "Damaged or defective product",
    "Received wrong item",
    "Quality not as expected",
    "Other reasons"
  ];

  void submitReturn() {
    if (selectedReason.isEmpty) {
      Get.snackbar("Error", "Please select a reason");
      return;
    }
    Get.back();
    Get.snackbar("Success", "Return Request Submitted");
  }
}

class ReturnItemScreen extends StatelessWidget {
  final CartItemModel item;
  final String orderId;

  const ReturnItemScreen({super.key, required this.item, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReturnItemController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Return Item", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: (item.product.imageUrl.startsWith('data:image'))
                      ? Image.memory(base64Decode(item.product.imageUrl.split(',').last), width: 80, height: 80, fit: BoxFit.cover)
                      : (item.product.imageUrl.isNotEmpty && item.product.imageUrl.startsWith('http'))
                          ? Image.network(item.product.imageUrl, width: 80, height: 80, fit: BoxFit.cover)
                          : Container(width: 80, height: 80, color: Colors.grey[100], child: const Icon(Icons.image, color: Colors.grey)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("ORDER #${orderId.substring(0,8).toUpperCase()}", style: GoogleFonts.poppins(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(item.product.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text("Size: ${item.selectedSize}", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 8),
                        Text("₹${item.product.price.toStringAsFixed(0)}", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            Text("Select Reason", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            
            Obx(() => Column(
              children: controller.reasons.map((reason) => _buildReasonOption(reason, controller)).toList(),
            )),

            const SizedBox(height: 30),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Attach Evidence", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("0/2 Photos", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
              ],
            ),
            Text("Recommended for damaged/wrong items", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildUploadButton(Icons.camera_alt, "CAMERA"),
                const SizedBox(width: 16),
                _buildUploadButton(Icons.image, "GALLERY"),
              ],
            ),

            const SizedBox(height: 30),
            Text("Additional Details", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                onChanged: (val) => controller.additionalDetails.value = val,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Tell us more about the issue you encountered...",
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text("0 / 200", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 10)),
              ),
            ),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: controller.submitReturn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 5,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Submit Refund Request", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
             const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonOption(String reason, ReturnItemController controller) {
    bool isSelected = controller.selectedReason.value == reason;
    return GestureDetector(
      onTap: () => controller.selectedReason.value = reason,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red[50] : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isSelected ? Colors.red[100]! : Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(
              _getReasonIcon(reason), 
              color: isSelected ? AppColors.primary : Colors.grey[400],
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                reason,
                style: GoogleFonts.poppins(
                  color: isSelected ? AppColors.primary : Colors.black,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? AppColors.primary : Colors.grey[300]!, width: 2),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected ? const Center(child: Icon(Icons.circle, size: 8, color: Colors.white)) : null,
            )
          ],
        ),
      ),
    );
  }

  IconData _getReasonIcon(String reason) {
    if (reason.contains("Size")) return Icons.straighten;
    if (reason.contains("Damaged")) return Icons.error_outline;
    if (reason.contains("wrong")) return Icons.local_shipping; // Use a different icon map if needed
    if (reason.contains("Quality")) return Icons.thumb_down_alt_outlined;
    return Icons.help_outline;
  }

  Widget _buildUploadButton(IconData icon, String label) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid), // Dashed border replacement
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
