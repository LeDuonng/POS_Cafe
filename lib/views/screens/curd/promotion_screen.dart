import 'package:coffeeapp/models/menu_model.dart';
import 'package:coffeeapp/models/promotion_model.dart';
import 'package:coffeeapp/views/widgets/nofication.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../responsive.dart'; // Import the Responsive widget
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';

class PromotionScreen extends StatefulWidget {
  const PromotionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PromotionScreenState createState() => _PromotionScreenState();
}

late Future<List<dynamic>> promotionsList;
late Future<List<dynamic>> discountedProductsList;

String searchText = '';

class PromotionListTab extends StatefulWidget {
  const PromotionListTab({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PromotionListTabState createState() => _PromotionListTabState();
}

class _PromotionScreenState extends State<PromotionScreen> {
  Future<void> _refreshPromotionsList([String? searchText]) async {
    var temp = searchPromotions(searchText);
    setState(() {
      promotionsList = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý mã giảm giá'),
          bottom: const TabBar(
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.money_off, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Mã giảm giá',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_offer, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'Giảm giá sản phẩm',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.money_off),
              label: const Text('Thêm mã giảm giá'),
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) => const AddPromotionScreen(),
                );
                _refreshPromotionsList();
                // ignore: use_build_context_synchronously
                await exportPromotionsToExcel(context);
              },
            ),
            TextButton.icon(
              icon: const Icon(Icons.local_offer),
              label: const Text('Thêm giảm giá sản phẩm'),
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) => const AddDiscountedProductScreen(),
                );
                setState(() {
                  discountedProductsList = fetchDiscountedProducts();
                });
              },
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            PromotionListTab(),
            ProductDiscountTab(),
          ],
        ),
      ),
    );
  }
}

Future<void> exportPromotionsToExcel(BuildContext context) async {
  try {
    var excel = Excel.createExcel();
    excel.rename('Sheet1', 'Mã khuyến mãi');
    Sheet sheetObject = excel['Mã khuyến mãi'];
    sheetObject.appendRow([
      TextCellValue('Mã khuyến mãi'),
      TextCellValue('Mã giảm giá'),
      TextCellValue('Mô tả'),
      TextCellValue('Kiểu giảm giá'),
      TextCellValue('Giá trị giảm giá'),
      TextCellValue('Ngày bắt đầu'),
      TextCellValue('Ngày kết thúc'),
      TextCellValue('Đơn hàng từ'),
      TextCellValue('Số lượng mã'),
      TextCellValue('Số lần sử dụng'),
    ]);

    final promotionsData = await promotionsList;
    for (var item in promotionsData) {
      sheetObject.appendRow([
        IntCellValue(item['id']),
        TextCellValue(item['name'] ?? 'Không có'),
        TextCellValue(item['description'] ?? 'Không có'),
        TextCellValue(
            item['discount_type'] == 'percentage' ? 'Phần trăm' : 'Tiền mặt'),
        DoubleCellValue(
            double.tryParse(item['discount_value'].toString()) ?? 0.0),
        TextCellValue(item['start_date'] ?? 'Không có'),
        TextCellValue(item['end_date'] ?? 'Không có'),
        DoubleCellValue(
            double.tryParse(item['min_order_value'].toString()) ?? 0.0),
        IntCellValue(item['code_limit']),
        IntCellValue(item['usage_limit']),
      ]);
    }

    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String fileName = "promotions_$currentDate.xlsx";

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
              Text('Dữ liệu mã giảm giá đã được xuất thành công: $fileName')),
    );
  } catch (e) {
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lỗi khi xuất Excel: $e')),
    );
  }
}

Future<void> importPromotionsFromExcel(BuildContext context) async {
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
          await addPromotion({
            'name': row[1]?.value.toString() ?? 'Không có',
            'description': row[2]?.value.toString() ?? 'Không có',
            'discount_type': row[3]?.value.toString() == 'Phần trăm'
                ? 'percentage'
                : 'fixed_amount',
            'discount_value':
                double.tryParse(row[4]?.value.toString() ?? '0') ?? 0.0,
            'start_date': row[5]?.value.toString() ?? 'Không có',
            'end_date': row[6]?.value.toString() ?? 'Không có',
            'min_order_value':
                double.tryParse(row[7]?.value.toString() ?? '0') ?? 0.0,
            'code_limit': int.tryParse(row[8]?.value.toString() ?? '0') ?? 0,
            'usage_limit': int.tryParse(row[9]?.value.toString() ?? '0') ?? 0,
          });
        }
      }

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Dữ liệu mã giảm giá đã được nhập thành công!')),
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

