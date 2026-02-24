import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';
import 'dart:convert';
import '../controllers/profile_controller.dart';
import '../controllers/customer_order_controller.dart';
import '../controllers/wishlist_controller.dart';
import 'cart_screen.dart';
import 'my_orders_screen.dart';
import 'wishlist_screen.dart';
import 'wallet_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'help_support_screen.dart';
import 'package:pvp_traders/core/constants/app_assets.dart';
import 'shipping_address_screen.dart';
import '../../auth/views/login_screen.dart';
import '../../auth/controllers/login_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Register controllers if not present
    final ProfileController controller = Get.find<ProfileController>();
    final CustomerOrderController orderController = Get.find<CustomerOrderController>();
    final WishlistController wishlistController = Get.find<WishlistController>();
    final LoginController loginController = Get.find<LoginController>();
    
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      AppAssets.logo,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.person_outline, size: 80, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  "welcome".tr,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "login_manage_desc".tr,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Get.to(() => const LoginScreen()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 4,
                      shadowColor: AppColors.primary.withOpacity(0.4),
                    ),
                    child: Text(
                      "login_signup".tr,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Get.to(() => const HelpSupportScreen()),
                  child: Text(
                    "need_help".tr,
                    style: GoogleFonts.poppins(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
            onPressed: () => Get.to(() => const CartScreen()),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Profile Header
            Obx(() {
              final userData = controller.userProfile;
              final name = userData['fullName'] ?? userData['name'] ?? 'Guest';
              final profileImageUrl = userData['profileImage'] ?? '';
              
              // Determine image provider
              ImageProvider? imageProvider;
              if (profileImageUrl.isNotEmpty) {
                if (profileImageUrl.startsWith('data:image')) {
                  // Base64 image
                  try {
                    imageProvider = MemoryImage(base64Decode(profileImageUrl.split(',').last));
                  } catch (e) {
                    print('Error decoding base64 profile image: $e');
                  }
                } else if (profileImageUrl.startsWith('http')) {
                  // Network image
                  imageProvider = NetworkImage(profileImageUrl);
                }
              }
              
              return Column(
                children: [
                   Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFFEEDCC6),
                          backgroundImage: imageProvider,
                          child: imageProvider == null
                              ? const Icon(Icons.person, size: 50, color: Colors.white)
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => Get.to(() => const EditProfileScreen()),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Get.theme.textTheme.displayLarge?.color,
                    ),
                  ),
                  Text(
                    user?.email ?? user?.phoneNumber ?? "Not available",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 30),

            // Stats Row
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Get.theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => _buildStatItem(
                    icon: Icons.local_mall,
                    label: "my_orders".tr,
                    badge: "total_items".trParams({'count': orderController.myOrders.length.toString()}),
                    color: Colors.red[50]!,
                    iconColor: Colors.red,
                    onTap: () => Get.to(() => const MyOrdersScreen()),
                  )),
                  Obx(() => _buildStatItem(
                    icon: Icons.favorite,
                    label: "wishlist".tr,
                    badge: "items_count".trParams({'count': wishlistController.wishlistItems.length.toString()}),
                    color: Colors.red[50]!,
                    iconColor: Colors.red,
                    onTap: () => Get.to(() => const WishlistScreen()),
                  )),
                  Obx(() => _buildStatItem(
                    icon: Icons.account_balance_wallet,
                    label: "wallet".tr,
                    badge: "₹${controller.walletBalance.value.toStringAsFixed(0)}",
                    isPrice: true,
                    color: Colors.red[50]!,
                    iconColor: Colors.red,
                    onTap: () => Get.to(() => const WalletScreen()),
                  )),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Menu Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.location_on, 
                    title: "shipping_addresses".tr, 
                    onTap: () => Get.to(() => const ShippingAddressScreen()),
                  ),
                  _buildMenuItem(
                    icon: Icons.person_outline, 
                    title: "edit_account".tr, 
                    onTap: () => Get.to(() => const EditProfileScreen()),
                  ), 
                  _buildMenuItem(
                    icon: Icons.settings_outlined, 
                    title: "settings".tr, 
                    onTap: () => Get.to(() => const SettingsScreen()),
                  ),
                  _buildMenuItem(
                    icon: Icons.help_outline, 
                    title: "help_support".tr, 
                    onTap: () => Get.to(() => const HelpSupportScreen()),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Get.defaultDialog(
                      title: "logout_confirm_title".tr,
                      middleText: "logout_confirm_desc".tr,
                      onCancel: () {},
                      onConfirm: () async {
                        Get.back(); // Close dialog
                        await loginController.logout();
                      },
                      confirmTextColor: Colors.white,
                      buttonColor: Colors.red,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout),
                      const SizedBox(width: 8),
                      Text(
                        "logout".tr,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
             const SizedBox(height: 20),
            Text(
              "PVP TRADERS PREMIUM",
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.red.withOpacity(0.4),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              "v2.4.0 (2024)",
               style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String badge,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
    bool isPrice = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Get.theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 4),
          isPrice
              ? Text(
                  badge,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.005),
            blurRadius: 10,
             offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Get.theme.scaffoldBackgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Get.theme.iconTheme.color, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Get.theme.textTheme.bodyLarge?.color,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      ),
    );
  }
}
