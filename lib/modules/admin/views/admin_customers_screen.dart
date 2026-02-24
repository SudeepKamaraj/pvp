import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';

class AdminCustomersController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  var customers = <Map<String, dynamic>>[].obs; // Using map for flexible data
  
  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
  }
  
  void fetchCustomers() async {
    // Mocking real fetch for now since User model might need expanding
    final snapshot = await _db.collection('users').get();
    customers.value = snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  void toggleBlockUser(String uid, bool currentStatus) async {
    // Logic to update Firestore 'isBlocked' field
    await _db.collection('users').doc(uid).update({'isBlocked': !currentStatus});
    fetchCustomers();
  }
}

class AdminCustomersScreen extends StatelessWidget {
  const AdminCustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminCustomersController controller = Get.put(AdminCustomersController());

    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("PVP TRADERS ADMIN", style: GoogleFonts.poppins(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            Text("Customers", style: GoogleFonts.poppins(color: Get.theme.textTheme.displayLarge?.color, fontWeight: FontWeight.bold, fontSize: 24)),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.teal, width: 2)),
            child: const CircleAvatar(backgroundColor: Colors.teal, child: Text("AD", style: TextStyle(color: Colors.white))),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: Get.theme.cardColor, borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const TextField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.search, color: Colors.grey),
                        hintText: "Search name or email...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.tune, color: Colors.red),
                )
              ],
            ),
          ),
          
          // Stats Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildStatCircle("TOTAL USERS", "12,842"),
                const SizedBox(width: 16),
                _buildStatCircle("ACTIVE TODAY", "842", isRed: true),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // List
          Expanded(
            child: Obx(() {
               if (controller.customers.isEmpty) return const Center(child: Text("No customers found"));
               
               return ListView.builder(
                 padding: const EdgeInsets.all(20),
                 itemCount: controller.customers.length,
                 itemBuilder: (context, index) {
                   final user = controller.customers[index];
                   final isBlocked = user['isBlocked'] ?? false;
                   
                   return Container(
                     margin: const EdgeInsets.only(bottom: 16),
                     padding: const EdgeInsets.all(20),
                     decoration: BoxDecoration(color: Get.theme.cardColor, borderRadius: BorderRadius.circular(24)),
                     child: Column(
                       children: [
                         Row(
                           children: [
                             Stack(
                               children: [
                                 const CircleAvatar(
                                   radius: 26,
                                   backgroundColor: Colors.teal,
                                   child: Icon(Icons.person, color: Colors.white, size: 30),
                                 ),
                                 Positioned(
                                   bottom: 0, right: 0,
                                   child: Container(
                                     width: 14, height: 14,
                                     decoration: BoxDecoration(color: isBlocked ? Colors.red : Colors.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                   ),
                                 )
                               ],
                             ),
                             const SizedBox(width: 16),
                             Expanded(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Row(
                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                     children: [
                                       Text(user['name'] ?? "Unknown User", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Get.theme.textTheme.displayLarge?.color)),
                                       Container(
                                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                         decoration: BoxDecoration(color: isBlocked ? Colors.red[50] : Colors.green[50], borderRadius: BorderRadius.circular(8)),
                                         child: Text(isBlocked ? "BLOCKED" : "ACTIVE", style: GoogleFonts.poppins(color: isBlocked ? Colors.red : Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                                       )
                                     ],
                                   ),
                                   Text(user['email'] ?? "", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                                 ],
                               ),
                             ),
                           ],
                         ),
                         const SizedBox(height: 16),
                         Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             _buildDetail("Phone", "+1 (555) 012-3456"), // Mock
                             _buildDetail("Orders", "24 Orders", isRed: true),
                           ],
                         ),
                         const SizedBox(height: 20),
                         Row(
                           children: [
                             Expanded(
                               child: ElevatedButton.icon(
                                 onPressed: () {},
                                 icon: const Icon(Icons.person, color: Colors.red, size: 16),
                                 label: Text("View Profile", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold)),
                                 style: ElevatedButton.styleFrom(
                                   backgroundColor: Colors.red[50],
                                   elevation: 0,
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                 ),
                               ),
                             ),
                             const SizedBox(width: 12),
                             Expanded(
                               child: ElevatedButton.icon(
                                 onPressed: () => controller.toggleBlockUser(user['id'], isBlocked),
                                 icon: Icon(isBlocked ? Icons.check_circle : Icons.block, color: isBlocked ? Colors.white : Colors.black, size: 16),
                                 label: Text(isBlocked ? "Unblock" : "Block", style: GoogleFonts.poppins(color: isBlocked ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                                 style: ElevatedButton.styleFrom(
                                   backgroundColor: isBlocked ? Colors.red : Colors.grey[200],
                                   elevation: 0,
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                 ),
                               ),
                             ),
                           ],
                         )
                       ],
                     ),
                   );
                 },
               );
            }),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.red,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCircle(String label, String count, {bool isRed = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(color: Get.theme.cardColor, borderRadius: BorderRadius.circular(40)),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey, letterSpacing: 1.2)),
          Text(count, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: isRed ? Colors.red : Get.theme.textTheme.displayLarge?.color)),
        ],
      ),
    );
  }

  Widget _buildDetail(String title, String value, {bool isRed = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 12)),
        Text(value, style: GoogleFonts.poppins(color: isRed ? Colors.red : Get.theme.textTheme.displayLarge?.color, fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}