Future<void> exportDiscountedProductsToExcel(BuildContext context) async {
  try {
    var excel = Excel.createExcel();
    excel.rename('Sheet1', 'Sản phẩm khuyến mãi');
    Sheet sheetObject = excel['Sản phẩm khuyến mãi'];
    sheetObject.appendRow([
      TextCellValue('Mã sản phẩm khuyến mãi'),
      TextCellValue('Tên sản phẩm'),
      TextCellValue('Giá'),
      TextCellValue('Kiểu giảm giá'),
      TextCellValue('Giảm giá'),
      TextCellValue('Ngày bắt đầu'),
      TextCellValue('Ngày kết thúc'),
      TextCellValue('Trạng thái'),
    ]);

    final discountedProductsData = await discountedProductsList;
    for (var item in discountedProductsData) {
      sheetObject.appendRow([
        IntCellValue(item['id']),
        TextCellValue(item['name'] ?? 'Không có'),
        DoubleCellValue(double.tryParse(item['price'].toString()) ?? 0.0),
        TextCellValue(
            item['discount_type'] == 'percentage' ? 'Phần trăm' : 'Tiền mặt'),
        DoubleCellValue(
            double.tryParse(item['discount_value'].toString()) ?? 0.0),
        TextCellValue(item['start_date'] ?? 'Không có'),
        TextCellValue(item['end_date'] ?? 'Không có'),
        TextCellValue(item['active'] == 1 ? 'Kích hoạt' : 'Chưa kích hoạt'),
      ]);
    }

    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String fileName = "discounted_products_$currentDate.xlsx";

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
          content: Text(
              'Dữ liệu sản phẩm giảm giá đã được xuất thành công: $fileName')),
    );
  } catch (e) {
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lỗi khi xuất Excel: $e')),
    );
  }
}

Future<void> importDiscountedProductsFromExcel(BuildContext context) async {
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
          await addDiscountedProduct({
            'menu_id': int.tryParse(row[0]?.value.toString() ?? '0') ?? 0,
            'discount_type': row[3]?.value.toString() == 'Phần trăm'
                ? 'percentage'
                : 'fixed_amount',
            'discount_value':
                double.tryParse(row[4]?.value.toString() ?? '0') ?? 0.0,
            'start_date': row[5]?.value.toString() ?? 'Không có',
            'end_date': row[6]?.value.toString() ?? 'Không có',
            'active': row[7]?.value.toString() == 'Kích hoạt' ? 1 : 0,
          });
        }
      }

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Dữ liệu sản phẩm giảm giá đã được nhập thành công!')),
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

