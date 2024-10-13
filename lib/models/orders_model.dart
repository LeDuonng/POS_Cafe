import '../controllers/orders_controller.dart';

// Model for Order
class Order {
  final int id;
  final int tableId;
  final int customerId;
  final int staffId;
  final DateTime orderDate;
  final String status;

  Order({
    required this.id,
    required this.tableId,
    required this.customerId,
    required this.staffId,
    required this.orderDate,
    required this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      tableId: json['table_id'],
      customerId: json['customer_id'],
      staffId: json['staff_id'],
      orderDate: DateTime.parse(json['order_date']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'table_id': tableId,
      'customer_id': customerId,
      'staff_id': staffId,
      'order_date': orderDate.toIso8601String(),
      'status': status,
    };
  }
}

// Fetch all orders
Future<List<dynamic>> orderList = fetchOrders();

// Fetch order by ID
Future<List<dynamic>> fetchOrderById(int id) {
  return fetchOrderById(id);
}

// Add a new order
Future<void> addOrder({
  required int tableId,
  required int customerId,
  required int staffId,
  required DateTime orderDate,
  required String status,
}) async {
  Map<String, dynamic> newOrder = {
    'table_id': tableId,
    'customer_id': customerId,
    'staff_id': staffId,
    'order_date': orderDate.toIso8601String(),
    'status': status,
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

// Update an existing order
Future<void> updateOrder({
  required int id,
  required int tableId,
  required int customerId,
  required int staffId,
  required DateTime orderDate,
  required String status,
}) async {
  Map<String, dynamic> updatedOrder = {
    'table_id': tableId,
    'customer_id': customerId,
    'staff_id': staffId,
    'order_date': orderDate.toIso8601String(),
    'status': status,
  };
  try {
    await updateExistingOrder(id, updatedOrder);
    // ignore: avoid_print
    print('Order updated successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to update order: $e');
  }
}

// Delete an order
Future<void> deleteOrder(int id) async {
  try {
    await deleteExistingOrder(id);
    // ignore: avoid_print
    print('Order deleted successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to delete order: $e');
  }
}
