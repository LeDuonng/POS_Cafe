import 'package:coffeeapp/models/users_model.dart';

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
    'password': password,
    'role': role,
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
  };
  try {
    await addUserr(newUser);
    // ignore: avoid_print
    print('User added successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to add user: $e');
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
    // ignore: avoid_print
    print('User updated successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to update user in model: $e');
  }
}

Future<void> deleteUser(int id) async {
  try {
    await deleteUserr(id);
    // ignore: avoid_print
    print('User deleted successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to delete user: $e');
  }
}

Future<List<dynamic>> signin(String username, String password) async {
  try {
    return await authenticateUser(username, password);
  } catch (e) {
    // ignore: avoid_print
    print('Failed to login: $e');
    return []; // Trả về một Map rỗng thay vì List rỗng
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
    'password': password,
    'role': role,
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
  };
  try {
    await registerNewUser(newUser);
    // ignore: avoid_print
    print('User registered successfully');
    return true;
  } catch (e) {
    // ignore: avoid_print
    print('Failed to register user: $e');
    return false;
  }
}
