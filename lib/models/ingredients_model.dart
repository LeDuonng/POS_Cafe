import 'package:coffeeapp/models/auth_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Ingredient {
  int id;
  String name;
  String unit;
  int quantity;

  Ingredient({
    required this.id,
    required this.name,
    required this.unit,
    required this.quantity,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'],
      name: json['name'],
      unit: json['unit'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'quantity': quantity,
    };
  }
}

Future<List<dynamic>> searchIngredients([String? name]) async {
  final uri = name != null
      ? Uri.parse('${getPlatformBaseUrl()}/ingredients/search?name=$name')
      : Uri.parse('${getPlatformBaseUrl()}/ingredients/search');

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load ingredients');
  }
}

Future<List<dynamic>> fetchIngredients() async {
  final response =
      await http.get(Uri.parse('${getPlatformBaseUrl()}/ingredients'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load ingredients');
  }
}

Future<void> addIngredientItem(Map<String, dynamic> ingredient) async {
  final response = await http.post(
    Uri.parse('${getPlatformBaseUrl()}/ingredients'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(ingredient),
  );

  if (response.statusCode != 201) {
    throw Exception('Failed to add ingredient');
  }
}

Future<void> updateIngredientItem(
    int id, Map<String, dynamic> ingredient) async {
  final response = await http.put(
    Uri.parse('${getPlatformBaseUrl()}/ingredients/$id'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(ingredient),
  );

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    if (responseBody['rows_affected'] == null ||
        responseBody['rows_affected'] == 0) {
      throw Exception('Failed to update ingredient');
    } else {
      // ignore: avoid_print
      print('Ingredient updated successfully');
    }
  }
}

Future<void> deleteIngredientItem(int id) async {
  final response = await http.delete(
    Uri.parse('${getPlatformBaseUrl()}/ingredients/$id'),
  );

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    if (responseBody['rows_affected'] == null ||
        responseBody['rows_affected'] == 0) {
      throw Exception('Failed to delete ingredient');
    } else {
      // ignore: avoid_print
      print('Ingredient deleted successfully');
    }
  }
}

Future<List<dynamic>> fetchIngredientById(int id) async {
  final response =
      await http.get(Uri.parse('${getPlatformBaseUrl()}/ingredients/$id'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load ingredient');
  }
}

Future<String> getNameIngredientById(int id) async {
  final response = await http
      .get(Uri.parse('${getPlatformBaseUrl()}/getnameingredientbyid/$id'));

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    return responseBody['name'];
  } else {
    throw Exception('Failed to load ingredient name');
  }
}
