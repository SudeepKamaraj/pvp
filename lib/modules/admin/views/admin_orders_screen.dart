import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';
import 'package:pvp_traders/data/models/order_model.dart';
import '../controllers/admin_order_controller.dart';
import 'admin_order_details_screen.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is loaded
    final AdminOrderController controller = Get.put(AdminOrderController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          title: Text("Orders", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.search, color: Colors.black),
            )
          ],
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black,
            indicatorSize: TabBarIndicatorSize.label,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.red, // Design uses red theme
            ),
            tabs: const [
              Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("New 12"))),
              Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Packed 8"))), // Mock counts
              Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Shipped"))),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrderList(controller, "Processing"), // "New" maps to Processing in DB usually
            _buildOrderList(controller, "Packed"),
            _buildOrderList(controller, "Shipped"),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(AdminOrderController controller, String statusFilter) {
    return Obx(() {
      // Filter logic (Enhanced to support multiple status mappings if needed)
      final filteredOrders = controller.orders.where((o) {
        if (statusFilter == "Processing") return o.status == "Processing" || o.status == "New" || o.status == "Pending";
        return o.status == statusFilter;
      }).toList();

      if (filteredOrders.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox, size: 60, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text("No orders found", style: GoogleFonts.poppins(color: Colors.grey)),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          return _buildOrderCard(order);
        },
      );
    });
  }

  Widget _buildOrderCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  "TODAY, ${DateFormat('hh:mm a').format(order.date)}", 
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                child: Text("PREPAID", style: GoogleFonts.poppins(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "#${order.id.substring(0, 8).toUpperCase()}",
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150'), // Placeholder
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Customer Name",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${order.items.length} Items • ₹${order.totalAmount.toStringAsFixed(0)}",
                      style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          "Status: ${order.status}",
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.to(() => AdminOrderDetailsScreen(order: order)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    "PROCESS NOW",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
