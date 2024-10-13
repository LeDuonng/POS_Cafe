import '../controllers/ingredients_controller.dart';

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
    // ignore: avoid_print
    print('Ingredient added successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to add ingredient: $e');
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
    // ignore: avoid_print
    print('Ingredient updated successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to update ingredient: $e');
  }
}

// delete from ingredients where id = 1
Future<void> deleteIngredient(int id) async {
  try {
    await deleteIngredientItem(id);
    // ignore: avoid_print
    print('Ingredient deleted successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to delete ingredient: $e');
  }
}
