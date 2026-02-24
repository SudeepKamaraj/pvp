import 'package:get/get.dart';
import '../../../../data/models/cart_item_model.dart';
import '../../../../data/models/product_model.dart';

class CartController extends GetxController {
  var cartItems = <CartItemModel>[].obs;

  double get totalAmount => cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

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
    Get.snackbar("Added to Cart", "${product.name} (Size: $size) added to cart");
  }

  void removeFromCart(CartItemModel item) {
    cartItems.remove(item);
  }

  void incrementQuantity(CartItemModel item) {
    item.quantity++;
    cartItems.refresh();
  }

  void decrementQuantity(CartItemModel item) {
    if (item.quantity > 1) {
      item.quantity--;
      cartItems.refresh();
    } else {
      removeFromCart(item);
    }
  }

  void clearCart() {
    cartItems.clear();
  }
}
