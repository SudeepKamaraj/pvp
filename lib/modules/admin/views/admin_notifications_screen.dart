import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/admin_marketing_controller.dart';

class AdminNotificationsScreen extends StatelessWidget {
  const AdminNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is found (put in offers screen or here)
    final AdminMarketingController controller = Get.find<AdminMarketingController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text("Notification Center", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Get.back()),
      ),
      body: SingleChildScrollView(
         padding: const EdgeInsets.all(20),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Container(
               padding: const EdgeInsets.all(24),
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(24),
                 boxShadow: [
                   BoxShadow(
                     color: Colors.grey.withOpacity(0.15),
                     blurRadius: 12,
                     offset: const Offset(0, 4),
                   ),
                 ],
               ),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     children: [
                       Container(
                         padding: const EdgeInsets.all(12),
                         decoration: BoxDecoration(
                           gradient: const LinearGradient(
                             colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
                             begin: Alignment.topLeft,
                             end: Alignment.bottomRight,
                           ),
                           borderRadius: BorderRadius.circular(12),
                           boxShadow: [
                             BoxShadow(
                               color: Colors.red.withOpacity(0.3),
                               blurRadius: 8,
                               offset: const Offset(0, 2),
                             ),
                           ],
                         ),
                         child: const Icon(
                           Icons.notifications_active,
                           color: Colors.white,
                           size: 24,
                         ),
                       ),
                       const SizedBox(width: 12),
                       Text(
                         "NEW NOTIFICATION",
                         style: GoogleFonts.poppins(
                           fontSize: 14,
                           fontWeight: FontWeight.bold,
                           color: Colors.black87,
                           letterSpacing: 0.5,
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 24),
                   
                   Text(
                     "Notification Title",
                     style: GoogleFonts.poppins(
                       fontSize: 13,
                       fontWeight: FontWeight.bold,
                       color: Colors.black87,
                     ),
                   ),
                   const SizedBox(height: 8),
                   TextField(
                     controller: controller.notifTitleController,
                     style: GoogleFonts.poppins(
                       fontSize: 14,
                       color: Colors.black87,
                     ),
                     decoration: InputDecoration(
                       hintText: "e.g. Flash Sale Live Now! 🔥",
                       hintStyle: GoogleFonts.poppins(
                         color: Colors.grey[400],
                         fontSize: 14,
                       ),
                       filled: true,
                       fillColor: const Color(0xFFF5F5F5),
                       border: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(12),
                         borderSide: BorderSide.none,
                       ),
                       enabledBorder: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(12),
                         borderSide: BorderSide(color: Colors.grey[300]!),
                       ),
                       focusedBorder: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(12),
                         borderSide: const BorderSide(color: Colors.red, width: 2),
                       ),
                       contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                     ),
                   ),
                   const SizedBox(height: 20),
                   
                   Text(
                     "Message Content",
                     style: GoogleFonts.poppins(
                       fontSize: 13,
                       fontWeight: FontWeight.bold,
                       color: Colors.black87,
                     ),
                   ),
                   const SizedBox(height: 8),
                   TextField(
                     controller: controller.notifBodyController,
                     maxLines: 4,
                     style: GoogleFonts.poppins(
                       fontSize: 14,
                       color: Colors.black87,
                     ),
                     decoration: InputDecoration(
                       hintText: "Enter your notification message here...",
                       hintStyle: GoogleFonts.poppins(
                         color: Colors.grey[400],
                         fontSize: 14,
                       ),
                       filled: true,
                       fillColor: const Color(0xFFF5F5F5),
                       border: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(12),
                         borderSide: BorderSide.none,
                       ),
                       enabledBorder: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(12),
                         borderSide: BorderSide(color: Colors.grey[300]!),
                       ),
                       focusedBorder: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(12),
                         borderSide: const BorderSide(color: Colors.red, width: 2),
                       ),
                       contentPadding: const EdgeInsets.all(20),
                     ),
                   ),
                   const SizedBox(height: 20),
                   
                   Text(
                     "Target Audience",
                     style: GoogleFonts.poppins(
                       fontSize: 13,
                       fontWeight: FontWeight.bold,
                       color: Colors.black87,
                     ),
                   ),
                   const SizedBox(height: 8),
                   Obx(() => Container(
                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                     decoration: BoxDecoration(
                       color: const Color(0xFFF5F5F5),
                       borderRadius: BorderRadius.circular(12),
                       border: Border.all(color: Colors.grey[300]!),
                     ),
                     child: DropdownButtonHideUnderline(
                       child: DropdownButton<String>(
                         value: controller.selectedAudience.value,
                         isExpanded: true,
                         style: GoogleFonts.poppins(
                           fontSize: 14,
                           color: Colors.black87,
                         ),
                         dropdownColor: Colors.white,
                         icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
                         items: ["All Users", "Active Buyers", "Inactive Users"].map((String val) {
                           return DropdownMenuItem<String>(
                             value: val,
                             child: Text(val),
                           );
                         }).toList(),
                         onChanged: (val) => controller.selectedAudience.value = val!,
                       ),
                     ),
                   )),
                   
                   const SizedBox(height: 30),
                   
                   SizedBox(
                     width: double.infinity,
                     child: Obx(() => ElevatedButton.icon(
                       onPressed: controller.isLoading.value ? null : () => controller.sendBroadcastNotification(),
                       icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                       label: Text(
                         controller.isLoading.value ? "Sending..." : "Broadcast Notification",
                         style: GoogleFonts.poppins(
                           fontWeight: FontWeight.bold,
                           color: Colors.white,
                           fontSize: 15,
                         ),
                       ),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: controller.isLoading.value ? Colors.grey : Colors.red,
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                         padding: const EdgeInsets.symmetric(vertical: 18),
                         elevation: controller.isLoading.value ? 0 : 6,
                         shadowColor: Colors.red.withOpacity(0.4),
                       ),
                     )),
                   )
                 ],
               ),
             ),
             
             const SizedBox(height: 30),
             
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text("History", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
                 Text("VIEW ALL", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
               ],
             ),
             const SizedBox(height: 16),
             
             _buildHistoryItem("Flash Sale: 50% Off Everything!", "Oct 24, 2:30 PM", "Delivered to 12,400 users", true),
             _buildHistoryItem("Last Chance: VIP Early Access", "Oct 22, 11:15 AM", "API connection error", false),
           ],
         ),
      ),
    );
  }

  Widget _buildHistoryItem(String title, String date, String status, bool isSuccess) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSuccess ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: isSuccess ? Colors.green : Colors.red),
                    const SizedBox(width: 6),
                    Text(
                      isSuccess ? "SENT" : "FAILED",
                      style: GoogleFonts.poppins(
                        color: isSuccess ? Colors.green : Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(date, style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 11)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                status,
                style: GoogleFonts.poppins(
                  color: isSuccess ? Colors.grey[600] : Colors.red,
                  fontSize: 11,
                ),
              ),
              Text(
                isSuccess ? "REPLICATE" : "RETRY",
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
