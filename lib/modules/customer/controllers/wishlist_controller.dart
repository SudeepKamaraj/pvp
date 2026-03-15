import 'package:get/get.dart';
import '../../../../data/models/product_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../data/services/database_service.dart';
import './home_controller.dart';

class WishlistController extends GetxController {
  final DatabaseService _databaseService = DatabaseService();
  var wishlistItems = <ProductModel>[].obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    _loadWishlistFromFirestore();
  }

  void _loadWishlistFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final wishlistIds = await _databaseService.getWishlist(user.uid);
      if (wishlistIds.isEmpty) return;

      // Fetch all products and filter locally for those in wishlist
      // In a larger app, we'd fetch only specific IDs from Firestore
      final allProducts = await _databaseService.getProducts();
      wishlistItems.assignAll(allProducts.where((p) => wishlistIds.contains(p.id)));
    } catch (e) {
      print("Error loading wishlist: $e");
    }
  }

  void toggleWishlist(ProductModel product) async {
    final user = _auth.currentUser;
    if (user == null) {
      Get.snackbar("Error", "Please login to manage wishlist");
      return;
    }

    if (isInWishlist(product)) {
      wishlistItems.removeWhere((item) => item.id == product.id);
      await _databaseService.toggleWishlist(user.uid, product.id, false);
      Get.snackbar("Removed", "${product.name} removed from wishlist");
    } else {
      wishlistItems.add(product);
      await _databaseService.toggleWishlist(user.uid, product.id, true);
      Get.snackbar("Added", "${product.name} added to wishlist");
    }

    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().refreshPersonalizedFeedFromCurrentProducts();
    }
  }

  bool isInWishlist(ProductModel product) {
    return wishlistItems.any((item) => item.id == product.id);
  }
}
