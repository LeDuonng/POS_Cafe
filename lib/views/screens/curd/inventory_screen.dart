// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:coffeeapp/models/ingredients_model.dart';
import 'package:coffeeapp/models/inventory_model.dart';
import 'package:flutter/material.dart';
import '../../../controllers/inventory_controller.dart';
import '../../../responsive.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late Future<List<dynamic>> inventoryList;
  String searchText = '';

  @override
  void initState() {
    super.initState();
    inventoryList = searchInventory();
  }

  Future<void> _refreshInventoryList([String? searchText]) async {
    var temp = searchInventory(searchText);
    setState(() {
      inventoryList = temp;
    });
  }

  Future<void> exportInventoryToExcel() async {
    try {
      var excel = Excel.createExcel();
      excel.rename('Sheet1', 'Tồn kho');
      Sheet sheetObject = excel['Tồn kho'];
      sheetObject.appendRow([
        TextCellValue('Mã nhập kho'),
        TextCellValue('Nguyên liệu'),
        TextCellValue('Số lượng'),
        TextCellValue('Ngày cập nhật'),
      ]);

      final inventoryData = await inventoryList;
      for (var item in inventoryData) {
        sheetObject.appendRow([
          IntCellValue(item['id']),
          TextCellValue(await getNameIngredientById(item['ingredient_id'])),
          IntCellValue(item['quantity']),
          TextCellValue(item['last_updated'].toString()),
        ]);
      }

      String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String fileName = "inventory_$currentDate.xlsx";

      final excelBytes = excel.save();
      final blob = html.Blob([Uint8List.fromList(excelBytes!)],
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);

      // ignore: unused_local_variable
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..click();
      html.Url.revokeObjectUrl(url);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Dữ liệu kho đã được xuất thành công: $fileName')),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xuất Excel: $e')),
      );
    }
  }

  Future<void> importInventoryFromExcel() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null) {
        Uint8List? bytes = result.files.single.bytes;
        if (bytes == null) throw 'Không thể đọc file Excel';

        var excel = Excel.decodeBytes(bytes);

        for (var table in excel.tables.keys) {
          var sheet = excel.tables[table];
          for (var i = 1; i < sheet!.rows.length; i++) {
            var row = sheet.rows[i];
            await addInventory(
              ingredientId: int.parse(row[1]?.value.toString() ?? '0'),
              quantity: int.parse(row[2]?.value.toString() ?? '0'),
              lastUpdated: DateTime.parse(
                  row[3]?.value.toString() ?? DateTime.now().toString()),
            );
          }
        }

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dữ liệu kho đã được nhập thành công!')),
        );
      } else {
        throw 'Không có file nào được chọn.';
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi nhập Excel: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý kho'),
        actions: [
          _buildSearchField(),
          _buildAddButton(),
          _buildExportButton(),
          _buildImportButton(),
        ],
      ),
      body: Responsive(
        mobile: _buildInventoryList(context),
        tablet: _buildInventoryList(context),
        desktop: _buildInventoryList(context),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        width: 300,
        child: TextFormField(
          decoration: InputDecoration(
            hintText: 'Tìm kiếm nguyên liệu...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onChanged: (value) {
            setState(() {
              searchText = value;
              _refreshInventoryList(searchText);
            });
          },
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return TextButton.icon(
      icon: const Icon(Icons.add),
      label: const Text('Thêm vào kho'),
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (context) => const AddInventoryItemScreen(),
        );
        _refreshInventoryList();
      },
    );
  }

  Widget _buildExportButton() {
    return TextButton.icon(
      icon: const Icon(Icons.file_download),
      label: const Text('Xuất Excel'),
      onPressed: () {
        try {
          exportInventoryToExcel();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi xuất Excel: $e')),
          );
        }
      },
    );
  }

  Widget _buildImportButton() {
    return TextButton.icon(
      icon: const Icon(Icons.file_upload),
      label: const Text('Nhập Excel'),
      onPressed: () async {
        try {
          await importInventoryFromExcel();
        } catch (e) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi nhập Excel: $e')),
          );
        }
        _refreshInventoryList();
      },
    );
  }

  Widget _buildInventoryList(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: inventoryList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không có dữ liệu'));
        } else {
          return _buildDataTable(snapshot.data!);
        }
      },
    );
  }

  Widget _buildDataTable(List<dynamic> data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double totalWidth = constraints.maxWidth;
        double columnWidth = totalWidth / 4;

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columnSpacing: 12,
            // ignore: deprecated_member_use
            dataRowHeight: 100,
            columns: _buildDataColumns(columnWidth),
            rows: _buildDataRows(data),
          ),
        );
      },
    );
  }

  List<DataColumn> _buildDataColumns(double columnWidth) {
    return [
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text(
            'Nguyên liệu',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text(
            'Số lượng',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text(
            'Ngày cập nhật',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text(
            'Hành động',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
        ),
      ),
    ];
  }

  List<DataRow> _buildDataRows(List<dynamic> data) {
    return List.generate(data.length, (index) {
      return DataRow(
        color: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            return index.isEven ? Colors.grey.withOpacity(0.1) : Colors.white;
          },
        ),
        cells: [
          DataCell(
              Text(data[index]['ingredient_name']?.toString() ?? 'Không có')),
          DataCell(Text(data[index]['quantity']?.toString() ?? 'Không có')),
          DataCell(Text(data[index]['last_updated']?.toString() ?? 'Không có')),
          DataCell(_buildActionButtons(data[index], index)),
        ],
      );
    });
  }

  Widget _buildActionButtons(dynamic item, int index) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () async {
            await showDialog(
              context: context,
              builder: (context) => EditInventoryItemScreen(
                inventory: item,
                inventoryItem: {
                  'id': item['id'],
                  'ingredient_id': item['ingredient_id'],
                  'quantity': item['quantity'],
                  'last_updated': item['last_updated'],
                },
              ),
            );
            _refreshInventoryList();
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            _showDeleteConfirmationDialog(item, index);
          },
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(dynamic item, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xoá'),
          content: const Text('Bạn có chắc chắn muốn xoá mục này không?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Huỷ'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  try {
                    deleteInventory(item['id']);
                    inventoryList.then((data) => data.removeAt(index));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: $e')),
                    );
                  }
                });
                Navigator.of(context).pop();
              },
              child: const Text('Xoá'),
            ),
          ],
        );
      },
    );
  }
}

