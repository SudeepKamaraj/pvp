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
        orders[index] = _withUpdatedStatus(order, newStatus);
        orders.refresh();
      }

      if (order.userId != null) {
        await _databaseService.createNotification(
          userId: order.userId!,
          title: 'Order Status Updated',
          body: 'Your order #${order.id.substring(0, 8)} is now $newStatus.',
          type: 'order',
          data: {'orderId': order.id, 'status': newStatus},
        );
      }

      Get.snackbar("Success", "Order status updated");
    } catch (e) {
      Get.snackbar("Error", "Failed to update status");
    }
  }

  Future<void> approveCancellationRequest(OrderModel order) async {
    try {
      final requiresRefund = (order.paymentMethod ?? '').toLowerCase() != 'cod';
      await _databaseService.adminApproveCancellationRequest(
        orderId: order.id,
        requiresRefund: requiresRefund,
      );

      await fetchOrders();

      if (order.userId != null) {
        await _databaseService.createNotification(
          userId: order.userId!,
          title: 'Cancellation Approved',
          body: 'Your cancellation request for order #${order.id.substring(0, 8)} has been approved.${requiresRefund ? ' Refund initiated.' : ''}',
          type: 'order',
          data: {
            'orderId': order.id,
            'requestType': 'cancellation',
            'approved': true,
          },
        );
      }

      Get.snackbar('Success', 'Cancellation request approved');
    } catch (e) {
      Get.snackbar('Error', 'Failed to approve cancellation request');
    }
  }

  Future<void> rejectCancellationRequest(OrderModel order, {required String reason}) async {
    try {
      await _databaseService.adminRejectCancellationRequest(
        orderId: order.id,
        reason: reason,
      );

      await fetchOrders();

      if (order.userId != null) {
        await _databaseService.createNotification(
          userId: order.userId!,
          title: 'Cancellation Rejected',
          body: 'Your cancellation request for order #${order.id.substring(0, 8)} was rejected. Reason: $reason',
          type: 'order',
          data: {
            'orderId': order.id,
            'requestType': 'cancellation',
            'approved': false,
          },
        );
      }

      Get.snackbar('Updated', 'Cancellation request rejected');
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject cancellation request');
    }
  }

  Future<void> approveReturnRequest(OrderModel order) async {
    try {
      await _databaseService.adminApproveReturnRequest(orderId: order.id);

      await fetchOrders();

      if (order.userId != null) {
        await _databaseService.createNotification(
          userId: order.userId!,
          title: 'Return Approved',
          body: 'Your return request for order #${order.id.substring(0, 8)} has been approved. Refund initiated.',
          type: 'order',
          data: {
            'orderId': order.id,
            'requestType': 'return',
            'approved': true,
            'refundStatus': 'Initiated',
          },
        );
      }

      Get.snackbar('Success', 'Return request approved and refund initiated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to approve return request');
    }
  }

  Future<void> rejectReturnRequest(OrderModel order, {required String reason}) async {
    try {
      await _databaseService.adminRejectReturnRequest(
        orderId: order.id,
        reason: reason,
      );

      await fetchOrders();

      if (order.userId != null) {
        await _databaseService.createNotification(
          userId: order.userId!,
          title: 'Return Rejected',
          body: 'Your return request for order #${order.id.substring(0, 8)} was rejected. Reason: $reason',
          type: 'order',
          data: {
            'orderId': order.id,
            'requestType': 'return',
            'approved': false,
          },
        );
      }

      Get.snackbar('Updated', 'Return request rejected');
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject return request');
    }
  }

  Future<void> advanceRefundStatus(OrderModel order, String nextStatus) async {
    try {
      await _databaseService.adminAdvanceRefundStatus(
        orderId: order.id,
        nextStatus: nextStatus,
      );

      await fetchOrders();

      if (order.userId != null) {
        await _databaseService.createNotification(
          userId: order.userId!,
          title: 'Refund Update',
          body: 'Refund status for order #${order.id.substring(0, 8)}: $nextStatus',
          type: 'payment',
          data: {
            'orderId': order.id,
            'refundStatus': nextStatus,
          },
        );
      }

      Get.snackbar('Success', 'Refund status updated to $nextStatus');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update refund status');
    }
  }

  OrderModel _withUpdatedStatus(OrderModel order, String status) {
    return OrderModel(
      id: order.id,
      items: order.items,
      totalAmount: order.totalAmount,
      status: status,
      date: order.date,
      address: order.address,
      city: order.city,
      zip: order.zip,
      userId: order.userId,
      trackingId: order.trackingId,
      estimatedArrival: order.estimatedArrival,
      progress: order.progress,
      paymentMethod: order.paymentMethod,
      lastFourDigits: order.lastFourDigits,
      phone: order.phone,
      subtotal: order.subtotal,
      shippingFee: order.shippingFee,
      tax: order.tax,
      paymentId: order.paymentId,
      razorpayOrderId: order.razorpayOrderId,
      razorpaySignature: order.razorpaySignature,
      cancellationRequest: order.cancellationRequest,
      returnRequest: order.returnRequest,
      refundStatus: order.refundStatus,
      refundUpdatedAt: order.refundUpdatedAt,
    );
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
