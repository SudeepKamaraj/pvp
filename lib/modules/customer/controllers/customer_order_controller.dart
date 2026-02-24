import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../views/help_support_screen.dart';

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/services/database_service.dart';

class CustomerOrderController extends GetxController {
  final DatabaseService _databaseService = DatabaseService();
  var myOrders = <OrderModel>[].obs;
  var isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    fetchMyOrders();
  }

  Future<void> fetchMyOrders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      isLoading.value = true;
      try {
        myOrders.value = await _databaseService.getUserOrders(user.uid);
      } catch (e) {
        print("Error fetching orders: $e");
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> refreshMyOrders() async {
    await fetchMyOrders();
  }

  Future<void> deleteOrder(String orderId) async {
    isLoading.value = true;
    try {
      await _databaseService.deleteOrder(orderId);
      myOrders.removeWhere((order) => order.id == orderId); // Updates UI locally
      Get.snackbar("Success", "Order removed from history");
    } catch (e) {
      Get.snackbar("Error", "Failed to delete order: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void contactSupport() {
    Get.to(() => const HelpSupportScreen());
  }

  Future<void> downloadInvoice(OrderModel order) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('PVP TRADERS - INVOICE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text(DateFormat('dd MMM yyyy').format(DateTime.now())),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text("Order ID: ${order.id}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
              pw.Text("Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(order.date)}"),
              pw.SizedBox(height: 10),
              pw.Text("Billed To:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text("${order.address}\n${order.city}, ${order.zip}"),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                border: pw.TableBorder.all(),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                headers: ['Item', 'Size', 'Qty', 'Price'],
                data: order.items.map((item) => [
                  item.product.name,
                  item.selectedSize,
                  item.quantity.toString(),
                  'Rs. ${item.product.price.toStringAsFixed(2)}',
                ]).toList(),
              ),
              pw.SizedBox(height: 10),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text("Total: Rs. ${order.totalAmount.toStringAsFixed(2)}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
              ),
              pw.Spacer(),
              pw.Center(child: pw.Text("Thank you for shopping with PVP Traders!", style: const pw.TextStyle(color: PdfColors.grey))),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'invoice_${order.id}.pdf');
  }
}
