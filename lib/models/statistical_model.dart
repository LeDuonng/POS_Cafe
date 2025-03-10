import 'package:coffeeapp/models/auth_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<dynamic>> fetchDailyRevenue() async {
  final response = await http.get(
    Uri.parse(
        '${getPlatformBaseUrl()}/reports/revenue/daily?date=${DateTime.now().toIso8601String().split('T').first}'),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonMap = json.decode(response.body);
    // Trả về một List chứa một Map, mỗi Map sẽ chứa total_cash và total_card
    return [
      {
        'total_cash': double.parse(jsonMap['total_cash'].toString()),
        'total_card': double.parse(jsonMap['total_card'].toString())
      }
    ];
  } else {
    throw Exception('Failed to load daily revenue');
  }
}

Future<List<dynamic>> fetchRevenueByRange(
    String startDate, String endDate) async {
  final response = await http.get(Uri.parse(
      '${getPlatformBaseUrl()}/reports/revenue/range?start_date=$startDate&end_date=$endDate'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load revenue by range');
  }
}

Future<List<dynamic>> fetchRevenueByCategoryRange(
    String startDate, String endDate) async {
  final response = await http.get(Uri.parse(
      '${getPlatformBaseUrl()}/reports/revenue/category/range?start_date=$startDate&end_date=$endDate'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load revenue by category range');
  }
}

Future<List<dynamic>> fetchRevenueByStaffRange(
    String startDate, String endDate) async {
  final response = await http.get(Uri.parse(
      '${getPlatformBaseUrl()}/reports/revenue/staff/range?start_date=$startDate&end_date=$endDate'));
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load revenue by staff range');
  }
}
