import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';
import 'package:pvp_traders/data/models/order_model.dart';
import '../controllers/admin_order_controller.dart';
import 'dart:convert';

class AdminOrderDetailsScreen extends StatelessWidget {
  final OrderModel order;
  const AdminOrderDetailsScreen({super.key, required this.order});

  String _translate(String text) {
    if (text.isEmpty) return text;
    String cleanText = text.trim().toLowerCase();
    String translated = cleanText.tr;
    return (translated == cleanText) ? text : translated;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Column(
          children: [
            Text("#${order.id.substring(0, 8).toUpperCase()}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16)),
            Text(DateFormat('MMM dd, yyyy • hh:mm a').format(order.date), style: GoogleFonts.poppins(color: Colors.grey, fontSize: 10)),
          ],
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(20)),
            child: Text(order.status.toUpperCase(), style: GoogleFonts.poppins(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Current Status: ${order.status}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black)),
                  const Icon(Icons.unfold_more, color: Colors.red),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("CUSTOMER INFO", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const CircleAvatar(radius: 20, backgroundColor: Colors.teal, child: Icon(Icons.person, color: Colors.white)),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Customer ID: ${order.userId?.substring(0,8) ?? 'Unknown'}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, color: Colors.red, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Shipping Address", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text("${order.address ?? 'No address'}, ${order.city ?? ''}, ${order.zip ?? ''}", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12, height: 1.4)),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            Container(
               padding: const EdgeInsets.all(20),
               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text("ITEMS (${order.items.length})", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                   const SizedBox(height: 16),
                   ...order.items.map((item) {
                     final imageStr = item.product.imageUrl;
                     return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: (imageStr.startsWith('data:image'))
                                ? Image.memory(base64Decode(imageStr.split(',').last), width: 60, height: 60, fit: BoxFit.cover)
                                : (imageStr.isNotEmpty && imageStr.startsWith('http'))
                                    ? Image.network(imageStr, width: 60, height: 60, fit: BoxFit.cover)
                                    : Container(width: 60, height: 60, color: Colors.grey[100], child: const Icon(Icons.image, color: Colors.grey)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_translate(item.product.name), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text("SIZE: ${item.selectedSize}", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("${item.quantity} x ₹${item.product.price.toStringAsFixed(0)}", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                              Text("₹${(item.quantity * item.product.price).toStringAsFixed(0)}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.red)),
                            ],
                          )
                        ],
                      ),
                    );
                   }).toList(),
                 ],
               ),
            ),

            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("PAYMENT SUMMARY", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 16),
                  _buildSummaryRow("Subtotal", "₹${(order.totalAmount - 40).toStringAsFixed(0)}"),
                  _buildSummaryRow("Delivery Fee", "₹40"),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Paid", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text("₹${order.totalAmount.toStringAsFixed(0)}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.red)),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text("UPDATE STATUS", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
          Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}
