import 'package:coffeeapp/models/bills_model.dart';
import 'package:coffeeapp/views/screens/curd/order_items_screen.dart';
import 'package:flutter/material.dart';
import '../../../controllers/bills_controller.dart';
import '../../../responsive.dart'; // Import the Responsive widget
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BillsScreenState createState() => _BillsScreenState();
}

late Future<List<dynamic>> billsList;
String searchText = '';
bool sortAscending = true;
int sortColumnIndex = 0;

class _BillsScreenState extends State<BillsScreen> {
  @override
  void initState() {
    super.initState();
    billsList = searchBills();
  }

  Future<void> _refreshBillsList([String? paymentMethod]) async {
    var temp = searchBills(paymentMethod);
    setState(() {
      billsList = temp;
    });
  }

  void _sort<T>(Comparable<T> Function(dynamic bill) getField, int columnIndex,
      bool ascending) {
    setState(() {
      sortColumnIndex = columnIndex;
      sortAscending = ascending;
      billsList = billsList.then((bills) {
        bills.sort((a, b) {
          if (!ascending) {
            final dynamic c = a;
            a = b;
            b = c;
          }
          final Comparable<T> aValue = getField(a);
          final Comparable<T> bValue = getField(b);
          return Comparable.compare(aValue, bValue);
        });
        return bills;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý hóa đơn'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 300,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm hóa đơn...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                    _refreshBillsList(searchText);
                  });
                },
              ),
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Thêm hóa đơn'),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) => const AddBillScreen(),
              );
              _refreshBillsList();
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.file_download),
            label: const Text('Xuất Excel'),
            onPressed: () async {
              await exportBillsToExcel();
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.file_upload),
            label: const Text('Nhập Excel'),
            onPressed: () async {
              await importBillsFromExcel();
              _refreshBillsList();
            },
          ),
        ],
      ),
      body: Responsive(
        mobile: _buildBillsList(context),
        tablet: _buildBillsList(context),
        desktop: _buildBillsList(context),
      ),
    );
  }

  Future<void> exportBillsToExcel() async {
    try {
      var excel = Excel.createExcel();
      excel.rename('Sheet1', 'Hóa đơn');
      Sheet sheetObject = excel['Hóa đơn'];
      sheetObject.appendRow([
        TextCellValue('Mã hóa đơn'),
        TextCellValue('Mã đơn hàng'),
        TextCellValue('Thành tiền'),
        TextCellValue('Phương thức thanh toán'),
        TextCellValue('Ngày thanh toán'),
      ]);

      // Lấy dữ liệu hóa đơn
      final billsData = await billsList;
      for (var item in billsData) {
        sheetObject.appendRow([
          IntCellValue(item['id']),
          TextCellValue(item['order_id']?.toString() ?? 'Không có'),
          TextCellValue(
              '${double.tryParse(item['total_amount'].toString()) ?? 0.0} VNĐ'),
          TextCellValue(item['payment_method'] == 'card' ? 'Thẻ' : 'Tiền mặt'),
          TextCellValue(item['payment_date'] ?? 'Không có'),
        ]);
      }

      // Tạo tên file với ngày hiện tại
      String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String fileName = "bills_$currentDate.xlsx";

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
                Text('Dữ liệu hóa đơn đã được xuất thành công: $fileName')),
      );
    } catch (e) {
      // Thông báo lỗi
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xuất Excel: $e')),
      );
    }
  }

  Future<void> importBillsFromExcel() async {
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
            await addBill(
              orderId: int.parse(row[1]?.value.toString() ?? '0'),
              totalAmount: double.parse(row[2]?.value.toString() ?? '0.0'),
              paymentMethod: row[3]?.value.toString() ?? 'Không có',
              paymentDate: row[4]?.value.toString() ?? 'Không có',
            );
          }
        }

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Dữ liệu hóa đơn đã được nhập thành công!')),
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

  Widget _buildBillsList(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: billsList,
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
              double columnWidth = totalWidth / 4; // 6 là tổng số cột hiện có

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columnSpacing: 12,
                  // ignore: deprecated_member_use
                  dataRowHeight: 100,
                  showCheckboxColumn: false, // Tắt dấu checkbox ở dòng đầu tiên
                  sortColumnIndex: sortColumnIndex,
                  sortAscending: sortAscending,
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
                      onSort: (columnIndex, ascending) => _sort(
                          (bill) => bill['order_id'], columnIndex, ascending),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'Thành tiền',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                      onSort: (columnIndex, ascending) => _sort(
                          (bill) => bill['total_amount'],
                          columnIndex,
                          ascending),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'Phương thức thanh toán',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                      onSort: (columnIndex, ascending) => _sort(
                          (bill) => bill['payment_method'],
                          columnIndex,
                          ascending),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'Ngày thanh toán',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                      onSort: (columnIndex, ascending) => _sort(
                          (bill) => bill['payment_date'],
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
                        DataCell(Text(
                            snapshot.data![index]['order_id']?.toString() ??
                                'Không có')),
                        DataCell(Text(
                            '${snapshot.data![index]['total_amount']?.toString() ?? 'Không có'} VND')),
                        DataCell(Text(snapshot.data![index]['payment_method'] ==
                                'card'
                            ? 'Thẻ'
                            : (snapshot.data![index]['payment_method'] == 'cash'
                                ? 'Tiền mặt'
                                : 'Không có'))),
                        DataCell(Text(snapshot.data![index]['payment_date'] ??
                            'Không có')),
                      ],
                      onSelectChanged: (selected) {
                        if (selected != null && selected) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderItemsScreen(
                                orderId: snapshot.data![index]['order_id']
                                    .toString(),
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

class AddBillScreen extends StatefulWidget {
  const AddBillScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddBillScreenState createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();
  late String orderId, totalAmount, paymentMethod;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      addBill(
        orderId: int.parse(orderId),
        totalAmount: double.parse(totalAmount),
        paymentMethod: paymentMethod,
        paymentDate: DateTime.now().toString(),
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
                  decoration: const InputDecoration(labelText: 'Mã đơn hàng'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mã đơn hàng';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      orderId = value;
                    }
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Tổng tiền'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tổng tiền';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    totalAmount = value!;
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                      labelText: 'Phương thức thanh toán'),
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('Tiền mặt')),
                    DropdownMenuItem(value: 'card', child: Text('Thẻ')),
                  ],
                  onChanged: (value) {
                    paymentMethod = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn phương thức thanh toán';
                    }
                    return null;
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
                  child: const Text('Thêm hóa đơn'),
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

class EditBillScreen extends StatefulWidget {
  final Map<String, dynamic> billItem;
  final dynamic bill;

  const EditBillScreen({
    super.key,
    required this.billItem,
    required this.bill,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EditBillScreenState createState() => _EditBillScreenState();
}

class _EditBillScreenState extends State<EditBillScreen> {
  final _formKey = GlobalKey<FormState>();
  late String orderId, totalAmount, paymentMethod;
  late DateTime paymentDate;

  @override
  void initState() {
    super.initState();
    orderId = widget.billItem['order_id']?.toString() ?? 'Không có';
    totalAmount = widget.billItem['total_amount']?.toString() ?? 'Không có';
    paymentMethod = widget.billItem['payment_method'] ?? 'Không có';
    paymentDate = DateTime.parse(widget.billItem['payment_date'] ?? 'Không có');
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      updateBill(
        id: widget.billItem['id'],
        orderId: int.parse(orderId),
        totalAmount: double.parse(totalAmount),
        paymentMethod: paymentMethod,
        paymentDate: paymentDate.toString(),
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
                  initialValue: widget.billItem['id'].toString(),
                  decoration: const InputDecoration(labelText: 'Mã hóa đơn'),
                  readOnly: true,
                ),
                TextFormField(
                  initialValue: orderId,
                  decoration: const InputDecoration(labelText: 'Mã đơn hàng'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mã đơn hàng';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      orderId = value;
                    }
                  },
                ),
                TextFormField(
                  initialValue: totalAmount,
                  decoration: const InputDecoration(labelText: 'Tổng tiền'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tổng tiền';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    totalAmount = value!;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: paymentMethod,
                  decoration: const InputDecoration(
                      labelText: 'Phương thức thanh toán'),
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('Tiền mặt')),
                    DropdownMenuItem(value: 'card', child: Text('Thẻ')),
                  ],
                  onChanged: (value) {
                    paymentMethod = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn phương thức thanh toán';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: paymentDate.toString(),
                  decoration:
                      const InputDecoration(labelText: 'Ngày thanh toán'),
                  readOnly: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Green for Save
                  ),
                  child: const Text('Lưu hóa đơn'),
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
