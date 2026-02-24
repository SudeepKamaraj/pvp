import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HelpSupportController extends GetxController {
  final messageController = TextEditingController();
  final subjectController = TextEditingController();
  final isSending = false.obs;

  Future<void> launchPhone() async {
    final Uri launchUri = Uri(scheme: 'tel', path: '7845832799');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      Get.snackbar("Error", "Could not launch phone dialer");
    }
  }

  Future<void> launchEmail() async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: '23.sudeepk@gmail.com',
      query: 'subject=Support Inquiry&body=Hi PVP Traders Team,',
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
       Get.snackbar("Error", "Could not launch email app");
    }
  }

  Future<void> sendMessage() async {
    if (messageController.text.isEmpty || subjectController.text.isEmpty) {
      Get.snackbar("Error", "Please fill in all fields", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isSending.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('support_messages').add({
        'userId': user?.uid,
        'userEmail': user?.email,
        'subject': subjectController.text.trim(),
        'message': messageController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'Check', // initial status
      });

      messageController.clear();
      subjectController.clear();
      Get.snackbar("Success", "Message sent successfully!", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Failed to send message: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSending.value = false;
    }
  }
}

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HelpSupportController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text("Help & Support", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black)),
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
            Text("Contact Us", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            _buildContactCard(
              Icons.phone_outlined, 
              "Call Us", 
              "+91 78458 32799", 
              Colors.orange,
              controller.launchPhone
            ),
            _buildContactCard(
              Icons.email_outlined, 
              "Email Us", 
              "23.sudeepk@gmail.com", 
              Colors.blue,
              controller.launchEmail
            ),

            const SizedBox(height: 32),
            Text("Send us a Message", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ]
              ),
              child: Column(
                children: [
                   TextField(
                    controller: controller.subjectController,
                    decoration: InputDecoration(
                      labelText: "Subject",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.messageController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: "Message",
                      hintText: "How can we help you?",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Obx(() => ElevatedButton(
                      onPressed: controller.isSending.value ? null : controller.sendMessage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: controller.isSending.value 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text("Send Message", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                    )),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            Text("Common Questions", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

             _buildExpansionTile(
              "Where is my order?", 
              "You can track your order in real-time under the 'My Orders' section in your profile. Once an order ships, you will receive an email with a tracking number.",
              isExpanded: true
            ),
            _buildExpansionTile("Can I cancel my order?", "Orders can be cancelled within 1 hour of placement before they are processed."),
            _buildExpansionTile("What is your return policy?", "We offer a 7-day return policy for all unused items with original tags."),
            _buildExpansionTile("Refund processing time", "Refunds are processed within 5-7 business days to your original payment method."),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))
          ]
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(subtitle, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionTile(String title, String content, {bool isExpanded = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
         boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))
          ]
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14)),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(content, style: GoogleFonts.poppins(color: Colors.grey, height: 1.5, fontSize: 13)),
            )
          ],
        ),
      ),
    );
  }
}
