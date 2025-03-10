import 'package:coffeeapp/models/auth_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderItem {
  int id;
  int orderId;
  int menuId;
  int quantity;
  double price;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.menuId,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['order_id'],
      menuId: json['menu_id'],
      quantity: json['quantity'],
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'menu_id': menuId,
      'quantity': quantity,
      'price': price,
    };
  }
}

Future<List<dynamic>> searchOrderItems(
    {required String orderId, String? textsearch}) async {
  final uri = Uri.parse(
      '${getPlatformBaseUrl()}/order_items/search?order_id=$orderId${textsearch != null ? '&textsearch=$textsearch' : ''}');

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load order items');
  }
}

Future<List<dynamic>> fetchOrderItems() async {
  final response =
      await http.get(Uri.parse('${getPlatformBaseUrl()}/order_items'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load order items');
  }
}

Future<void> addOrderItemToDb(Map<String, dynamic> item) async {
  final response = await http.post(
    Uri.parse('${getPlatformBaseUrl()}/order_items'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(item),
  );

  if (response.statusCode != 201) {
    throw Exception('Failed to add order item');
  }
}

Future<void> updateOrderItemInDb(int id, Map<String, dynamic> item) async {
  final response = await http.put(
    Uri.parse('${getPlatformBaseUrl()}/order_items/$id'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(item),
  );

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    if (responseBody['rows_affected'] == null ||
        responseBody['rows_affected'] == 0) {
      throw Exception('Failed to update order item');
    } else {
      // ignore: avoid_print
      print('Order item updated successfully');
    }
  }
}

Future<void> deleteOrderItemFromDb(int id) async {
  final response = await http.delete(
    Uri.parse('${getPlatformBaseUrl()}/order_items/$id'),
  );

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    if (responseBody['rows_affected'] == null ||
        responseBody['rows_affected'] == 0) {
      throw Exception('Failed to delete order item');
    } else {
      // ignore: avoid_print
      print('Order item deleted successfully');
    }
  }
}

Future<List<dynamic>> fetchOrderItemById(int id) async {
  final response =
      await http.get(Uri.parse('${getPlatformBaseUrl()}/order_items/$id'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load order item');
  }
}
