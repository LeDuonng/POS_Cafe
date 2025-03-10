import 'package:coffeeapp/models/auth_model.dart';
import 'package:coffeeapp/views/widgets/nofication.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Order {
  int id;
  int tableId;
  int customerId;
  int staffId;
  DateTime orderDate;
  String status;

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

Future<List<dynamic>> searchOrders([String? status]) async {
  final uri = status != null
      ? Uri.parse('${getPlatformBaseUrl()}/orders/search?id=$status')
      : Uri.parse('${getPlatformBaseUrl()}/orders/search');

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load orders');
  }
}

Future<List<dynamic>> fetchOrders() async {
  final response = await http.get(Uri.parse('${getPlatformBaseUrl()}/orders'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load orders');
  }
}

Future<void> addNewOrder(Map<String, dynamic> order) async {
  final response = await http.post(
    Uri.parse('${getPlatformBaseUrl()}/orders'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(order),
  );

  if (response.statusCode != 201) {
    // ignore: avoid_print
    print('Failed to add order: ${response.body}');
  }
}

Future<void> updateExistingOrder(int id, Map<String, dynamic> order) async {
  final response = await http.put(
    Uri.parse('${getPlatformBaseUrl()}/orders/$id'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(order),
  );

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    if (responseBody['rows_affected'] == null ||
        responseBody['rows_affected'] == 0) {
      throw Exception('Failed to update order');
    } else {
      // ignore: avoid_print
      print('Order updated successfully');
    }
  }
}

Future<void> deleteExistingOrder(int id) async {
  final response = await http.delete(
    Uri.parse('${getPlatformBaseUrl()}/orders/$id'),
  );

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    if (responseBody['rows_affected'] == null ||
        responseBody['rows_affected'] == 0) {
      throw Exception('Failed to delete order');
    } else {
      // ignore: avoid_Print
      print('Order deleted successfully');
    }
  }
}

Future<List<dynamic>> fetchOrderById(int id) async {
  final response =
      await http.get(Uri.parse('${getPlatformBaseUrl()}/orders/$id'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load order');
  }
}

Future<int> getLastOrderId() async {
  final response =
      await http.get(Uri.parse('${getPlatformBaseUrl()}/orders/last'));

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    return responseBody['id'];
  } else {
    throw Exception('Failed to fetch last order ID');
  }
}

//gộp bàn, chuyển bàn
Future<void> mergeTable(int oldTableId, int newTableId) async {
  final response = await http.put(
    Uri.parse('${getPlatformBaseUrl()}/orders/merge_change_table'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'old_table_id': oldTableId,
      'new_table_id': newTableId,
    }),
  );

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    if (responseBody['order_updated'] == 0 ||
        responseBody['table_updated'] == 0) {
      ToastNotification.showToast(message: 'Gộp bàn thất bại');
    } else {
      ToastNotification.showToast(message: 'Gộp bàn thành công');
    }
  } else {
    ToastNotification.showToast(message: 'Gộp bàn thất bại');
  }
}