class AddInventoryItemScreen extends StatefulWidget {
  const AddInventoryItemScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddInventoryItemScreenState createState() => _AddInventoryItemScreenState();
}

class _AddInventoryItemScreenState extends State<AddInventoryItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late int ingredientId, quantity;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      addInventory(
        ingredientId: ingredientId,
        quantity: quantity,
        lastUpdated: DateTime.now(),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(10),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 900),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                _buildIngredientIdField(),
                _buildQuantityField(),
                const SizedBox(height: 20),
                _buildAddButton(),
                const SizedBox(height: 10),
                _buildCancelButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientIdField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Mã nguyên liệu'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập mã nguyên liệu';
        }
        return null;
      },
      onSaved: (value) {
        ingredientId = int.parse(value!);
      },
    );
  }

  Widget _buildQuantityField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Số lượng'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập số lượng';
        }
        return null;
      },
      onSaved: (value) {
        quantity = int.parse(value!);
      },
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
      ),
      child: const Text('Thêm vào kho'),
    );
  }

  Widget _buildCancelButton() {
    return ElevatedButton(
      onPressed: () => Navigator.pop(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
      ),
      child: const Text('Hủy'),
    );
  }
}

class EditInventoryItemScreen extends StatefulWidget {
  final Map<String, dynamic> inventoryItem;
  final dynamic inventory;

  const EditInventoryItemScreen({
    super.key,
    required this.inventoryItem,
    required this.inventory,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EditInventoryItemScreenState createState() =>
      _EditInventoryItemScreenState();
}

class _EditInventoryItemScreenState extends State<EditInventoryItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late int ingredientId, quantity;
  late DateTime lastUpdated;

  @override
  void initState() {
    super.initState();
    ingredientId = widget.inventoryItem['ingredient_id'] ?? 0;
    quantity = widget.inventoryItem['quantity'] ?? 0;
    lastUpdated = widget.inventoryItem['last_updated'] != null
        ? DateTime.parse(widget.inventoryItem['last_updated'])
        : DateTime.now();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      updateInventory(
        id: widget.inventoryItem['id'],
        ingredientId: ingredientId,
        quantity: quantity,
        lastUpdated: DateTime.now(),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(10),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 900),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                _buildIdField(),
                _buildIngredientIdField(),
                _buildQuantityField(),
                _buildLastUpdatedField(),
                const SizedBox(height: 20),
                _buildSaveButton(),
                const SizedBox(height: 10),
                _buildCancelButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIdField() {
    return TextFormField(
      initialValue: widget.inventoryItem['id'].toString(),
      decoration: const InputDecoration(labelText: 'Mã nhập kho'),
      readOnly: true,
    );
  }

  Widget _buildIngredientIdField() {
    return TextFormField(
      initialValue: ingredientId.toString(),
      decoration: const InputDecoration(labelText: 'Mã nguyên liệu'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập mã nguyên liệu';
        }
        return null;
      },
      onSaved: (value) {
        ingredientId = int.parse(value!);
      },
    );
  }

  Widget _buildQuantityField() {
    return TextFormField(
      initialValue: quantity.toString(),
      decoration: const InputDecoration(labelText: 'Số lượng'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập số lượng';
        }
        return null;
      },
      onSaved: (value) {
        quantity = int.parse(value!);
      },
    );
  }

  Widget _buildLastUpdatedField() {
    return TextFormField(
      initialValue: lastUpdated.toString(),
      decoration: const InputDecoration(labelText: 'Ngày cập nhật'),
      readOnly: true,
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
      ),
      child: const Text('Lưu thay đổi'),
    );
  }

  Widget _buildCancelButton() {
    return ElevatedButton(
      onPressed: () => Navigator.pop(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
      ),
      child: const Text('Hủy'),
    );
  }
}
