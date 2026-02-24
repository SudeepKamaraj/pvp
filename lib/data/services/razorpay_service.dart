import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:get/get.dart';

class RazorpayService {
  late Razorpay _razorpay;
  
  // Test API Keys - IMPORTANT: Replace with your actual Razorpay test keys
  // Get your test keys from: https://dashboard.razorpay.com/app/website-app-settings/api-keys
  static const String keyId = 'rzp_test_RKjVY9b5n2bPLf'; 
  static const String keySecret = 'MOPH6UOti8F4gyqzNF6s668'; 
  
  Function(PaymentSuccessResponse)? onSuccess;
  Function(PaymentFailureResponse)? onFailure;
  Function(ExternalWalletResponse)? onExternalWallet;
  
  void initialize({
    required Function(PaymentSuccessResponse) onPaymentSuccess,
    required Function(PaymentFailureResponse) onPaymentError,
    Function(ExternalWalletResponse)? onExternalWalletSelected,
  }) {
    _razorpay = Razorpay();
    onSuccess = onPaymentSuccess;
    onFailure = onPaymentError;
    onExternalWallet = onExternalWalletSelected;
    
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }
  
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (onSuccess != null) {
      onSuccess!(response);
    }
  }
  
  void _handlePaymentError(PaymentFailureResponse response) {
    if (onFailure != null) {
      onFailure!(response);
    }
  }
  
  void _handleExternalWallet(ExternalWalletResponse response) {
    if (onExternalWallet != null) {
      onExternalWallet!(response);
    }
  }
  
  void openCheckout({
    required double amount,
    required String orderId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    String? description,
  }) {
    // Validate phone number (should be 10 digits for India)
    String cleanPhone = customerPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.length == 10) {
      cleanPhone = '+91$cleanPhone'; // Add country code for India
    } else if (cleanPhone.length == 12 && cleanPhone.startsWith('91')) {
      cleanPhone = '+$cleanPhone';
    } else if (!cleanPhone.startsWith('+')) {
      cleanPhone = '+91${cleanPhone.substring(cleanPhone.length >= 10 ? cleanPhone.length - 10 : 0)}';
    }

    var options = {
      'key': keyId,
      'amount': (amount * 100).toInt(), // Amount in paise (multiply by 100)
      'currency': 'INR',
      'name': 'PVP Traders',
      'description': description ?? 'Order Payment',
      'timeout': 300, // Payment timeout in seconds (5 minutes)
      'notes': {
        'merchant_order_id': orderId,
      },
      'prefill': {
        'contact': cleanPhone,
        'email': customerEmail.isNotEmpty ? customerEmail : 'customer@pvptraders.com',
        'name': customerName.isNotEmpty ? customerName : 'Customer',
      },
      'theme': {
        'color': '#7A1F2B' // App primary color
      },
      'retry': {
        'enabled': true,
        'max_count': 3
      }
    };
    
    
    print('DEBUG: Razorpay Key: $keyId');
    print('DEBUG: Razorpay Amount: ${options['amount']} paise (₹$amount)');
    print('DEBUG: Razorpay Phone: $cleanPhone');
    print('DEBUG: Razorpay Options: $options');

    try {
      _razorpay.open(options);
      print('DEBUG: Razorpay checkout opened successfully');
    } catch (e, stack) {
      print('DEBUG: Razorpay open failed: $e');
      print('DEBUG: Stack trace: $stack');
      Get.snackbar(
        'Error',
        'Failed to open payment gateway: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }
  
  void dispose() {
    _razorpay.clear();
  }
}
