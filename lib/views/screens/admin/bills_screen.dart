import 'package:coffeeapp/models/bills_model.dart';
import 'package:coffeeapp/views/screens/curd/order_items_screen.dart';
import 'package:flutter/material.dart';
import '../../../responsive.dart'; // Import the Responsive widget
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
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
String sortColumn = 'order_id';
bool isAscending = true;

class _BillsScreenState extends State<BillsScreen> {
  @override
  void initState() {
    super.initState();
    billsList = searchBillsWithDetails();
  }

  Future<void> _refreshBillsList([String? search]) async {
    try {
      var temp = searchBillsWithDetails(search);
      setState(() {
        billsList = temp;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lọc hoặc sắp xếp: $e')),
      );
    }
  }

  void _sortBills(String column) {
    setState(() {
      if (sortColumn == column) {
        isAscending = !isAscending;
      } else {
        sortColumn = column;
        isAscending = true;
      }
      _refreshBillsList(searchText);
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
            icon: const Icon(Icons.file_download),
            label: const Text('Xuất Excel'),
            onPressed: () async {
              await exportBillsToExcel();
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
        TextCellValue('Mã đơn hàng'),
        TextCellValue('Khách hàng'),
        TextCellValue('Nhân viên'),
        TextCellValue('Bàn'),
        TextCellValue('Thành tiền'),
        TextCellValue('Phương thức thanh toán'),
        TextCellValue('Ngày thanh toán'),
        TextCellValue('Mô tả'),
      ]);

      // Lấy dữ liệu hóa đơn
      final billsData = await billsList;
      for (var item in billsData) {
        sheetObject.appendRow([
          TextCellValue(item['order_id']?.toString() ?? 'Không có'),
          TextCellValue(item['customer_name']?.toString() ?? 'Không có'),
          TextCellValue(item['staff_name']?.toString() ?? 'Không có'),
          TextCellValue(item['table_name']?.toString() ?? 'Không có'),
          TextCellValue(
              '${double.tryParse(item['total_amount'].toString()) ?? 0.0} VNĐ'),
          TextCellValue(item['payment_method'] == 'card' ? 'Thẻ' : 'Tiền mặt'),
          TextCellValue(item['payment_date'] ?? 'Không có'),
          TextCellValue(item['description'] ?? 'Không có'),
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
          List<dynamic> sortedData = snapshot.data!;
          sortedData.sort((a, b) {
            var aValue = a[sortColumn];
            var bValue = b[sortColumn];
            if (aValue is String && bValue is String) {
              return isAscending
                  ? aValue.compareTo(bValue)
                  : bValue.compareTo(aValue);
            } else if (aValue is num && bValue is num) {
              return isAscending
                  ? aValue.compareTo(bValue)
                  : bValue.compareTo(aValue);
            } else {
              return 0;
            }
          });

          return LayoutBuilder(
            builder: (context, constraints) {
              double totalWidth = constraints.maxWidth;
              double columnWidth = totalWidth / 9.5; // 7 là tổng số cột hiện có

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columnSpacing: 12,
                  // ignore: deprecated_member_use
                  dataRowHeight: 100,
                  showCheckboxColumn: false, // Tắt dấu checkbox ở dòng đầu tiên

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
                      onSort: (columnIndex, _) {
                        _sortBills('order_id');
                      },
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
                      onSort: (columnIndex, _) {
                        _sortBills('customer_name');
                      },
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'Nhân viên',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                      onSort: (columnIndex, _) {
                        _sortBills('staff_name');
                      },
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
                      onSort: (columnIndex, _) {
                        _sortBills('table_name');
                      },
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
                      onSort: (columnIndex, _) {
                        _sortBills('total_amount');
                      },
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
                      onSort: (columnIndex, _) {
                        _sortBills('payment_method');
                      },
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
                      onSort: (columnIndex, _) {
                        _sortBills('payment_date');
                      },
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
                  ],
                  rows: List.generate(sortedData.length, (index) {
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
                            sortedData[index]['order_id']?.toString() ??
                                'Không có')),
                        DataCell(Text(
                            sortedData[index]['customer_name']?.toString() ??
                                'Không có')),
                        DataCell(Text(
                            sortedData[index]['staff_name']?.toString() ??
                                'Không có')),
                        DataCell(Text(
                            sortedData[index]['table_name']?.toString() ??
                                'Không có')),
                        DataCell(Text(
                            '${sortedData[index]['total_amount']?.toString() ?? 'Không có'} VND')),
                        DataCell(Text(
                            sortedData[index]['payment_method'] == 'card'
                                ? 'Thẻ'
                                : (sortedData[index]['payment_method'] == 'cash'
                                    ? 'Tiền mặt'
                                    : 'Không có'))),
                        DataCell(Text(
                            sortedData[index]['payment_date'] ?? 'Không có')),
                        DataCell(Text(
                            sortedData[index]['description'] ?? 'Không có')),
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
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Chức năng phụ'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.edit),
                                    title: const Text('Chỉnh sửa hóa đơn'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      // Thêm chức năng chỉnh sửa hóa đơn tại đây
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.delete),
                                    title: const Text('Xóa hóa đơn'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      // Thêm chức năng xóa hóa đơn tại đây
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.print),
                                    title: const Text('Xuất lại hóa đơn'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Đóng'),
                                ),
                              ],
                            );
                          },
                        );
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
