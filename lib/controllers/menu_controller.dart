import 'package:coffeeapp/views/widgets/nofication.dart';

import '../models/menu_model.dart';

//select * from menu
Future<List<dynamic>> menuList = fetchMenu();
//select * from menu where id = 1
Future<List<dynamic>> menuSearch(int id) {
  return fetchItemById(id);
}

//insert into menu
Future<void> addMenu(
    {required String name,
    required String description,
    required String price,
    required String image,
    required String category}) async {
  Map<String, dynamic> newItem = {
    'name': name,
    'description': description,
    'price': price,
    'image': image,
    'category': category,
  };
  try {
    await addItem(newItem);
    ToastNotification.showToast(message: 'Thêm món thành công');
  } catch (e) {
    ToastNotification.showToast(message: 'Thêm món không thành công: $e');
  }
}

//update menu set name = 'new name' where id = 1
Future<void> updateMenu(
    {required int id,
    required String name,
    required String description,
    required String price,
    required String image,
    required String category}) async {
  Map<String, dynamic> updatedItem = {
    'name': name,
    'description': description,
    'price': price,
    'image': image,
    'category': category,
  };
  try {
    await updateItem(id, updatedItem);
    ToastNotification.showToast(message: 'Cập nhật thành công');
  } catch (e) {
    ToastNotification.showToast(message: 'Cập nhật không thành công: $e');
  }
}

//delete from menu where id = 1
Future<void> deleteMenu(int id) async {
  try {
    await deleteItem(id);
    ToastNotification.showToast(message: 'Xóa món thành công');
  } catch (e) {
    ToastNotification.showToast(message: 'Xóa món không thành công: $e');
  }
}

Future<void> addTopping(
    {required String name,
    required String description,
    required String price,
    required String image,
    required String category}) async {
  Map<String, dynamic> newTopping = {
    'name': name,
    'description': description,
    'price': price,
    'image': image,
    'category': category,
    'topping': 1,
  };
  try {
    await addToppingg(newTopping);
    ToastNotification.showToast(message: 'Thêm topping thành công');
  } catch (e) {
    ToastNotification.showToast(message: 'Thêm topping không thành công: $e');
  }
}

Future<void> updateTopping(
    {required int id,
    required String name,
    required String description,
    required String price,
    required String image,
    required String category}) async {
  Map<String, dynamic> updatedTopping = {
    'name': name,
    'description': description,
    'price': price,
    'image': image,
    'category': category,
    'topping': 1,
  };
  try {
    await updateToppingg(id, updatedTopping);
    ToastNotification.showToast(message: 'Cập nhật topping thành công');
  } catch (e) {
    ToastNotification.showToast(
        message: 'Cập nhật topping không thành công: $e');
  }
}

Future<void> deleteTopping(int id) async {
  try {
    await deleteToppingg(id);
    ToastNotification.showToast(message: 'Xóa topping thành công');
  } catch (e) {
    ToastNotification.showToast(message: 'Xóa topping không thành công: $e');
  }
}

Future<List<dynamic>> searchTopping(String query) async {
  try {
    return await searchToppingItem(query);
  } catch (e) {
    ToastNotification.showToast(
        message: 'Tìm kiếm topping không thành công: $e');
    return [];
  }
}
