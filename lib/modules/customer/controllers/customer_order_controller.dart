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

  Future<void> requestOrderCancellation(OrderModel order, {required String reason}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar("Error", "Please login to continue");
      return;
    }

    final status = order.status.toLowerCase();
    final cancellableStatuses = {'new', 'pending', 'processing'};
    if (!cancellableStatuses.contains(status)) {
      Get.snackbar("Not Allowed", "This order cannot be cancelled at this stage");
      return;
    }

    if (DateTime.now().difference(order.date) > const Duration(hours: 1)) {
      Get.snackbar("Window Closed", "Cancellation is available only within 1 hour of ordering");
      return;
    }

    isLoading.value = true;
    try {
      await _databaseService.requestOrderCancellation(
        orderId: order.id,
        userId: user.uid,
        reason: reason,
      );

      await _databaseService.createNotification(
        userId: user.uid,
        title: 'Cancellation Requested',
        body: 'Your cancellation request for order #${order.id.substring(0, 8)} has been submitted.',
        type: 'order',
        data: {'orderId': order.id, 'requestType': 'cancellation'},
      );

      await fetchMyOrders();
      Get.snackbar("Request Submitted", "We received your cancellation request");
    } catch (e) {
      Get.snackbar("Error", "Failed to request cancellation: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> requestOrderReturn(
    OrderModel order, {
    required String reason,
    DateTime? pickupDate,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar("Error", "Please login to continue");
      return;
    }

    if (order.status.toLowerCase() != 'delivered') {
      Get.snackbar("Not Allowed", "Returns are available only for delivered orders");
      return;
    }

    if (DateTime.now().difference(order.date) > const Duration(days: 7)) {
      Get.snackbar("Window Closed", "Return window is 7 days from delivery");
      return;
    }

    isLoading.value = true;
    try {
      await _databaseService.requestOrderReturn(
        orderId: order.id,
        userId: user.uid,
        reason: reason,
        pickupDate: pickupDate,
      );

      await _databaseService.createNotification(
        userId: user.uid,
        title: 'Return Requested',
        body: 'Your return request for order #${order.id.substring(0, 8)} is under review.',
        type: 'order',
        data: {'orderId': order.id, 'requestType': 'return'},
      );

      await fetchMyOrders();
      Get.snackbar("Request Submitted", "Return request created successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to request return: $e");
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
