import 'package:coffeeapp/models/auth_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Menu {
  int id;
  String name;
  String description;
  double price;
  String image;
  String category;

  Menu({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price']),
      image: json['image'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'category': category,
    };
  }
}

Future<List<dynamic>> fetchMenu() async {
  final response = await http.get(Uri.parse('${getPlatformBaseUrl()}/menu'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load menu');
  }
}

Future<List<dynamic>> fetchMenus() async {
  final response = await http.get(Uri.parse('${getPlatformBaseUrl()}/menu'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load menu');
  }
}

Future<List<dynamic>> fetchTopping() async {
  final response = await http.get(Uri.parse('${getPlatformBaseUrl()}/topping'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load topping');
  }
}

//searchTopping
Future<List<dynamic>> searchToppingItem([String? name]) async {
  final uri = name != null
      ? Uri.parse('${getPlatformBaseUrl()}/topping/search?name=$name')
      : Uri.parse('${getPlatformBaseUrl()}/topping/search');

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load topping');
  }
}

Future<void> addItem(Map<String, dynamic> item) async {
  final response = await http.post(
    Uri.parse('${getPlatformBaseUrl()}/menu'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(item),
  );

  if (response.statusCode != 201) {
    throw Exception('Failed to add item');
  } else {
    // ignore: avoid_print
    print('Item added successfully');
  }
}

Future<void> updateItem(int id, Map<String, dynamic> item) async {
  final response = await http.put(
    Uri.parse('${getPlatformBaseUrl()}/menu/$id'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(item),
  );

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    if (responseBody['rows_affected'] == null ||
        responseBody['rows_affected'] == 0) {
      // ignore: avoid_print
      print('$responseBody');
    } else {
      // ignore: avoid_print
      print('Item update successfully');
    }
  }
}

Future<void> deleteItem(int id) async {
  final response = await http.delete(
    Uri.parse('${getPlatformBaseUrl()}/menu/$id'),
  );

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    if (responseBody['rows_affected'] == null ||
        responseBody['rows_affected'] == 0) {
      throw Exception('Failed to delete Item');
    } else {
      // ignore: avoid_print
      print('Item deleted successfully');
    }
  }
}

Future<List<dynamic>> fetchItemById(int id) async {
  final response =
      await http.get(Uri.parse('${getPlatformBaseUrl()}/menu/$id'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load item');
  }
}

Future<void> addToppingg(Map<String, dynamic> topping) async {
  final response = await http.post(
    Uri.parse('${getPlatformBaseUrl()}/topping'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(topping),
  );

  if (response.statusCode != 201) {
    throw Exception('Failed to add topping');
  }
}

Future<void> updateToppingg(int id, Map<String, dynamic> topping) async {
  final response = await http.put(
    Uri.parse('${getPlatformBaseUrl()}/topping/$id'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(topping),
  );

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    if (responseBody['rows_affected'] == null ||
        responseBody['rows_affected'] == 0) {
      throw Exception('Failed to update topping');
    } else {
      // ignore: avoid_print
      print('Topping updated successfully');
    }
  }
}

Future<void> deleteToppingg(int id) async {
  final response = await http.delete(
    Uri.parse('${getPlatformBaseUrl()}/topping/$id'),
  );

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    if (responseBody['rows_affected'] == null ||
        responseBody['rows_affected'] == 0) {
      throw Exception('Failed to delete topping');
    } else {
      // ignore: avoid_print
      print('Topping deleted successfully');
    }
  }
}

Future<List<dynamic>> fetchToppingById(String query) async {
  final response = await http
      .get(Uri.parse('${getPlatformBaseUrl()}/topping/search?q=$query'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load item');
  }
}

Future<List<dynamic>> fetchToppingDistinct() async {
  final response =
      await http.get(Uri.parse('${getPlatformBaseUrl()}/topping/distinct'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load item');
  }
}

Future<List<dynamic>> fetchMenuCategory([String? category]) async {
  final uri = category != null
      ? Uri.parse('${getPlatformBaseUrl()}/menu/category?category=$category')
      : Uri.parse('${getPlatformBaseUrl()}/menu/category');

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load menu category');
  }
}

Future<String> getNameMenuItemById(int id) async {
  final response = await http
      .get(Uri.parse('${getPlatformBaseUrl()}/getnamemenuitembyid/$id'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['name'];
  } else {
    throw Exception('Failed to load menu item name');
  }
}