class _PromotionListTabState extends State<PromotionListTab> {
  @override
  void initState() {
    super.initState();
    promotionsList = searchPromotions();
  }

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: _buildPromotionsList(context),
      tablet: _buildPromotionsList(context),
      desktop: _buildPromotionsList(context),
    );
  }

  Widget _buildPromotionsList(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: promotionsList,
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
              double columnWidth = totalWidth / 12; // 8 là tổng số cột hiện có

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
                          'Mã giảm giá',
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
                          'Kiểu giảm giá',
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
                          'Giá trị giảm giá',
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
                          'Ngày kết thúc',
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
                          'Đơn hàng từ',
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
                          'Số lượng mã',
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
                          'Số lần sử dụng',
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
                        DataCell(Text(snapshot.data![index]['discount_type'] ==
                                'percentage'
                            ? 'Phần trăm'
                            : 'Tiền mặt')),
                        DataCell(Text(snapshot.data![index]['discount_type'] ==
                                'percentage'
                            ? '${snapshot.data![index]['discount_value']} %'
                            : '${snapshot.data![index]['discount_value']} VNĐ')),
                        DataCell(Text(
                            snapshot.data![index]['start_date'] ?? 'Không có')),
                        DataCell(Text(
                            snapshot.data![index]['end_date'] ?? 'Không có')),
                        DataCell(Text(
                            '${snapshot.data![index]['min_order_value']} VNĐ')),
                        DataCell(Text(
                            snapshot.data![index]['code_limit'].toString())),
                        DataCell(Text(
                            snapshot.data![index]['usage_limit'].toString())),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (context) => EditPromotionScreen(
                                      promotion: snapshot.data![index],
                                      promotionItem: {
                                        'id': snapshot.data![index]['id'],
                                        'name': snapshot.data![index]['name'],
                                        'description': snapshot.data![index]
                                            ['description'],
                                        'discount_type': snapshot.data![index]
                                            ['discount_type'],
                                        'discount_value': snapshot.data![index]
                                            ['discount_value'],
                                        'start_date': snapshot.data![index]
                                            ['start_date'],
                                        'end_date': snapshot.data![index]
                                            ['end_date'],
                                        'min_order_value': snapshot.data![index]
                                            ['min_order_value'],
                                        'code_limit': snapshot.data![index]
                                            ['code_limit'],
                                        'usage_limit': snapshot.data![index]
                                            ['usage_limit'],
                                        'active': snapshot.data![index]
                                            ['active'],
                                      },
                                    ),
                                  );
                                  setState(() {
                                    promotionsList = fetchPromotions();
                                    setState(() {
                                      promotionsList = fetchPromotions();
                                    });
                                  });
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
                                            'Bạn có chắc chắn muốn xoá mã giảm giá này không?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Huỷ'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              try {
                                                deletePromotion(snapshot
                                                    .data![index]['id']);
                                                snapshot.data!.removeAt(index);
                                                ToastNotification.showToast(
                                                    message:
                                                        'Xoá mã giảm giá thành công');
                                              } catch (e) {
                                                ToastNotification.showToast(
                                                    message:
                                                        'Lỗi xoá mã giảm giá: $e');
                                              }
                                              Navigator.of(context).pop();
                                              setState(() {
                                                promotionsList =
                                                    fetchPromotions();
                                                setState(() {
                                                  promotionsList =
                                                      fetchPromotions();
                                                });
                                              });
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

class ProductDiscountTab extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _ProductDiscountTabState createState() => _ProductDiscountTabState();
  const ProductDiscountTab({super.key});
}

