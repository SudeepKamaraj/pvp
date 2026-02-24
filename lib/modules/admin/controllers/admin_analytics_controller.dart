import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAnalyticsController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  var totalRevenue = 0.0.obs;
  var revenueGrowth = 0.0.obs; // Percentage
  var conversionRate = 3.42.obs; // Mock for now
  var repeatCustomers = 22.8.obs; // Percentage
  var topSellingProducts = <Map<String, dynamic>>[].obs;
  
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAnalytics();
  }

  void fetchAnalytics() async {
    isLoading.value = true;
    try {
      QuerySnapshot ordersSnapshot = await _db.collection('orders').get();
      
      double revenue = 0;
      double revenueToday = 0;
      double revenueYesterday = 0;
      
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime yesterday = today.subtract(const Duration(days: 1));

      Map<String, Map<String, dynamic>> productStats = {};

      for (var doc in ordersSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        double amount = (data['totalAmount'] as num).toDouble();
        revenue += amount;

        // Date logic
        DateTime orderDate = DateTime.parse(data['date']);
        if (orderDate.isAfter(today)) {
          revenueToday += amount;
        } else if (orderDate.isAfter(yesterday) && orderDate.isBefore(today)) {
          revenueYesterday += amount;
        }
        
        // Product Sales for Top Selling
        if (data.containsKey('items')) {
           List items = data['items'];
           for (var item in items) {
             String prodName = item['productName'];
             int qty = item['quantity'];
             double price = (item['price'] as num).toDouble();
             
             if (!productStats.containsKey(prodName)) {
               productStats[prodName] = {'sold': 0, 'revenue': 0.0};
             }
             
             productStats[prodName]!['sold'] += qty;
             productStats[prodName]!['revenue'] += (qty * price);
           }
        }
      }
      totalRevenue.value = revenue;

      // 2. Growth Logic
      if (revenueYesterday > 0) {
        revenueGrowth.value = ((revenueToday - revenueYesterday) / revenueYesterday) * 100;
      } else if (revenueToday > 0) {
        revenueGrowth.value = 100.0;
      } else {
        revenueGrowth.value = 0.0;
      }

      // 3. Top Selling Products
      var sortedKeys = productStats.keys.toList()
        ..sort((k1, k2) => productStats[k2]!['sold'].compareTo(productStats[k1]!['sold']));
      
      topSellingProducts.clear();
      for (var key in sortedKeys.take(5)) {
        topSellingProducts.add({
          'name': key,
          'sold': productStats[key]!['sold'],
          'revenue': productStats[key]!['revenue'],
        });
      }

    } catch (e) {
      print("Error fetching analytics: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
