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
    // ignore: avoid_print
    print('Customer points added successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to add customer points: $e');
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
    // ignore: avoid_print
    print('Customer points updated successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to update customer points: $e');
  }
}

// delete from customer_points where id = 1
Future<void> deleteCustomerPoints(int id) async {
  try {
    await deleteCustomerPointsItem(id);
    // ignore: avoid_print
    print('Customer points deleted successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to delete customer points: $e');
  }
}