class _ProductDiscountTabState extends State<ProductDiscountTab> {
  @override
  void initState() {
    super.initState();
    discountedProductsList = fetchDiscountedProducts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: discountedProductsList,
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
              double columnWidth = totalWidth / 12;

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columnSpacing: 9,
                  // ignore: deprecated_member_use
                  dataRowHeight: 100,
                  columns: [
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
                          'Kiểu giảm giá',
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
                          'Giảm giá',
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
                          'Ngày kết thúc',
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
                    var product = snapshot.data![index];
                    return DataRow(
                      color: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                          return index.isEven
                              ? Colors.grey.withOpacity(0.1)
                              : Colors.white;
                        },
                      ),
                      cells: [
                        DataCell(Text(product['name'] ?? 'Không có')),
                        DataCell(Text('${product['price'] ?? 0} VNĐ')),
                        DataCell(Text(product['discount_type'] == 'percentage'
                            ? 'Phần trăm'
                            : 'Tiền mặt')),
                        DataCell(Text(
                          product['discount_type'] == 'percentage'
                              ? '${product['discount_value'] ?? 0} %'
                              : '${product['discount_value'] ?? 0} VNĐ',
                        )),
                        DataCell(Text(product['start_date'] ?? 'Không có')),
                        DataCell(Text(product['end_date'] ?? 'Không có')),
                        DataCell(Text(product['active'] == 1
                            ? 'Kích hoạt'
                            : 'Chưa kích hoạt')),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (context) =>
                                        EditDiscountedProductScreen(
                                      product: product,
                                    ),
                                  );
                                  setState(() {
                                    discountedProductsList =
                                        fetchDiscountedProducts();
                                  });
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
                                            'Bạn có chắc chắn muốn xoá sản phẩm giảm giá này không?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Huỷ'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              await deleteDiscountedProduct(
                                                  product['id']);
                                              // ignore: use_build_context_synchronously
                                              Navigator.of(context).pop();
                                              setState(() {
                                                discountedProductsList =
                                                    fetchDiscountedProducts();
                                              });
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

class AddDiscountedProductScreen extends StatefulWidget {
  const AddDiscountedProductScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddDiscountedProductScreenState createState() =>
      _AddDiscountedProductScreenState();
}

class _AddDiscountedProductScreenState
    extends State<AddDiscountedProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late String discountType;
  late double discountValue;
  late DateTime startDate = DateTime.now(), endDate = DateTime.now();
  int? menuId;
  late int active = 0;
  late Future<List<dynamic>> productList = fetchMenu();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await addDiscountedProduct({
          'menu_id': menuId,
          'discount_type': discountType,
          'discount_value': discountValue,
          'start_date': DateFormat('yyyy-MM-dd').format(startDate),
          'end_date': DateFormat('yyyy-MM-dd').format(endDate),
          'active': active,
        });
        ToastNotification.showToast(
            message: 'Thêm sản phẩm giảm giá thành công');
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } catch (e) {
        ToastNotification.showToast(
            message: 'Lỗi khi thêm sản phẩm giảm giá: $e');
      }
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
                FutureBuilder<List<dynamic>>(
                  future: productList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Lỗi: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Không có dữ liệu'));
                    } else {
                      return DropdownButtonFormField<int>(
                        decoration:
                            const InputDecoration(labelText: 'Sản phẩm'),
                        items:
                            snapshot.data!.map<DropdownMenuItem<int>>((item) {
                          return DropdownMenuItem<int>(
                            value: item['id'],
                            child:
                                Text('${item['name']} - ${item['price']} VNĐ'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            menuId = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Vui lòng chọn sản phẩm';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          menuId = value!;
                        },
                      );
                    }
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Kiểu giảm giá'),
                  value: 'percentage',
                  items: const [
                    DropdownMenuItem(
                      value: 'percentage',
                      child: Text('Phần trăm'),
                    ),
                    DropdownMenuItem(
                      value: 'fixed_amount',
                      child: Text('Tiền mặt'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      discountType = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn kiểu giảm giá';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    discountType = value!;
                  },
                ),
                FutureBuilder<List<dynamic>>(
                  future: productList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Lỗi: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Không có dữ liệu'));
                    } else {
                      double productPrice = 0.0;
                      if (menuId != null) {
                        productPrice = double.parse(snapshot.data!
                            .firstWhere((item) => item['id'] == menuId)['price']
                            .toString());
                      }
                      return TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Giá trị giảm giá'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập giá trị giảm giá';
                          }
                          double discount = double.parse(value);
                          if (discountType == 'percentage' && discount > 100) {
                            return 'Giá trị giảm giá không được vượt quá 100%';
                          } else if (discountType == 'fixed_amount' &&
                              discount > productPrice) {
                            return 'Giá trị giảm giá không được lớn hơn giá sản phẩm';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          discountValue = double.parse(value!);
                        },
                      );
                    }
                  },
                ),
                TextFormField(
                  controller: TextEditingController(
                    text: DateFormat('yyyy-MM-dd').format(startDate),
                  ),
                  decoration: const InputDecoration(labelText: 'Ngày bắt đầu'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        startDate = pickedDate;
                      });
                    }
                  },
                  validator: (value) {
                    if (startDate.isAfter(endDate)) {
                      return 'Ngày bắt đầu không được sau ngày kết thúc';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: TextEditingController(
                    text: DateFormat('yyyy-MM-dd').format(endDate),
                  ),
                  decoration: const InputDecoration(labelText: 'Ngày kết thúc'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: endDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        endDate = pickedDate;
                      });
                    }
                  },
                  validator: (value) {
                    if (endDate.isBefore(startDate)) {
                      return 'Ngày kết thúc không được trước ngày bắt đầu';
                    }
                    return null;
                  },
                ),
                SwitchListTile(
                  title: const Text('Kích hoạt'),
                  value: active == 1,
                  onChanged: (value) {
                    setState(() {
                      active = value ? 1 : 0;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Thêm sản phẩm giảm giá'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Huỷ'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EditDiscountedProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const EditDiscountedProductScreen({super.key, required this.product});

  @override
  // ignore: library_private_types_in_public_api
  _EditDiscountedProductScreenState createState() =>
      _EditDiscountedProductScreenState();
}

class _EditDiscountedProductScreenState
    extends State<EditDiscountedProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late String discountType;
  late String discountValue;
  late DateTime startDate, endDate;
  late int active;

  @override
  void initState() {
    super.initState();
    discountType = widget.product['discount_type'] ?? 'percentage';
    discountValue = widget.product['discount_value']?.toString() ?? '0';
    startDate = widget.product['start_date'] != null
        ? DateTime.parse(widget.product['start_date'])
        : DateTime.now();
    endDate = widget.product['end_date'] != null
        ? DateTime.parse(widget.product['end_date'])
        : DateTime.now();
    active = widget.product['active'] ?? 0;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await updateDiscountedProduct(widget.product['id'], {
          'discount_type': discountType,
          'discount_value': discountValue,
          'start_date': DateFormat('yyyy-MM-dd').format(startDate),
          'end_date': DateFormat('yyyy-MM-dd').format(endDate),
          'active': active,
        });
        ToastNotification.showToast(
            message: 'Cập nhật sản phẩm giảm giá thành công');
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } catch (e) {
        ToastNotification.showToast(
            message: 'Lỗi khi cập nhật sản phẩm giảm giá: $e');
      }
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
                  decoration: const InputDecoration(
                      labelText: 'Mã sản phẩm được giảm giá'),
                  initialValue: widget.product['id'].toString(),
                  readOnly: true,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
                  initialValue: widget.product['name'],
                  readOnly: true,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Giá'),
                  initialValue: widget.product['price']?.toString() ?? '0',
                  readOnly: true,
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Kiểu giảm giá'),
                  value: discountType,
                  items: const [
                    DropdownMenuItem(
                      value: 'percentage',
                      child: Text('Phần trăm'),
                    ),
                    DropdownMenuItem(
                      value: 'fixed_amount',
                      child: Text('Tiền mặt'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      discountType = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn kiểu giảm giá';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    discountType = value!;
                  },
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Giá trị giảm giá'),
                  initialValue: discountValue.toString(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập giá trị giảm giá';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    discountValue = value!;
                  },
                ),
                TextFormField(
                  controller: TextEditingController(
                    text: DateFormat('yyyy-MM-dd').format(startDate),
                  ),
                  decoration: const InputDecoration(labelText: 'Ngày bắt đầu'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        startDate = pickedDate;
                      });
                    }
                  },
                  validator: (value) {
                    // ignore: unnecessary_null_comparison
                    if (startDate == null) {
                      return 'Vui lòng chọn ngày bắt đầu';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: TextEditingController(
                    text: DateFormat('yyyy-MM-dd').format(endDate),
                  ),
                  decoration: const InputDecoration(labelText: 'Ngày kết thúc'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: endDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        endDate = pickedDate;
                      });
                    }
                  },
                  validator: (value) {
                    // ignore: unnecessary_null_comparison
                    if (endDate == null) {
                      return 'Vui lòng chọn ngày kết thúc';
                    }
                    return null;
                  },
                ),
                SwitchListTile(
                  title: const Text('Kích hoạt'),
                  value: active == 1,
                  onChanged: (value) {
                    setState(() {
                      active = value ? 1 : 0;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Cập nhật sản phẩm giảm giá'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Huỷ'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddPromotionScreen extends StatefulWidget {
  const AddPromotionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddPromotionScreenState createState() => _AddPromotionScreenState();
}

class _AddPromotionScreenState extends State<AddPromotionScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name, discountType, description;
  late double discountValue, minOrderValue;
  late DateTime startDate = DateTime.now(), endDate = DateTime.now();
  late int codeLimit, usageLimit;
  late bool active = false;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        addPromotion(
          {
            'name': name,
            'discount_type': discountType,
            'discount_value': discountValue,
            'start_date': DateFormat('yyyy-MM-dd').format(startDate),
            'end_date': DateFormat('yyyy-MM-dd').format(endDate),
            'min_order_value': minOrderValue,
            'code_limit': codeLimit,
            'usage_limit': usageLimit,
            'active': active,
            'description': description,
          },
        );
        ToastNotification.showToast(message: 'Thêm mã giảm giá thành công');
        Navigator.pop(context);
      } catch (e) {
        ToastNotification.showToast(message: 'Lỗi khi thêm mã giảm giá: $e');
      }
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
                  decoration:
                      const InputDecoration(labelText: 'Tên mã giảm giá'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên mã giảm giá';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      name = value;
                    }
                  },
                ),
                //description
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
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Kiểu giảm giá'),
                  value: 'percentage',
                  items: const [
                    DropdownMenuItem(
                      value: 'percentage',
                      child: Text('Phần trăm'),
                    ),
                    DropdownMenuItem(
                      value: 'fixed_amount',
                      child: Text('Tiền mặt'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      discountType = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn kiểu giảm giá';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    discountType = value!;
                  },
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Giá trị giảm giá'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập giá trị giảm giá';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    discountValue = double.parse(value!);
                  },
                ),
                TextFormField(
                  controller: TextEditingController(
                    // ignore: unnecessary_null_comparison
                    text: startDate == null
                        ? DateFormat('yyyy-MM-dd').format(DateTime.now())
                        : DateFormat('yyyy-MM-dd').format(startDate),
                  ),
                  decoration: const InputDecoration(labelText: 'Ngày bắt đầu'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        startDate = pickedDate;
                      });
                    }
                  },
                  validator: (value) {
                    // ignore: unnecessary_null_comparison
                    if (startDate == null) {
                      return 'Vui lòng chọn ngày bắt đầu';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: TextEditingController(
                    // ignore: unnecessary_null_comparison
                    text: endDate == null
                        ? DateFormat('yyyy-MM-dd').format(DateTime.now())
                        : DateFormat('yyyy-MM-dd').format(endDate),
                  ),
                  decoration: const InputDecoration(labelText: 'Ngày kết thúc'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        endDate = pickedDate;
                      });
                    }
                  },
                  validator: (value) {
                    // ignore: unnecessary_null_comparison
                    if (endDate == null) {
                      return 'Vui lòng chọn ngày kết thúc';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Giá trị đơn hàng tối thiểu'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập giá trị đơn hàng tối thiểu';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    minOrderValue = double.parse(value!);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Số lượng mã'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số lượng mã';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    codeLimit = int.parse(value!);
                  },
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Số lần sử dụng'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số lần sử dụng';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    usageLimit = int.parse(value!);
                  },
                ),
                SwitchListTile(
                  title: const Text('Kích hoạt'),
                  value: active,
                  onChanged: (value) {
                    setState(() {
                      active = value;
                    });
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
                  child: const Text('Thêm mã giảm giá'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Red for Cancel
                  ),
                  child: const Text('Huỷ'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EditPromotionScreen extends StatefulWidget {
  final Map<String, dynamic> promotionItem;
  final dynamic promotion;

  const EditPromotionScreen({
    super.key,
    required this.promotionItem,
    required this.promotion,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EditPromotionScreenState createState() => _EditPromotionScreenState();
}

class _EditPromotionScreenState extends State<EditPromotionScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name, discountType, discountValue, minOrderValue, description;
  late DateTime startDate, endDate;
  late int codeLimit, usageLimit;
  late bool active;

  @override
  void initState() {
    super.initState();
    name = widget.promotionItem['name'] ?? 'Không có';
    discountType = widget.promotionItem['discount_type'] ?? 'percentage';
    discountValue = widget.promotionItem['discount_value']?.toString() ?? '0';
    startDate = widget.promotionItem['start_date'] != null
        ? DateTime.parse(widget.promotionItem['start_date'])
        : DateTime.now();
    endDate = widget.promotionItem['end_date'] != null
        ? DateTime.parse(widget.promotionItem['end_date'])
        : DateTime.now();
    minOrderValue = widget.promotionItem['min_order_value'] ?? 0.0;
    codeLimit = widget.promotionItem['code_limit'] ?? 0;
    usageLimit = widget.promotionItem['usage_limit'] ?? 0;
    active = widget.promotionItem['active'] == 1 ? true : false;
    description = widget.promotionItem['description'] ?? 'Không có';
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        updatePromotion(
          widget.promotion['id'],
          {
            'name': name,
            'discount_type': discountType,
            'discount_value': discountValue,
            'start_date': DateFormat('yyyy-MM-dd').format(startDate),
            'end_date': DateFormat('yyyy-MM-dd').format(endDate),
            'min_order_value': minOrderValue,
            'code_limit': codeLimit,
            'usage_limit': usageLimit,
            'active': active,
            'description': description,
          },
        );
        Navigator.pop(context);
        ToastNotification.showToast(message: 'Cập nhật mã giảm giá thành công');
      } catch (e) {
        ToastNotification.showToast(
            message: 'Cập nhật mã giảm giá thất bại: $e');
      }
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
                  decoration:
                      const InputDecoration(labelText: 'Tên mã giảm giá'),
                  initialValue: name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên mã giảm giá';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      name = value;
                    }
                  },
                ),
                //description
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  initialValue: description,
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
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Kiểu giảm giá'),
                  value: discountType,
                  items: const [
                    DropdownMenuItem(
                      value: 'percentage',
                      child: Text('Phần trăm'),
                    ),
                    DropdownMenuItem(
                      value: 'fixed_amount',
                      child: Text('Tiền mặt'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      discountType = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn kiểu giảm giá';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    discountType = value!;
                  },
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Giá trị giảm giá'),
                  initialValue: discountValue.toString(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập giá trị giảm giá';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    discountValue = value.toString();
                  },
                ),
                TextFormField(
                  controller: TextEditingController(
                      text: DateFormat('yyyy-MM-dd').format(startDate)),
                  decoration: const InputDecoration(labelText: 'Ngày bắt đầu'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        startDate = pickedDate;
                      });
                      TextEditingController(
                              text: DateFormat('yyyy-MM-dd').format(startDate))
                          .text = DateFormat('yyyy-MM-dd').format(startDate);
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn ngày bắt đầu';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    startDate = DateTime.parse(value!);
                  },
                ),
                TextFormField(
                  controller: TextEditingController(
                      text: DateFormat('yyyy-MM-dd').format(endDate)),
                  decoration: const InputDecoration(labelText: 'Ngày kết thúc'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: endDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        endDate = pickedDate;
                      });
                      TextEditingController(
                              text: DateFormat('yyyy-MM-dd').format(endDate))
                          .text = DateFormat('yyyy-MM-dd').format(endDate);
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn ngày kết thúc';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    endDate = DateTime.parse(value!);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Giá trị đơn hàng tối thiểu'),
                  initialValue: minOrderValue.toString(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập giá trị đơn hàng tối thiểu';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    minOrderValue = value.toString();
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Số lượng mã'),
                  initialValue: codeLimit.toString(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số lượng mã';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    codeLimit = int.parse(value!);
                  },
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Số lần sử dụng'),
                  initialValue: usageLimit.toString(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số lần sử dụng';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    usageLimit = int.parse(value!);
                  },
                ),
                SwitchListTile(
                  title: const Text('Kích hoạt'),
                  value: active,
                  onChanged: (value) {
                    setState(() {
                      active = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _submitForm();
                    setState(() {
                      promotionsList = fetchPromotions();
                      setState(() {
                        promotionsList = fetchPromotions();
                      });
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Green for Add Item
                  ),
                  child: const Text('Cập nhật'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      promotionsList = fetchPromotions();
                      setState(() {
                        promotionsList = fetchPromotions();
                      });
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Red for Cancel
                  ),
                  child: const Text('Huỷ'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
