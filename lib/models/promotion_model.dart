import 'dart:convert';
import 'package:coffeeapp/models/auth_model.dart';
import 'package:http/http.dart' as http;

Future<List<dynamic>> fetchPromotions() async {
  final response =
      await http.get(Uri.parse('${getPlatformBaseUrl()}/promotions'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load promotions');
  }
}

Future<List<dynamic>> fetchPromotionscustomer() async {
  final response =
      await http.get(Uri.parse('${getPlatformBaseUrl()}/promotions'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load promotions');
  }
}

Future<dynamic> fetchPromotionById(int id) async {
  final response =
      await http.get(Uri.parse('${getPlatformBaseUrl()}/promotions/$id'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load promotion');
  }
}

Future<void> addPromotion(Map<String, dynamic> promotion) async {
  try {
    final response = await http.post(
      Uri.parse('${getPlatformBaseUrl()}/promotions'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(promotion),
    );

    if (response.statusCode == 201) {
      // ignore: avoid_print
      print('Promotion added successfully');
    } else {
      throw Exception('Failed to add promotion');
    }
  } catch (e) {
    // ignore: avoid_print
    print(e.toString());
  }
}

Future<void> updatePromotion(int id, Map<String, dynamic> promotion) async {
  try {
    final response = await http.put(
      Uri.parse('${getPlatformBaseUrl()}/promotions/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(promotion),
    );

    if (response.statusCode == 200) {
      // ignore: avoid_print
      print('Promotion updated successfully');
    } else {
      throw Exception('Failed to update promotion');
    }
  } catch (e) {
    // ignore: avoid_print
    print(e.toString());
  }
}

Future<void> deletePromotion(int id) async {
  try {
    final response = await http.delete(
      Uri.parse('${getPlatformBaseUrl()}/promotions/$id'),
    );

    if (response.statusCode == 200) {
      // ignore: avoid_print
      print('Promotion deleted successfully');
    } else {
      throw Exception('Failed to delete promotion');
    }
  } catch (e) {
    // ignore: avoid_print
    print(e.toString());
  }
}

Future<List<dynamic>> searchPromotionscustomer(String searchTerm) async {
  try {
    final response = await http.get(Uri.parse(
        '${getPlatformBaseUrl()}/promotionscustomer/search/$searchTerm'));

    if (response.statusCode == 200) {
      // ignore: avoid_print
      print('Promotions found successfully');
      return json.decode(response.body);
    } else {
      throw Exception('Failed to search promotions');
    }
  } catch (e) {
    // ignore: avoid_print
    print(e.toString());
    return [];
  }
}

Future<List<dynamic>> searchPromotions([String? name]) async {
  final uri = name != null
      ? Uri.parse('${getPlatformBaseUrl()}/promotions/search?name=$name')
      : Uri.parse('${getPlatformBaseUrl()}/promotions/search');

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load promotions');
  }
}

Future<List<dynamic>> searchPromotionCodes([int? promotionId]) async {
  final uri = promotionId != null
      ? Uri.parse(
          '${getPlatformBaseUrl()}/promotion_codes/search?promotion_id=$promotionId')
      : Uri.parse('${getPlatformBaseUrl()}/promotion_codes/search');

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load promotion codes');
  }
}

Future<String> getNamePromotionById(int id) async {
  final response = await http
      .get(Uri.parse('${getPlatformBaseUrl()}/getnamepromotionbyid/$id'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['name'];
  } else {
    throw Exception('Failed to load promotion name');
  }
}

Future<List<dynamic>> fetchDiscountedProducts() async {
  final response =
      await http.get(Uri.parse('${getPlatformBaseUrl()}/discounted_products'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load discounted products');
  }
}

Future<void> addDiscountedProduct(Map<String, dynamic> product) async {
  final response = await http.post(
    Uri.parse('${getPlatformBaseUrl()}/discounted_products'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(product),
  );

  if (response.statusCode != 201) {
    throw Exception('Failed to add discounted product');
  } else {
    // ignore: avoid_print
    print('Discounted product added successfully');
  }
}

Future<void> updateDiscountedProduct(
    int id, Map<String, dynamic> product) async {
  final response = await http.put(
    Uri.parse('${getPlatformBaseUrl()}/discounted_products/$id'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(product),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update discounted product');
  } else {
    // ignore: avoid_print
    print('Discounted product updated successfully');
  }
}

Future<void> deleteDiscountedProduct(int id) async {
  final response = await http.delete(
    Uri.parse('${getPlatformBaseUrl()}/discounted_products/$id'),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to delete discounted product');
  } else {
    // ignore: avoid_print
    print('Discounted product deleted successfully');
  }
}

Future<List<dynamic>> searchDiscountedProducts([String? name]) async {
  final uri = name != null
      ? Uri.parse(
          '${getPlatformBaseUrl()}/discounted_products/search?name=$name')
      : Uri.parse('${getPlatformBaseUrl()}/discounted_products/search');

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to search discounted products');
  }
}

Future<void> usePromotionCode(int id) async {
  final response = await http.put(
    Uri.parse('${getPlatformBaseUrl()}/promotions/$id/use'),
  );

  if (response.statusCode == 200) {
    // ignore: avoid_print
    print('Promotion code used successfully');
  } else if (response.statusCode == 404) {
    throw Exception('Promotion not found');
  } else if (response.statusCode == 400) {
    throw Exception('Promotion code usage limit reached');
  } else {
    throw Exception('Failed to use promotion code');
  }
}
