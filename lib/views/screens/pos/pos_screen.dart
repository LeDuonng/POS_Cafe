import 'package:coffeeapp/controllers/config_controller.dart';
import 'package:coffeeapp/controllers/menu_controller.dart';
import 'package:coffeeapp/models/payment_model.dart';
import 'package:coffeeapp/views/screens/pos/classification.dart';
import 'package:coffeeapp/views/screens/pos/find_customer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LeeDuong Coffee Shop',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      debugShowCheckedModeBanner: false,
      home: const POSScreen(
        tableId: null,
        userID: null,
      ),
    );
  }
}

class POSScreen extends StatefulWidget {
  const POSScreen({super.key, required this.tableId, required this.userID});
  final String? tableId;
  final String? userID;

  @override
  // ignore: library_private_types_in_public_api
  _POSScreenState createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  late Future<List<dynamic>> menuList;
  String selectedCategory = 'Tất cả';
  String? customerID;
  String? customerName;
  String _selectedPaymentMethod = 'cash';
  bool hasTaxMode = false;

  @override
  void initState() {
    super.initState();
    _initializeAsync();
    menuList = fetchMenuCategory(); // Fetch all menus initially
  }

  Future<void> _initializeAsync() async {
    final configData = await fetchConfig();
    setState(() {
      hasTaxMode = configData.any(
        (config) => config['key'] == 'tax' && config['value'] == 'true',
      );
    });
  }

  void updateMenuList(String category) {
    setState(() {
      selectedCategory = category;
      menuList = fetchMenuCategory(category == 'Tất cả' ? null : category);
    });
  }

