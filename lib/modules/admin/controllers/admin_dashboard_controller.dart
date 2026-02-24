import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminDashboardController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  var totalOrders = "0".obs;
  var totalRevenue = "₹0.0k".obs;
  var totalProducts = "0".obs;
  var totalCustomers = "0".obs;
  var adminName = "Admin".obs;
  var weeklySales = <double>[0, 0, 0, 0, 0, 0, 0].obs; // Sun to Sat
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStats();
    fetchAdminInfo();
  }

  void fetchAdminInfo() async {
    try {
      final String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          adminName.value = data['fullName'] ?? data['name'] ?? "Admin";
        }
      }
    } catch (e) {
      print("Error fetching admin info: $e");
    }
  }

  void fetchStats() async {
    isLoading.value = true;
    try {
      // 1. Products
      QuerySnapshot productsSnapshot = await _db.collection('products').get();
      totalProducts.value = productsSnapshot.size.toString();

      // 2. Orders & Revenue
      QuerySnapshot ordersSnapshot = await _db.collection('orders').get();
      totalOrders.value = ordersSnapshot.size.toString();
      
      double revenue = 0;
      List<double> tempWeekly = [0, 0, 0, 0, 0, 0, 0];
      
      for (var doc in ordersSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        String status = data['status'] ?? 'pending';
        
        // Only count Delivered/Processing/Pending orders as Revenue (ignore Cancelled)
        if (status.toLowerCase() != 'cancelled') {
          if (data.containsKey('totalAmount') && data['totalAmount'] != null) {
            double amount = (data['totalAmount'] as num).toDouble();
            revenue += amount;
            
            // For Chart: Group by day of week
            final dynamic dateField = data['date'] ?? data['createdAt'];
            if (dateField != null) {
              DateTime date;
              if (dateField is Timestamp) {
                date = dateField.toDate();
              } else {
                try {
                  date = DateTime.parse(dateField.toString());
                } catch (e) {
                  date = DateTime.now();
                }
              }

              // Calculate how many days ago this order was
              final difference = DateTime.now().difference(date).inDays;
              if (difference <= 7) {
                int day = date.weekday % 7; // 0 for Sun, 1-6 for Mon-Sat
                tempWeekly[day] += amount;
              }
            }
          }
        }
      }
      
      weeklySales.value = tempWeekly;
      
      if (revenue >= 1000) {
        totalRevenue.value = "₹${(revenue / 1000).toStringAsFixed(1)}k";
      } else {
        totalRevenue.value = "₹${revenue.toStringAsFixed(0)}";
      }

      // 3. Customers
      QuerySnapshot usersSnapshot = await _db.collection('users')
          .where('role', isEqualTo: 'customer')
          .get();
      totalCustomers.value = usersSnapshot.size.toString();
      
    } catch (e) {
      print("Error fetching dashboard stats: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createOffer(String title, String description, double discount) async {
    isLoading.value = true;
    try {
      await _db.collection('offers').doc('current_offer').set({
        'title': title,
        'description': description,
        'discount': discount,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      Get.snackbar("Success", "Offer posted successfully! Customers will see it now.");
    } catch (e) {
      Get.snackbar("Error", "Failed to create offer: $e");
    } finally {
      isLoading.value = false;
    }
  }


  Future<Map<String, dynamic>> calculateProfit() async {
    try {
      // Get all delivered orders
      QuerySnapshot ordersSnapshot = await _db.collection('orders')
          .where('status', isEqualTo: 'Delivered')
          .get();
      
      // Create a map to track sales per product
      Map<String, int> productSales = {};
      
      for (var orderDoc in ordersSnapshot.docs) {
        final orderData = orderDoc.data() as Map<String, dynamic>;
        final items = orderData['items'] as List<dynamic>? ?? [];
        
        for (var item in items) {
          String productId = item['productId'] ?? '';
          int quantity = item['quantity'] ?? 0;
          
          if (productId.isNotEmpty) {
            productSales[productId] = (productSales[productId] ?? 0) + quantity;
          }
        }
      }
      
      // Now calculate profit based on actual sales
      QuerySnapshot productsSnapshot = await _db.collection('products').get();
      
      double totalProfit = 0;
      double totalRevenue = 0;
      double totalCost = 0;
      int profitableProducts = 0;
      List<Map<String, dynamic>> topProfitProducts = [];
      
      for (var doc in productsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        String productId = doc.id;
        double regularPrice = (data['price'] ?? 0).toDouble();
        double? offerPrice = data['offerPrice'] != null ? (data['offerPrice']).toDouble() : null;
        // Use offer price if available and greater than 0, otherwise use regular price
        double sellingPrice = (offerPrice != null && offerPrice > 0) ? offerPrice : regularPrice;
        double? buyingPrice = data['buyingPrice'] != null ? (data['buyingPrice']).toDouble() : null;
        String productName = data['name'] ?? 'Unknown';
        
        // Get actual sold units from delivered orders
        int soldUnits = productSales[productId] ?? 0;
        
        if (buyingPrice != null && buyingPrice > 0 && soldUnits > 0) {
          double profitPerUnit = sellingPrice - buyingPrice;
          double totalProductProfit = profitPerUnit * soldUnits;
          
          totalProfit += totalProductProfit;
          totalRevenue += sellingPrice * soldUnits;
          totalCost += buyingPrice * soldUnits;
          
          if (profitPerUnit > 0) {
            profitableProducts++;
            topProfitProducts.add({
              'name': productName,
              'profit': totalProductProfit,
              'profitPerUnit': profitPerUnit,
              'soldUnits': soldUnits,
            });
          }
        }
      }
      
      // Sort by profit descending
      topProfitProducts.sort((a, b) => (b['profit'] as double).compareTo(a['profit'] as double));
      
      return {
        'totalProfit': totalProfit,
        'totalRevenue': totalRevenue,
        'totalCost': totalCost,
        'profitMargin': totalRevenue > 0 ? (totalProfit / totalRevenue * 100) : 0,
        'profitableProducts': profitableProducts,
        'topProducts': topProfitProducts.take(5).toList(),
      };
    } catch (e) {
      print("Error calculating profit: $e");
      return {
        'totalProfit': 0.0,
        'totalRevenue': 0.0,
        'totalCost': 0.0,
        'profitMargin': 0.0,
        'profitableProducts': 0,
        'topProducts': [],
      };
    }
  }
}
