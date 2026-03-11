import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../data/services/database_service.dart';
import '../../../../data/services/razorpay_service.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/cart_item_model.dart';
import '../controllers/cart_controller.dart';
import 'order_success_screen.dart';
import 'shipping_address_screen.dart'; // Import for ShippingAddressController

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController(); // Restored
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  final _stateController = TextEditingController(); // Added state controller
  final _phoneController = TextEditingController();
  final _couponController = TextEditingController(); // Coupon code input
  int _selectedPaymentMethod = 0; // 0: COD, 1: Online
  Map<String, dynamic>? _selectedSavedAddress;
  bool _isPlacingOrder = false;
  
  // Coupon variables
  double _discountPercentage = 0.0;
  bool _isCouponApplied = false;
  String _appliedCouponCode = '';
  bool _isValidatingCoupon = false;
  
  final RazorpayService _razorpayService = RazorpayService();
  String? _pendingOrderId;

  @override
  void initState() {
    super.initState();
    _razorpayService.initialize(
      onPaymentSuccess: _handlePaymentSuccess,
      onPaymentError: _handlePaymentError,
      onExternalWalletSelected: _handleExternalWallet,
    );
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _stateController.dispose();
    _phoneController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();
    final ShippingAddressController addrController = Get.put(ShippingAddressController());

    return Scaffold(
      appBar: AppBar(
        title: Text("checkout".tr, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saved Addresses Section
              Obx(() {
                 if (addrController.addresses.isNotEmpty) {
                   return Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text("saved_addresses".tr, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                       const SizedBox(height: 12),
                       SizedBox(
                         height: 140,
                         child: ListView.separated(
                           scrollDirection: Axis.horizontal,
                           itemCount: addrController.addresses.length,
                           separatorBuilder: (_, __) => const SizedBox(width: 12),
                           itemBuilder: (context, index) {
                             final addr = addrController.addresses[index];
                             final isSelected = _selectedSavedAddress == addr;
                             return InkWell(
                               onTap: () {
                                 setState(() {
                                   _selectedSavedAddress = addr;
                                   _addressController.text = addr['address'] ?? '';
                                   _cityController.text = addr['city'] ?? '';
                                   _zipController.text = addr['zip'] ?? '';
                                   _stateController.text = addr['state'] ?? '';
                                   _phoneController.text = addr['phone'] ?? '';
                                 });
                               },
                               child: Container(
                                 width: 240,
                                 padding: const EdgeInsets.all(12),
                                 decoration: BoxDecoration(
                                   color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
                                   borderRadius: BorderRadius.circular(12),
                                   border: Border.all(
                                     color: isSelected ? AppColors.primary : Colors.grey[300]!,
                                     width: isSelected ? 2 : 1
                                   ),
                                 ),
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Row(
                                       children: [
                                         Icon(Icons.location_on, size: 16, color: isSelected ? AppColors.primary : Colors.grey),
                                         const SizedBox(width: 8),
                                         Text(addr['label'] ?? "Address", style: const TextStyle(fontWeight: FontWeight.bold)),
                                       ],
                                     ),
                                     const Spacer(),
                                     Text(
                                       "${addr['address']},\n${addr['city']} - ${addr['zip']}",
                                       maxLines: 3,
                                       overflow: TextOverflow.ellipsis,
                                       style: const TextStyle(fontSize: 12, color: Colors.grey),
                                     ),
                                   ],
                                 ),
                               ),
                             );
                           },
                         ),
                       ),
                       const SizedBox(height: 16),
                     ],
                   );
                 }
                 return const SizedBox.shrink();
              }),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text("delivery_address".tr, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                   TextButton.icon(
                     onPressed: () => _showAddAddressDialog(context, addrController),
                     icon: const Icon(Icons.add, size: 18),
                     label: Text("add_new".tr),
                     style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                   ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: "street_address".tr, 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.home_outlined),
                ),
                validator: (value) => value!.isEmpty ? "required".tr : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                   Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        labelText: "city".tr, 
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.location_city),
                      ),
                      validator: (value) => value!.isEmpty ? "required".tr : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _zipController,
                      decoration: InputDecoration(
                        labelText: "zip_code".tr, 
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? "required".tr : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "phone_number".tr, 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? "required".tr : null,
              ),
              const SizedBox(height: 24),
              Text("payment_method".tr, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    RadioListTile(
                      value: 0,
                      groupValue: _selectedPaymentMethod,
                      activeColor: AppColors.primary,
                      title: Text("cash_on_delivery".tr),
                      onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
                    ),
                    const Divider(height: 1),
                    RadioListTile(
                      value: 1,
                      groupValue: _selectedPaymentMethod,
                      activeColor: AppColors.primary,
                      title: Row(
                        children: [
                          Flexible(
                            child: Text("online_payment".tr, overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 8),
                          Image.asset(
                            'assets/images/razorpay_logo.png',
                            height: 20,
                            errorBuilder: (context, error, stackTrace) => const SizedBox(),
                          ),
                        ],
                      ),
                      subtitle: Text("razorpay_methods".tr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Coupon Code Section
              Text("Have a Coupon Code?", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _couponController,
                      enabled: !_isCouponApplied,
                      decoration: InputDecoration(
                        hintText: "Enter coupon code",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.local_offer),
                        filled: true,
                        fillColor: _isCouponApplied ? Colors.green.withOpacity(0.1) : null,
                        suffixIcon: _isCouponApplied 
                          ? IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _isCouponApplied = false;
                                  _discountPercentage = 0.0;
                                  _appliedCouponCode = '';
                                  _couponController.clear();
                                });
                              },
                            )
                          : null,
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isCouponApplied || _isValidatingCoupon ? null : _validateAndApplyCoupon,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isValidatingCoupon
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          _isCouponApplied ? "APPLIED" : "APPLY",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                ],
              ),
              
              if (_isCouponApplied)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        "$_appliedCouponCode applied - ${_discountPercentage.toStringAsFixed(0)}% OFF",
                        style: GoogleFonts.poppins(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 24),
              Text("order_summary".tr, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("subtotal".tr),
                        Text("₹${cartController.totalAmount.toStringAsFixed(0)}"),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("delivery_fee".tr),
                        const Text("₹40", style: TextStyle(color: Colors.green)),
                      ],
                    ),
                    if (_isCouponApplied) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Discount ($_appliedCouponCode)", style: const TextStyle(color: Colors.green)),
                          Text(
                            "-₹${((cartController.totalAmount + 40) * _discountPercentage / 100).toStringAsFixed(0)}",
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("total".tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(
                          "₹${_calculateFinalTotal(cartController.totalAmount).toStringAsFixed(0)}", 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isPlacingOrder ? null : () async {
                    print("DEBUG: Pay Now Button CLICKED");
                    Get.snackbar("Debug", "Processing Pay Now...", duration: const Duration(seconds: 1));
                    
                    if (cartController.cartItems.isEmpty) {
                      Get.snackbar("error".tr, "your_cart_empty".tr, backgroundColor: Colors.red, colorText: Colors.white);
                      return;
                    }

                    if (_formKey.currentState!.validate()) {
                      print("DEBUG: Pay button validated. Payment method: $_selectedPaymentMethod");
                      // If online payment is selected
                      if (_selectedPaymentMethod == 1) {
                        print("DEBUG: Initiating online payment");
                        try {
                          _initiateOnlinePayment(cartController);
                        } catch (e) {
                          print("DEBUG: Error initiating payment: $e");
                          Get.snackbar("Error", "Could not initiate payment: $e");
                        }
                      } else {
                        // Cash on Delivery
                        print("DEBUG: Initiating COD order");
                        _placeCODOrder(cartController);
                      }
                    } else {
                      print("DEBUG: Form validation failed");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                  child: _isPlacingOrder 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        _selectedPaymentMethod == 1 ? "pay_now".tr : "place_order".tr,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Calculate final total with discount
  double _calculateFinalTotal(double cartTotal) {
    double total = cartTotal + 40; // Add delivery fee
    if (_isCouponApplied) {
      double discount = total * _discountPercentage / 100;
      total -= discount;
    }
    return total;
  }

  // Validate and apply coupon
  Future<void> _validateAndApplyCoupon() async {
    if (_couponController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter a coupon code",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar(
        "Error",
        "Please login to apply coupon",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isValidatingCoupon = true);

    try {
      print('📱 Attempting to validate coupon: ${_couponController.text.trim()} for user: ${user.uid}');
      final couponData = await DatabaseService().validateCoupon(_couponController.text.trim(), user.uid);
      
      print('📱 Coupon validation result: $couponData');
      
      if (couponData != null) {
        // Check if it's an error response (already used)
        if (couponData.containsKey('error') && couponData['error'] == 'already_used') {
          Get.snackbar(
            "Already Used",
            couponData['message'] ?? "You have already used this coupon code",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          return;
        }
        
        print('✅ Coupon is valid, applying discount...');
        setState(() {
          _isCouponApplied = true;
          _discountPercentage = (couponData['discount'] ?? 0.0).toDouble();
          _appliedCouponCode = _couponController.text.trim().toUpperCase();
        });
        
        Get.snackbar(
          "✓ Coupon Applied!",
          "${_discountPercentage.toStringAsFixed(0)}% discount applied successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        print('❌ Coupon validation returned null');
        Get.snackbar(
          "Invalid Coupon",
          "This coupon code is not valid or has expired",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Exception during coupon validation: $e');
      Get.snackbar(
        "Error",
        "Failed to validate coupon: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isValidatingCoupon = false);
    }
  }

  void _showAddAddressDialog(BuildContext context, ShippingAddressController controller) {
    final labelCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final stateCtrl = TextEditingController();
    final zipCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final RxString selectedType = "Home".obs;
    final RxBool setAsDefault = false.obs;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("add_address".tr, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 16),
              
              // Live Location Button (Simplified)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final loc = await controller.getCurrentLocation();
                    if (loc != null) {
                      addressCtrl.text = loc['address'] ?? "";
                      cityCtrl.text = loc['city'] ?? "";
                      stateCtrl.text = loc['state'] ?? "";
                      zipCtrl.text = loc['zip'] ?? "";
                    }
                  },
                  icon: const Icon(Icons.my_location_rounded, size: 18),
                  label: Text("use_current_location".tr),
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(controller: labelCtrl, decoration: InputDecoration(labelText: "label_eg_my_home".tr, border: const OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: addressCtrl, decoration: InputDecoration(labelText: "address".tr, border: const OutlineInputBorder())),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: cityCtrl, decoration: InputDecoration(labelText: "city".tr, border: const OutlineInputBorder()))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: zipCtrl, decoration: InputDecoration(labelText: "zip_code".tr, border: const OutlineInputBorder()))),
                ],
              ),
              const SizedBox(height: 12),
              TextField(controller: phoneCtrl, decoration: InputDecoration(labelText: "phone_number".tr, border: const OutlineInputBorder()), keyboardType: TextInputType.phone),
              
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (addressCtrl.text.isNotEmpty && cityCtrl.text.isNotEmpty) {
                      final newAddr = {
                        'label': labelCtrl.text.trim().isEmpty ? "New Address" : labelCtrl.text.trim(),
                        'address': addressCtrl.text.trim(),
                        'city': cityCtrl.text.trim(),
                        'state': stateCtrl.text.trim(),
                        'zip': zipCtrl.text.trim(),
                        'phone': phoneCtrl.text.trim(),
                        'type': selectedType.value,
                        'isDefault': setAsDefault.value,
                        'createdAt': DateTime.now().toIso8601String(),
                      };
                      controller.addAddress(newAddr);
                      // Auto-select this new address
                      setState(() {
                        _selectedSavedAddress = newAddr;
                        _addressController.text = (newAddr['address'] ?? '').toString();
                        _cityController.text = (newAddr['city'] ?? '').toString();
                        _zipController.text = (newAddr['zip'] ?? '').toString();
                        _stateController.text = (newAddr['state'] ?? '').toString();
                        _phoneController.text = (newAddr['phone'] ?? '').toString();
                      });
                      Get.back();
                    } else {
                       Get.snackbar("error".tr, "fill_required_fields".tr);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: Text("save_address".tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32), // Keyboard buffer
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // Place Cash on Delivery Order
  Future<void> _placeCODOrder(CartController cartController) async {
    setState(() => _isPlacingOrder = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final finalTotal = _calculateFinalTotal(cartController.totalAmount);
      final order = OrderModel(
        id: "ORD-${DateTime.now().millisecondsSinceEpoch}",
        userId: user?.uid,
        items: cartController.cartItems.toList(),
        totalAmount: finalTotal,
        status: 'Processing',
        date: DateTime.now(),
        address: _addressController.text,
        city: _cityController.text,
        zip: _zipController.text,
        phone: _phoneController.text,
        paymentMethod: 'COD',
      );

      await DatabaseService().createOrder(order);
      
      // Mark coupon as used if applied
      if (_isCouponApplied && user != null && _appliedCouponCode.isNotEmpty) {
        try {
          await DatabaseService().markCouponAsUsed(_appliedCouponCode, user.uid, order.id);
          print('✅ Coupon marked as used in order');
          // Clear coupon state after marking as used
          if (mounted) {
            setState(() {
              _isCouponApplied = false;
              _discountPercentage = 0.0;
              _appliedCouponCode = '';
              _couponController.clear();
            });
          }
        } catch (couponError) {
          debugPrint('Failed to mark coupon as used: $couponError');
          // Continue even if marking fails
        }
      }
      
      // Create notification
      if (user != null) {
        try {
          await DatabaseService().createNotification(
            userId: user.uid,
            title: 'Order Confirmed! 🎉',
            body: 'Your order #${order.id.substring(0, 8)} has been placed successfully. Total: ₹${order.totalAmount.toStringAsFixed(0)}${_isCouponApplied ? " (Discount applied: $_appliedCouponCode)" : ""}',
            type: 'order',
            data: {'orderId': order.id},
          );
        } catch (notifError) {
          debugPrint('Failed to create notification: $notifError');
        }
      }
      
      cartController.clearCart();
      Get.off(() => OrderSuccessScreen(order: order));
    } catch (e) {
      Get.snackbar("Error", "Failed to place order: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  // Initiate Online Payment
  void _initiateOnlinePayment(CartController cartController) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar("Error", "Please login to continue", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final totalAmount = _calculateFinalTotal(cartController.totalAmount);
    _pendingOrderId = "ORD-${DateTime.now().millisecondsSinceEpoch}";

    _razorpayService.openCheckout(
      amount: totalAmount,
      orderId: _pendingOrderId!,
      customerName: user.displayName ?? 'Customer',
      customerEmail: user.email ?? 'customer@example.com',
      customerPhone: _phoneController.text,
      description: 'Order Payment for PVP Traders',
    );
  }

  // Handle Payment Success
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _isPlacingOrder = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final cartController = Get.find<CartController>();
      final finalTotal = _calculateFinalTotal(cartController.totalAmount);
      
      final order = OrderModel(
        id: "ORD-${DateTime.now().millisecondsSinceEpoch}",
        userId: user?.uid,
        items: cartController.cartItems.toList(),
        totalAmount: finalTotal,
        status: 'Processing',
        date: DateTime.now(),
        address: _addressController.text,
        city: _cityController.text,
        zip: _zipController.text,
        phone: _phoneController.text,
        paymentMethod: 'Online',
        paymentId: response.paymentId,
        razorpayOrderId: response.orderId,
        razorpaySignature: response.signature,
      );

      await DatabaseService().createOrder(order);
      
      // Mark coupon as used if applied
      if (_isCouponApplied && user != null && _appliedCouponCode.isNotEmpty) {
        try {
          await DatabaseService().markCouponAsUsed(_appliedCouponCode, user.uid, order.id);
          print('✅ Coupon marked as used in payment order');
          // Clear coupon state after marking as used
          if (mounted) {
            setState(() {
              _isCouponApplied = false;
              _discountPercentage = 0.0;
              _appliedCouponCode = '';
              _couponController.clear();
            });
          }
        } catch (couponError) {
          debugPrint('Failed to mark coupon as used: $couponError');
          // Continue even if marking fails
        }
      }
      
      // Create notification
      if (user != null) {
        try {
          await DatabaseService().createNotification(
            userId: user.uid,
            title: 'Payment Successful! 🎉',
            body: 'Your payment of ₹${order.totalAmount.toStringAsFixed(0)} was successful. Order #${order.id.substring(0, 8)}${_isCouponApplied ? " (Discount: $_appliedCouponCode)" : ""}',
            type: 'order',
            data: {'orderId': order.id},
          );
        } catch (notifError) {
          debugPrint('Failed to create notification: $notifError');
        }
      }
      
      cartController.clearCart();
      
      Get.snackbar(
        "Payment Successful! 🎉",
        "Order placed successfully${_isCouponApplied ? " with $_appliedCouponCode discount" : ""}",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      
      Get.off(() => OrderSuccessScreen(order: order));
    } catch (e) {
      Get.snackbar("Error", "Payment successful but order creation failed: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  // Handle Payment Error
  void _handlePaymentError(PaymentFailureResponse response) {
    Get.snackbar(
      "Payment Failed",
      "${response.message}",
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  // Handle External Wallet
  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar(
      "External Wallet",
      "Wallet: ${response.walletName}",
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }
}