  void _showPaymentConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'HÓA ĐƠN THANH TOÁN',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thông tin quán
                const Center(
                  child: Column(
                    children: [
                      Text(
                        'LeeDuong Coffee',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      Text('Số ĐT: 0971533147'),
                      Text('ĐC: Hóc Môn, Hồ Chí Minh'),
                    ],
                  ),
                ),
                const Divider(),

                // Thông tin hóa đơn
                Text('Mã HĐ: #${DateTime.now().millisecondsSinceEpoch}'),
                Text(
                    'Ngày: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}'),
                Text(
                    'Giờ vào: ${DateFormat('HH:mm:ss').format(DateTime.now())}'),
                Text('Bàn: ${widget.tableId ?? '1'}'),
                Text('Nhân viên: ${widget.userID ?? 'admin'}'),
                const Divider(),

                // Danh sách món hàng
                const Text(
                  'Danh sách món',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                ),
                const SizedBox(height: 8.0),
                ..._cartItems.map((item) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item['name']} - ${item['quantity']} x ${item['price'].toStringAsFixed(0)} đ',
                        style: const TextStyle(fontSize: 14.0),
                      ),
                      if (item.containsKey('size'))
                        Text('Size: ${item['size']}'),
                      if (item.containsKey('sugar'))
                        Text('Đường: ${item['sugar']}%'),
                      if (item.containsKey('toppings') &&
                          item['toppings'].isNotEmpty)
                        Text(
                            'Topping: ${item['toppings'].map((topping) => '$topping').join(', ')}'),
                      const SizedBox(height: 4.0),
                      const Divider(),
                    ],
                  );
                  // ignore: unnecessary_to_list_in_spreads
                }).toList(),
                const Divider(),

                // Tổng cộng

                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Phụ thu:',
                            style: TextStyle(fontSize: 18.0)),
                        Text('${_surcharge.toStringAsFixed(2)} đ',
                            style: const TextStyle(fontSize: 18.0)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng cộng:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16.0),
                        ),
                        Text(
                          '${(_totalPrice + _tax).toStringAsFixed(0)} đ',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(),
                // Chọn phương thức thanh toán
                const Text(
                  'Phương thức thanh toán:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Radio<String>(
                      value: 'cash',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod =
                              value!; // Sửa lỗi tại đây: thêm dấu !
                        });
                      },
                    ),
                    const Text('Tiền mặt'),
                    Radio<String>(
                      value: 'card',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod =
                              value!; // Sửa lỗi tại đây: thêm dấu !
                        });
                      },
                    ),
                    const Text('Thẻ'),
                  ],
                ),
                // Lời cảm ơn
                const Center(
                  child: Column(
                    children: [
                      SizedBox(height: 8.0),
                      Text(
                        'Cảm ơn quý khách!',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 14.0,
                        ),
                      ),
                      Text('Hẹn gặp lại!'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Huỷ'),
            ),
            ElevatedButton(
              onPressed: () {
                _printInvoice(); // Gọi hàm hiển thị xác nhận thanh toán
              },
              child: const Text('in hoá đơn'),
            ),
            ElevatedButton(
              onPressed: () {
                try {
                  addOrder(
                    tableId:
                        widget.tableId != null ? int.parse(widget.tableId!) : 1,
                    customerId: int.parse(customerID ?? widget.userID!),
                    staffId: int.parse(widget.userID!),
                    orderDate: DateTime.now(),
                    status: 'Paid',
                    description:
                        'Order from POS${_surcharge > 0 ? ', Phụ thu: $_surcharge đ, Lý do: $_surchargeReason' : ''}',
                  );

                  addBill(
                    totalAmount: _totalPrice + _tax,
                    paymentMethod: _selectedPaymentMethod,
                    paymentDate: DateTime.now(),
                  );

                  for (var item in _cartItems) {
                    addOrderItem(
                      menuId: item['id'],
                      quantity: item['quantity'],
                      price: item['price'],
                      description:
                          'Giá: ${item['price'].toString()} đ, Số lượng: ${item['quantity']}, ${item.containsKey('size') ? 'Size: ${item['size']}, ' : 'Size: M, '}${item.containsKey('toppings') && item['toppings'].isNotEmpty ? 'Topping: ${item['toppings'].map((topping) => '$topping').join(', ')}, ' : 'Toppings: Không, '}${item.containsKey('sugar') ? 'Đường: ${item['sugar']}%' : 'Đường: 100%'}',
                    );
                  }
                } catch (e) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Lỗi'),
                        content: Text(
                            'Có lỗi xảy ra trong quá trình thanh toán: $e'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }

                setState(() {
                  _cartItems.clear();
                  _calculateTotal();
                });

                Navigator.of(context).pop();
              },
              child: const Text('Thanh toán'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LEDUONG COFFEE SHOP'),
        centerTitle: true,
      ),
      body: Row(
        children: [
          // Menu
          Expanded(
            flex: 2,
            child: Container(
              color: const Color.fromARGB(255, 233, 229, 229),
              child: Column(
                children: [
                  // Classification (Milk Tea, Iced Coffee, ...)
                  ClassificationScreen(onCategorySelected: updateMenuList),
                  Expanded(
                    child: FutureBuilder<List<dynamic>>(
                      future: menuList,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(child: Text('Không có sản phẩm'));
                        } else {
                          final items = snapshot.data!;
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              int crossAxisCount = 2; // Default to 2 columns
                              if (constraints.maxWidth > 1200) {
                                crossAxisCount =
                                    4; // 4 columns for large screens
                              } else if (constraints.maxWidth > 800) {
                                crossAxisCount =
                                    3; // 3 columns for medium screens
                              }
                              return GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 8.0,
                                  mainAxisSpacing: 8.0,
                                  childAspectRatio: 0.75,
                                ),
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  return GestureDetector(
                                    onTap: () {
                                      _addToCart({
                                        'id': item['id'],
                                        'name': item['name'],
                                        'price': double.parse(
                                            item['price'].toString()),
                                        'image': item['image'],
                                        'quantity': 1,
                                      });
                                    },
                                    child: Card(
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Image.asset(
                                              'assets/menu/${item['name']}.png',
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Image.asset(
                                                  'assets/menu/${item['image']}',
                                                  height: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Icon(
                                                        Icons.error);
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(item['name']),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Giá: ${double.parse(item['price'].toString())} đ',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Order Summary and Actions
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Order Summary Title
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Text(
                      'ĐƠN HÀNG',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),

                  // Cart Items List
                  Expanded(
                    child: ListView.builder(
                      itemCount: _cartItems.length,
                      itemBuilder: (context, index) {
                        final item = _cartItems[index];
                        return Column(
                          children: [
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              elevation: 5,
                              child: ListTile(
                                title: Text(
                                  item['name'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Giá: ${item['price'].toString()} đ'),
                                    Text('Số lượng: ${item['quantity']}'),
                                    if (item.containsKey('size'))
                                      Text('Size: ${item['size']}')
                                    else
                                      const Text('Size: M'),
                                    if (item.containsKey('toppings') &&
                                        item['toppings'].isNotEmpty)
                                      Text(
                                          'Topping: ${item['toppings'].map((topping) => '$topping').join(', ')}')
                                    else
                                      const Text('Toppings: Không'),
                                    if (item.containsKey('sugar'))
                                      Text('Đường: ${item['sugar']}%')
                                    else
                                      const Text('Đường: 100%'),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () {
                                            _showCustomizationDialog(item);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () {
                                            setState(() {
                                              _cartItems.removeAt(index);
                                              _calculateTotal();
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // const Divider(), // Ngăn cách giữa các loại đồ uống
                          ],
                        );
                      },
                    ),
                  ),

                  // Summary and Actions
                  Column(
                    children: [
                      // Subtotal, VAT, Total
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Tổng cộng:',
                                    style: TextStyle(fontSize: 18.0)),
                                Text('${_totalPrice.toStringAsFixed(2)} đ',
                                    style: const TextStyle(fontSize: 18.0)),
                              ],
                            ),
                            if (_surcharge > 0) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Phụ thu:',
                                      style: TextStyle(fontSize: 18.0)),
                                  Text('${_surcharge.toStringAsFixed(2)} đ',
                                      style: const TextStyle(fontSize: 18.0)),
                                ],
                              ),
                            ],
                            if (hasTaxMode) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('VAT (10%):',
                                      style: TextStyle(fontSize: 18.0)),
                                  Text('${_tax.toStringAsFixed(2)} đ',
                                      style: const TextStyle(fontSize: 18.0)),
                                ],
                              ),
                            ],
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Thanh toán:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0),
                                ),
                                Text(
                                  '${(_totalPrice + _tax).toStringAsFixed(2)} đ',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Customer Loyalty, Discount Code
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height:
                                  50.0, // Chiều cao cố định cho tất cả các nút
                              child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title:
                                            const Text('Tìm kiếm khách hàng'),
                                        content: const SizedBox(
                                          width: 300,
                                          height: 400,
                                          child: FindCustomerScreen(),
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
                                  ).then((value) {
                                    if (value != null) {
                                      setState(() {
                                        customerID = value['id'].toString();
                                        customerName = value['name'].toString();
                                      });
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  textStyle: const TextStyle(fontSize: 18.0),
                                ),
                                child: customerName != null
                                    ? Column(
                                        children: [
                                          const Text('Khách hàng:'),
                                          Text(customerName.toString()),
                                        ],
                                      )
                                    : const Text('Tích điểm',
                                        textAlign: TextAlign.center),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: SizedBox(
                              height:
                                  50.0, // Chiều cao cố định cho tất cả các nút
                              child: ElevatedButton(
                                onPressed: () {
                                  // Xử lý nhập mã khuyến mãi
                                },
                                style: ElevatedButton.styleFrom(
                                  textStyle: const TextStyle(fontSize: 18.0),
                                ),
                                child: const Text('Khuyến mãi',
                                    textAlign: TextAlign.center),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: SizedBox(
                              height:
                                  50.0, // Chiều cao cố định cho tất cả các nút
                              child: ElevatedButton(
                                onPressed: () {
                                  _showSurchargeDialog(); // Gọi hàm hiển thị dialog nhập phụ thu
                                },
                                style: ElevatedButton.styleFrom(
                                  textStyle: const TextStyle(fontSize: 18.0),
                                ),
                                child: Text(
                                  _surcharge > 0
                                      ? 'Phụ thu: ${_surcharge.toStringAsFixed(2)} đ'
                                      : 'Phụ thu',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Cancel and Payment Buttons
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50.0, // Chiều cao cố định cho cả hai nút
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _cartItems.clear();
                                    _calculateTotal();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  textStyle: const TextStyle(fontSize: 18.0),
                                ),
                                child: const Text('Huỷ'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: SizedBox(
                              height: 50.0, // Chiều cao cố định cho cả hai nút
                              child: ElevatedButton(
                                onPressed: () {
                                  _showPaymentConfirmationDialog(); // Hiển thị dialog xác nhận thanh toán
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  textStyle: const TextStyle(fontSize: 18.0),
                                ),
                                child: const Text('Thanh toán'),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  final List<Map<String, dynamic>> _cartItems = [];
  double _totalPrice = 0.0;
  double _tax = 0.0;
  double _surcharge = 0.0; // Thêm biến phụ thu
  String _surchargeReason = ""; // Biến để lưu lý do phụ thu

  void _printInvoice() {
    // In hóa đơn
    // Tạo nội dung hóa đơn
    String invoiceContent = '***** HÓA ĐƠN *****\n\n';
    invoiceContent += 'Khách hàng: ${customerName ?? 'Không có'}\n';
    invoiceContent +=
        'Ngày: ${DateTime.now().toLocal().toString().split(' ')[0]}\n'; // Ngày hiện tại
    invoiceContent += '--------------------------------\n';
    invoiceContent += 'STT | Tên sản phẩm | Số lượng | Đơn giá \n';
    invoiceContent += '--------------------------------\n';

    for (int i = 0; i < _cartItems.length; i++) {
      final item = _cartItems[i];
      invoiceContent +=
          '${i + 1}   | ${item['name']} | ${item['quantity']} | ${item['price']} đ | ';

      // Thêm thông tin tùy chọn
      // ignore: unused_local_variable
      String additionalInfo = '';
      if (item.containsKey('size')) {
        additionalInfo += 'Size: ${item['size']}; ';
      }
      if (item.containsKey('toppings') && item['toppings'].isNotEmpty) {
        additionalInfo +=
            'Topping: ${item['toppings'].map((topping) => '$topping').join(', ')}; ';
      }
      if (item.containsKey('sugar')) {
        additionalInfo += 'Đường: ${item['sugar']}%; ';
      }

      invoiceContent += '\n--------------------------------\n';
    }

    invoiceContent += 'Phụ thu: ${_surcharge.toStringAsFixed(2)} đ\n';
    if (_surchargeReason.isNotEmpty) {
      invoiceContent += 'Lý do phụ thu: $_surchargeReason\n';
    }
    invoiceContent += 'Tổng cộng: ${_totalPrice.toStringAsFixed(2)} đ\n';
    invoiceContent += 'VAT (10%): ${_tax.toStringAsFixed(2)} đ\n';
    invoiceContent += '--------------------------------\n';
    invoiceContent +=
        'Thanh toán: ${(_totalPrice + _tax).toStringAsFixed(2)} đ\n';
    invoiceContent += '***** CẢM ƠN QUÝ KHÁCH *****\n';

    // Hiển thị nội dung hóa đơn trong một dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Text(
              invoiceContent,
              style: const TextStyle(
                  fontFamily: 'Courier New'), // Font monospace cho dễ đọc
            ),
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
  }

  void _addToCart(Map<String, dynamic> item) {
    setState(() {
      _cartItems.add(item);
      _calculateTotal();
    });
  }

  void _calculateTotal() {
    _totalPrice = _cartItems.fold(
        0, (sum, item) => sum + (item['price'] * item['quantity']));
    _tax = _totalPrice * 0.1;
    _totalPrice += _surcharge; // Cộng thêm phụ thu vào tổng tiền
  }

  void _showSurchargeDialog() {
    // Khởi tạo TextEditingController với giá trị đã nhập trước đó (nếu có)
    TextEditingController surchargeController = TextEditingController(
        text: _surcharge > 0 ? _surcharge.toString() : '');
    TextEditingController surchargeReasonController =
        TextEditingController(text: _surchargeReason);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nhập phụ thu'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: surchargeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "Nhập số tiền phụ thu",
                  suffixText: "VNĐ",
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: surchargeReasonController,
                decoration:
                    const InputDecoration(hintText: "Nhập lý do phụ thu"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Huỷ'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _surcharge = double.tryParse(surchargeController.text) ?? 0.0;
                  _surchargeReason = surchargeReasonController.text;
                  _calculateTotal(); // Tính lại tổng tiền sau khi nhập phụ thu
                });
                Navigator.of(context).pop();
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  void _showCustomizationDialog(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String selectedSize = product['size'] ?? 'M';
        List<String> selectedToppings =
            List<String>.from(product['toppings'] ?? []);
        int selectedSugar = product['sugar'] ?? 100;
        int selectedQuantity = product['quantity'] ?? 1;
        double originalPrice = product['price'];
        double updatedPrice = originalPrice;

        return AlertDialog(
          title: Text('Tuỳ chọn ${product['name']}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromARGB(255, 192, 87, 87)),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      children: [
                        const Text('Chọn size',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return DropdownButton<String>(
                              value: selectedSize,
                              items: ['S', 'M', 'L'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text('Size: $value'),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  selectedSize = newValue!;
                                });
                              },
                            );
                          },
                        ),
                      ],
                    )),
                const SizedBox(height: 8.0),
                Container(
                  // color: Colors.red[100],
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromARGB(255, 192, 87, 87)),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: [
                      const Text('Chọn lượng đường',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return DropdownButton<int>(
                            value: selectedSugar,
                            items: [0, 20, 40, 60, 80, 100].map((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text('Lượng đường: $value%'),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                selectedSugar = newValue!;
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),
                Container(
                  // color: Colors.yellow[100],
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromARGB(255, 192, 87, 87)),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: [
                      const Text('Chọn số lượng',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    if (selectedQuantity > 1) {
                                      selectedQuantity--;
                                    }
                                  });
                                },
                              ),
                              Text('$selectedQuantity'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    selectedQuantity++;
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  // color: Colors.green[100],
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Text('Chọn topping',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      FutureBuilder<List<dynamic>>(
                        future: fetchToppings(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text('No toppings found'));
                          } else {
                            final toppings = snapshot.data!;
                            return Column(
                              children: toppings.map((topping) {
                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: StatefulBuilder(
                                    builder: (BuildContext context,
                                        StateSetter setState) {
                                      return Column(
                                        children: [
                                          const SizedBox(height: 8.0),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            clipBehavior: Clip.hardEdge,
                                            child: Image.asset(
                                              'assets/menu/${topping['name']}.png',
                                              height: 100,
                                              width: 100,
                                              fit: BoxFit.fitHeight,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Image.asset(
                                                  'assets/menu/${topping['image']}',
                                                  height: 100,
                                                  width: 100,
                                                  fit: BoxFit.fitHeight,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Icon(
                                                        Icons.error);
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                          ListTile(
                                            title: Text(topping['name']),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    'Giá: ${topping['price']} đ'),
                                                Text(
                                                    'Description: ${topping['description']}'),
                                              ],
                                            ),
                                            trailing: Checkbox(
                                              value: selectedToppings
                                                  .contains(topping['name']),
                                              onChanged: (selected) {
                                                setState(() {
                                                  if (selected!) {
                                                    selectedToppings
                                                        .add(topping['name']);
                                                    updatedPrice +=
                                                        double.parse(
                                                            topping['price']
                                                                .toString());
                                                  } else {
                                                    selectedToppings.remove(
                                                        topping['name']);
                                                    updatedPrice -=
                                                        double.parse(
                                                            topping['price']
                                                                .toString());
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                );
                              }).toList(),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Huỷ'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  final existingItemIndex = _cartItems
                      .indexWhere((item) => item['name'] == product['name']);
                  if (existingItemIndex != -1) {
                    _cartItems[existingItemIndex] = {
                      'id': product['id'],
                      'name': product['name'],
                      'size': selectedSize,
                      'toppings': selectedToppings,
                      'sugar': selectedSugar,
                      'quantity': selectedQuantity,
                      'price': updatedPrice,
                    };
                  } else {
                    _addToCart({
                      'id': product['id'],
                      'name': product['name'],
                      'size': selectedSize,
                      'toppings': selectedToppings,
                      'sugar': selectedSugar,
                      'quantity': selectedQuantity,
                      'price': updatedPrice,
                    });
                  }
                  _calculateTotal();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }
}
