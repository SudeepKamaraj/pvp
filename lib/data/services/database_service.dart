import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../models/review_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Products
  Future<List<ProductModel>> getProducts() async {
    final snapshot = await _db.collection('products').get();
    return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc.data(), doc.id)).toList();
  }

  Future<List<ProductModel>> getTrendingProducts() async {
    // Sort by orderCount descending to show most popular products first
    final snapshot = await _db.collection('products')
        .orderBy('orderCount', descending: true)
        .limit(10)
        .get();
    return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc.data(), doc.id)).toList();
  }

  Future<List<ProductModel>> getProductsByCategory(String category) async {
    // Firestore queries are case-sensitive, so we need to handle this carefully
    // We'll fetch all products and filter in memory for case-insensitive matching
    final snapshot = await _db.collection('products').get();
    final allProducts = snapshot.docs.map((doc) => ProductModel.fromFirestore(doc.data(), doc.id)).toList();
    
    // Filter by category (case-insensitive)
    return allProducts.where((product) => 
      product.category.toLowerCase() == category.toLowerCase()
    ).toList();
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final snapshot = await _db.collection('categories').get();
    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc = await _db.collection('products').doc(productId).get();
      if (doc.exists && doc.data() != null) {
        return ProductModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error fetching product by ID: $e');
      return null;
    }
  }

  // Orders
  Future<void> createOrder(OrderModel order) async {
    await _db.collection('orders').doc(order.id).set({
      'userId': order.userId ?? 'unknown',
      'totalAmount': order.totalAmount,
      'status': order.status,
      'date': order.date.toIso8601String(),
      'address': order.address,
      'city': order.city,
      'zip': order.zip,
      'phone': order.phone,
      'paymentMethod': order.paymentMethod,
      'paymentId': order.paymentId,
      'razorpayOrderId': order.razorpayOrderId,
      'razorpaySignature': order.razorpaySignature,
      'items': order.items.map((item) => {
        'productId': item.product.id,
        'productName': item.product.name,
        'quantity': item.quantity,
        'size': item.selectedSize,
        'price': item.product.price,
        'imageUrl': item.product.imageUrl,
        'images': item.product.images, // Add images array
        'category': item.product.category,
      }).toList(),
    });

    // Try to increment orderCount for each product (non-blocking)
    // This may fail for regular users due to permissions, but shouldn't block order creation
    try {
      for (final item in order.items) {
        await _db.collection('products').doc(item.product.id).update({
          'orderCount': FieldValue.increment(item.quantity)
        });
      }
    } catch (e) {
      // Silently fail - orderCount update is not critical for order placement
      print('Note: Could not update product orderCount (this is normal for non-admin users): $e');
    }
  }

  // Admin: Product Management
  Future<void> addProduct(ProductModel product) async {
    final docRef = _db.collection('products').doc();
    final data = product.toFirestore();
    data['createdAt'] = FieldValue.serverTimestamp();
    await docRef.set(data);
  }

  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }

  Future<void> updateProduct(ProductModel product) async {
    final data = product.toFirestore();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection('products').doc(product.id).update(data);
  }

  // Orders
  Future<List<OrderModel>> getUserOrders(String userId) async {
    final snapshot = await _db.collection('orders')
        .where('userId', isEqualTo: userId)
        .get();
        
    final orders = snapshot.docs.map((doc) => _mapDocToOrder(doc)).toList();
    // Sort in-memory: descending by date
    orders.sort((a, b) => b.date.compareTo(a.date));
    return orders;
  }

  Future<List<OrderModel>> getAllOrders() async {
    final snapshot = await _db.collection('orders')
        .orderBy('date', descending: true)
        .get();
        
    return snapshot.docs.map((doc) => _mapDocToOrder(doc)).toList();
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _db.collection('orders').doc(orderId).update({'status': newStatus});
  }

  Future<void> deleteOrder(String orderId) async {
    await _db.collection('orders').doc(orderId).delete();
  }

  OrderModel _mapDocToOrder(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      items: (data['items'] as List<dynamic>).map((item) => CartItemModel(
        id: '', 
        product: ProductModel(
          id: item['productId'],
          name: item['productName'],
          category: item['category'] ?? '', 
          price: (item['price'] as num).toDouble(),
          imageUrl: item['imageUrl'] ?? '', 
          images: item['images'] != null ? List<String>.from(item['images']) : [], // Add images array
          rating: 0.0,
          isTrending: false,
        ),
        selectedSize: item['size'],
        quantity: item['quantity'],
      )).toList(),
      totalAmount: (data['totalAmount'] as num).toDouble(),
      status: data['status'],
      date: DateTime.parse(data['date'] as String),
      address: data['address'],
      city: data['city'],
      zip: data['zip'],
      userId: data['userId'],
      paymentMethod: data['paymentMethod'],
      paymentId: data['paymentId'],
      razorpayOrderId: data['razorpayOrderId'],
      razorpaySignature: data['razorpaySignature'],
    );
  }

  ProductModel _mapDocToProduct(DocumentSnapshot doc) {
    return ProductModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
  }

  // Wishlist
  Future<List<String>> getWishlist(String userId) {
    return _db.collection('users').doc(userId).get().then((snapshot) {
      if (snapshot.exists && snapshot.data() != null && snapshot.data()!.containsKey('wishlist')) {
        return List<String>.from(snapshot.data()!['wishlist']);
      }
      return [];
    });
  }

  Future<void> toggleWishlist(String userId, String productId, bool add) async {
    if (add) {
      await _db.collection('users').doc(userId).update({
        'wishlist': FieldValue.arrayUnion([productId])
      });
    } else {
      await _db.collection('users').doc(userId).update({
        'wishlist': FieldValue.arrayRemove([productId])
      });
    }
  }

  // App Settings
  Future<Map<String, dynamic>> getAppSettings() async {
    final doc = await _db.collection('settings').doc('app_config').get();
    if (doc.exists) {
      return doc.data()!;
    }
    return {
      'currency': 'INR (₹)',
      'taxRate': 12.5,
      'isMaintenanceMode': false,
      'twoFactorAuth': false,
    };
  }

  Future<void> updateAppSettings(Map<String, dynamic> settings) async {
    await _db.collection('settings').doc('app_config').set(settings, SetOptions(merge: true));
  }

  // Wallet
  Future<Map<String, dynamic>> getWalletData(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      return {
        'balance': (data['walletBalance'] ?? 0.0).toDouble(),
        'points': data['rewardPoints'] ?? 0,
      };
    }
    return {'balance': 0.0, 'points': 0};
  }

  // Shipping Addresses
  Future<List<Map<String, dynamic>>> getShippingAddresses(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists && doc.data() != null && doc.data()!.containsKey('addresses')) {
      return List<Map<String, dynamic>>.from(doc.data()!['addresses']);
    }
    return [];
  }

  Future<void> addShippingAddress(String userId, Map<String, dynamic> address) async {
    await _db.collection('users').doc(userId).update({
      'addresses': FieldValue.arrayUnion([address])
    });
  }

  Future<void> deleteShippingAddress(String userId, Map<String, dynamic> address) async {
    await _db.collection('users').doc(userId).update({
      'addresses': FieldValue.arrayRemove([address])
    });
  }

  // Offers & Promotions
  Future<void> setCurrentOffer(String title, String description, double discount) async {
    await _db.collection('offers').doc('current_offer').set({
      'title': title,
      'description': description,
      'discount': discount,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> getCurrentOffer() async {
    final doc = await _db.collection('offers').doc('current_offer').get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      // Optional: Check if offer is expired or inactive
      if (data['isActive'] == true) {
        return data;
      }
    }
    return null;
  }

  // Reviews
  Future<void> addReview(ReviewModel review) async {
    final reviewRef = _db.collection('products').doc(review.productId).collection('reviews').doc(review.id);
    final productRef = _db.collection('products').doc(review.productId);
    
    // Get user name if not provided
    String userName = review.userName;
    if (userName == 'Anonymous' || userName.isEmpty) {
      final userDoc = await _db.collection('users').doc(review.userId).get();
      if (userDoc.exists) {
        userName = userDoc.data()?['fullName'] ?? 'Anonymous';
      }
    }

    final reviewData = review.toMap();
    reviewData['userName'] = userName; // Ensure name is saved

    return _db.runTransaction((transaction) async {
      final productDoc = await transaction.get(productRef);
      if (!productDoc.exists) throw Exception("Product not found");

      final currentRating = (productDoc.data()?['rating'] ?? 0).toDouble();
      final currentReviewCount = (productDoc.data()?['reviewCount'] ?? 0) as int;

      // Calculate new average
      final newReviewCount = currentReviewCount + 1;
      final newRating = ((currentRating * currentReviewCount) + review.rating) / newReviewCount;

      transaction.set(reviewRef, reviewData);
      transaction.update(productRef, {
        'rating': newRating,
        'reviewCount': newReviewCount,
      });
    });
  }

  Future<List<ReviewModel>> getReviewsForProduct(String productId) async {
    final snapshot = await _db.collection('products')
        .doc(productId)
        .collection('reviews')
        .orderBy('date', descending: true)
        .get();
    
    return snapshot.docs.map((doc) => ReviewModel.fromMap(doc.data(), doc.id)).toList();
  }

  Future<bool> hasUserReviewedProduct(String userId, String productId) async {
    final snapshot = await _db.collection('products')
        .doc(productId)
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  // Notifications
  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    String type = 'general',
    Map<String, dynamic>? data,
  }) async {
    await _db.collection('notifications').add({
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'isRead': false,
      'timestamp': FieldValue.serverTimestamp(),
      'data': data ?? {},
    });
  }

  Future<void> createNotificationForAllUsers({
    required String title,
    required String body,
    String type = 'general',
  }) async {
    // Get all users
    final usersSnapshot = await _db.collection('users').get();
    
    // Create notification for each user
    final batch = _db.batch();
    for (var userDoc in usersSnapshot.docs) {
      final notificationRef = _db.collection('notifications').doc();
      batch.set(notificationRef, {
        'userId': userDoc.id,
        'title': title,
        'body': body,
        'type': type,
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
    
    await batch.commit();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    final notifications = await _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _db.batch();
    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
