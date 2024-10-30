import '../models/order_items_model.dart';

// select * from order_items
Future<List<dynamic>> orderItemsList = fetchOrderItems();

// select * from order_items where id = 1
Future<List<dynamic>> orderItemsSearch(int id) {
  return fetchOrderItemById(id);
}

// insert into order_items
Future<void> addOrderItem({
  required int orderId,
  required int menuId,
  required int quantity,
  required double price,
}) async {
  Map<String, dynamic> newItem = {
    'order_id': orderId,
    'menu_id': menuId,
    'quantity': quantity,
    'price': price,
  };
  try {
    await addOrderItemToDb(newItem);
    // ignore: avoid_print
    print('Order item added successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to add order item: $e');
  }
}

// update order_items set quantity = 'new quantity' where id = 1
Future<void> updateOrderItem({
  required int id,
  required int orderId,
  required int menuId,
  required int quantity,
  required double price,
}) async {
  Map<String, dynamic> updatedItem = {
    'order_id': orderId,
    'menu_id': menuId,
    'quantity': quantity,
    'price': price,
  };
  try {
    await updateOrderItemInDb(id, updatedItem);
    // ignore: avoid_print
    print('Order item updated successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to update order item: $e');
  }
}

// delete from order_items where id = 1
Future<void> deleteOrderItem(int id) async {
  try {
    await deleteOrderItemFromDb(id);
    // ignore: avoid_print
    print('Order item deleted successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to delete order item: $e');
  }
}
