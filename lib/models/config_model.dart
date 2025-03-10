import 'package:coffeeapp/models/auth_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Config {
  int id;
  String key;
  String value;
  String description;

  Config({
    required this.id,
    required this.key,
    required this.value,
    required this.description,
  });

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      id: json['id'],
      key: json['key'],
      value: json['value'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'value': value,
      'description': description,
    };
  }
}

Future<List<dynamic>> fetchConfigs() async {
  final response = await http.get(Uri.parse('${getPlatformBaseUrl()}/config'));

  if (response.statusCode == 200) {
    List<dynamic> body = json.decode(response.body);
    return body.map((dynamic item) => Config.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load configs');
  }
}

Future<List<dynamic>> fetchConfig() async {
  final response = await http.get(Uri.parse('${getPlatformBaseUrl()}/config'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load config');
  }
}

Future<void> addConfig(Map<String, dynamic> config) async {
  final response = await http.post(
    Uri.parse('${getPlatformBaseUrl()}/config'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(config),
  );

  if (response.statusCode != 201) {
    throw Exception('Failed to add config');
  }
}

Future<void> updateConfig(int id, Map<String, dynamic> config) async {
  final response = await http.put(
    Uri.parse('${getPlatformBaseUrl()}/config/$id'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(config),
  );

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    if (responseBody['rows_affected'] == null ||
        responseBody['rows_affected'] == 0) {
      throw Exception('Failed to update config');
    } else {
      // ignore: avoid_print
      print('Config updated successfully');
    }
  }
}

Future<List<dynamic>> searchConfig([String? key]) async {
  final uri = key != null
      ? Uri.parse('${getPlatformBaseUrl()}/config/search?key=$key')
      : Uri.parse('${getPlatformBaseUrl()}/config/search');

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load config');
  }
}
