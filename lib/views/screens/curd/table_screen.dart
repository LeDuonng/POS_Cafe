import 'package:coffeeapp/models/tables_model.dart';
import 'package:coffeeapp/responsive.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/controllers/tables_controller.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';

class TableScreen extends StatefulWidget {
  const TableScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TableScreenState createState() => _TableScreenState();
}

late Future<List<dynamic>> tableList;
String searchText = '';

class _TableScreenState extends State<TableScreen> {
  @override
  void initState() {
    super.initState();
    tableList = searchTables();
  }

  Future<void> _refreshTableList([String? searchtext]) async {
    var temp = searchTables(searchtext);
    setState(() {
      tableList = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Bàn'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 300,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm bàn...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                    _refreshTableList(searchText);
                  });
                },
              ),
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Thêm Bàn'),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) => const AddTableScreen(),
              );
              _refreshTableList();
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.file_download),
            label: const Text('Xuất Excel'),
            onPressed: () async {
              await exportTablesToExcel();
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.file_upload),
            label: const Text('Nhập Excel'),
            onPressed: () async {
              await importTablesFromExcel();
              _refreshTableList();
            },
          ),
        ],
      ),
      body: Responsive(
        mobile: _buildTableList(context),
        tablet: _buildTableList(context),
        desktop: _buildTableList(context),
      ),
    );
  }

  Future<void> exportTablesToExcel() async {
    try {
      var excel = Excel.createExcel();
      excel.rename('Sheet1', 'Danh sách bàn');
      Sheet sheetObject = excel['Danh sách bàn'];
      sheetObject.appendRow([
        TextCellValue('Mã bàn'),
        TextCellValue('Tên bàn'),
        TextCellValue('Tầng'),
        TextCellValue('Khu vực'),
        TextCellValue('Trạng thái'),
      ]);

      // Lấy dữ liệu bàn
      final tableData = await tableList;
      for (var item in tableData) {
        sheetObject.appendRow([
          IntCellValue(item['id']),
          TextCellValue(item['name'] ?? 'Không có'),
          IntCellValue(item['floor'] ?? 0),
          TextCellValue(item['area'] ?? 'Không có'),
          TextCellValue(
              item['status'] == 'available' ? 'Sẵn sàng' : 'Đang bận'),
        ]);
      }

      // Tạo tên file với ngày hiện tại
      String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String fileName = "tables_$currentDate.xlsx";

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
            content: Text('Dữ liệu bàn đã được xuất thành công: $fileName')),
      );
    } catch (e) {
      // Thông báo lỗi
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xuất Excel: $e')),
      );
    }
  }

  Future<void> importTablesFromExcel() async {
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
            await addTable(
              name: row[1]?.value.toString() ?? 'Không có',
              floor: int.tryParse(row[2]?.value.toString() ?? '0') ?? 0,
              area: row[3]?.value.toString() ?? 'Không có',
              status: row[4]?.value.toString() == 'Sẵn sàng'
                  ? 'available'
                  : 'occupied',
            );
          }
        }

        // ignore: avoid_print
        print('Nhập Excel thành công!');
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dữ liệu bàn đã được nhập thành công!')),
        );
      } else {
        throw 'Không có file nào được chọn.';
      }
    } catch (e) {
      // ignore: avoid_print
      print('Lỗi khi nhập Excel: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi nhập Excel: $e')),
      );
    }
  }

  Widget _buildTableList(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: tableList,
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
              double columnWidth = totalWidth / 5; // 7 là tổng số cột hiện có

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
                          'Tên bàn',
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
                          'Tầng',
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
                          'Khu vực',
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
                          'Trạng thái',
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
                        DataCell(Text(
                            'Tầng ${snapshot.data![index]['floor'] ?? 'Không có'}')),
                        DataCell(
                            Text(snapshot.data![index]['area'] ?? 'Không có')),
                        DataCell(Text(
                            snapshot.data![index]['status'] == 'available'
                                ? 'Sẵn sàng'
                                : 'Đang bận')),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (context) => EditTableScreen(
                                      table: snapshot.data![index],
                                      tableItem: {
                                        'id': snapshot.data![index]['id'],
                                        'name': snapshot.data![index]['name'],
                                        'floor': snapshot.data![index]['floor'],
                                        'area': snapshot.data![index]['area'],
                                        'status': snapshot.data![index]
                                            ['status'],
                                      },
                                    ),
                                  );
                                  _refreshTableList();
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
                                            'Bạn có chắc chắn muốn xoá bàn này không?'),
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
                                                  deleteTable(snapshot
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

class AddTableScreen extends StatefulWidget {
  const AddTableScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddTableScreenState createState() => _AddTableScreenState();
}

class _AddTableScreenState extends State<AddTableScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name, area, status;
  late int floor;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      addTable(
        name: name,
        floor: floor,
        area: area,
        status: status,
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
                  decoration: const InputDecoration(labelText: 'Tên bàn'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên bàn';
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
                  decoration: const InputDecoration(labelText: 'Tầng'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tầng';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    floor = int.tryParse(value!) ?? floor;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Khu vực'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập khu vực';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    area = value!;
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Trạng thái'),
                  value: 'available',
                  items: const [
                    DropdownMenuItem(
                      value: 'available',
                      child: Text('Sẵn sàng'),
                    ),
                    DropdownMenuItem(
                      value: 'occupied',
                      child: Text('Đang bận'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      status = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn trạng thái';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    status = value!;
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
                  child: const Text('Thêm Bàn'),
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

class EditTableScreen extends StatefulWidget {
  final Map<String, dynamic> tableItem;
  final dynamic table;

  const EditTableScreen({
    super.key,
    required this.tableItem,
    required this.table,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EditTableScreenState createState() => _EditTableScreenState();
}

class _EditTableScreenState extends State<EditTableScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name, area, status;
  late int floor;

  @override
  void initState() {
    super.initState();
    name = widget.tableItem['name'] ?? 'Không có';
    floor = widget.tableItem['floor'] ?? 0;
    area = widget.tableItem['area'] ?? 'Không có';
    status = widget.tableItem['status'] ?? 'available';
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      updateTable(
        id: widget.tableItem['id'] as int,
        name: name,
        floor: floor,
        area: area,
        status: status,
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
                  initialValue: widget.tableItem['id'].toString(),
                  decoration: const InputDecoration(labelText: 'Mã bàn'),
                  readOnly: true,
                ),
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(labelText: 'Tên bàn'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên bàn';
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
                  initialValue: floor.toString(),
                  decoration: const InputDecoration(labelText: 'Tầng'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tầng';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    floor = int.tryParse(value!) ?? floor;
                  },
                ),
                TextFormField(
                  initialValue: area,
                  decoration: const InputDecoration(labelText: 'Khu vực'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập khu vực';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    area = value!;
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Trạng thái'),
                  value: status,
                  items: const [
                    DropdownMenuItem(
                      value: 'available',
                      child: Text('Sẵn sàng'),
                    ),
                    DropdownMenuItem(
                      value: 'occupied',
                      child: Text('Đang bận'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      status = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn trạng thái';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    status = value!;
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
                  child: const Text('Lưu thay đổi'),
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
