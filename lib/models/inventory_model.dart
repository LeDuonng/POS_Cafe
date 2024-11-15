import 'package:coffeeapp/models/auth_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Inventory {
  int id;
  int ingredientId;
  int quantity;
  DateTime lastUpdated;

  Inventory({
    required this.id,
    required this.ingredientId,
    required this.quantity,
    required this.lastUpdated,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      id: json['id'],
      ingredientId: json['ingredient_id'],
      quantity: json['quantity'],
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ingredient_id': ingredientId,
      'quantity': quantity,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}

Future<List<dynamic>> searchInventory([String? ingredientId]) async {
  final uri = ingredientId != null
      ? Uri.parse(
          '${getPlatformBaseUrl()}/inventory/search?ingredient_id=$ingredientId')
      : Uri.parse('${getPlatformBaseUrl()}/inventory/search');

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load inventory');
  }
}

Future<List<dynamic>> fetchInventory() async {
  final response =
      await http.get(Uri.parse('${getPlatformBaseUrl()}/inventory'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load inventory');
  }
}

Future<void> addInventoryItem(Map<String, dynamic> item) async {
  final response = await http.post(
    Uri.parse('${getPlatformBaseUrl()}/inventory'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(item),
  );

  if (response.statusCode != 201) {
    throw Exception('Failed to add inventory item');
  }
}

Future<void> updateInventoryItem(int id, Map<String, dynamic> item) async {
  final response = await http.put(
    Uri.parse('${getPlatformBaseUrl()}/inventory/$id'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(item),
  );

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    if (responseBody['rows_affected'] == null ||
        responseBody['rows_affected'] == 0) {
      throw Exception('Failed to update inventory item');
    } else {
      // ignore: avoid_print
      print('Inventory item updated successfully');
    }
  }
}

Future<void> deleteInventoryItem(int id) async {
  final response = await http.delete(
    Uri.parse('${getPlatformBaseUrl()}/inventory/$id'),
  );

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    if (responseBody['rows_affected'] == null ||
        responseBody['rows_affected'] == 0) {
      throw Exception('Failed to delete inventory item');
    } else {
      // ignore: avoid_print
      print('Inventory item deleted successfully');
    }
  }
}

Future<List<dynamic>> fetchInventoryItemById(int id) async {
  final response =
      await http.get(Uri.parse('${getPlatformBaseUrl()}/inventory/$id'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load inventory item');
  }
}
