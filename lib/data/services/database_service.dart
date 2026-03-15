import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../models/review_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _normalizeCategoryKey(String category) {
    return category
        .trim()
        .toLowerCase()
        .replaceAll('.', '_')
        .replaceAll('/', '_')
        .replaceAll(' ', '_');
  }

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

  // Cart persistence
  Future<void> saveUserCart(String userId, List<CartItemModel> items) async {
    final cartRef = _db.collection('carts').doc(userId);

    await cartRef.set({
      'userId': userId,
      'items': items.map((item) => {
        'id': item.id,
        'productId': item.product.id,
        'productName': item.product.name,
        'selectedSize': item.selectedSize,
        'quantity': item.quantity,
        'category': item.product.category,
        'price': item.product.price,
        'offerPrice': item.product.offerPrice,
        'imageUrl': item.product.imageUrl,
        'images': item.product.images,
        'sizes': item.product.sizes,
        'colors': item.product.colors,
        'stockQuantity': item.product.stockQuantity,
        'rating': item.product.rating,
        'reviewCount': item.product.reviewCount,
        'orderCount': item.product.orderCount,
      }).toList(),
      'itemCount': items.fold<int>(0, (sum, item) => sum + item.quantity),
      'totalAmount': items.fold<double>(0, (sum, item) => sum + item.totalPrice),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<List<CartItemModel>> getUserCart(String userId) async {
    final snapshot = await _db.collection('carts').doc(userId).get();
    if (!snapshot.exists || snapshot.data() == null) {
      return [];
    }

    final data = snapshot.data()!;
    final rawItems = List<Map<String, dynamic>>.from(data['items'] ?? []);
    return rawItems.map(_mapStoredCartItem).toList();
  }

  Future<void> clearUserCart(String userId) async {
    await _db.collection('carts').doc(userId).delete();
  }

  CartItemModel _mapStoredCartItem(Map<String, dynamic> item) {
    return CartItemModel(
      id: item['id'] ?? '',
      product: ProductModel(
        id: item['productId'] ?? '',
        name: item['productName'] ?? '',
        category: item['category'] ?? '',
        price: (item['price'] as num? ?? 0).toDouble(),
        offerPrice: item['offerPrice'] != null ? (item['offerPrice'] as num).toDouble() : null,
        imageUrl: item['imageUrl'] ?? '',
        images: List<String>.from(item['images'] ?? []),
        sizes: List<String>.from(item['sizes'] ?? []),
        colors: List<String>.from(item['colors'] ?? []),
        stockQuantity: item['stockQuantity'] ?? 0,
        rating: (item['rating'] as num? ?? 0).toDouble(),
        reviewCount: item['reviewCount'] ?? 0,
        orderCount: item['orderCount'] ?? 0,
      ),
      selectedSize: item['selectedSize'] ?? '',
      quantity: item['quantity'] ?? 1,
    );
  }

  Future<void> maybeCreateAbandonedCartRecoveryNotification({
    required String userId,
    Duration inactivityThreshold = const Duration(hours: 6),
  }) async {
    try {
      final cartRef = _db.collection('carts').doc(userId);
      final cartDoc = await cartRef.get();
      if (!cartDoc.exists || cartDoc.data() == null) return;

      final cartData = cartDoc.data()!;
      final rawItems = List<Map<String, dynamic>>.from(cartData['items'] ?? []);
      if (rawItems.isEmpty) return;

      final updatedAt = (cartData['updatedAt'] as Timestamp?)?.toDate() ??
          (cartData['createdAt'] as Timestamp?)?.toDate();
      if (updatedAt == null) return;

      final now = DateTime.now();
      if (now.difference(updatedAt) < inactivityThreshold) return;

      final lastReminderAt = (cartData['lastReminderAt'] as Timestamp?)?.toDate();
      if (lastReminderAt != null && !lastReminderAt.isBefore(updatedAt)) {
        return;
      }

      final recentOrders = await getUserOrders(userId);
      if (recentOrders.any((order) => order.date.isAfter(updatedAt.subtract(const Duration(minutes: 5))))) {
        return;
      }

      final cartItems = rawItems.map(_mapStoredCartItem).toList();
      final primaryItem = cartItems.first;
      final recommendedProduct = await _findRecoveryRecommendation(cartItems);

      final title = 'Your cart is waiting';
      final body = recommendedProduct == null
          ? 'You left ${cartItems.length} item${cartItems.length == 1 ? '' : 's'} in your cart, including ${primaryItem.product.name}. Complete your order before it sells out.'
          : 'You left ${cartItems.length} item${cartItems.length == 1 ? '' : 's'} in your cart, including ${primaryItem.product.name}. Complete your order and you may also like ${recommendedProduct.name}.';

      await createNotification(
        userId: userId,
        title: title,
        body: body,
        type: 'abandoned_cart',
        data: {
          'cartItemCount': cartItems.length,
          'cartProductIds': cartItems.map((item) => item.product.id).toList(),
          'recommendedProductId': recommendedProduct?.id,
        },
      );

      await cartRef.set({
        'lastReminderAt': FieldValue.serverTimestamp(),
        'reminderCount': FieldValue.increment(1),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error creating abandoned cart reminder: $e');
    }
  }

  Future<ProductModel?> _findRecoveryRecommendation(List<CartItemModel> cartItems) async {
    final cartProductIds = cartItems.map((item) => item.product.id).toSet();
    final cartCategories = cartItems.map((item) => item.product.category.toLowerCase()).toSet();
    final preferredSizes = cartItems.map((item) => item.selectedSize.toUpperCase()).toSet();
    final averagePrice = cartItems.fold<double>(0, (sum, item) => sum + item.product.price) / cartItems.length;

    final products = await getProducts();
    ProductModel? bestProduct;
    double bestScore = -1;

    for (final product in products) {
      if (cartProductIds.contains(product.id) || product.stockQuantity <= 0) continue;

      final categoryScore = cartCategories.contains(product.category.toLowerCase()) ? 1.0 : 0.0;
      final sizeOverlap = product.sizes.where((size) => preferredSizes.contains(size.toUpperCase())).length;
      final sizeScore = preferredSizes.isEmpty ? 0.0 : (sizeOverlap / preferredSizes.length).clamp(0.0, 1.0);
      final trendScore = ((product.orderCount / 100).clamp(0.0, 1.0) * 0.5) +
          ((product.rating / 5).clamp(0.0, 1.0) * 0.3) +
          ((product.reviewCount / 200).clamp(0.0, 1.0) * 0.2);
      final priceDistance = averagePrice == 0 ? 1.0 : ((product.price - averagePrice).abs() / averagePrice);
      final priceScore = (1 - priceDistance).clamp(0.0, 1.0);

      final score = (categoryScore * 0.45) +
          (trendScore * 0.30) +
          (sizeScore * 0.15) +
          (priceScore * 0.10);

      if (score > bestScore) {
        bestScore = score;
        bestProduct = product;
      }
    }

    return bestProduct;
  }

  // Recommendation signals
  Future<void> trackProductView({
    required String userId,
    required ProductModel product,
  }) async {
    try {
      final userRef = _db.collection('users').doc(userId);
      final categoryKey = _normalizeCategoryKey(product.category);

      await userRef.set({
        'recentViewedProductIds': FieldValue.arrayUnion([product.id]),
        'recentViewedCategories': FieldValue.arrayUnion([product.category]),
        'lastViewedProductId': product.id,
        'lastViewedAt': FieldValue.serverTimestamp(),
        'categoryViewScore.$categoryKey': FieldValue.increment(1),
        'productViewScore.${product.id}': FieldValue.increment(1),
      }, SetOptions(merge: true));
    } catch (e) {
      // Recommendation telemetry should never block UX
      print('Error tracking product view: $e');
    }
  }

  Future<Map<String, dynamic>> getUserRecommendationSignals(String userId) async {
    try {
      final userDoc = await _db.collection('users').doc(userId).get();
      final data = userDoc.data() ?? <String, dynamic>{};

      final wishlistIds = List<String>.from(data['wishlist'] ?? []);
      final recentViewedProductIds = List<String>.from(data['recentViewedProductIds'] ?? []);
      final recentViewedCategories = List<String>.from(data['recentViewedCategories'] ?? []);

      final categoryViewRaw = Map<String, dynamic>.from(data['categoryViewScore'] ?? {});
      final categoryViewScore = <String, int>{
        for (final entry in categoryViewRaw.entries)
          entry.key: (entry.value as num?)?.toInt() ?? 0,
      };

      final productViewRaw = Map<String, dynamic>.from(data['productViewScore'] ?? {});
      final productViewScore = <String, int>{
        for (final entry in productViewRaw.entries)
          entry.key: (entry.value as num?)?.toInt() ?? 0,
      };

      return {
        'wishlistIds': wishlistIds,
        'recentViewedProductIds': recentViewedProductIds,
        'recentViewedCategories': recentViewedCategories,
        'categoryViewScore': categoryViewScore,
        'productViewScore': productViewScore,
      };
    } catch (e) {
      print('Error getting user recommendation signals: $e');
      return {
        'wishlistIds': <String>[],
        'recentViewedProductIds': <String>[],
        'recentViewedCategories': <String>[],
        'categoryViewScore': <String, int>{},
        'productViewScore': <String, int>{},
      };
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

  Future<void> deleteOffer() async {
    await _db.collection('offers').doc('current_offer').delete();
  }

  // Coupon validation and retrieval with user-specific one-time use check
  Future<Map<String, dynamic>?> validateCoupon(String code, String userId) async {
    try {
      print('🔍 Validating coupon code: $code for user: $userId');
      print('🔍 Uppercased code: ${code.toUpperCase()}');
      
      // Check if coupon exists, is active, and NOT used (query level filtering)
      final snapshot = await _db.collection('coupons')
          .where('code', isEqualTo: code.toUpperCase())
          .where('isActive', isEqualTo: true)
          .where('isUsed', isEqualTo: false)
          .limit(1)
          .get(const GetOptions(source: Source.server)); // Force server read to avoid cache
      
      print('🔍 Query completed. Docs found: ${snapshot.docs.length}');
      
      if (snapshot.docs.isEmpty) {
        // Check if coupon exists but is used
        final usedCheck = await _db.collection('coupons')
            .where('code', isEqualTo: code.toUpperCase())
            .limit(1)
            .get(const GetOptions(source: Source.server));
        
        if (usedCheck.docs.isNotEmpty) {
          final data = usedCheck.docs.first.data();
          if (data['isUsed'] == true) {
            print('❌ Coupon has already been used');
            return {'error': 'already_used', 'message': 'This coupon code has already been used'};
          } else if (data['isActive'] != true) {
            print('❌ Coupon is not active');
            return null;
          }
        }
        
        print('❌ No matching coupon found');
        return null;
      }
      
      final couponData = snapshot.docs.first.data();
      print('✅ Coupon found: $couponData');
      
      // Check if coupon belongs to this user (for personalized coupons)
      final couponUserId = couponData['userId'];
      if (couponUserId != null && couponUserId != userId) {
        print('❌ Coupon does not belong to this user');
        return {'error': 'invalid', 'message': 'This coupon code is not valid for your account'};
      }
      
      print('✅ Coupon is valid and unused');
      return couponData;
    } catch (e) {
      print('❌ Error validating coupon: $e');
      return null;
    }
  }

  // Mark coupon as used (both in coupon_usage collection and mark coupon as used)
  Future<void> markCouponAsUsed(String couponCode, String userId, String orderId) async {
    try {
      // Add usage record
      await _db.collection('coupon_usage').add({
        'userId': userId,
        'couponCode': couponCode.toUpperCase(),
        'orderId': orderId,
        'usedAt': FieldValue.serverTimestamp(),
      });
      
      // Mark the coupon as used in the coupons collection
      final couponSnapshot = await _db.collection('coupons')
          .where('code', isEqualTo: couponCode.toUpperCase())
          .limit(1)
          .get();
      
      if (couponSnapshot.docs.isNotEmpty) {
        await couponSnapshot.docs.first.reference.update({
          'isUsed': true,
          'usedBy': userId,
          'usedAt': FieldValue.serverTimestamp(),
        });
      }
      
      print('✅ Coupon marked as used: $couponCode by user: $userId');
    } catch (e) {
      print('❌ Error marking coupon as used: $e');
      throw e;
    }
  }

  // Check if user has used a specific coupon
  Future<bool> hasUserUsedCoupon(String couponCode, String userId) async {
    try {
      final snapshot = await _db.collection('coupon_usage')
          .where('userId', isEqualTo: userId)
          .where('couponCode', isEqualTo: couponCode.toUpperCase())
          .limit(1)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ Error checking coupon usage: $e');
      return false;
    }
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
    final now = Timestamp.now();
    await _db.collection('notifications').add({
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'isRead': false,
      'timestamp': now,
      'createdAt': FieldValue.serverTimestamp(),
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
    
    // Use current timestamp to avoid null values in orderBy
    final now = Timestamp.now();
    
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
        'timestamp': now,
        'createdAt': FieldValue.serverTimestamp(), // Keep server timestamp for accuracy
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
