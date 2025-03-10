import 'package:coffeeapp/controllers/customer_points_controller.dart';
import 'package:coffeeapp/controllers/payment_controller.dart';
import 'package:coffeeapp/models/config_model.dart';
import 'package:coffeeapp/models/promotion_model.dart';
import 'package:coffeeapp/models/tables_model.dart';
import 'package:coffeeapp/views/screens/qr_code/qr_code.dart';
import 'package:coffeeapp/views/widgets/nofication.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// ignore: must_be_immutable
class PaymentConfirmationDialog extends StatefulWidget {
  final Future<List<dynamic>> discountedProducts;

  final String? tableId;
  final String? userID;
  final String? customerId;
  final List<Map<String, dynamic>> cartItems;
  final double totalPrice;
  final double tax;
  final double surcharge;
  final String surchargeReason;
  String selectedPaymentMethod;
  String orderType;
  final String? selectedPromotionCode;
  final double? promotionValue;
  final String? promotionType;
  final bool hasTaxMode;
  final Function() onPaymentSuccess;
  String maHD = "HĐ${DateTime.now().millisecondsSinceEpoch}";

  PaymentConfirmationDialog({
    super.key,
    this.tableId,
    this.userID,
    this.customerId,
    required this.orderType,
    required this.cartItems,
    required this.totalPrice,
    required this.tax,
    required this.surcharge,
    required this.surchargeReason,
    required this.selectedPaymentMethod,
    this.selectedPromotionCode,
    this.promotionValue,
    this.promotionType,
    required this.hasTaxMode,
    required this.onPaymentSuccess,
    required this.discountedProducts,
  });

  @override
  State<PaymentConfirmationDialog> createState() =>
      _PaymentConfirmationDialogState();
}

