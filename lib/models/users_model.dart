import 'package:coffeeapp/models/auth_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Users {
  int id;
  String username;
  String password;
  String role;
  String name;
  String email;
  String phone;
  String address;

  Users({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      role: json['role'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'role': role,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
    };
  }
}

Future<List<dynamic>> fetchUsers() async {
  final response = await http.get(Uri.parse('${getPlatformBaseUrl()}/users'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load users');
  }
}

Future<List<dynamic>> searchUsers([String? searchTerm]) async {
  final uri = searchTerm != null
      ? Uri.parse(
          '${getPlatformBaseUrl()}/users/search?search_term=$searchTerm')
      : Uri.parse('${getPlatformBaseUrl()}/users/search');

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load users');
  }
}

Future<void> addUserr(Map<String, dynamic> user) async {
  final response = await http.post(
    Uri.parse('${getPlatformBaseUrl()}/users'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(user),
  );

  if (response.statusCode != 201) {
    throw Exception('Failed to add user');
  } else {}
}

Future<void> updateUserr(int id, Map<String, dynamic> user) async {
  final response = await http.put(
    Uri.parse('${getPlatformBaseUrl()}/users/$id'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(user),
  );

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    if (responseBody['rows_affected'] == null ||
        responseBody['rows_affected'] == 0) {
      throw Exception('Failed to update user in controller');
    } else {
      // ignore: avoid_print
      print('User update successfully');
    }
  }
}

Future<void> deleteUserr(int id) async {
  final response = await http.delete(
    Uri.parse('${getPlatformBaseUrl()}/users/$id'),
  );

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    if (responseBody['rows_affected'] == null ||
        responseBody['rows_affected'] == 0) {
      throw Exception('Failed to delete user');
    } else {
      // ignore: avoid_print
      print('User deleted successfully');
    }
  } else {
    throw Exception('Failed to delete user');
  }
}

Future<List<dynamic>> fetchUserById(int id) async {
  try {
    final response =
        await http.get(Uri.parse('${getPlatformBaseUrl()}/users/$id'));
    if (response.statusCode == 200) {
      // Ép kiểu từ Map thành List
      Map<String, dynamic> userData =
          json.decode(response.body) as Map<String, dynamic>;
      return [userData]; // Đưa đối tượng vào trong một danh sách
    } else {
      throw Exception('Failed to load user');
    }
  } catch (e) {
    throw Exception('Failed to load user: $e');
  }
}

Future<List<dynamic>> authenticateUser(String username, String password) async {
  final response = await http.post(
    Uri.parse('${getPlatformBaseUrl()}/authenticate'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'username': username, 'password': password}),
  );

  if (response.statusCode == 200) {
    // Parse response body as List<dynamic>
    return json.decode(response.body); // Return as List<dynamic>
  } else {
    throw Exception('Failed to authenticate user: ${response.body}');
  }
}

Future<void> registerNewUser(Map<String, dynamic> user) async {
  final response = await http.post(
    Uri.parse('${getPlatformBaseUrl()}/register'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(user),
  );

  if (response.statusCode != 201) {
    throw Exception('Failed to register user');
  }
}

Future<List<dynamic>> findUser(String searchTerm) async {
  final response = await http.get(
    Uri.parse('${getPlatformBaseUrl()}/users/search/$searchTerm'),
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to search users');
  }
}

Future<String> getNameUserById(int id) async {
  final response =
      await http.get(Uri.parse('${getPlatformBaseUrl()}/getnameuserbyid/$id'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['name'];
  } else {
    throw Exception('Failed to load user name');
  }
}

Future<void> updatePassword(int id, String newPassword) async {
  final response = await http.put(
    Uri.parse('${getPlatformBaseUrl()}/users/$id/password'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'new_password': newPassword}),
  );

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    if (responseBody['rows_affected'] == null ||
        responseBody['rows_affected'] == 0) {
      throw Exception('Failed to update password');
    } else {
      // ignore: avoid_print
      print('Password updated successfully');
    }
  } else {
    throw Exception('Failed to update password');
  }
}
