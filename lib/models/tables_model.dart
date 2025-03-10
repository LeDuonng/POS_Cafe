import 'package:coffeeapp/models/auth_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Table {
  int id;
  String name;
  int floor;
  String area;
  String status;

  Table({
    required this.id,
    required this.name,
    required this.floor,
    required this.area,
    required this.status,
  });

  factory Table.fromJson(Map<String, dynamic> json) {
    return Table(
      id: json['id'],
      name: json['name'],
      floor: json['floor'],
      area: json['area'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'floor': floor,
      'area': area,
      'status': status,
    };
  }
}

Future<List<dynamic>> searchTables([String? searchTerm]) async {
  final uri = searchTerm != null
      ? Uri.parse(
          '${getPlatformBaseUrl()}/tables/search?search_term=$searchTerm')
      : Uri.parse('${getPlatformBaseUrl()}/tables/search');

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load tables');
  }
}

Future<List<dynamic>> fetchTables() async {
  final response = await http.get(Uri.parse('${getPlatformBaseUrl()}/tables'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load tables');
  }
}

Future<void> addTableItem(Map<String, dynamic> table) async {
  final response = await http.post(
    Uri.parse('${getPlatformBaseUrl()}/tables'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(table),
  );

  if (response.statusCode != 201) {
    throw Exception('Failed to add table');
  }
}

Future<void> updateTableItem(int id, Map<String, dynamic> table) async {
  final response = await http.put(
    Uri.parse('${getPlatformBaseUrl()}/tables/$id'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(table),
  );

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    if (responseBody['rows_affected'] == null ||
        responseBody['rows_affected'] == 0) {
      throw Exception('Failed to update table');
    } else {
      // ignore: avoid_print
      print('Table updated successfully');
    }
  }
}

Future<void> deleteTableItem(int id) async {
  final response = await http.delete(
    Uri.parse('${getPlatformBaseUrl()}/tables/$id'),
  );

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    if (responseBody['rows_affected'] == null ||
        responseBody['rows_affected'] == 0) {
      throw Exception('Failed to delete table');
    } else {
      // ignore: avoid_print
      print('Table deleted successfully');
    }
  }
}

Future<List<dynamic>> fetchTableById(int id) async {
  final response =
      await http.get(Uri.parse('${getPlatformBaseUrl()}/tables/$id'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load table');
  }
}

Future<List<dynamic>> fetchTableDistinct() async {
  final response =
      await http.get(Uri.parse('${getPlatformBaseUrl()}/table/distinct'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load tables');
  }
}

Future<List<dynamic>> fetchTableArea([String? area]) async {
  final uri = area != null
      ? Uri.parse('${getPlatformBaseUrl()}/table/area?area=$area')
      : Uri.parse('${getPlatformBaseUrl()}/table/area');

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load table area');
  }
}

Future<String> getNameTableById(int id) async {
  final response =
      await http.get(Uri.parse('${getPlatformBaseUrl()}/getnametablebyid/$id'));

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    return responseBody['name'];
  } else {
    throw Exception('Failed to load table name');
  }
}

Future<void> updateTableStatus(int id, String status) async {
  final response = await http.put(
    Uri.parse('${getPlatformBaseUrl()}/tables/$id/status'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'status': status}),
  );

  if (response.statusCode == 200) {
    if (json.decode(response.body)['rows_affected'] == null ||
        json.decode(response.body)['rows_affected'] == 0) {
      // ignore: avoid_print
      print('Table status update failed');
    } else {
      // ignore: avoid_print
      print('Table status updated successfully');
    }
  }
}
