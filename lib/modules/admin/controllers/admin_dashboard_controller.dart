import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/services/database_service.dart';

class AdminDashboardController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final DatabaseService _databaseService = DatabaseService();

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
      // Create the offer
      await _db.collection('offers').doc('current_offer').set({
        'title': title,
        'description': description,
        'discount': discount,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Generate unique coupon codes for each user
      try {
        // Get all users (exclude admins)
        final usersSnapshot = await _db.collection('users')
            .where('role', isEqualTo: 'customer')
            .get();
        
        final batch = _db.batch();
        int couponsCreated = 0;
        
        for (var userDoc in usersSnapshot.docs) {
          final userId = userDoc.id;
          // Generate unique code for this user (e.g., PVP50-ABC123)
          final uniqueCode = 'PVP${discount.toStringAsFixed(0)}-${userId.substring(0, 6).toUpperCase()}';
          
          // Check if user already has a coupon for this offer
          final existingCoupon = await _db.collection('coupons')
              .where('userId', isEqualTo: userId)
              .where('offerId', isEqualTo: 'current_offer')
              .limit(1)
              .get();
          
          if (existingCoupon.docs.isEmpty) {
            // Create new unique coupon for this user
            final couponRef = _db.collection('coupons').doc();
            batch.set(couponRef, {
              'code': uniqueCode,
              'userId': userId,
              'offerId': 'current_offer',
              'discount': discount,
              'isActive': true,
              'isUsed': false,
              'createdAt': FieldValue.serverTimestamp(),
              'autoGenerated': true,
            });
            couponsCreated++;
          } else {
            // Reactivate existing coupon
            batch.update(existingCoupon.docs.first.reference, {
              'isActive': true,
              'isUsed': false,
              'discount': discount,
            });
            couponsCreated++;
          }
        }
        
        await batch.commit();
        print('✅ Created/updated $couponsCreated unique coupon codes');
      } catch (couponError) {
        print('⚠️ Failed to create/update coupons: $couponError');
        // Continue even if coupon creation fails
      }
      
      // Send personalized push notification to each user with their unique coupon code
      try {
        // Get all customer users again with their coupon codes
        final usersSnapshot = await _db.collection('users')
            .where('role', isEqualTo: 'customer')
            .get();
        
        for (var userDoc in usersSnapshot.docs) {
          final userId = userDoc.id;
          
          // Get this user's coupon code
          final couponSnapshot = await _db.collection('coupons')
              .where('userId', isEqualTo: userId)
              .where('offerId', isEqualTo: 'current_offer')
              .where('isActive', isEqualTo: true)
              .limit(1)
              .get();
          
          if (couponSnapshot.docs.isNotEmpty) {
            final couponCode = couponSnapshot.docs.first.data()['code'] as String;
            
            // Create personalized notification with coupon code
            await _databaseService.createNotification(
              userId: userId,
              title: '🎉 New Offer: $title',
              body: '$discount% OFF! $description',
              type: 'offer',
              data: {
                'couponCode': couponCode,
                'discount': discount,
                'offerTitle': title,
                'offerDescription': description,
              },
            );
          }
        }
      } catch (notifError) {
        print('Failed to send notifications: $notifError');
      }
      
      Get.snackbar("Success", "Offer posted successfully! Unique coupon codes generated for all customers.");
    } catch (e) {
      Get.snackbar("Error", "Failed to create offer: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteOffer() async {
    isLoading.value = true;
    try {
      // Delete the offer
      await _databaseService.deleteOffer();
      
      // Deactivate all personalized coupons associated with this offer
      try {
        final coupons = await _db.collection('coupons')
            .where('offerId', isEqualTo: 'current_offer')
            .where('autoGenerated', isEqualTo: true)
            .get();
        
        final batch = _db.batch();
        for (var doc in coupons.docs) {
          batch.update(doc.reference, {'isActive': false});
        }
        await batch.commit();
        
        print('✅ Deactivated ${coupons.docs.length} personalized coupons');
      } catch (couponError) {
        print('⚠️ Failed to deactivate coupons: $couponError');
      }
      
      Get.snackbar("Success", "Offer deleted successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to delete offer: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> getCurrentOffer() async {
    try {
      return await _databaseService.getCurrentOffer();
    } catch (e) {
      print('Error fetching current offer: $e');
      return null;
    }
  }


  Future<Map<String, dynamic>> calculateProfit() async {
    try {
      print("DEBUG: Starting profit calculation...");
      
      // Get all delivered orders
      QuerySnapshot ordersSnapshot = await _db.collection('orders')
          .where('status', isEqualTo: 'Delivered')
          .get();
      
      print("DEBUG: Found ${ordersSnapshot.docs.length} delivered orders");
      
      // Create a map to track sales per product
      Map<String, int> productSales = {};
      
      for (var orderDoc in ordersSnapshot.docs) {
        final orderData = orderDoc.data() as Map<String, dynamic>;
        final items = orderData['items'] as List<dynamic>? ?? [];
        
        print("DEBUG: Order ${orderDoc.id} has ${items.length} items");
        
        for (var item in items) {
          String productId = item['productId'] ?? '';
          int quantity = item['quantity'] ?? 0;
          
          print("DEBUG: Item productId: $productId, quantity: $quantity");
          
          if (productId.isNotEmpty) {
            productSales[productId] = (productSales[productId] ?? 0) + quantity;
          }
        }
      }
      
      print("DEBUG: Product sales map: $productSales");
      
      // Now calculate profit based on actual sales
      QuerySnapshot productsSnapshot = await _db.collection('products').get();
      print("DEBUG: Found ${productsSnapshot.docs.length} products");
      
      double totalProfit = 0;
      double totalRevenue = 0;
      double totalCost = 0;
      int profitableProducts = 0;
      int productsWithBuyingPrice = 0;
      List<Map<String, dynamic>> topProfitProducts = [];
      
      for (var doc in productsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        String productId = doc.id;
        String productName = data['name'] ?? 'Unknown';
        double regularPrice = (data['price'] ?? 0).toDouble();
        double? offerPrice = data['offerPrice'] != null ? (data['offerPrice']).toDouble() : null;
        double sellingPrice = (offerPrice != null && offerPrice > 0) ? offerPrice : regularPrice;
        double? buyingPrice = data['buyingPrice'] != null ? (data['buyingPrice']).toDouble() : null;
        
        print("DEBUG: Product $productName - Selling: ₹$sellingPrice, Buying: ₹$buyingPrice");
        
        if (buyingPrice != null) {
          productsWithBuyingPrice++;
        }
        
        // Get actual sold units from delivered orders
        int soldUnits = productSales[productId] ?? 0;
        
        print("DEBUG: Product $productName sold $soldUnits units");
        
        if (buyingPrice != null && soldUnits > 0) {
          double profitPerUnit = sellingPrice - buyingPrice;
          double totalProductProfit = profitPerUnit * soldUnits;
          
          print("DEBUG: Product $productName profit: ₹$totalProductProfit (₹$profitPerUnit per unit x $soldUnits units)");
          
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
      
      print("DEBUG: Total Profit: ₹$totalProfit");
      print("DEBUG: Total Revenue: ₹$totalRevenue");
      print("DEBUG: Total Cost: ₹$totalCost");
      print("DEBUG: Products with buying price: $productsWithBuyingPrice");
      print("DEBUG: Profitable products (sold): $profitableProducts");
      
      // Sort by profit descending
      topProfitProducts.sort((a, b) => (b['profit'] as double).compareTo(a['profit'] as double));
      
      return {
        'totalProfit': totalProfit,
        'totalRevenue': totalRevenue,
        'totalCost': totalCost,
        'profitMargin': totalRevenue > 0 ? (totalProfit / totalRevenue * 100) : 0,
        'profitableProducts': profitableProducts,
        'productsWithBuyingPrice': productsWithBuyingPrice,
        'deliveredOrders': ordersSnapshot.docs.length,
        'topProducts': topProfitProducts.take(5).toList(),
      };
    } catch (e) {
      print("ERROR calculating profit: $e");
      return {
        'totalProfit': 0.0,
        'totalRevenue': 0.0,
        'totalCost': 0.0,
        'profitMargin': 0.0,
        'profitableProducts': 0,
        'productsWithBuyingPrice': 0,
        'deliveredOrders': 0,
        'topProducts': [],
      };
    }
  }
}
