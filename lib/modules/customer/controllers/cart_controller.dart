import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../../data/models/cart_item_model.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/services/database_service.dart';

class CartController extends GetxController {
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var cartItems = <CartItemModel>[].obs;
  StreamSubscription<User?>? _authSubscription;
  bool _isRestoringCart = false;

  double get totalAmount => cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  @override
  void onInit() {
    super.onInit();
    _authSubscription = _auth.authStateChanges().listen(_handleAuthStateChanged);
    _handleAuthStateChanged(_auth.currentUser);
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  Future<void> _handleAuthStateChanged(User? user) async {
    if (user == null) {
      cartItems.clear();
      return;
    }

    await _restoreCartForUser(user.uid);
  }

  Future<void> _restoreCartForUser(String userId) async {
    _isRestoringCart = true;
    try {
      final storedCart = await _databaseService.getUserCart(userId);

      if (storedCart.isNotEmpty) {
        cartItems.assignAll(storedCart);
      } else if (cartItems.isNotEmpty) {
        await _persistCart();
      }
    } finally {
      _isRestoringCart = false;
    }
  }

  Future<void> _persistCart() async {
    if (_isRestoringCart) return;

    final user = _auth.currentUser;
    if (user == null) return;

    if (cartItems.isEmpty) {
      await _databaseService.clearUserCart(user.uid);
      return;
    }

    await _databaseService.saveUserCart(user.uid, cartItems.toList());
  }

  Future<void> checkAbandonedCartRecovery() async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (!_isRestoringCart) {
      await _restoreCartForUser(user.uid);
    }

    await _databaseService.maybeCreateAbandonedCartRecoveryNotification(
      userId: user.uid,
    );
  }

  void addToCart(ProductModel product, String size) {
    // Check if item already exists
    final index = cartItems.indexWhere((item) => item.product.id == product.id && item.selectedSize == size);

    if (index != -1) {
      // Increment quantity
      cartItems[index].quantity++;
      cartItems.refresh();
    } else {
      // Add new item
      cartItems.add(CartItemModel(
        id: DateTime.now().toString(), // Simple ID generation
        product: product,
        selectedSize: size,
      ));
    }
    _persistCart();
    Get.snackbar("Added to Cart", "${product.name} (Size: $size) added to cart");
  }

  void removeFromCart(CartItemModel item) {
    cartItems.remove(item);
    _persistCart();
  }

  void incrementQuantity(CartItemModel item) {
    item.quantity++;
    cartItems.refresh();
    _persistCart();
  }

  void decrementQuantity(CartItemModel item) {
    if (item.quantity > 1) {
      item.quantity--;
      cartItems.refresh();
      _persistCart();
    } else {
      removeFromCart(item);
    }
  }

  void clearCart() {
    cartItems.clear();
    _persistCart();
  }
}