class _PaymentConfirmationDialogState extends State<PaymentConfirmationDialog> {
  String shopname = '';
  String phone = '';
  String address = '';
  String bankBin = '';
  String bankNumber = '';
  bool tax = false;
  String percentPoints = '';

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final configs = await fetchConfig();
      setState(() {
        phone =
            configs.firstWhere((config) => config['key'] == 'phone')['value'];
        address =
            configs.firstWhere((config) => config['key'] == 'address')['value'];
        shopname = configs
            .firstWhere((config) => config['key'] == 'shop_name')['value'];
        bankBin = configs
            .firstWhere((config) => config['key'] == 'bank_bin')['value'];
        bankNumber = configs
            .firstWhere((config) => config['key'] == 'bank_number')['value'];
        tax = configs.firstWhere((config) => config['key'] == 'tax')['value'] ==
            'true';
        percentPoints = configs
            .firstWhere((config) => config['key'] == 'percent_points')['value'];
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error loading config: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Center(
              child: Column(
                children: [
                  Text(
                    shopname,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  Text('Số ĐT: $phone'),
                  Text('ĐC: $address'),
                ],
              ),
            ),
            const Divider(),

            // Thông tin hóa đơn
            Text('Mã HĐ: #${widget.maHD.toString()}'),
            Text('Ngày: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}'),
            Text('Giờ vào: ${DateFormat('HH:mm:ss').format(DateTime.now())}'),
            Text('Bàn: ${widget.tableId ?? ''}'),
            Text('Nhân viên: ${widget.userID ?? 'admin'}'),
            const Divider(),

            // Danh sách món hàng
            const Text(
              'Danh sách món',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            ...widget.cartItems.map((item) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<List<dynamic>>(
                    future: widget.discountedProducts,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Loading...');
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        var discountedProducts = snapshot.data!;
                        var discountedProduct = discountedProducts.firstWhere(
                            (discountedProduct) =>
                                discountedProduct['id'] == item['id'],
                            orElse: () => null);
                        if (discountedProduct != null) {
                          return Text(
                            '${item['name']} - ${item['quantity']} x ${discountedProduct['discount_type'] == 'percentage' ? (double.parse(item['price'].toString()) * (1 - double.parse(discountedProduct['discount_value'].toString()) / 100)).toStringAsFixed(0) : (double.parse(item['price'].toString()) - double.parse(discountedProduct['discount_value'].toString())).toStringAsFixed(0)} VNĐ',
                            style: const TextStyle(fontSize: 14.0),
                          );
                        } else {
                          return Text(
                            '${item['name']} - ${item['quantity']} x ${item['price'].toStringAsFixed(0)} VNĐ',
                            style: const TextStyle(fontSize: 14.0),
                          );
                        }
                      }
                    },
                  ),
                  if (item.containsKey('size')) Text('Size: ${item['size']}'),
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
            }),
            const Divider(),

            // Tổng cộng

            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.selectedPromotionCode != null)
                  Row(
                    //khuyến mãi
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Khuyến mãi:',
                          style: TextStyle(fontSize: 18.0)),
                      Text(
                        widget.selectedPromotionCode != null
                            ? '${widget.promotionValue} ${widget.promotionType == 'percentage' ? '%' : 'VNĐ'}'
                            : 'Không',
                        style: const TextStyle(fontSize: 18.0),
                      ),
                    ],
                  ),
                if (widget.surchargeReason.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Phụ thu:', style: TextStyle(fontSize: 18.0)),
                      Text('${widget.surcharge.toStringAsFixed(2)} VNĐ',
                          style: const TextStyle(fontSize: 18.0)),
                    ],
                  ),
                //lí do phụ thu
                if (widget.surchargeReason.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Lý do phụ thu:',
                          style: TextStyle(fontSize: 18.0)),
                      Text(widget.surchargeReason,
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
                      '${(widget.hasTaxMode ? (widget.totalPrice + widget.tax - (widget.promotionValue != null ? widget.promotionType == 'percentage' ? widget.totalPrice * (widget.promotionValue! / 100) : widget.promotionValue! : 0)) : widget.totalPrice - (widget.promotionValue != null ? widget.promotionType == 'percentage' ? widget.totalPrice * (widget.promotionValue! / 100) : widget.promotionValue! : 0)).toStringAsFixed(0)} VNĐ',
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
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.selectedPaymentMethod == 'cash'
                        ? Colors.green
                        : Colors.grey,
                    minimumSize: const Size(150, 50), // Increase button size
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8.0), // Rectangle shape
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      widget.selectedPaymentMethod = 'cash';
                    });
                  },
                  child: const Text('Tiền mặt'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.selectedPaymentMethod == 'card'
                        ? Colors.green
                        : Colors.grey,
                    minimumSize: const Size(150, 50), // Increase button size
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8.0), // Rectangle shape
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      widget.selectedPaymentMethod = 'card';
                    });
                  },
                  child: const Text('Thẻ'),
                ),
              ],
            ),
            const SizedBox(height: 8.0),

            if (widget.selectedPaymentMethod == 'card')
              FutureBuilder<Widget>(
                future: qr_code(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Lỗi: ${snapshot.error}');
                  } else {
                    return snapshot.data ?? const SizedBox();
                  }
                },
              ),
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
        const SizedBox(
          height: 10,
        ),
        ElevatedButton(
          onPressed: () {
            _generateInvoicePdf(); // Gọi hàm tạo PDF hóa đơn
            // _printInvoice(); // Gọi hàm hiển thị xác nhận thanh toán
          },
          child: const Text('In hoá đơn'),
        ),
        const SizedBox(
          height: 10,
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              if (widget.tableId != null) {
                try {
                  updateTableStatus(
                      int.parse(widget.tableId!), 'occupied'); //available
                } catch (e) {
                  ToastNotification.showToast(
                      message: 'Cập nhật trạng thái bàn thất bại: $e');
                }
              }
              if (widget.customerId != null) {
                try {
                  List<dynamic> configs = await fetchConfig();

                  addCustomerPoints(
                      userId: int.parse(widget.customerId!),
                      points: widget.totalPrice.toInt() *
                          (int.parse(configs.firstWhere((config) =>
                              config['key'] == 'percent_points')['value'])) ~/
                          100);
                } catch (e) {
                  ToastNotification.showToast(
                      message: 'Cập nhật điểm thất bại: $e');
                }
              }
              addOrder(
                tableId:
                    widget.tableId != null ? int.parse(widget.tableId!) : null,
                customerId: widget.customerId != null
                    ? int.parse(widget.customerId!)
                    : null,
                staffId: int.parse(widget.userID!),
                orderDate: DateTime.now(),
                status: 'Paid',
                description:
                    '${widget.maHD}: \n${widget.orderType} ${widget.surcharge > 0 ? '\nPhụ thu: ${widget.surcharge} VNĐ, Lý do: ${widget.surchargeReason}' : ''} ${widget.selectedPromotionCode != null ? '\nKhuyến mãi: ${widget.promotionValue} ${widget.promotionType == 'percentage' ? '%' : 'VNĐ'}' : ''} ${widget.selectedPaymentMethod == 'card' ? '\nThanh toán bằng thẻ' : '\nThanh toán bằng tiền mặt'}',
              );

              addBill(
                totalAmount: widget.hasTaxMode
                    ? (widget.totalPrice +
                        widget.tax -
                        (widget.promotionValue != null
                            ? widget.promotionType == 'percentage'
                                ? widget.totalPrice *
                                    (widget.promotionValue! / 100)
                                : widget.promotionValue!
                            : 0))
                    : widget.totalPrice -
                        (widget.promotionValue != null
                            ? widget.promotionType == 'percentage'
                                ? widget.totalPrice *
                                    (widget.promotionValue! / 100)
                                : widget.promotionValue!
                            : 0),
                paymentMethod: widget.selectedPaymentMethod,
                paymentDate: DateTime.now(),
              );
              // Thêm 2 lần cho phần tử đầu tiên trong cartItems
              if (widget.cartItems.isNotEmpty) {
                var firstItem = widget.cartItems.first;
                addOrderItem(
                  menuId: firstItem['id'],
                  quantity: firstItem['quantity'],
                  price: firstItem['price'],
                  description:
                      'Giá: ${firstItem['price'].toString()} VNĐ, Số lượng: ${firstItem['quantity']}, ${firstItem.containsKey('size') ? 'Size: ${firstItem['size']}, ' : 'Size: M, '}${firstItem.containsKey('toppings') && firstItem['toppings'].isNotEmpty ? 'Topping: ${firstItem['toppings'].map((topping) => '$topping').join(', ')}, ' : 'Toppings: Không, '}${firstItem.containsKey('sugar') ? 'Đường: ${firstItem['sugar']}%' : 'Đường: 100%'}',
                );
                for (var item in widget.cartItems) {
                  // ignore: avoid_print
                  print('Adding item: $item'); // Thêm dòng này để kiểm tra
                  addOrderItem(
                    menuId: item['id'],
                    quantity: item['quantity'],
                    price: item['price'],
                    description:
                        'Giá: ${item['price'].toString()} VNĐ, Số lượng: ${item['quantity']}, ${item.containsKey('size') ? 'Size: ${item['size']}, ' : 'Size: M, '}${item.containsKey('toppings') && item['toppings'].isNotEmpty ? 'Topping: ${item['toppings'].map((topping) => '$topping').join(', ')}, ' : 'Toppings: Không, '}${item.containsKey('sugar') ? 'Đường: ${item['sugar']}%' : 'Đường: 100%'}',
                  );
                }
              }
              if (widget.selectedPromotionCode != null) {
                usePromotionCode(int.parse(widget.selectedPromotionCode!));
              }
              ToastNotification.showToast(message: 'Thanh toán thành công!');

              widget.onPaymentSuccess();
            } catch (e) {
              showDialog(
                // ignore: use_build_context_synchronously
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Lỗi'),
                    content:
                        Text('Có lỗi xảy ra trong quá trình thanh toán: $e'),
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

            // ignore: use_build_context_synchronously
            Navigator.of(context).pop();
          },
          child: const Text('Đã thanh toán'),
        ),
      ],
    );
  }

  // ignore: non_constant_identifier_names
  Future<Widget> qr_code() async {
    PaymentService paymentService = PaymentService(
        amount: int.parse((widget.hasTaxMode
                ? (widget.totalPrice +
                    widget.tax -
                    (widget.promotionValue != null
                        ? widget.promotionType == 'percentage'
                            ? widget.totalPrice * (widget.promotionValue! / 100)
                            : widget.promotionValue!
                        : 0))
                : widget.totalPrice -
                    (widget.promotionValue != null
                        ? widget.promotionType == 'percentage'
                            ? widget.totalPrice * (widget.promotionValue! / 100)
                            : widget.promotionValue!
                        : 0))
            .toStringAsFixed(0)),
        // ignore: unnecessary_string_interpolations
        addInfo: "${widget.maHD.toString()}");
    try {
      await paymentService.initialize();
      Image qrImage = await paymentService.generatePaymentQR();
      return qrImage;
    } catch (e) {
      // ignore: avoid_print
      print('An error occurred: $e');
      return const Center(child: Text('Lỗi khi tạo mã QR'));
    }
  }

  void _generateInvoicePdf() async {
    final pdf = pw.Document();

    // Chờ dữ liệu từ discountedProducts
    final discountedProducts = await widget.discountedProducts;

    // Lấy giá trị đã giảm giá cho mỗi sản phẩm
    final processedCartItems = widget.cartItems.map((item) {
      final discountedProduct = discountedProducts.firstWhere(
        (p) => p['id'] == item['id'],
        orElse: () => null,
      );

      // Tính giá sau giảm
      final discountedPrice = discountedProduct != null
          ? discountedProduct['discount_type'] == 'percentage'
              ? double.parse(item['price'].toString()) *
                  (1 -
                      double.parse(
                              discountedProduct['discount_value'].toString()) /
                          100)
              : double.parse(item['price'].toString()) -
                  double.parse(discountedProduct['discount_value'].toString())
          : double.parse(item['price'].toString());

      return {
        ...item,
        'discountedPrice': discountedPrice,
      };
    }).toList();

    try {
      // Load custom font
      final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      final ttf = pw.Font.ttf(fontData);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        shopname,
                        style: pw.TextStyle(
                          font: ttf,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      pw.Text('Số ĐT: $phone', style: pw.TextStyle(font: ttf)),
                      pw.Text('ĐC: $address', style: pw.TextStyle(font: ttf)),
                    ],
                  ),
                ),
                pw.Divider(),

                // Thông tin hóa đơn
                pw.Text('Mã HĐ: #${widget.maHD.toString()}',
                    style: pw.TextStyle(font: ttf)),
                pw.Text(
                    'Ngày: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
                    style: pw.TextStyle(font: ttf)),
                pw.Text(
                    'Giờ vào: ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                    style: pw.TextStyle(font: ttf)),
                pw.Text('Bàn: ${widget.tableId ?? ''}',
                    style: pw.TextStyle(font: ttf)),
                pw.Text('Nhân viên: ${widget.userID ?? 'admin'}',
                    style: pw.TextStyle(font: ttf)),
                pw.Divider(),

                // Danh sách món hàng
                pw.Text(
                  'Danh sách món',
                  style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16.0),
                ),
                pw.SizedBox(height: 8.0),
                ...processedCartItems.map((item) {
                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '${item['name']} - ${item['quantity']} x ${item['discountedPrice'].toStringAsFixed(0)} VNĐ',
                        style: pw.TextStyle(font: ttf, fontSize: 14.0),
                      ),
                      if (item.containsKey('size'))
                        pw.Text('Size: ${item['size']}',
                            style: pw.TextStyle(font: ttf)),
                      if (item.containsKey('sugar'))
                        pw.Text('Đường: ${item['sugar']}%',
                            style: pw.TextStyle(font: ttf)),
                      if (item.containsKey('toppings') &&
                          item['toppings'].isNotEmpty)
                        pw.Text(
                            'Topping: ${item['toppings'].map((t) => t).join(', ')}',
                            style: pw.TextStyle(font: ttf)),
                      pw.SizedBox(height: 4.0),
                      pw.Divider(),
                    ],
                  );
                  // ignore: unnecessary_to_list_in_spreads
                }).toList(),
                pw.Divider(),

                // Tổng cộng
                pw.Text(
                  'Tổng cộng: ${(widget.hasTaxMode ? (widget.totalPrice + widget.tax) : widget.totalPrice).toStringAsFixed(0)} VNĐ',
                  style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16.0),
                ),
                pw.Divider(),

                // QR Code
                if (widget.selectedPaymentMethod == 'card')
                  pw.Center(
                    child: pw.Text('Mã QR để thanh toán đã được tạo.',
                        style: pw.TextStyle(font: ttf)),
                  ),
                pw.Center(
                  child: pw.Text('Cảm ơn quý khách!',
                      style: pw.TextStyle(
                          font: ttf, fontStyle: pw.FontStyle.italic)),
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      // ignore: avoid_print
      print('Lỗi khi tạo PDF: $e');
    }
  }
}
