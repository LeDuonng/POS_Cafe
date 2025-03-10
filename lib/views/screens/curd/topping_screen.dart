import 'package:coffeeapp/models/menu_model.dart';
import 'package:flutter/material.dart';
import '../../../controllers/menu_controller.dart';
import '../../../responsive.dart'; // Import the Responsive widget
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';

class ToppingScreen extends StatefulWidget {
  const ToppingScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ToppingScreenState createState() => _ToppingScreenState();
}

late Future<List<dynamic>> toppingList;
String searchText = '';

class _ToppingScreenState extends State<ToppingScreen> {
  @override
  void initState() {
    super.initState();
    toppingList = searchToppingItem();
  }

  Future<void> _refreshToppingList([String? searchText]) async {
    var temp = searchToppingItem(searchText);
    setState(() {
      toppingList = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Topping'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 300,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm topping...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                    _refreshToppingList(searchText);
                  });
                },
              ),
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Thêm Topping'),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) => const AddToppingItemScreen(),
              );
              _refreshToppingList();
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.file_download),
            label: const Text('Xuất Excel'),
            onPressed: () {
              exportToppingToExcel();
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.file_upload),
            label: const Text('Nhập Excel'),
            onPressed: () async {
              await importToppingFromExcel();
              _refreshToppingList();
            },
          ),
        ],
      ),
      body: Responsive(
        mobile: _buildToppingList(context),
        tablet: _buildToppingList(context),
        desktop: _buildToppingList(context),
      ),
    );
  }

  Future<void> exportToppingToExcel() async {
    try {
      var excel = Excel.createExcel();
      excel.rename('Sheet1', 'Topping');
      Sheet sheetObject = excel['Topping'];
      sheetObject.appendRow([
        TextCellValue('Mã topping'),
        TextCellValue('Tên Topping'),
        TextCellValue('Mô tả'),
        TextCellValue('Giá'),
        TextCellValue('Hình ảnh'),
        TextCellValue('Danh mục'),
      ]);

      // Lấy dữ liệu topping
      final toppingData = await toppingList;
      for (var item in toppingData) {
        sheetObject.appendRow([
          IntCellValue(item['id']),
          TextCellValue(item['name'] ?? 'Không có'),
          TextCellValue(item['description'] ?? 'Không có'),
          DoubleCellValue(double.tryParse(item['price'].toString()) ?? 0.0),
          TextCellValue(item['image'] ?? 'Không có'),
          TextCellValue(item['category'] ?? 'Không có'),
        ]);
      }

      // Tạo tên file với ngày hiện tại
      String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String fileName = "topping_$currentDate.xlsx";

      // Tạo file Excel
      final excelBytes = excel.save();
      final blob = html.Blob([Uint8List.fromList(excelBytes!)],
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Tải file về với tên chứa ngày hiện tại
      // ignore: unused_local_variable
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..click();
      html.Url.revokeObjectUrl(url);

      // Thông báo thành công
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Dữ liệu topping đã được xuất thành công: $fileName')),
      );
    } catch (e) {
      // Thông báo lỗi
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xuất Excel: $e')),
      );
    }
  }

  Future<void> importToppingFromExcel() async {
    try {
      // Mở File Picker để chọn file Excel
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'], // Chỉ cho phép file Excel
      );

      if (result != null) {
        Uint8List? bytes = result.files.single.bytes; // Lấy dữ liệu file
        if (bytes == null) throw 'Không thể đọc file Excel';

        var excel = Excel.decodeBytes(bytes);

        // Đọc dữ liệu từ file Excel
        for (var table in excel.tables.keys) {
          var sheet = excel.tables[table];
          for (var i = 1; i < sheet!.rows.length; i++) {
            var row = sheet.rows[i];
            await addTopping(
              name: row[1]?.value.toString() ?? 'Không có',
              description: row[2]?.value.toString() ?? 'Không có',
              price: row[3]?.value.toString() ?? '0',
              image: row[4]?.value.toString() ?? 'Không có',
              category: row[5]?.value.toString() ?? 'Không có',
            );
          }
        }

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Dữ liệu topping đã được nhập thành công!')),
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

  Widget _buildToppingList(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: toppingList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không có dữ liệu'));
        } else {
          return LayoutBuilder(
            builder: (context, constraints) {
              double totalWidth = constraints.maxWidth;
              double columnWidth = totalWidth / 6; // 7 là tổng số cột hiện có

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columnSpacing: 12,
                  // ignore: deprecated_member_use
                  dataRowHeight: 100,
                  columns: [
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'Tên Topping',
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
                          'Mô tả',
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
                          'Giá',
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
                          'Hình ảnh',
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
                          'Danh mục',
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
                  ],
                  rows: List.generate(snapshot.data!.length, (index) {
                    return DataRow(
                      color: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                          return index.isEven
                              ? Colors.grey.withOpacity(0.1)
                              : Colors.white;
                        },
                      ),
                      cells: [
                        DataCell(
                            Text(snapshot.data![index]['name'] ?? 'Không có')),
                        DataCell(Text(snapshot.data![index]['description'] ??
                            'Không có')),
                        DataCell(Text(
                            snapshot.data![index]['price']?.toString() ??
                                'Không có')),
                        DataCell(
                          Image.asset(
                            'assets/menu/${snapshot.data![index]['name']}.png',
                            height: 100,
                            width: 100,
                            fit: BoxFit.fitHeight,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/menu/error.png',
                                height: 100,
                                width: 100,
                                fit: BoxFit.fitHeight,
                              );
                            },
                          ),
                        ),
                        DataCell(Text(
                            snapshot.data![index]['category'] ?? 'Không có')),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (context) => EditToppingItemScreen(
                                      topping: snapshot.data![index],
                                      toppingItem: {
                                        'id': snapshot.data![index]['id'],
                                        'name': snapshot.data![index]['name'],
                                        'description': snapshot.data![index]
                                            ['description'],
                                        'price': snapshot.data![index]['price'],
                                        'image': snapshot.data![index]['image'],
                                        'category': snapshot.data![index]
                                            ['category'],
                                      },
                                    ),
                                  );
                                  _refreshToppingList();
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Xác nhận xoá'),
                                        content: const Text(
                                            'Bạn có chắc chắn muốn xoá mục này không?'),
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
                                                  deleteTopping(snapshot
                                                      .data![index]['id']);
                                                  snapshot.data!
                                                      .removeAt(index);
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content:
                                                            Text('Lỗi: $e')),
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
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              );
            },
          );
        }
      },
    );
  }
}

