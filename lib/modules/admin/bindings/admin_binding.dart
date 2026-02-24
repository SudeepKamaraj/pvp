import 'package:get/get.dart';
import '../controllers/admin_marketing_controller.dart';
import '../controllers/admin_category_controller.dart';
import '../controllers/admin_order_controller.dart';
import '../views/admin_customers_screen.dart'; 
import '../controllers/admin_analytics_controller.dart';
import '../controllers/admin_product_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AdminAnalyticsController());
    Get.lazyPut(() => AdminMarketingController());
    Get.lazyPut(() => AdminCategoryController());
    Get.lazyPut(() => AdminOrderController());
    Get.lazyPut(() => AdminCustomersController());
    Get.lazyPut(() => AdminProductController());
  }
}
