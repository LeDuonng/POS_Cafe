// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:coffeeapp/models/menu_model.dart';
import 'package:coffeeapp/views/widgets/nofication.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../controllers/menu_controller.dart';
import '../../../responsive.dart'; // Import the Responsive widget
import 'package:pdf/pdf.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MenuScreenState createState() => _MenuScreenState();
}

late Future<List<dynamic>> menuList;
String searchText = '';

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    super.initState();
    menuList = fetchMenuCategory();
  }

  Future<void> _refreshMenuList([String? category]) async {
    var temp = fetchMenuCategory(category);
    setState(() {
      menuList = temp;
    });
  }

  void searchMenu(String query) {
    setState(() => searchText = query);
    _refreshMenuList(searchText); // Gọi _refreshMenuList với searchText mới
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Menu'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 300,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm menu...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                    _refreshMenuList(searchText);
                  });
                  searchMenu(value);
                },
              ),
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Thêm món'),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) => const AddMenuItemScreen(),
              );
              _refreshMenuList();
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.print),
            label: const Text('In Menu Món'),
            onPressed: () {
              // Implement print functionality here
              printMenuList(context);
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.file_download),
            label: const Text('Xuất Excel'),
            onPressed: () {
              try {
                exportMenuToExcel();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi khi xuất Excel: $e')),
                );
              }
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.file_upload),
            label: const Text('Nhập Excel'),
            onPressed: () async {
              try {
                importMenuFromExcel();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi khi nhập Excel: $e')),
                );
              }
              _refreshMenuList();
            },
          ),
        ],
      ),
      body: Responsive(
        mobile: _buildMenuList(context),
        tablet: _buildMenuList(context),
        desktop: _buildMenuList(context),
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: menuList,
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
              double columnWidth = totalWidth / 7; // 7 là tổng số cột hiện có

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,

                // child: SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                child: RefreshIndicator(
                  onRefresh: () => _refreshMenuList(),
                  triggerMode: RefreshIndicatorTriggerMode.onEdge,
                  edgeOffset: 50,
                  displacement: 200,
                  strokeWidth: 5,
                  color: Colors.green,
                  backgroundColor: Colors.grey.withOpacity(0.1),
                  child: DataTable(
                    columnSpacing: 12,
                    // ignore: deprecated_member_use
                    dataRowHeight: 100,
                    columns: [
                      DataColumn(
                        label: SizedBox(
                          width: columnWidth,
                          child: const Text(
                            'STT',
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
                            'Tên món',
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
                          DataCell(Text((index + 1).toString())),
                          DataCell(Text(
                              snapshot.data![index]['name'] ?? 'Không có')),
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
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () async {
                                    await showDialog(
                                      context: context,
                                      builder: (context) => EditMenuItemScreen(
                                        menu: snapshot.data![index],
                                        menuItem: {
                                          'id': snapshot.data![index]['id'],
                                          'name': snapshot.data![index]['name'],
                                          'description': snapshot.data![index]
                                              ['description'],
                                          'price': snapshot.data![index]
                                              ['price'],
                                          'image': snapshot.data![index]
                                              ['image'],
                                          'category': snapshot.data![index]
                                              ['category'],
                                        },
                                      ),
                                    );
                                    _refreshMenuList();
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
                                              'Bạn có chắc chắn muốn xoá món này không?'),
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
                                                    deleteMenu(snapshot
                                                        .data![index]['id']);
                                                    snapshot.data!
                                                        .removeAt(index);
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          content: Text(
                                                              'Error: $e')),
                                                    );
                                                  }
                                                });
                                                ToastNotification.showToast(
                                                    message:
                                                        'Xoá món thành công',
                                                    backgroundColor:
                                                        Colors.green);
                                                _refreshMenuList();
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
                ),
              );
            },
          );
        }
      },
    );
  }

  Future<void> printMenuList(BuildContext context) async {
    try {
      // Hiển thị thông báo "Đang tải"
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final pdf = pw.Document();

      // Load font
      final font = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
      final ttf = pw.Font.ttf(font);

      // Fetch menu data
      final menuData = await menuList;
      if (menuData.isEmpty) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menu trống!')),
        );
        return;
      }

      Future<Uint8List> networkImageToByte(String url) async {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          return response.bodyBytes;
        } else {
          throw Exception('Failed to load network image');
        }
      }

      // Load images
      final imageMap = <String, pw.MemoryImage>{};
      for (var item in menuData) {
        try {
          final imageBytes = await rootBundle
              .load('assets/menu/${item['name']}.png')
              .then((value) => value.buffer.asUint8List());
          imageMap[item['name']] = pw.MemoryImage(imageBytes);
        } catch (e) {
          try {
            final networkImage = await networkImageToByte(item['image']);
            imageMap[item['name']] = pw.MemoryImage(networkImage);
          } catch (e) {
            // Fallback image
            final placeholderBytes = await rootBundle
                .load('assets/menu/error.png')
                .then((value) => value.buffer.asUint8List());
            imageMap[item['name']] = pw.MemoryImage(placeholderBytes);
          }
        }
      }

      // Trang đầu: Tiêu đề "Menu Món"
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Menu Món',
                    style: pw.TextStyle(
                      fontSize: 36,
                      fontWeight: pw.FontWeight.bold,
                      font: ttf,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Chào mừng quý khách!',
                    style: pw.TextStyle(
                      fontSize: 24,
                      font: ttf,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Phân loại theo danh mục
      final categories =
          menuData.map((item) => item['category']).toSet().toList();

      // Tạo các trang danh mục
      for (var category in categories) {
        final categoryItems =
            menuData.where((item) => item['category'] == category).toList();

        // Chia sản phẩm thành các nhóm (2 sản phẩm mỗi hàng, 3 hàng mỗi trang)
        const itemsPerPage = 6;
        final totalPages = (categoryItems.length / itemsPerPage).ceil();

        for (var pageIndex = 0; pageIndex < totalPages; pageIndex++) {
          final itemsOnPage =
              categoryItems.skip(pageIndex * itemsPerPage).take(itemsPerPage);

          pdf.addPage(
            pw.Page(
              build: (pw.Context context) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Danh mục: $category',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        font: ttf,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: itemsOnPage.map((item) {
                        return pw.Container(
                          width: 250,
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey),
                            borderRadius: pw.BorderRadius.circular(8),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                item['name'],
                                style: pw.TextStyle(
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold,
                                  font: ttf,
                                ),
                              ),
                              pw.SizedBox(height: 5),
                              pw.Text(
                                'Giá: ${item['price']} VNĐ',
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  font: ttf,
                                ),
                              ),
                              pw.SizedBox(height: 5),
                              pw.Image(
                                imageMap[item['name']]!,
                                height: 150,
                                width: 150,
                                fit: pw.BoxFit.cover,
                              ),
                              pw.SizedBox(height: 5),
                              pw.Text(
                                item['description'],
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  font: ttf,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
          );
        }
      }

      // Ẩn thông báo "Đang tải"
      // ignore: use_build_context_synchronously
      Navigator.pop(context);

      // Hiển thị PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context); // Đóng thông báo "Đang tải" nếu có lỗi
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi in menu: $e')),
      );
    }
  }

  Future<void> exportMenuToExcel() async {
    try {
      var excel = Excel.createExcel();
      excel.rename('Sheet1', 'Menu');
      Sheet sheetObject = excel['Menu'];
      sheetObject.appendRow([
        TextCellValue('Mã sản phẩm'),
        TextCellValue('Tên món'),
        TextCellValue('Mô tả'),
        TextCellValue('Giá'),
        TextCellValue('Hình ảnh'),
        TextCellValue('Danh mục'),
      ]);

      // Lấy dữ liệu menu
      final menuData = await menuList;
      for (var item in menuData) {
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
      String fileName = "menu_$currentDate.xlsx";

      // Tạo file Excel
      final excelBytes = excel.save();
      final blob = html.Blob([Uint8List.fromList(excelBytes!)],
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Tải file về với tên chứa ngày hiện tại
      final anchor = html.AnchorElement(href: url);
      anchor.setAttribute("download", fileName);
      anchor.click();
      html.Url.revokeObjectUrl(url);

      // Thông báo thành công
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Dữ liệu menu đã được xuất thành công: $fileName')),
      );
    } catch (e) {
      // Thông báo lỗi
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xuất Excel: $e')),
      );
    }
  }

  Future<void> importMenuFromExcel() async {
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
            await addMenu(
              name: row[1]?.value.toString() ?? 'Không có',
              description: row[2]?.value.toString() ?? 'Không có',
              price: row[3]?.value.toString() ?? '0',
              image: row[4]?.value.toString() ?? 'Không có',
              category: row[5]?.value.toString() ?? 'Không có',
            );
          }
        }

        // ignore: avoid_print
        print('Nhập Excel thành công!');
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Dữ liệu menu đã được nhập thành công!')),
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
}

