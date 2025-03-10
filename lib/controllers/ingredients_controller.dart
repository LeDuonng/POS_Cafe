import 'package:coffeeapp/views/widgets/nofication.dart';

import '../models/ingredients_model.dart';

// select * from ingredients
Future<List<dynamic>> ingredientsList = fetchIngredients();

// select * from ingredients where id = 1
Future<List<dynamic>> ingredientsSearch(int id) {
  return fetchIngredientById(id);
}

// insert into ingredients
Future<void> addIngredient({
  required String name,
  required String unit,
  required int quantity,
}) async {
  Map<String, dynamic> newIngredient = {
    'name': name,
    'unit': unit,
    'quantity': quantity,
  };
  try {
    await addIngredientItem(newIngredient);
  } catch (e) {
    ToastNotification.showToast(message: 'Thêm nguyên liệu thất bại: $e');
  }
}

// update ingredients set name = 'new name' where id = 1
Future<void> updateIngredient({
  required int id,
  required String name,
  required String unit,
  required int quantity,
}) async {
  Map<String, dynamic> updatedIngredient = {
    'name': name,
    'unit': unit,
    'quantity': quantity,
  };
  try {
    await updateIngredientItem(id, updatedIngredient);
  } catch (e) {
    ToastNotification.showToast(message: 'Cập nhật nguyên liệu thất bại: $e');
  }
}

// delete from ingredients where id = 1
Future<void> deleteIngredient(int id) async {
  try {
    await deleteIngredientItem(id);
  } catch (e) {
    ToastNotification.showToast(message: 'Xóa nguyên liệu thất bại: $e');
  }
}
