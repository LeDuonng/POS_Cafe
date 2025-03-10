import 'package:coffeeapp/models/menu_model.dart';
import 'package:coffeeapp/models/order_items_model.dart';
import 'package:flutter/material.dart';
import '../../../controllers/order_items_controller.dart';
import '../../../responsive.dart'; // Import the Responsive widget
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';

class OrderItemsScreen extends StatefulWidget {
  final String orderId;
  const OrderItemsScreen({super.key, required this.orderId});

  @override
  // ignore: library_private_types_in_public_api
  _OrderItemsScreenState createState() => _OrderItemsScreenState();
}

late Future<List<dynamic>> orderItemsList;
String searchText = '';
bool sortAscending = true;
int sortColumnIndex = 0;

class _OrderItemsScreenState extends State<OrderItemsScreen> {
  @override
  void initState() {
    super.initState();
    orderItemsList = searchOrderItems(orderId: widget.orderId);
  }

  Future<void> _refreshOrderItemsList() async {
    var temp = searchText.isNotEmpty
        ? searchOrderItems(orderId: widget.orderId, textsearch: searchText)
        : searchOrderItems(orderId: widget.orderId);
    setState(() {
      orderItemsList = temp;
    });
  }

  void _sort<T>(Comparable<T> Function(dynamic d) getField, int columnIndex,
      bool ascending) {
    setState(() {
      sortColumnIndex = columnIndex;
      sortAscending = ascending;
      orderItemsList = orderItemsList.then((list) {
        list.sort((a, b) {
          if (!ascending) {
            final dynamic c = a;
            a = b;
            b = c;
          }
          final Comparable<T> aValue = getField(a);
          final Comparable<T> bValue = getField(b);
          return Comparable.compare(aValue, bValue);
        });
        return list;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Đơn Hàng'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 300,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm đon hàng...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                    _refreshOrderItemsList();
                  });
                },
              ),
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.file_download),
            label: const Text('Xuất Excel'),
            onPressed: () {
              exportOrderItemsToExcel();
            },
          ),
        ],
      ),
      body: Responsive(
        mobile: _buildOrderItemsList(context),
        tablet: _buildOrderItemsList(context),
        desktop: _buildOrderItemsList(context),
      ),
    );
  }

  Future<void> exportOrderItemsToExcel() async {
    try {
      var excel = Excel.createExcel();
      excel.rename('Sheet1', 'Chi tiết đơn hàng');
      Sheet sheetObject = excel['Chi tiết đơn hàng'];
      sheetObject.appendRow([
        TextCellValue('Mã đơn hàng'),
        TextCellValue('Tên sản phẩm'),
        TextCellValue('Số lượng'),
        TextCellValue('Giá'),
        TextCellValue('Mô tả'),
      ]);

      final orderItemsData = await orderItemsList;
      for (var item in orderItemsData) {
        sheetObject.appendRow([
          TextCellValue(item['order_id']?.toString() ?? 'Không có'),
          TextCellValue(
              await getNameMenuItemById(int.parse(item['menu_id'].toString()))),
          IntCellValue(item['quantity']),
          DoubleCellValue(double.tryParse(item['price'].toString()) ?? 0.0),
          TextCellValue(item['description']?.toString() ?? 'Không có'),
        ]);
      }

      String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String fileName = "order_items_$currentDate.xlsx";

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
            content:
                Text('Dữ liệu order items đã được xuất thành công: $fileName')),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xuất Excel: $e')),
      );
    }
  }

  Future<void> importOrderItemsFromExcel() async {
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
            await addOrderItem(
              orderId: int.parse(row[1]?.value.toString() ?? '0'),
              menuId: int.parse(row[2]?.value.toString() ?? '0'),
              quantity: int.parse(row[3]?.value.toString() ?? '0'),
              price: double.parse(row[4]?.value.toString() ?? '0.0'),
            );
          }
        }

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Dữ liệu order items đã được nhập thành công!')),
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

  Widget _buildOrderItemsList(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: orderItemsList,
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
              double columnWidth = totalWidth / 5.5;

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  sortColumnIndex: sortColumnIndex,
                  sortAscending: sortAscending,
                  columnSpacing: 12,
                  // ignore: deprecated_member_use
                  dataRowHeight: 100,
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
                      onSort: (columnIndex, ascending) =>
                          _sort((d) => d['order_id'], columnIndex, ascending),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'Tên sản phẩm',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                      onSort: (columnIndex, ascending) =>
                          _sort((d) => d['menu_name'], columnIndex, ascending),
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
                      onSort: (columnIndex, ascending) =>
                          _sort((d) => d['quantity'], columnIndex, ascending),
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
                      onSort: (columnIndex, ascending) =>
                          _sort((d) => d['price'], columnIndex, ascending),
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
                      onSort: (columnIndex, ascending) => _sort(
                          (d) => d['description'], columnIndex, ascending),
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
                                '0')),
                        DataCell(Text(
                          snapshot.data![index]['del'].toString() == '1'
                              ? '${snapshot.data![index]['menu_name']?.toString() ?? ''} (sản phẩm đã xóa)'
                              : snapshot.data![index]['menu_name']
                                      ?.toString() ??
                                  '',
                        )),
                        DataCell(Text(
                            snapshot.data![index]['quantity']?.toString() ??
                                '0')),
                        DataCell(Text(
                            snapshot.data![index]['price']?.toString() ?? '0')),
                        DataCell(Text(
                            snapshot.data![index]['description']?.toString() ??
                                '0')),
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
