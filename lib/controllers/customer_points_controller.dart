import 'package:coffeeapp/views/widgets/nofication.dart';

import '../models/customer_points_model.dart';

// select * from customer_points
Future<List<dynamic>> customerPointsList = fetchCustomerPoints();

// select * from customer_points where id = 1
Future<List<dynamic>> customerPointsSearch(int id) {
  return fetchCustomerPointsById(id);
}

// insert into customer_points
Future<void> addCustomerPoints({
  required int userId,
  required int points,
}) async {
  Map<String, dynamic> newCustomerPoints = {
    'user_id': userId,
    'points': points,
  };
  try {
    await addCustomerPointsItem(newCustomerPoints);
  } catch (e) {
    ToastNotification.showToast(message: 'Thêm điểm khách hàng thất bại: $e');
  }
}

// update customer_points set points = 'new points' where id = 1
Future<void> updateCustomerPoints({
  required int id,
  required int points,
}) async {
  Map<String, dynamic> updatedCustomerPoints = {
    'points': points,
  };
  try {
    await updateCustomerPointsItem(id, updatedCustomerPoints);
  } catch (e) {
    ToastNotification.showToast(
        message: 'Cập nhật điểm khách hàng thất bại: $e');
  }
}

// delete from customer_points where id = 1
Future<void> deleteCustomerPoints(int id) async {
  try {
    await deleteCustomerPointsItem(id);
  } catch (e) {
    ToastNotification.showToast(message: 'Xóa điểm khách hàng thất bại: $e');
  }
}
