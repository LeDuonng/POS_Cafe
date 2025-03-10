import 'package:coffeeapp/models/orders_model.dart' as controller;
import 'package:coffeeapp/controllers/orders_controller.dart';
import 'package:coffeeapp/models/staff_model.dart';
import 'package:coffeeapp/models/tables_model.dart';
import 'package:coffeeapp/models/users_model.dart';
import 'package:coffeeapp/views/screens/curd/order_items_screen.dart';
import 'package:flutter/material.dart';
import '../../../responsive.dart'; // Import the Responsive widget
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OrdersScreenState createState() => _OrdersScreenState();
}

late Future<List<dynamic>> ordersList;
String searchText = '';

class _OrdersScreenState extends State<OrdersScreen> {
  bool _sortAscending = true;
  int _sortColumnIndex = 0;

  @override
  void initState() {
    super.initState();
    ordersList = controller.searchOrders();
  }

  Future<void> _refreshOrdersList([String? orderId]) async {
    var temp = controller.searchOrders(orderId);
    setState(() {
      ordersList = temp;
    });
  }

  void _sort<T>(Comparable<T> Function(dynamic order) getField, int columnIndex,
      bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      ordersList = ordersList.then((orders) {
        orders.sort((a, b) {
          if (!ascending) {
            final dynamic c = a;
            a = b;
            b = c;
          }
          final Comparable<T> aValue = getField(a);
          final Comparable<T> bValue = getField(b);
          return Comparable.compare(aValue, bValue);
        });
        return orders;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý đơn hàng'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 300,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm đơn hàng...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                    _refreshOrdersList(searchText);
                  });
                },
              ),
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Thêm đơn hàng'),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) => const AddOrderScreen(),
              );
              _refreshOrdersList();
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.file_download),
            label: const Text('Xuất Excel'),
            onPressed: () {
              exportOrdersToExcel();
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.file_upload),
            label: const Text('Nhập Excel'),
            onPressed: () async {
              await importOrdersFromExcel();
              _refreshOrdersList();
            },
          ),
        ],
      ),
      body: Responsive(
        mobile: _buildOrdersList(context),
        tablet: _buildOrdersList(context),
        desktop: _buildOrdersList(context),
      ),
    );
  }

  Future<void> exportOrdersToExcel() async {
    try {
      var excel = Excel.createExcel();
      excel.rename('Sheet1', 'Đơn hàng');
      Sheet sheetObject = excel['Đơn hàng'];
      sheetObject.appendRow([
        TextCellValue('Mã đơn hàng'),
        TextCellValue('Bàn'),
        TextCellValue('Khách hàng'),
        TextCellValue('Nhân viên phục vụ'),
        TextCellValue('Trạng thái'),
        TextCellValue('Mô tả'),
      ]);

      // Lấy dữ liệu đơn hàng
      final ordersData = await ordersList;
      for (var item in ordersData) {
        sheetObject.appendRow([
          IntCellValue(item['id']),
          TextCellValue(item['table_id'] != null
              ? await getNameTableById(int.parse(item['table_id'].toString()))
              : 'Không có'),
          TextCellValue(item['customer_id'] != null
              ? await getNameUserById(int.parse(item['customer_id'].toString()))
              : 'Không có'),
          TextCellValue(item['staff_id'] != null
              ? await getNameStaffById(int.parse(item['staff_id'].toString()))
              : 'Không có'),
          TextCellValue(item['status'] ?? 'Không có'),
          TextCellValue(item['description'] ?? 'Không có'),
        ]);
      }

      // Tạo tên file với ngày hiện tại
      String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String fileName = "orders_$currentDate.xlsx";

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
                Text('Dữ liệu đơn hàng đã được xuất thành công: $fileName')),
      );
    } catch (e) {
      // Thông báo lỗi
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xuất Excel: $e')),
      );
    }
  }

  Future<void> importOrdersFromExcel() async {
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
            await addOrder(
              tableId: int.parse(row[2]?.value.toString() ?? '0'),
              customerId: int.parse(row[3]?.value.toString() ?? '0'),
              staffId: int.parse(row[4]?.value.toString() ?? '0'),
              orderDate: DateTime.now(), // Assuming current date for simplicity
              status: row[5]?.value.toString() ?? 'Không có',
              description: row[6]?.value.toString() ?? 'Không có',
            );
          }
        }

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Dữ liệu đơn hàng đã được nhập thành công!')),
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

  Widget _buildOrdersList(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: ordersList,
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
              double columnWidth = totalWidth / 6.5;

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columnSpacing: 12,
                  // ignore: deprecated_member_use
                  dataRowHeight: 100,
                  showCheckboxColumn: false, // Tắt dấu checkbox ở dòng đầu tiên
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  columns: [
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'Mã đơn hàng',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                      onSort: (columnIndex, ascending) => _sort<num>(
                          (order) => order['id'], columnIndex, ascending),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'Bàn',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                      onSort: (columnIndex, ascending) => _sort<String>(
                          (order) => order['table_name'] ?? 'Không có',
                          columnIndex,
                          ascending),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'Khách hàng',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                      onSort: (columnIndex, ascending) => _sort<String>(
                          (order) => order['customer_name'] ?? 'Không có',
                          columnIndex,
                          ascending),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'Nhân viên phục vụ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                      onSort: (columnIndex, ascending) => _sort<String>(
                          (order) => order['staff_name'] ?? 'Không có',
                          columnIndex,
                          ascending),
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
                      onSort: (columnIndex, ascending) => _sort<String>(
                          (order) => order['status'] ?? 'Không có',
                          columnIndex,
                          ascending),
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
                      onSort: (columnIndex, ascending) => _sort<String>(
                          (order) => order['description'] ?? 'Không có',
                          columnIndex,
                          ascending),
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
                        DataCell(Text(snapshot.data![index]['id']?.toString() ??
                            'Không có')),
                        DataCell(Text(
                            snapshot.data![index]['table_name']?.toString() ??
                                'Không có')),
                        DataCell(Text(snapshot.data![index]['customer_name']
                                ?.toString() ??
                            'Không có')),
                        DataCell(Text(
                            snapshot.data![index]['staff_name']?.toString() ??
                                'Không có')),
                        DataCell(Text(
                          snapshot.data![index]['status'] == 'paid'
                              ? 'Đã nhận đơn'
                              : snapshot.data![index]['status'] == 'preparing'
                                  ? 'Đang chuẩn bị'
                                  : 'Đã hoàn thành',
                        )),
                        DataCell(Text(snapshot.data![index]['description'] ??
                            'Không có mô tả')),
                      ],
                      onSelectChanged: (selected) {
                        if (selected != null && selected) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderItemsScreen(
                                orderId: snapshot.data![index]['id'].toString(),
                              ),
                            ),
                          );
                        }
                      },
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

