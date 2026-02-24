import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/order_model.dart';
import 'order_details_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  final OrderModel order;
  const OrderTrackingScreen({super.key, required this.order});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  
  // Mock coordinates for demonstration
  static const LatLng _center = LatLng(13.0827, 80.2707); // Chennai
  static const LatLng _warehouse = LatLng(13.06, 80.24);
  static const LatLng _courier = LatLng(13.075, 80.26);
  static const LatLng _destination = LatLng(13.0827, 80.2707);

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _setupMap();
  }

  void _setupMap() {
    _markers.add(
      Marker(
        markerId: const MarkerId('warehouse'),
        position: _warehouse,
        infoWindow: const InfoWindow(title: 'Warehouse'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
    );

    _markers.add(
      Marker(
        markerId: const MarkerId('courier'),
        position: _courier,
        infoWindow: const InfoWindow(title: 'Courier'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    _markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: _destination,
        infoWindow: const InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );

    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: [_warehouse, _courier, _destination],
        color: Colors.red,
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      Get.snackbar("Error", "Could not launch dialer");
    }
  }

  String _translate(String text) {
    if (text.isEmpty) return text;
    String cleanText = text.trim().toLowerCase();
    String translated = cleanText.tr;
    return (translated == cleanText) ? text : translated;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _center,
              zoom: 13.0,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            myLocationEnabled: false,
            zoomControlsEnabled: false,
          ),
          
          // Custom Back Button
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
              ),
            ),
          ),

           // Custom Menu Button (Mock)
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: () {},
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.more_horiz, color: Colors.black),
              ),
            ),
          ),

          // Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.2,
            maxChildSize: 0.6,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("arriving_soon".tr, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 22)),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: "estimated".tr + ": ", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
                                  TextSpan(text: "Today, 4:45 PM", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)), // Mock
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                          child: Text("on_the_way".tr, style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 10)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Main Item Preview
                     Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                           if (widget.order.items.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  widget.order.items.first.product.imageUrl.startsWith('http') 
                                    ? widget.order.items.first.product.imageUrl 
                                    : 'https://via.placeholder.com/60', // Fallback
                                  width: 50, height: 60, fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 50, color: Colors.grey),
                                ),
                              ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_translate(widget.order.items.first.product.name), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text("${"size".tr}: ${widget.order.items.first.selectedSize}", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                            Text("₹${widget.order.totalAmount.toStringAsFixed(0)}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
                        ],
                      ),
                     ),
                     const SizedBox(height: 30),

                     // Timeline
                     _buildTrackingStep(
                       icon: Icons.local_shipping,
                       color: Colors.red,
                       title: "out_for_delivery".tr,
                       subtitle: "courier_nearby".trParams({'distance': '1.2 km'}),
                       time: "4:12 PM",
                       isActive: true,
                       isLast: false,
                     ),
                     _buildTrackingStep(
                       icon: Icons.inventory_2,
                       color: Colors.red,
                       title: "arrived_at_facility".tr,
                       subtitle: "Distribution center, Chennai",
                       time: "1:30 PM",
                       isActive: true,
                       isLast: false,
                     ),
                     _buildTrackingStep(
                       icon: Icons.check_circle,
                       color: Colors.red.withOpacity(0.5),
                       title: "quality_check_passed".tr,
                       subtitle: "",
                       time: "10:00 AM",
                       isActive: false,
                       isLast: true,
                     ),

                     const SizedBox(height: 24),
                     // Actions
                     Row(
                       children: [
                         Expanded(
                           child: ElevatedButton.icon(
                             onPressed: () => _makePhoneCall('1234567890'),
                             icon: const Icon(Icons.support_agent, color: Colors.white),
                             label: Text("contact_support".tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                             style: ElevatedButton.styleFrom(
                               backgroundColor: const Color(0xFFFF1728), // Red color from image
                               padding: const EdgeInsets.symmetric(vertical: 16),
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                             ),
                           ),
                         ),
                         const SizedBox(width: 16),
                         Container(
                           decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(30)),
                           child: IconButton(
                             onPressed: () => _makePhoneCall('9876543210'),
                             icon: const Icon(Icons.call, color: Colors.black87),
                             padding: const EdgeInsets.all(16),
                           ),
                         ),
                       ],
                     ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingStep({required IconData icon, required Color color, required String title, required String subtitle, required String time, required bool isActive, required bool isLast}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isActive ? Colors.red : Colors.red[50], 
                  shape: BoxShape.circle
                ),
                child: Icon(icon, color: isActive ? Colors.white : Colors.red, size: 20),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isActive ? Colors.red : Colors.grey[200],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                if(subtitle.isNotEmpty) Text(subtitle, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 24),
              ],
            ),
          ),
          Text(time, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
