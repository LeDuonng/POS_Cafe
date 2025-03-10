import 'package:coffeeapp/models/customer_points_model.dart';
import 'package:coffeeapp/models/users_model.dart';
import 'package:coffeeapp/views/widgets/nofication.dart';
import 'package:flutter/material.dart';
import '../../../controllers/customer_points_controller.dart';
import '../../../responsive.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';

class CustomerPointsScreen extends StatefulWidget {
  const CustomerPointsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CustomerPointsScreenState createState() => _CustomerPointsScreenState();
}

late Future<List<dynamic>> customerPointsList;
String searchText = '';

class _CustomerPointsScreenState extends State<CustomerPointsScreen> {
  @override
  void initState() {
    super.initState();
    customerPointsList = searchCustomerPoints();
  }

  Future<void> _refreshCustomerPointsList([String? userId]) async {
    var temp = searchCustomerPoints(userId);
    setState(() {
      customerPointsList = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Điểm Tích Luỹ Khách Hàng'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 300,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                    _refreshCustomerPointsList(searchText);
                  });
                },
              ),
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Thêm Điểm Tích Luỹ'),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) => const AddCustomerPointsScreen(),
              );
              _refreshCustomerPointsList();
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.file_download),
            label: const Text('Xuất Excel'),
            onPressed: () async {
              await exportCustomerPointsToExcel();
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.file_upload),
            label: const Text('Nhập Excel'),
            onPressed: () async {
              await importCustomerPointsFromExcel();
              _refreshCustomerPointsList();
            },
          ),
        ],
      ),
      body: Responsive(
        mobile: _buildCustomerPointsList(context),
        tablet: _buildCustomerPointsList(context),
        desktop: _buildCustomerPointsList(context),
      ),
    );
  }

  Future<void> exportCustomerPointsToExcel() async {
    try {
      var excel = Excel.createExcel();
      excel.rename('Sheet1', 'Điểm tích luỹ khách hàng');
      Sheet sheetObject = excel['Điểmm tích luỹ khách hàng'];
      sheetObject.appendRow([
        TextCellValue('Mã Điểm Tích Luỹ'),
        TextCellValue('Khách Hàng'),
        TextCellValue('Điểm Tích Luỹ'),
      ]);

      // Lấy dữ liệu customer points
      final customerPointsData = await customerPointsList;
      for (var item in customerPointsData) {
        sheetObject.appendRow([
          IntCellValue(item['id'] ?? 0),
          TextCellValue(await getNameUserById(
              int.parse(item['user_id']?.toString() ?? 'Không có'))),
          TextCellValue(item['points']?.toString() ?? 'Không có'),
        ]);
      }

      // Tạo tên file với ngày hiện tại
      String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String fileName = "customer_points_$currentDate.xlsx";

      // Tạo file Excel
      final excelBytes = excel.save();
      final blob = html.Blob([Uint8List.fromList(excelBytes!)],
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Tải file về với tên chứa ngày hiện tại
      html.Url.revokeObjectUrl(url);

      // Thông báo thành công
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Dữ liệu điểm tích luỹ khách hàng đã được xuất thành công: $fileName')),
      );
    } catch (e) {
      // Thông báo lỗi
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xuất Excel: $e')),
      );
    }
  }

  Future<void> importCustomerPointsFromExcel() async {
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
            await addCustomerPoints(
              userId: int.parse(row[1]?.value.toString() ?? '0'),
              points: int.parse(row[2]?.value.toString() ?? '0'),
            );
          }
        }

        // ignore: avoid_print
        print('Nhập Excel thành công!');
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Dữ liệu điểm tích luỹ khách hàng đã được nhập thành công!')),
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

  Widget _buildCustomerPointsList(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: customerPointsList,
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
              double columnWidth = totalWidth / 3; // 4 là tổng số cột hiện có

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
                        child: const Center(
                          child: Text(
                            'Khách hàng',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.brown,
                            ),
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Center(
                          child: Text(
                            'Điểm tích luỹ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.brown,
                            ),
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Center(
                          child: Text(
                            'Hành động',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.brown,
                            ),
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
                        DataCell(Center(
                          child: Text(
                              snapshot.data![index]['user_name']?.toString() ??
                                  'Không có'),
                        )),
                        DataCell(Center(
                          child: Text(
                              snapshot.data![index]['points']?.toString() ??
                                  'Không có'),
                        )),
                        DataCell(
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () async {
                                    await showDialog(
                                      context: context,
                                      builder: (context) =>
                                          EditCustomerPointsScreen(
                                        customerPoints: snapshot.data![index],
                                        customerPointsItem: {
                                          'id': snapshot.data![index]['id'],
                                          'user_id': snapshot.data![index]
                                              ['user_id'],
                                          'points': snapshot.data![index]
                                              ['points'],
                                        },
                                      ),
                                    );
                                    _refreshCustomerPointsList();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Xác nhận xoá'),
                                          content: const Text(
                                              'Bạn có chắc chắn muốn xoá điểm tích luỹ này không?'),
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
                                                    deleteCustomerPoints(
                                                        snapshot.data![index]
                                                            ['id']);
                                                    snapshot.data!
                                                        .removeAt(index);
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(
                                                            context)
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

class AddCustomerPointsScreen extends StatefulWidget {
  const AddCustomerPointsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddCustomerPointsScreenState createState() =>
      _AddCustomerPointsScreenState();
}

class _AddCustomerPointsScreenState extends State<AddCustomerPointsScreen> {
  final _formKey = GlobalKey<FormState>();
  late int userId;
  late String points;
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save the form fields
      addCustomerPoints(
        userId: userId,
        points: points as int,
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
                  decoration: const InputDecoration(labelText: 'Mã Khách Hàng'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mã khách hàng';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    try {
                      userId = int.parse(value!);
                    } catch (e) {
                      ToastNotification.showToast(
                          message: 'Lỗi mã khách hàng: $e');
                    }
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Điểm tích luỹ'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập điểm tích luỹ';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    try {
                      points = value!;
                    } catch (e) {
                      ToastNotification.showToast(
                          message: 'Lỗi điểm tích luỹ: $e');
                    }
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
                  child: const Text('Thêm Điểm Tích Luỹ'),
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

class EditCustomerPointsScreen extends StatefulWidget {
  final Map<String, dynamic> customerPointsItem;
  final dynamic customerPoints;

  const EditCustomerPointsScreen({
    super.key,
    required this.customerPointsItem,
    required this.customerPoints,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EditCustomerPointsScreenState createState() =>
      _EditCustomerPointsScreenState();
}

class _EditCustomerPointsScreenState extends State<EditCustomerPointsScreen> {
  final _formKey = GlobalKey<FormState>();
  late int userId;
  late int points;

  @override
  void initState() {
    super.initState();
    userId = widget.customerPointsItem['user_id'] ?? 'Không có';
    points = widget.customerPointsItem['points'] ?? 'Không có';
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save the form fields
      updateCustomerPoints(
        id: widget.customerPointsItem['id'],
        points: points,
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
                  initialValue: widget.customerPointsItem['id'].toString(),
                  decoration:
                      const InputDecoration(labelText: 'Mã Điểm Tích Luỹ'),
                  readOnly: true,
                ),
                TextFormField(
                  initialValue: widget.customerPointsItem['user_id'].toString(),
                  decoration: const InputDecoration(labelText: 'Mã Khách Hàng'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mã khách hàng';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    try {
                      userId = int.parse(value!);
                    } catch (e) {
                      ToastNotification.showToast(
                          message: 'Lỗi mã khách hàng: $e');
                    }
                  },
                ),
                TextFormField(
                  initialValue: widget.customerPointsItem['points'].toString(),
                  decoration: const InputDecoration(labelText: 'Điểm Tích Luỹ'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập điểm tích luỹ';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    try {
                      points = value! as int;
                    } catch (e) {
                      ToastNotification.showToast(
                          message: 'Lỗi điểm tích luỹ: $e');
                    }
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
                  child: const Text('Lưu Thay Đổi'),
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
