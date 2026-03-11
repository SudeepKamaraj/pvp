import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';
import '../../../../data/models/order_model.dart';
import '../controllers/customer_order_controller.dart';
import 'cart_screen.dart';
import 'order_details_screen.dart';
import 'product_details_screen.dart';
import '../../../../data/services/database_service.dart';
import '../../../../data/models/product_model.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CustomerOrderController controller = Get.put(CustomerOrderController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text("my_orders".tr, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
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
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.myOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text("no_orders".tr, style: GoogleFonts.poppins(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.myOrders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final order = controller.myOrders[index];
            return _buildOrderCard(order);
          },
        );
      }),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    Color statusColor;
    Color statusBgColor;

    switch (order.status.toLowerCase()) {
      case 'delivered':
        statusColor = Colors.green;
        statusBgColor = Colors.green[50]!;
        break;
      case 'shipped':
        statusColor = Colors.blue;
        statusBgColor = Colors.blue[50]!;
        break;
      case 'processing':
        statusColor = Colors.orange;
        statusBgColor = Colors.orange[50]!;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusBgColor = Colors.red[50]!;
        break;
      default:
        statusColor = Colors.grey;
        statusBgColor = Colors.grey[100]!;
    }

    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final imageStr = firstItem?.product.imageUrl ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () async {
                    if (firstItem != null) {
                      // Fetch full product data
                      final fullProduct = await DatabaseService().getProductById(firstItem.product.id);
                      if (fullProduct != null) {
                        Get.to(() => ProductDetailsScreen(product: fullProduct));
                      } else {
                        Get.to(() => ProductDetailsScreen(product: firstItem.product));
                      }
                    }
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: (imageStr.startsWith('data:image'))
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(base64Decode(imageStr.split(',').last), fit: BoxFit.cover),
                          )
                        : (imageStr.isNotEmpty && imageStr.startsWith('http'))
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(imageStr, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.shopping_bag, color: Colors.grey);
                                }),
                              )
                            : FutureBuilder<ProductModel?>(
                                future: firstItem != null ? DatabaseService().getProductById(firstItem.product.id) : null,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData && snapshot.data != null && snapshot.data!.imageUrl.isNotEmpty) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        snapshot.data!.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.shopping_bag, color: Colors.grey);
                                        },
                                      ),
                                    );
                                  }
                                  return const Icon(Icons.shopping_bag, color: Colors.grey);
                                },
                              ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                order.status.toLowerCase().tr.toUpperCase(),
                                style: GoogleFonts.poppins(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "₹${order.totalAmount.toStringAsFixed(0)}",
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (firstItem != null && firstItem.product.name.toLowerCase().tr.isNotEmpty && firstItem.product.name.toLowerCase().tr != firstItem.product.name.toLowerCase())
                            ? firstItem.product.name.toLowerCase().tr
                            : firstItem?.product.name ?? "order_id".trParams({'id': order.id.substring(0, 8).toUpperCase()}),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        "qty_items".trParams({'count': order.items.length.toString()}),
                        style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.to(() => OrderDetailsScreen(order: order)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[200]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text("details".tr, style: GoogleFonts.poppins(color: Colors.black, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 12),
                if (order.status.toLowerCase() == 'cancelled')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Confirm deletion dialog
                        Get.defaultDialog(
                          title: "Delete Order",
                          middleText: "Are you sure you want to remove this order from your history?",
                          textConfirm: "Delete",
                          textCancel: "Cancel",
                          confirmTextColor: Colors.white,
                          buttonColor: Colors.red,
                          onConfirm: () {
                            if (Get.isDialogOpen ?? false) {
                              Get.back();
                            }
                            Get.find<CustomerOrderController>().deleteOrder(order.id);
                          }
                        );
                      },
                      icon: const Icon(Icons.delete_outline, size: 16, color: Colors.white),
                      label: Text("Delete", style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.to(() => OrderDetailsScreen(order: order)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: Text(
                        "track_order".tr,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
