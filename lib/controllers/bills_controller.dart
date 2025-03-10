import 'package:coffeeapp/views/widgets/nofication.dart';

import '../models/bills_model.dart';

//select * from bills
Future<List<dynamic>> billsList = fetchBills();

//select * from bills where id = 1
Future<List<dynamic>> billsSearch(int id) {
  return fetchBillById(id);
}

//insert into bills
Future<void> addBill({
  required int orderId,
  required double totalAmount,
  required String paymentMethod,
  required String paymentDate,
}) async {
  Map<String, dynamic> newBill = {
    'order_id': orderId,
    'total_amount': totalAmount,
    'payment_method': paymentMethod,
    'payment_date': paymentDate,
  };
  try {
    await addBillItem(newBill);
  } catch (e) {
    ToastNotification.showToast(message: 'Thêm hóa đơn thất bại: $e');
  }
}

//update bills set total_amount = 'new amount' where id = 1
Future<void> updateBill({
  required int id,
  required int orderId,
  required double totalAmount,
  required String paymentMethod,
  required String paymentDate,
}) async {
  Map<String, dynamic> updatedBill = {
    'order_id': orderId,
    'total_amount': totalAmount,
    'payment_method': paymentMethod,
    'payment_date': paymentDate,
  };
  try {
    await updateBillItem(id, updatedBill);
  } catch (e) {
    ToastNotification.showToast(message: 'Cập nhật hóa đơn thất bại: $e');
  }
}

//delete from bills where id = 1
Future<void> deleteBill(int id) async {
  try {
    await deleteBillItem(id);
  } catch (e) {
    ToastNotification.showToast(message: 'Xóa hóa đơn thất bại: $e');
  }
}
