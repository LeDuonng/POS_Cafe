import 'package:coffeeapp/controllers/auth_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomerPoints {
  int id;
  int userId;
  int points;

  CustomerPoints({
    required this.id,
    required this.userId,
    required this.points,
  });

  factory CustomerPoints.fromJson(Map<String, dynamic> json) {
    return CustomerPoints(
      id: json['id'],
      userId: json['user_id'],
      points: json['points'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'points': points,
    };
  }
}

Future<List<dynamic>> fetchCustomerPoints() async {
  final response =
      await http.get(Uri.parse('${getPlatformBaseUrl()}/customer_points'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load customer points');
  }
}

Future<void> addCustomerPointsItem(Map<String, dynamic> points) async {
  final response = await http.post(
    Uri.parse('${getPlatformBaseUrl()}/customer_points'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(points),
  );

  if (response.statusCode != 201) {
    throw Exception('Failed to add customer points');
  }
}

Future<void> updateCustomerPointsItem(
    int id, Map<String, dynamic> points) async {
  final response = await http.put(
    Uri.parse('${getPlatformBaseUrl()}/customer_points/$id'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(points),
  );

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    if (responseBody['rows_affected'] == null ||
        responseBody['rows_affected'] == 0) {
      throw Exception('Failed to update customer points');
    } else {
      // ignore: avoid_print
      print('Customer points updated successfully');
    }
  }
}

Future<void> deleteCustomerPointsItem(int id) async {
  final response = await http.delete(
    Uri.parse('${getPlatformBaseUrl()}/customer_points/$id'),
  );

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    if (responseBody['rows_affected'] == null ||
        responseBody['rows_affected'] == 0) {
      throw Exception('Failed to delete customer points');
    } else {
      // ignore: avoid_print
      print('Customer points deleted successfully');
    }
  }
}

Future<List<dynamic>> fetchCustomerPointsById(int id) async {
  final response =
      await http.get(Uri.parse('${getPlatformBaseUrl()}/customer_points/$id'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load customer points');
  }
}
