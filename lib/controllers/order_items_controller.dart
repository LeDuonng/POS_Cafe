import 'package:coffeeapp/views/widgets/nofication.dart';

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
  } catch (e) {
    ToastNotification.showToast(message: 'Thêm mục đơn hàng thất bại: $e');
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
  } catch (e) {
    ToastNotification.showToast(message: 'Cập nhật mục đơn hàng thất bại: $e');
  }
}

// delete from order_items where id = 1
Future<void> deleteOrderItem(int id) async {
  try {
    await deleteOrderItemFromDb(id);
  } catch (e) {
    ToastNotification.showToast(message: 'Xóa mục đơn hàng thất bại: $e');
  }
}
