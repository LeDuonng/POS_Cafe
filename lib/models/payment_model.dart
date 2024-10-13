import '../controllers/bills_controller.dart';
import '../controllers/orders_controller.dart';
import '../controllers/order_items_controller.dart';

// Add a new order
Future<void> addOrder({
  required int tableId,
  required int customerId,
  required int staffId,
  required DateTime orderDate,
  required String status,
  required String description,
}) async {
  Map<String, dynamic> newOrder = {
    'table_id': tableId,
    'customer_id': customerId,
    'staff_id': staffId,
    'order_date': orderDate.toIso8601String(),
    'status': status,
    'description': description,
  };
  try {
    await addNewOrder(newOrder);
    // ignore: avoid_print
    print('Order added successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to add order: $e');
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
    // ignore: avoid_print
    print('Order item added successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to add order item: $e');
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
    // ignore: avoid_print
    print('Bill added successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to add bill: $e');
  }
}
