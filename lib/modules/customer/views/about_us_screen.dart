import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
         centerTitle: true,
        title: Text("OUR STORY", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Logo Center
            Center(
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5))
                  ]
                ),
                child: Column(
                  children: [
                    Text("PVP", style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1A3C34))), // Dark Greenish
                    Container(height: 1, width: 40, color: const Color(0xFF1A3C34), margin: const EdgeInsets.symmetric(vertical: 4)),
                    Text("TRADERS", style: GoogleFonts.poppins(fontSize: 8, letterSpacing: 2, color: const Color(0xFF1A3C34))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
             RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                children: [
                  const TextSpan(text: "PVP "),
                  TextSpan(text: "Traders", style: GoogleFonts.poppins(color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 30),
            
            Text(
              "\"Redefining the intersection of luxury and accessibility.\"",
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.grey[700]),
            ),
            const SizedBox(height: 30),
            
            Text(
              "Founded on the principles of timeless elegance and modern sophistication, PVP Traders serves as a bridge between high-fashion runways and your daily lifestyle. We believe that premium style should not just be worn, but lived. Every piece in our curated collection is a testament to quality craftsmanship and conscious design.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey, height: 1.8),
            ),
            
            const SizedBox(height: 40),
            
            // Mission/Vision Circles
            _buildCircularCard("MISSION", "To empower self-expression through curated premium fashion.", Icons.auto_awesome, Colors.red[50]!, AppColors.primary),
            const SizedBox(height: 20),
            _buildCircularCard("VISION", "The global destination for conscious luxury and style.", Icons.remove_red_eye, const Color(0xFF1A2A3A), Colors.white),

            const SizedBox(height: 40),
            
            // Image Bottom
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(100)),
              child: Image.network(
                "https://images.unsplash.com/photo-1441986300917-64674bd600d8?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80",
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, _) => Container(height: 150, color: Colors.grey[300]),
              ),
            ),
            const SizedBox(height: 20),
            
            Text("JOIN OUR COMMUNITY", style: GoogleFonts.poppins(fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold, color: Colors.grey[400])),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon(Icons.camera_alt), // Instagram placeholder
                const SizedBox(width: 16),
                 _buildSocialIcon(Icons.facebook),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularCard(String title, String desc, IconData icon, Color bgColor, Color textColor) {
    bool isDark = bgColor == const Color(0xFF1A2A3A);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100), // Pill shape / rounded rect
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white : AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isDark ? Colors.black : Colors.white),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(color: textColor.withOpacity(isDark ? 0.7 : 0.6), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 4),
                Text(desc, style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600, fontSize: 13, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]
      ),
      child: Icon(icon, color: Colors.black),
    );
  }
}
