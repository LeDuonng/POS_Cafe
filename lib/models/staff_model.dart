import 'package:coffeeapp/models/auth_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Staff {
  int id;
  int userId;
  double salary;
  DateTime startDate;
  String position;
  int del;

  Staff({
    required this.id,
    required this.userId,
    required this.salary,
    required this.startDate,
    required this.position,
    this.del = 0,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'],
      userId: json['user_id'],
      salary: json['salary'],
      startDate: DateTime.parse(json['start_date']),
      position: json['position'],
      del: json['del'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'salary': salary,
      'start_date': startDate.toIso8601String(),
      'position': position,
      'del': del,
    };
  }
}

Future<List<dynamic>> searchStaff([String? position]) async {
  final uri = position != null
      ? Uri.parse('${getPlatformBaseUrl()}/staff/search?position=$position')
      : Uri.parse('${getPlatformBaseUrl()}/staff/search');

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load staff');
  }
}

Future<List<dynamic>> fetchStaff() async {
  final response = await http.get(Uri.parse('${getPlatformBaseUrl()}/staff'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load staff');
  }
}

Future<void> addStaffItem(Map<String, dynamic> staff) async {
  final response = await http.post(
    Uri.parse('${getPlatformBaseUrl()}/staff'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(staff),
  );

  if (response.statusCode != 201) {
    throw Exception('Failed to add staff');
  }
}

Future<void> updateStaffItem(int id, Map<String, dynamic> staff) async {
  final response = await http.put(
    Uri.parse('${getPlatformBaseUrl()}/staff/$id'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(staff),
  );

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    if (responseBody['rows_affected'] == null ||
        responseBody['rows_affected'] == 0) {
      throw Exception('Failed to update staff');
    } else {
      // ignore: avoid_print
      print('Staff updated successfully');
    }
  }
}

Future<void> deleteStaffItem(int id) async {
  final response = await http.delete(
    Uri.parse('${getPlatformBaseUrl()}/staff/$id'),
  );

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    if (responseBody['rows_affected'] == null ||
        responseBody['rows_affected'] == 0) {
      throw Exception('Failed to delete staff');
    } else {
      // ignore: avoid_print
      print('Staff deleted successfully');
    }
  }
}

Future<List<dynamic>> fetchStaffById(int id) async {
  final response =
      await http.get(Uri.parse('${getPlatformBaseUrl()}/staff/$id'));

  if (response.statusCode == 200) {
    Map<String, dynamic> staffData =
        json.decode(response.body) as Map<String, dynamic>;
    return [staffData]; // Đưa đối tượng staff vào trong một danh sách
  } else {
    throw Exception('Failed to load staff');
  }
}

Future<String> getNameStaffById(int id) async {
  final response =
      await http.get(Uri.parse('${getPlatformBaseUrl()}/getnamestaffbyid/$id'));

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    return responseBody['user_name'];
  } else {
    throw Exception('Failed to load staff name');
  }
}
