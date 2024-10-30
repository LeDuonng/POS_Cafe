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
    // ignore: avoid_print
    print('Item added successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to add item: $e');
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
    // ignore: avoid_print
    print('Item updated successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to update item: $e');
  }
}

//delete from menu where id = 1
Future<void> deleteMenu(int id) async {
  try {
    await deleteItem(id);
    // ignore: avoid_print
    print('Item deleted successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to delete item: $e');
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
    // ignore: avoid_print
    print('Topping added successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to add topping: $e');
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
    // ignore: avoid_print
    print('Topping updated successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to update topping: $e');
  }
}

Future<void> deleteTopping(int id) async {
  try {
    await deleteToppingg(id);
    // ignore: avoid_print
    print('Topping deleted successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to delete topping: $e');
  }
}

Future<List<dynamic>> searchTopping(int id) async {
  try {
    return await fetchToppingById(id);
  } catch (e) {
    // ignore: avoid_print
    print('Failed to fetch topping: $e');
    return [];
  }
}
