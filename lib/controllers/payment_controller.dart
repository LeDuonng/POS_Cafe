import 'package:coffeeapp/views/widgets/nofication.dart';

import '../models/bills_model.dart';
import '../models/orders_model.dart';
import '../models/order_items_model.dart';

// Add a new order
Future<void> addOrder({
  int? tableId,
  int? customerId,
  required int staffId,
  required DateTime orderDate,
  required String status,
  required String description,
}) async {
  Map<String, dynamic> newOrder = {
    if (tableId != null) 'table_id': tableId,
    'customer_id': customerId,
    'staff_id': staffId,
    'order_date': orderDate.toIso8601String(),
    'status': status,
    'description': description,
  };
  try {
    await addNewOrder(newOrder);
  } catch (e) {
    ToastNotification.showToast(message: 'Thêm đơn hàng thất bại: $e');
  }
}

Future<void> addOrderItem({
  int? orderId,
  required int menuId,
  required int quantity,
  required double price,
  required String description,
}) async {
  orderId ??= await getLastOrderId();
  Map<String, dynamic> newItem = {
    'order_id': orderId,
    'menu_id': menuId,
    'quantity': quantity,
    'price': price,
    'description': description,
  };
  try {
    await addOrderItemToDb(newItem);
  } catch (e) {
    ToastNotification.showToast(message: 'Thêm món hàng thất bại: $e');
  }
}

//add payment
Future<void> addBill({
  int? orderId,
  required double totalAmount,
  required String paymentMethod,
  required DateTime paymentDate,
}) async {
  orderId ??= await getLastOrderId();

  Map<String, dynamic> newBill = {
    'order_id': orderId,
    'total_amount': totalAmount,
    'payment_method': paymentMethod,
    'payment_date': paymentDate.toIso8601String(),
  };
  try {
    await addBillItem(newBill);
  } catch (e) {
    ToastNotification.showToast(message: 'Thêm hóa đơn thất bại: $e');
  }
}