class AddMenuItemScreen extends StatelessWidget {
  // Changed to StatelessWidget
  const AddMenuItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    final _formKey = GlobalKey<FormState>();
    String name = '', description = '', price = '', image = '', category = '';

    // ignore: no_leading_underscores_for_local_identifiers
    void _submitForm() {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        addMenu(
          name: name,
          description: description,
          price: price,
          image: image,
          category: category,
        );
        Navigator.pop(context);
      }
    }

    return Dialog(
        child: ConstrainedBox(
      // Limit the Dialog size
      constraints: const BoxConstraints(maxWidth: 500, maxHeight: 400),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Tên món'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên món';
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
                child: const Text('Thêm món'),
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
    ));
  }
}

class EditMenuItemScreen extends StatefulWidget {
  final Map<String, dynamic> menuItem;
  final dynamic menu;

  const EditMenuItemScreen({
    super.key,
    required this.menuItem,
    required this.menu,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EditMenuItemScreenState createState() => _EditMenuItemScreenState();
}

class _EditMenuItemScreenState extends State<EditMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name, description, price, image, category;

  @override
  void initState() {
    super.initState();
    name = widget.menuItem['name'] ?? 'Không có';
    description = widget.menuItem['description'] ?? 'Không có';
    price = widget.menuItem['price']?.toString() ??
        ''; // Convert to String if it's a number
    image = widget.menuItem['image'] ?? 'Không có';
    category = widget.menuItem['category'] ?? 'Không có';
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      updateMenu(
        id: widget.menuItem['id'],
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
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              // Use ListView for scrolling
              children: <Widget>[
                TextFormField(
                  initialValue: widget.menuItem['id'].toString(),
                  decoration: const InputDecoration(labelText: 'Mã món'),
                  readOnly: true,
                ),
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(labelText: 'Tên món'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên món';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    name = value!;
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
                  keyboardType: TextInputType.number, // For numeric input
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập giá';
                    }
                    // Add more validation if needed (e.g., number format)

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
                  onPressed: _submitForm,
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
