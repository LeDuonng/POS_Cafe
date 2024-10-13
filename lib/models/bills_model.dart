import '../controllers/bills_controller.dart';

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
    // ignore: avoid_print
    print('Bill added successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to add bill: $e');
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
    // ignore: avoid_print
    print('Bill updated successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to update bill: $e');
  }
}

//delete from bills where id = 1
Future<void> deleteBill(int id) async {
  try {
    await deleteBillItem(id);
    // ignore: avoid_print
    print('Bill deleted successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to delete bill: $e');
  }
}
