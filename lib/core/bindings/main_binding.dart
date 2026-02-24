import 'package:get/get.dart';
import '../../modules/customer/controllers/home_controller.dart';
import '../../modules/customer/controllers/cart_controller.dart';
import '../../modules/customer/controllers/wishlist_controller.dart';
import '../../modules/customer/controllers/profile_controller.dart';
import '../../modules/customer/controllers/customer_order_controller.dart';
import '../../modules/admin/controllers/admin_product_controller.dart';
import '../../modules/admin/controllers/admin_dashboard_controller.dart';
import '../../modules/admin/controllers/admin_order_controller.dart';
import '../../modules/admin/controllers/admin_settings_controller.dart';
import '../../modules/customer/controllers/settings_controller.dart';
import '../../modules/auth/controllers/login_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController(), fenix: true);
    Get.lazyPut(() => HomeController(), fenix: true);
    Get.lazyPut(() => SettingsController(), fenix: true);
    Get.lazyPut(() => CartController(), fenix: true);
    Get.lazyPut(() => WishlistController(), fenix: true);
    Get.lazyPut(() => ProfileController(), fenix: true);
    Get.lazyPut(() => CustomerOrderController(), fenix: true);
    Get.lazyPut(() => AdminProductController(), fenix: true);
    Get.lazyPut(() => AdminDashboardController(), fenix: true);
    Get.lazyPut(() => AdminOrderController(), fenix: true);
    Get.lazyPut(() => AdminSettingsController(), fenix: true);
  }
}
