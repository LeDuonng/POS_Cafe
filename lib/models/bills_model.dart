import 'package:coffeeapp/models/auth_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Bill {
  int id;
  int orderId;
  double totalAmount;
  String paymentMethod;
  DateTime paymentDate;

  Bill({
    required this.id,
    required this.orderId,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentDate,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'],
      orderId: json['order_id'],
      totalAmount: json['total_amount'],
      paymentMethod: json['payment_method'],
      paymentDate: DateTime.parse(json['payment_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'payment_date': paymentDate.toIso8601String(),
    };
  }
}

Future<List<dynamic>> searchBills([String? paymentMethod]) async {
  final uri = paymentMethod != null
      ? Uri.parse(
          '${getPlatformBaseUrl()}/bills/search?payment_method=$paymentMethod')
      : Uri.parse('${getPlatformBaseUrl()}/bills/search');

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Lỗi khi tìm kiếm hóa đơn');
  }
}

Future<List<dynamic>> fetchBills() async {
  final response = await http.get(Uri.parse('${getPlatformBaseUrl()}/bills'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Lỗi khi tải hóa đơn');
  }
}

Future<void> addBillItem(Map<String, dynamic> bill) async {
  final response = await http.post(
    Uri.parse('${getPlatformBaseUrl()}/bills'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(bill),
  );

  if (response.statusCode != 201) {
    throw Exception('Lỗi khi thêm hóa đơn');
  }
}

Future<void> updateBillItem(int id, Map<String, dynamic> bill) async {
  final response = await http.put(
    Uri.parse('${getPlatformBaseUrl()}/bills/$id'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(bill),
  );

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    if (responseBody['rows_affected'] == null ||
        responseBody['rows_affected'] == 0) {
      throw Exception('Lỗi khi cập nhật hóa đơn');
    } else {
      // ignore: avoid_print
    }
  }
}

Future<void> deleteBillItem(int id) async {
  final response = await http.delete(
    Uri.parse('${getPlatformBaseUrl()}/bills/$id'),
  );

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    if (responseBody['rows_affected'] == null ||
        responseBody['rows_affected'] == 0) {
      throw Exception('Lỗi khi xóa hóa đơn');
    } else {
      // ignore: avoid_print
    }
  }
}

Future<List<dynamic>> fetchBillById(int id) async {
  final response =
      await http.get(Uri.parse('${getPlatformBaseUrl()}/bills/$id'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Lỗi khi tải hóa đơn');
  }
}

Future<List<dynamic>> searchBillsWithDetails([String? paymentMethod]) async {
  final uri = paymentMethod != null
      ? Uri.parse(
          '${getPlatformBaseUrl()}/billss/search?payment_method=$paymentMethod')
      : Uri.parse('${getPlatformBaseUrl()}/billss/search');

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Lỗi khi tìm kiếm hóa đơn với chi tiết');
  }
}
