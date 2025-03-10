import 'package:coffeeapp/models/staff_model.dart';
import 'package:flutter/material.dart';
import '../../../controllers/staff_controller.dart';
import '../../../responsive.dart'; // Import the Responsive widget
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StaffScreenState createState() => _StaffScreenState();
}

late Future<List<dynamic>> staffList;
String searchText = '';

class _StaffScreenState extends State<StaffScreen> {
  @override
  void initState() {
    super.initState();
    staffList = searchStaff();
  }

  Future<void> _refreshStaffList([String? searchText]) async {
    var temp = searchStaff(searchText);
    setState(() {
      staffList = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý nhân viên'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 300,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm nhân viên...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                    _refreshStaffList(searchText);
                  });
                },
              ),
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Thêm nhân viên'),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) => const AddStaffItemScreen(),
              );
              _refreshStaffList();
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.file_download),
            label: const Text('Xuất Excel'),
            onPressed: () {
              exportStaffToExcel();
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.file_upload),
            label: const Text('Nhập Excel'),
            onPressed: () async {
              await importStaffFromExcel();
              _refreshStaffList();
            },
          ),
        ],
      ),
      body: Responsive(
        mobile: _buildStaffList(context),
        tablet: _buildStaffList(context),
        desktop: _buildStaffList(context),
      ),
    );
  }

  Future<void> exportStaffToExcel() async {
    try {
      var excel = Excel.createExcel();
      excel.rename('Sheet1', 'Nhân viên');
      Sheet sheetObject = excel['Nhân viên'];
      sheetObject.appendRow([
        TextCellValue('Mã nhân viên'),
        TextCellValue('Tên nhân viên'),
        TextCellValue('Lương'),
        TextCellValue('Ngày bắt đầu'),
        TextCellValue('Vị trí'),
      ]);

      // Lấy dữ liệu nhân viên
      final staffData = await staffList;
      for (var item in staffData) {
        sheetObject.appendRow([
          IntCellValue(item['id']),
          TextCellValue(item['name'] ?? 'Không có'),
          DoubleCellValue(double.tryParse(item['salary'].toString()) ?? 0.0),
          TextCellValue(item['start_date'] ?? 'Không có'),
          TextCellValue(item['position'] ?? 'Không có'),
        ]);
      }

      // Tạo tên file với ngày hiện tại
      String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String fileName = "staff_$currentDate.xlsx";

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
                Text('Dữ liệu nhân viên đã được xuất thành công: $fileName')),
      );
    } catch (e) {
      // Thông báo lỗi
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xuất Excel: $e')),
      );
    }
  }

  Future<void> importStaffFromExcel() async {
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
            await addStaff(
              userId: int.parse(row[1]?.value.toString() ?? '0'),
              salary: double.parse(row[2]?.value.toString() ?? '0'),
              startDate: DateTime.parse(row[3]?.value.toString() ?? 'Không có'),
              position: row[4]?.value.toString() ?? 'Không có',
            );
          }
        }

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Dữ liệu nhân viên đã được nhập thành công!')),
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

  Widget _buildStaffList(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: staffList,
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
              double columnWidth = totalWidth / 5; // 6 là tổng số cột hiện có

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
                          'Tên nhân viên',
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
                          'Lương',
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
                          'Ngày bắt đầu',
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
                          'Vị trí',
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
                        DataCell(Text(
                            snapshot.data![index]['user_name']?.toString() ??
                                'Không có')),
                        DataCell(Text(
                            snapshot.data![index]['salary']?.toString() ??
                                'Không có')),
                        DataCell(Text(
                            snapshot.data![index]['start_date'] ?? 'Không có')),
                        DataCell(Text(
                            snapshot.data![index]['position'] ?? 'Không có')),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (context) => EditStaffItemScreen(
                                      staff: snapshot.data![index],
                                      staffItem: {
                                        'id': snapshot.data![index]['id'],
                                        'user_id': snapshot.data![index]
                                            ['user_id'],
                                        'salary': snapshot.data![index]
                                            ['salary'],
                                        'start_date': snapshot.data![index]
                                            ['start_date'],
                                        'position': snapshot.data![index]
                                            ['position'],
                                      },
                                    ),
                                  );
                                  _refreshStaffList();
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
                                            'Bạn có chắc chắn muốn xoá nhân viên này không?'),
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
                                                  deleteStaff(snapshot
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

class AddStaffItemScreen extends StatefulWidget {
  const AddStaffItemScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddStaffItemScreenState createState() => _AddStaffItemScreenState();
}

class _AddStaffItemScreenState extends State<AddStaffItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late String userId, salary, startDate, position;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      addStaff(
        userId: int.parse(userId),
        salary: double.parse(salary),
        startDate: DateTime.parse(startDate),
        position: position,
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
                  decoration: const InputDecoration(labelText: 'Mã nhân viên'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mã nhân viên';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      userId = value;
                    }
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Lương'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập lương';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    salary = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Ngày bắt đầu'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập ngày bắt đầu';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    startDate = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Vị trí'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập vị trí';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    position = value!;
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
                  child: const Text('Thêm nhân viên'),
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

class EditStaffItemScreen extends StatefulWidget {
  final Map<String, dynamic> staffItem;
  final dynamic staff;

  const EditStaffItemScreen({
    super.key,
    required this.staffItem,
    required this.staff,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EditStaffItemScreenState createState() => _EditStaffItemScreenState();
}

class _EditStaffItemScreenState extends State<EditStaffItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late String userId, salary, startDate, position;

  @override
  void initState() {
    super.initState();
    userId = widget.staffItem['user_id']?.toString() ?? 'Không có';
    salary = widget.staffItem['salary']?.toString() ?? 'Không có';
    startDate = widget.staffItem['start_date'] ?? 'Không có';
    position = widget.staffItem['position'] ?? 'Không có';
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      updateStaff(
        id: widget.staffItem['id'],
        userId: int.parse(userId),
        salary: double.parse(salary),
        startDate: DateTime.parse(startDate),
        position: position,
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
                  initialValue: widget.staffItem['id'].toString(),
                  decoration: const InputDecoration(labelText: 'ID'),
                  readOnly: true,
                ),
                TextFormField(
                  initialValue: userId,
                  decoration: const InputDecoration(labelText: 'Mã nhân viên'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mã nhân viên';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      userId = value;
                    }
                  },
                ),
                TextFormField(
                  initialValue: salary,
                  decoration: const InputDecoration(labelText: 'Lương'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập lương';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    salary = value!;
                  },
                ),
                TextFormField(
                  initialValue: startDate,
                  decoration: const InputDecoration(labelText: 'Ngày bắt đầu'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập ngày bắt đầu';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    startDate = value!;
                  },
                ),
                TextFormField(
                  initialValue: position,
                  decoration: const InputDecoration(labelText: 'Vị trí'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập vị trí';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    position = value!;
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
