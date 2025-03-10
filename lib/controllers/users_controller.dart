import 'dart:convert';

import 'package:coffeeapp/models/users_model.dart';
import 'package:coffeeapp/views/widgets/nofication.dart';

Future<List<dynamic>> userList = fetchUsers();

Future<List<dynamic>> userSearch(int id) {
  return fetchUserById(id);
}

Future<void> addUser({
  required String username,
  required String password,
  required String role,
  required String name,
  required String email,
  required String phone,
  required String address,
}) async {
  Map<String, dynamic> newUser = {
    'username': username,
    'password': base64Encode(utf8.encode(password)),
    'role': role,
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
  };
  try {
    await addUserr(newUser);
  } catch (e) {
    ToastNotification.showToast(message: 'Thêm người dùng thất bại: $e');
  }
}

Future<void> updateUser({
  required int id,
  required String username,
  required String password,
  required String role,
  required String name,
  required String email,
  required String phone,
  required String address,
}) async {
  Map<String, dynamic> updatedUser = {
    'username': username,
    'password': password,
    'role': role,
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
  };
  try {
    await updateUserr(id, updatedUser);
  } catch (e) {
    ToastNotification.showToast(message: 'Cập nhật người dùng thất bại: $e');
  }
}

Future<void> deleteUser(int id) async {
  try {
    await deleteUserr(id);
  } catch (e) {
    ToastNotification.showToast(message: 'Xóa người dùng thất bại: $e');
  }
}

Future<List<dynamic>> signin(String username, String password) async {
  try {
    return await authenticateUser(username, password);
  } catch (e) {
    ToastNotification.showToast(message: 'Đăng nhập thất bại: $e');
    return [];
  }
}

Future<bool> registerUser({
  required String username,
  required String password,
  required String role,
  required String name,
  required String email,
  required String phone,
  required String address,
}) async {
  Map<String, dynamic> newUser = {
    'username': username,
    'password': base64Encode(utf8.encode(password)),
    'role': role,
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
  };
  try {
    await registerNewUser(newUser);
    return true;
  } catch (e) {
    ToastNotification.showToast(message: 'Đăng ký người dùng thất bại: $e');
    return false;
  }
}
