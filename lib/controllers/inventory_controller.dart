import 'package:coffeeapp/views/widgets/nofication.dart';

import '../models/inventory_model.dart';

// select * from inventory
Future<List<dynamic>> inventoryList = fetchInventory();

// select * from inventory where id = 1
Future<List<dynamic>> inventorySearch(int id) {
  return fetchInventoryItemById(id);
}

// insert into inventory
Future<void> addInventory({
  required int ingredientId,
  required int quantity,
  required DateTime lastUpdated,
}) async {
  Map<String, dynamic> newItem = {
    'ingredient_id': ingredientId,
    'quantity': quantity,
    'last_updated': lastUpdated.toIso8601String(),
  };
  try {
    await addInventoryItem(newItem);
  } catch (e) {
    ToastNotification.showToast(message: 'Thêm mục hàng tồn kho thất bại: $e');
  }
}

// update inventory set quantity = 'new quantity' where id = 1
Future<void> updateInventory({
  required int id,
  required int ingredientId,
  required int quantity,
  required DateTime lastUpdated,
}) async {
  Map<String, dynamic> updatedItem = {
    'ingredient_id': ingredientId,
    'quantity': quantity,
    'last_updated': lastUpdated.toIso8601String(),
  };
  try {
    await updateInventoryItem(id, updatedItem);
  } catch (e) {
    ToastNotification.showToast(
        message: 'Cập nhật mục hàng tồn kho thất bại: $e');
  }
}

// delete from inventory where id = 1
Future<void> deleteInventory(int id) async {
  try {
    await deleteInventoryItem(id);
  } catch (e) {
    ToastNotification.showToast(message: 'Xóa mục hàng tồn kho thất bại: $e');
  }
}