class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddOrderScreenState createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  late int tableId, customerId, staffId;
  late String status = 'paid';
  late String description;
  late DateTime orderDate;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      addOrder(
        tableId: tableId,
        customerId: customerId,
        staffId: staffId,
        orderDate: orderDate,
        status: status,
        description: description,
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
                  decoration: const InputDecoration(labelText: 'Mã bàn'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mã bàn';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    tableId = int.parse(value!);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Mã khách hàng'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mã khách hàng';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    customerId = int.parse(value!);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Mã nhân viên'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mã nhân viên';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    staffId = int.parse(value!);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Ngày đặt hàng'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn ngày đặt hàng';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    orderDate = DateTime.parse(value!);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  onSaved: (value) {
                    description = value!;
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
                  child: const Text('Thêm đơn hàng'),
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

class EditOrderScreen extends StatefulWidget {
  final Map<String, dynamic> orderItem;
  final dynamic order;

  const EditOrderScreen({
    super.key,
    required this.orderItem,
    required this.order,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EditOrderScreenState createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  late int tableId, customerId, staffId;
  late String status = 'paid';
  late String description;
  late DateTime orderDate;

  @override
  void initState() {
    super.initState();
    tableId = widget.orderItem['table_id'] ?? 0;
    staffId = widget.orderItem['staff_id'] ?? 0;

    orderDate = widget.orderItem['order_date'] != null
        ? DateTime.parse(widget.orderItem['order_date'])
        : DateTime.now();

    description = widget.order['description'] ?? 'Không có';
    status = widget.orderItem['status'] ?? 'paid';
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      updateOrder(
        id: widget.orderItem['id'],
        tableId: tableId,
        customerId: customerId,
        staffId: staffId,
        orderDate: orderDate,
        status: status,
        description: description,
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
                  initialValue: widget.orderItem['id'].toString(),
                  decoration: const InputDecoration(labelText: 'Mã đơn hàng'),
                  readOnly: true,
                ),
                TextFormField(
                  initialValue: tableId.toString(),
                  decoration: const InputDecoration(labelText: 'Mã bàn'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mã bàn';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    tableId = int.parse(value!);
                  },
                ),
                TextFormField(
                  initialValue: customerId.toString(),
                  decoration: const InputDecoration(labelText: 'Mã khách hàng'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mã khách hàng';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    customerId = int.parse(value!);
                  },
                ),
                TextFormField(
                  initialValue: staffId.toString(),
                  decoration: const InputDecoration(labelText: 'Mã nhân viên'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mã nhân viên';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    staffId = int.parse(value!);
                  },
                ),
                TextFormField(
                  initialValue: orderDate.toString(),
                  decoration: const InputDecoration(labelText: 'Ngày đặt hàng'),
                  readOnly: true,
                ),
                TextFormField(
                  initialValue: description,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  onSaved: (value) {
                    description = value!;
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
