import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';
import '../controllers/admin_order_controller.dart';
import '../../../../data/models/order_model.dart';

class AdminOrderManagementScreen extends StatelessWidget {
  const AdminOrderManagementScreen({super.key});

  String _translate(String text) {
    if (text.isEmpty) return text;
    String cleanText = text.trim().toLowerCase();
    String translated = cleanText.tr;
    return (translated == cleanText) ? text : translated;
  }

  @override
  Widget build(BuildContext context) {
    final AdminOrderController controller = Get.find<AdminOrderController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Orders"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => controller.downloadOrdersPdf(),
            tooltip: "Download Report",
          )
        ],
      ),
      body: Obx(() {
        if (controller.orders.isEmpty) {
          return const Center(child: Text("No orders found"));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.orders.length,
          itemBuilder: (context, index) {
            final order = controller.orders[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            order.id,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd MMM yyyy').format(order.date),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const Divider(),
                    ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              "${item.quantity}x ${_translate(item.product.name)}",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text("Size: ${item.selectedSize}"),
                        ],
                      ),
                    )),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          "₹${order.totalAmount.toStringAsFixed(0)}",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            "Status: ${order.status}",
                            style: TextStyle(
                              color: _getStatusColor(order.status),
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          onSelected: (value) => controller.updateOrderStatus(order, value),
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: "Processing", child: Text("Processing")),
                            const PopupMenuItem(value: "Shipped", child: Text("Shipped")),
                            const PopupMenuItem(value: "Delivered", child: Text("Delivered")),
                            const PopupMenuItem(value: "Cancelled", child: Text("Cancelled")),
                          ],
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Get.theme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Update Status",
                              style: TextStyle(color: Get.theme.textTheme.bodyLarge?.color),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (order.status.toLowerCase() == 'cancelled')
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                             Get.defaultDialog(
                              title: "Delete Order",
                              middleText: "Are you sure you want to delete this order permanently?",
                              textConfirm: "Delete",
                              textCancel: "Cancel",
                              confirmTextColor: Colors.white,
                              buttonColor: Colors.red,
                              onConfirm: () {
                                if (Get.isDialogOpen ?? false) {
                                  Get.back();
                                }
                                controller.deleteOrder(order.id);
                              }
                            );
                          },
                          icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                          label: const Text("Delete Order", style: TextStyle(color: Colors.red)),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Processing': return Colors.orange;
      case 'Shipped': return Colors.blue;
      case 'Delivered': return Colors.green;
      case 'Cancelled': return Colors.red;
      default: return Get.theme.textTheme.bodyLarge?.color ?? Colors.black;
    }
  }
}
