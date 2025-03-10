import 'package:coffeeapp/views/widgets/nofication.dart';

import '../models/staff_model.dart';

// select * from staff
Future<List<dynamic>> staffList = fetchStaff();

// select * from staff where id = 1
Future<List<dynamic>> staffSearch(int id) {
  return fetchStaffById(id);
}

// insert into staff
Future<void> addStaff({
  required int userId,
  required double salary,
  required DateTime startDate,
  required String position,
}) async {
  Map<String, dynamic> newStaff = {
    'user_id': userId,
    'salary': salary,
    'start_date': startDate.toIso8601String(),
    'position': position,
  };
  try {
    await addStaffItem(newStaff);
  } catch (e) {
    ToastNotification.showToast(message: 'Thêm nhân viên thất bại: $e');
  }
}

// update staff set user_id = 'new user_id' where id = 1
Future<void> updateStaff({
  required int id,
  required int userId,
  required double salary,
  required DateTime startDate,
  required String position,
}) async {
  Map<String, dynamic> updatedStaff = {
    'user_id': userId,
    'salary': salary,
    'start_date': startDate.toIso8601String(),
    'position': position,
  };
  try {
    await updateStaffItem(id, updatedStaff);
  } catch (e) {
    ToastNotification.showToast(message: 'Cập nhật nhân viên thất bại: $e');
  }
}

// delete from staff where id = 1
Future<void> deleteStaff(int id) async {
  try {
    await deleteStaffItem(id);
  } catch (e) {
    ToastNotification.showToast(message: 'Xóa nhân viên thất bại: $e');
  }
}
