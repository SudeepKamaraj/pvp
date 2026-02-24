import 'package:get/get.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/services/database_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class AdminOrderController extends GetxController {
  final DatabaseService _databaseService = DatabaseService();
  var orders = <OrderModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    isLoading.value = true;
    try {
      orders.value = await _databaseService.getAllOrders();
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch orders: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateOrderStatus(OrderModel order, String newStatus) async {
    try {
      await _databaseService.updateOrderStatus(order.id, newStatus);
      // Update local state
      final index = orders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        orders[index] = OrderModel(
          id: order.id,
          items: order.items,
          totalAmount: order.totalAmount,
          status: newStatus,
          date: order.date,
          address: order.address,
          city: order.city,
          zip: order.zip,
          userId: order.userId,
        );
        orders.refresh();
      }
      Get.snackbar("Success", "Order status updated");
    } catch (e) {
      Get.snackbar("Error", "Failed to update status");
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _databaseService.deleteOrder(orderId);
      orders.removeWhere((order) => order.id == orderId);
      Get.snackbar("Success", "Order deleted successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to delete order: $e");
    }
  }

  Future<void> downloadOrdersPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('PVP TRADERS - Order Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Text(DateFormat('dd MMM yyyy').format(DateTime.now())),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              context: context,
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              headerHeight: 25,
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerRight,
                3: pw.Alignment.center,
              },
              headers: ['Order ID', 'Date', 'Amount', 'Status'],
              data: orders.map((order) => [
                order.id.substring(0, 8).toUpperCase(),
                DateFormat('dd-MM-yyyy').format(order.date),
                'Rs. ${order.totalAmount.toStringAsFixed(0)}',
                order.status,
              ]).toList(),
            ),
             pw.Padding(padding: const pw.EdgeInsets.all(10)),
             pw.Row(
               mainAxisAlignment: pw.MainAxisAlignment.end,
               children: [
                 pw.Text(
                   'Total Revenue: Rs. ${orders.fold(0.0, (sum, item) => sum + item.totalAmount).toStringAsFixed(2)}',
                   style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)
                 )
               ]
             )
          ];
        },
      ),
    );

    // Print or Share the PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'PVP_Traders_Orders_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf'
    );
  }
}
