import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';
import 'package:pvp_traders/modules/admin/views/admin_product_management_screen.dart';
import 'package:pvp_traders/modules/admin/views/admin_order_management_screen.dart';
import 'package:pvp_traders/modules/admin/views/admin_settings_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/admin_dashboard_controller.dart';
import 'add_product_screen.dart';
import 'admin_support_messages_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDashboardController>();

    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Get.theme.iconTheme.color),
          onPressed: () {}, // Drawer or Menu
        ),
        title: Text("Dashboard", style: GoogleFonts.poppins(color: Get.theme.textTheme.displayLarge?.color, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          Padding(
             padding: const EdgeInsets.only(right: 16.0),
             child: Stack(
               alignment: Alignment.bottomRight,
               children: [
                 const CircleAvatar(
                   backgroundColor: Colors.orange,
                   child: Icon(Icons.person, color: Colors.white),
                 ),
                 Container(
                   width: 12, height: 12,
                   decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                 )
               ],
             ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome back,", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
            Obx(() => Row(
              children: [
                Text(controller.adminName.value, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Get.theme.textTheme.displayLarge?.color)),
                const SizedBox(width: 8),
                const Text("👋", style: TextStyle(fontSize: 24)),
              ],
            )),
            const SizedBox(height: 24),

            // Stats Grid
            Obx(() => GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0, // Reduced from 1.1 to 1.0 to provide more height and prevent overflow
              children: [
                _buildStatCard(
                  title: "TOTAL ORDERS", 
                  value: controller.totalOrders.value, 
                  trend: "+12%", 
                  icon: Icons.shopping_bag, 
                  iconColor: Colors.red,
                  trendUp: true
                ),
                _buildStatCard(
                  title: "REVENUE", 
                  value: controller.totalRevenue.value, 
                  trend: "+8.4%", 
                  icon: Icons.currency_rupee, 
                  iconColor: Colors.red, // Using red theme from design
                  trendUp: true
                ),
                _buildStatCard(
                  title: "PRODUCTS", 
                  value: controller.totalProducts.value, 
                  trend: "Active Items", 
                  icon: Icons.inventory_2, 
                  iconColor: Colors.red,
                  isTrendText: true
                ),
                _buildStatCard(
                  title: "CUSTOMERS", 
                  value: controller.totalCustomers.value, 
                  trend: "+15%", 
                  icon: Icons.people, 
                  iconColor: Colors.red,
                  trendUp: true
                ),
              ],
            )),
            
            const SizedBox(height: 30),
            
            // Sales Growth Placeholder
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Get.theme.cardColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text("Sales Growth", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Get.theme.textTheme.bodyLarge?.color), overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
                              child: Text("Weekly", style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text("Monthly", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    height: 150,
                    child: Obx(() => BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: () {
                          double maxVal = controller.weeklySales.reduce((a, b) => a > b ? a : b);
                          return maxVal < 1000 ? 1000.0 : maxVal * 1.2;
                        }(),
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                                return Text(days[value.toInt()], style: const TextStyle(fontSize: 10, color: Colors.grey));
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(7, (i) => BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: controller.weeklySales[i],
                              color: AppColors.primary,
                              width: 12,
                              borderRadius: BorderRadius.circular(4),
                            )
                          ],
                        )),
                      ),
                    )),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Quick Actions
            Text("Quick Actions", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => Get.to(() => const AddProductScreen()),
                icon: const Icon(Icons.add_circle, color: Colors.white),
                label: Text("Add New Product", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  shadowColor: AppColors.primary.withOpacity(0.4),
                  elevation: 8,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => Get.to(() => const AdminSupportMessagesScreen()),
                icon: const Icon(Icons.support_agent, color: Colors.white),
                label: Text("Support Inquiries", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  shadowColor: Colors.indigo.withOpacity(0.4),
                  elevation: 8,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _showProfitAnalysis(context, controller),
                icon: const Icon(Icons.trending_up, color: Colors.white),
                label: Text("View Profit Analysis", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  shadowColor: Colors.green.withOpacity(0.4),
                  elevation: 8,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton("View Orders", Icons.list_alt, () => Get.to(() => const AdminOrderManagementScreen())),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton("Create Offer", Icons.local_offer, () {
                    _showCreateOfferDialog(context);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
      bottomNavigationBar: _buildAdminBottomNav(),
    );
  }

  Widget _buildStatCard({required String title, required String value, required String trend, required IconData icon, required Color iconColor, bool trendUp = true, bool isTrendText = false}) {
    return Container(
      padding: const EdgeInsets.all(12), // Reduced padding to prevent overflow
      decoration: BoxDecoration(color: Get.theme.cardColor, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const Spacer(),
          Text(title, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Get.theme.textTheme.displayLarge?.color)),
          const SizedBox(height: 4),
          Text(
            trend, 
            style: GoogleFonts.poppins(
              color: isTrendText ? Colors.grey : (trendUp ? Colors.green : Colors.red), 
              fontSize: 10, 
              fontWeight: FontWeight.bold
            )
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(color: Get.theme.cardColor, borderRadius: BorderRadius.circular(28)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Get.theme.textTheme.bodyLarge?.color)),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: Get.theme.cardColor, border: Border(top: BorderSide(color: Get.theme.dividerColor))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.dashboard, "Dashboard", true, () {}),
          _buildNavItem(Icons.inventory_2, "Inventory", false, () => Get.to(() => const AdminProductManagementScreen())),
          _buildNavItem(Icons.shopping_cart, "Orders", false, () => Get.to(() => const AdminOrderManagementScreen())),
          _buildNavItem(Icons.settings, "Settings", false, () => Get.to(() => const AdminSettingsScreen())),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? AppColors.primary : Colors.grey[400]),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.poppins(fontSize: 10, color: isActive ? AppColors.primary : Colors.grey[400], fontWeight: FontWeight.w500))
        ],
      ),
    );
  }

  void _showCreateOfferDialog(BuildContext context) {
    final controller = Get.find<AdminDashboardController>();
    final titleController = TextEditingController();
    final discountController = TextEditingController();
    
    // Fetch current offer first
    controller.getCurrentOffer().then((currentOffer) {
      Get.defaultDialog(
        title: "Manage Offer",
        titleStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        contentPadding: const EdgeInsets.all(20),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show current offer if exists
              if (currentOffer != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.local_offer, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Current Offer",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        currentOffer['title'] ?? '',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${currentOffer['discount']}% OFF',
                        style: GoogleFonts.poppins(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Get.back();
                            Get.defaultDialog(
                              title: "Delete Offer?",
                              middleText: "Are you sure you want to delete the current offer?",
                              textConfirm: "DELETE",
                              textCancel: "CANCEL",
                              confirmTextColor: Colors.white,
                              buttonColor: Colors.red,
                              onConfirm: () async {
                                Get.back();
                                await controller.deleteOffer();
                              },
                            );
                          },
                          icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                          label: Text(
                            "Delete Offer",
                            style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Divider(),
                const SizedBox(height: 16),
              ],
              
              Text(
                currentOffer != null ? "Create New Offer (Replaces Current)" : "Create New Offer",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Offer Title (e.g. MEGA50)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: discountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Discount Percentage",
                  suffixText: "%",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        textConfirm: "CREATE",
        confirmTextColor: Colors.white,
        buttonColor: AppColors.primary,
        onConfirm: () {
          if (titleController.text.isEmpty || discountController.text.isEmpty) {
            Get.snackbar("Error", "Please fill all fields", backgroundColor: Colors.red, colorText: Colors.white);
            return;
          }

          double? discount = double.tryParse(discountController.text);
          if (discount == null) {
            Get.snackbar("Error", "Invalid discount percentage", backgroundColor: Colors.red, colorText: Colors.white);
            return;
          }

          Get.back();
          
          String title = titleController.text.trim();
          String desc = "$discount% OFF! Limited Time Offer.";

          controller.createOffer(title, desc, discount);
        },
        textCancel: "CANCEL",
      );
    });
  }

  void _showProfitAnalysis(BuildContext context, AdminDashboardController controller) async {
    // Show loading dialog
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final profitData = await controller.calculateProfit();
    Get.back(); // Close loading

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("💰 Profit Analysis", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 20),
              
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildProfitCard(
                      "Total Profit",
                      "₹${profitData['totalProfit'].toStringAsFixed(0)}",
                      Icons.account_balance_wallet,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildProfitCard(
                      "Profit Margin",
                      "${profitData['profitMargin'].toStringAsFixed(1)}%",
                      Icons.percent,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildProfitCard(
                      "Total Revenue",
                      "₹${profitData['totalRevenue'].toStringAsFixed(0)}",
                      Icons.trending_up,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildProfitCard(
                      "Total Cost",
                      "₹${profitData['totalCost'].toStringAsFixed(0)}",
                      Icons.shopping_cart,
                      Colors.red,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Top Profitable Products", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              
              // Top Products List
              Expanded(
                child: (profitData['topProducts'] as List).isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              "No Profit Data Available",
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              profitData['deliveredOrders'] == 0
                                  ? "No delivered orders yet.\nProfit is calculated from delivered orders."
                                  : profitData['productsWithBuyingPrice'] == 0
                                      ? "Add buying prices to your products\nin the 'Add Product' screen."
                                      : "Products sold don't have buying prices set.",
                              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("📊 Debug Info:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text("• Delivered Orders: ${profitData['deliveredOrders']}", style: GoogleFonts.poppins(fontSize: 11)),
                                  Text("• Products with Buying Price: ${profitData['productsWithBuyingPrice']}", style: GoogleFonts.poppins(fontSize: 11)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: (profitData['topProducts'] as List).length,
                        itemBuilder: (context, index) {
                          final product = (profitData['topProducts'] as List)[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32, height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(child: Text("${index + 1}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.green))),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(product['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                                      Text("${product['soldUnits']} units sold • ₹${product['profitPerUnit'].toStringAsFixed(0)}/unit", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                Text("₹${product['profit'].toStringAsFixed(0)}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.green)),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfitCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(title, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
