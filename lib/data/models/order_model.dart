import 'cart_item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderProgress {
  final DateTime? orderedAt;
  final DateTime? packedAt;
  final DateTime? shippedAt;
  final DateTime? inTransitAt;
  final DateTime? deliveredAt;

  OrderProgress({
    this.orderedAt,
    this.packedAt,
    this.shippedAt,
    this.inTransitAt,
    this.deliveredAt,
  });
}

class OrderModel {
  final String id;
  final List<CartItemModel> items;
  final double totalAmount;
  final String status;
  final DateTime date;
  final String? address;
  final String? city;
  final String? zip;
  final String? userId;
  final String? trackingId;
  final DateTime? estimatedArrival;
  final OrderProgress? progress;
  final String? paymentMethod;
  final String? lastFourDigits;
  final String? phone;
  final double? subtotal;
  final double? shippingFee;
  final double? tax;
  final String? paymentId; // Razorpay payment ID
  final String? razorpayOrderId; // Razorpay order ID
  final String? razorpaySignature; // Razorpay signature

  OrderModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.date,
    this.address,
    this.city,
    this.zip,
    this.userId,
    this.trackingId,
    this.estimatedArrival,
    this.progress,
    this.paymentMethod,
    this.lastFourDigits,
    this.phone,
    this.subtotal,
    this.shippingFee,
    this.tax,
    this.paymentId,
    this.razorpayOrderId,
    this.razorpaySignature,
  });
}