class AddToppingItemScreen extends StatefulWidget {
  const AddToppingItemScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddToppingItemScreenState createState() => _AddToppingItemScreenState();
}

class _AddToppingItemScreenState extends State<AddToppingItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name, description, price, image, category;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      addTopping(
        name: name,
        description: description,
        price: price,
        image: image,
        category: category,
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
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Tên Topping'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên topping';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      name = value;
                    }
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mô tả';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    description = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Giá'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập giá';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    price = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Hình ảnh URL'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập URL hình ảnh';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    image = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Danh mục'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập danh mục';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    category = value!;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _submitForm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Green for Add Item
                  ),
                  child: const Text('Thêm Topping'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Red for Cancel
                  ),
                  child: const Text('Hủy'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EditToppingItemScreen extends StatefulWidget {
  final Map<String, dynamic> toppingItem;
  final dynamic topping;

  const EditToppingItemScreen({
    super.key,
    required this.toppingItem,
    required this.topping,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EditToppingItemScreenState createState() => _EditToppingItemScreenState();
}

class _EditToppingItemScreenState extends State<EditToppingItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name, description, price, image, category;

  @override
  void initState() {
    super.initState();
    name = widget.toppingItem['name'] ?? 'Không có';
    description = widget.toppingItem['description'] ?? 'Không có';
    price = widget.toppingItem['price'] ?? 'Không có';
    image = widget.toppingItem['image'] ?? 'Không có';
    category = widget.toppingItem['category'] ?? 'Không có';
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      updateTopping(
        id: widget.toppingItem['id'],
        name: name,
        description: description,
        price: price,
        image: image,
        category: category,
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
                TextFormField(
                  initialValue: widget.toppingItem['id'].toString(),
                  decoration: const InputDecoration(labelText: 'Mã Topping'),
                  readOnly: true,
                ),
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(labelText: 'Tên Topping'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên topping';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      name = value;
                    }
                  },
                ),
                TextFormField(
                  initialValue: description,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mô tả';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    description = value!;
                  },
                ),
                TextFormField(
                  initialValue: price,
                  decoration: const InputDecoration(labelText: 'Giá'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập giá';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    price = value!;
                  },
                ),
                TextFormField(
                  initialValue: image,
                  decoration: const InputDecoration(labelText: 'Hình ảnh'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập URL hình ảnh';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    image = value!;
                  },
                ),
                TextFormField(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'Danh mục'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập danh mục';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    category = value!;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _submitForm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Green for Save
                  ),
                  child: const Text('Lưu thay Đổi'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Red for Cancel
                  ),
                  child: const Text('Hủy'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
