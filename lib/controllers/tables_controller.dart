import '../models/tables_model.dart';

// select * from tables
Future<List<dynamic>> tableList = fetchTables();

// select * from tables where id = 1
Future<List<dynamic>> tableSearch(int id) {
  return fetchTableById(id);
}

// insert into tables
Future<void> addTable({
  required String name,
  required int floor,
  required String area,
  required String status,
}) async {
  Map<String, dynamic> newTable = {
    'name': name,
    'floor': floor,
    'area': area,
    'status': status,
  };
  try {
    await addTableItem(newTable);
    // ignore: avoid_print
    print('Table added successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to add table: $e');
  }
}

// update tables set name = 'new name' where id = 1
Future<void> updateTable({
  required int id,
  required String name,
  required int floor,
  required String area,
  required String status,
}) async {
  Map<String, dynamic> updatedTable = {
    'name': name,
    'floor': floor,
    'area': area,
    'status': status,
  };
  try {
    await updateTableItem(id, updatedTable);
    // ignore: avoid_print
    print('Table updated successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to update table: $e');
  }
}

// delete from tables where id = 1
Future<void> deleteTable(int id) async {
  try {
    await deleteTableItem(id);
    // ignore: avoid_print
    print('Table deleted successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to delete table: $e');
  }
}
