import '../controllers/inventory_controller.dart';

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
    // ignore: avoid_print
    print('Inventory item added successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to add inventory item: $e');
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
    // ignore: avoid_print
    print('Inventory item updated successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to update inventory item: $e');
  }
}

// delete from inventory where id = 1
Future<void> deleteInventory(int id) async {
  try {
    await deleteInventoryItem(id);
    // ignore: avoid_print
    print('Inventory item deleted successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to delete inventory item: $e');
  }
}
