import 'dart:convert';
import 'package:coffeeapp/controllers/auth_controller.dart';
import 'package:http/http.dart' as http;

class Promotion {
  int id;
  String name;
  String description;
  DateTime? startDate;
  DateTime? endDate;
  String discountType;
  double discountValue;
  double minOrderValue;
  int codeLimit;
  int usageLimit;
  bool active;

  Promotion({
    required this.id,
    required this.name,
    required this.description,
    this.startDate,
    this.endDate,
    required this.discountType,
    required this.discountValue,
    required this.minOrderValue,
    required this.codeLimit,
    required this.usageLimit,
    required this.active,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      discountType: json['discount_type'] as String,
      discountValue: double.parse(json['discount_value'] as String),
      minOrderValue: double.parse(json['min_order_value'] as String),
      codeLimit: json['code_limit'] as int,
      usageLimit: json['usage_limit'] as int,
      active: (json['active'] as int) == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'discount_type': discountType.toString(),
      'discount_value': discountValue,
      'min_order_value': minOrderValue,
      'code_limit': codeLimit,
      'usage_limit': usageLimit,
      'active': active,
    };
  }
}

class PromotionController {
  static Future<List<dynamic>> fetchPromotions() async {
    final response =
        await http.get(Uri.parse('${getPlatformBaseUrl()}/promotions'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load promotions');
    }
  }

  static Future<List<dynamic>> fetchPromotionscustomer() async {
    final response =
        await http.get(Uri.parse('${getPlatformBaseUrl()}/promotions'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load promotions');
    }
  }

  static Future<dynamic> fetchPromotionById(int id) async {
    final response =
        await http.get(Uri.parse('${getPlatformBaseUrl()}/promotions/$id'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load promotion');
    }
  }

  static Future<void> addPromotion(Map<String, dynamic> promotion) async {
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

  static Future<void> updatePromotion(
      int id, Map<String, dynamic> promotion) async {
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

  static Future<void> deletePromotion(int id) async {
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

  static Future<List<dynamic>> searchPromotions(String searchTerm) async {
    try {
      final response = await http.get(
          Uri.parse('${getPlatformBaseUrl()}/promotions/search/$searchTerm'));

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

  static Future<List<dynamic>> searchPromotionscustomer(
      String searchTerm) async {
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
}
