import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';
import '../controllers/admin_analytics_controller.dart';
import 'admin_notifications_screen.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminAnalyticsController controller = Get.put(AdminAnalyticsController());

    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ADMIN CONSOLE", style: GoogleFonts.poppins(fontSize: 10, color: Colors.pink, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            Text("Sales Analytics", style: GoogleFonts.poppins(color: Get.theme.textTheme.displayLarge?.color, fontWeight: FontWeight.bold, fontSize: 22)),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.confirmation_number_outlined, color: Colors.red),
            onPressed: () => Get.toNamed('/admin-offers'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined, color: Colors.red),
            onPressed: () => Get.to(() => const AdminNotificationsScreen()),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.totalRevenue.value == 0) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time Filter
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(25)),
                child: Row(
                  children: [
                     _buildTimeTab("Daily", true),
                     _buildTimeTab("Weekly", false),
                     _buildTimeTab("Monthly", false),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Main Revenue Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Get.theme.cardColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Revenue", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.currency_rupee, color: Colors.red, size: 20),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "₹${controller.totalRevenue.value.toStringAsFixed(0)}",
                      style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Get.theme.textTheme.displayLarge?.color),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          controller.revenueGrowth.value >= 0 ? Icons.trending_up : Icons.trending_down, 
                          color: controller.revenueGrowth.value >= 0 ? Colors.green : Colors.red, 
                          size: 16
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${controller.revenueGrowth.value.abs().toStringAsFixed(1)}% vs yesterday", 
                          style: GoogleFonts.poppins(
                            color: controller.revenueGrowth.value >= 0 ? Colors.green : Colors.red, 
                            fontWeight: FontWeight.bold, fontSize: 12
                          )
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Chart Placeholder
                    SizedBox(
                      height: 150,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildBar(0.4), _buildBar(0.6), _buildBar(0.5), _buildBar(0.3),
                          _buildBar(0.7, isSelected: true), _buildBar(0.5), _buildBar(0.8), _buildBar(0.6),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Secondary Stats
              Row(
                children: [
                  Expanded(child: _buildStatCard("Conversion Rate", "${controller.conversionRate.value}%", "+0.5%", true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard("Repeat Customers", "${controller.repeatCustomers.value}%", "+1.2%", true)),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Top Selling Products
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Top-selling products", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Get.theme.textTheme.displayLarge?.color)),
                  Text("VIEW ALL", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red)),
                ],
              ),
              const SizedBox(height: 16),
              
              if (controller.topSellingProducts.isEmpty)
                 Center(child: Text("No sales data yet", style: GoogleFonts.poppins(color: Colors.grey)))
              else
                ...controller.topSellingProducts.map((product) => _buildProductItem(
                  product['name'], 
                  "Collection", 
                  "${product['sold']} Sold", 
                  (product['revenue'] as num).toDouble()
                )).toList(),
              
              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTimeTab(String text, bool isSelected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildBar(double heightFactor, {bool isSelected = false}) {
    return FractionallySizedBox(
      heightFactor: heightFactor,
      child: Container(
        width: 8,
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.pink[100],
          borderRadius: BorderRadius.circular(4),
          boxShadow: isSelected ? [BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))] : [],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String trend, bool isPositive) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Get.theme.cardColor, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Get.theme.textTheme.displayLarge?.color)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1), 
              borderRadius: BorderRadius.circular(8)
            ),
            child: Text(
              trend, 
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, 
                color: isPositive ? Colors.green : Colors.red, fontSize: 10
              )
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProductItem(String name, String category, String sold, double revenue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Get.theme.cardColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.inventory_2, color: Colors.red, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Get.theme.textTheme.displayLarge?.color)),
                Text(category, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
              ],
            )
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(sold, style: GoogleFonts.poppins(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 4),
              Text("₹${revenue.toStringAsFixed(0)}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Get.theme.textTheme.displayLarge?.color)),
            ],
          )
        ],
      ),
    );
  }
}
