import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';

import '../controllers/profile_controller.dart';

class WalletController extends GetxController {
  final ProfileController _profileController = Get.find<ProfileController>();
  
  RxDouble get balance => _profileController.walletBalance;
  RxInt get points => _profileController.rewardPoints;
  
  var transactions = [
    {'title': 'Sign Up Reward', 'date': 'Today', 'amount': '+100.00', 'id': 'New Member Bonus', 'icon': Icons.card_giftcard, 'color': Colors.green},
    {'title': 'Order Cashback', 'date': 'Yesterday', 'amount': '+25.00', 'id': '#PVP-1002', 'icon': Icons.shopping_bag, 'color': Colors.blue},
  ].obs;

  Future<void> refreshData() async {
    await _profileController.fetchUserProfile();
  }

  @override
  void onInit() {
    super.onInit();
    // Ensure fresh data when wallet is opened
    refreshData();
  }
}

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WalletController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text("wallet_rewards".tr, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        color: const Color(0xFFE31E24),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Red Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE31E24), Color(0xFFA80005)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE31E24).withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Flexible(
                           child: Text(
                             "available_balance".tr,
                             style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8)),
                             overflow: TextOverflow.ellipsis,
                           ),
                         ),
                         const SizedBox(width: 8),
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                           decoration: BoxDecoration(
                             color: Colors.white.withOpacity(0.2),
                             borderRadius: BorderRadius.circular(20),
                           ),
                           child: Row(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               const Icon(Icons.verified, color: Colors.white, size: 14),
                               const SizedBox(width: 4),
                               Text(
                                 "premium_tag".tr,
                                 style: GoogleFonts.poppins(
                                   color: Colors.white,
                                   fontSize: 10,
                                   fontWeight: FontWeight.bold,
                                 ),
                               ),
                             ],
                           ),
                         )
                       ],
                     ),
                     const SizedBox(height: 8),
                     Obx(() => Text(
                       "₹${controller.balance.value.toStringAsFixed(0)}",
                       style: GoogleFonts.poppins(
                         color: Colors.white,
                         fontSize: 36,
                         fontWeight: FontWeight.bold,
                       ),
                     )),
                     const SizedBox(height: 30),
                     Divider(color: Colors.white.withOpacity(0.1)),
                     const SizedBox(height: 16),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Flexible(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 "reward_points".tr,
                                 style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 12),
                                 overflow: TextOverflow.ellipsis,
                               ),
                               const SizedBox(height: 4),
                               Obx(() => Row(
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                   const Icon(Icons.stars, color: Colors.white, size: 20),
                                   const SizedBox(width: 6),
                                   Text(
                                     "${controller.points.value}",
                                     style: GoogleFonts.poppins(
                                       color: Colors.white,
                                       fontSize: 20,
                                       fontWeight: FontWeight.bold,
                                     ),
                                   ),
                                 ],
                               )),
                             ],
                           ),
                         ),
                         const SizedBox(width: 8),
                         Flexible(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.end,
                             children: [
                               Text(
                                 "rate".tr,
                                 style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.bold),
                                 overflow: TextOverflow.ellipsis,
                               ),
                               Text(
                                 "100 pts = ₹10",
                                 style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                               ),
                             ],
                           ),
                         )
                       ],
                     )
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Redeem Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF0142F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 5,
                    shadowColor: const Color(0xFFF0142F).withOpacity(0.4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.card_giftcard, color: Colors.white),
                      const SizedBox(width: 10),
                      Text(
                        "redeem_points".tr,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              
              // Progress
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("member_status".trParams({'name': 'Gold'}), style: GoogleFonts.poppins(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                              Text("pts_until_tier".trParams({'count': '500', 'tier': 'Platinum'}), style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text("90%", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFFF0142F))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: 0.9,
                        minHeight: 8,
                        backgroundColor: Colors.grey[100],
                        valueColor: const AlwaysStoppedAnimation(Color(0xFFF0142F)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              
              // History
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      "cashback_history".tr,
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    "see_all".tr,
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFF0142F)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.transactions.length,
                itemBuilder: (context, index) {
                  final item = controller.transactions[index];
                  final amount = item['amount'] as String;
                  final isPositive = amount.startsWith('+');
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (item['color'] as Color).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(item['icon'] as IconData, color: item['color'] as Color),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] as String,
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                "${item['id']} • ${item['date']}",
                                 style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                         Text(
                            amount,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isPositive ? Colors.green[700] : Colors.black,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
