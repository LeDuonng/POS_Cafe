import 'package:coffeeapp/controllers/payment_controller.dart';
import 'package:coffeeapp/views/screens/qr_code/qr_code.dart';
import 'package:coffeeapp/views/widgets/nofication.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class PaymentConfirmationDialog extends StatefulWidget {
  final String? tableId;
  final String? userID;
  final List<Map<String, dynamic>> cartItems;
  final double totalPrice;
  final double tax;
  final double surcharge;
  final String surchargeReason;
  String selectedPaymentMethod;
  final String? selectedPromotionCode;
  final double? promotionValue;
  final String? promotionType;
  final bool hasTaxMode;
  final Function() onPaymentSuccess;

  PaymentConfirmationDialog({
    super.key,
    this.tableId,
    this.userID,
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
  });

  @override
  State<PaymentConfirmationDialog> createState() =>
      _PaymentConfirmationDialogState();
}

class _PaymentConfirmationDialogState extends State<PaymentConfirmationDialog> {
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
            Text('Ngày: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}'),
            Text('Giờ vào: ${DateFormat('HH:mm:ss').format(DateTime.now())}'),
            Text('Bàn: ${widget.tableId ?? '1'}'),
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
                  Text(
                    '${item['name']} - ${item['quantity']} x ${item['price'].toStringAsFixed(0)} VNĐ',
                    style: const TextStyle(fontSize: 14.0),
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
            }).toList(),
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

            if (widget.selectedPaymentMethod == 'card')
              FutureBuilder<Widget>(
                future: qr_code(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
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
                customerId: int.parse(widget.userID!),
                staffId: int.parse(widget.userID!),
                orderDate: DateTime.now(),
                status: 'Paid',
                description:
                    'Order from POS${widget.surcharge > 0 ? ', Phụ thu: ${widget.surcharge} VNĐ, Lý do: ${widget.surchargeReason}' : ''}',
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

              for (var item in widget.cartItems) {
                addOrderItem(
                  menuId: item['id'],
                  quantity: item['quantity'],
                  price: item['price'],
                  description:
                      'Giá: ${item['price'].toString()} VNĐ, Số lượng: ${item['quantity']}, ${item.containsKey('size') ? 'Size: ${item['size']}, ' : 'Size: M, '}${item.containsKey('toppings') && item['toppings'].isNotEmpty ? 'Topping: ${item['toppings'].map((topping) => '$topping').join(', ')}, ' : 'Toppings: Không, '}${item.containsKey('sugar') ? 'Đường: ${item['sugar']}%' : 'Đường: 100%'}',
                );
              }
              ToastNotification.showToast(message: 'Thanh toán thành công!');

              widget.onPaymentSuccess();
            } catch (e) {
              showDialog(
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

            Navigator.of(context).pop();
          },
          child: const Text('Thanh toán'),
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
        addInfo: "${DateFormat('yyyyMMddhhmmss').format(DateTime.now())}");
    try {
      await paymentService.initialize();
      Image qrImage = await paymentService.generatePaymentQR();
      return Center(child: qrImage);
    } catch (e) {
      // ignore: avoid_print
      print('An error occurred: $e');
      return const Center(child: Text('Failed to load QR code'));
    }
  }

  void _printInvoice() {
    // In hóa đơn
    // Tạo nội dung hóa đơn
    String invoiceContent = '***** HÓA ĐƠN *****\n\n';
    // invoiceContent += 'Khách hàng: ${customerName ?? 'Không có'}\n';
    invoiceContent +=
        'Ngày: ${DateTime.now().toLocal().toString().split(' ')[0]}\n'; // Ngày hiện tại
    invoiceContent += '--------------------------------\n';
    invoiceContent += 'STT | Tên sản phẩm | Số lượng | Đơn giá \n';
    invoiceContent += '--------------------------------\n';

    for (int i = 0; i < widget.cartItems.length; i++) {
      final item = widget.cartItems[i];
      invoiceContent +=
          '${i + 1}   | ${item['name']} | ${item['quantity']} | ${item['price']} VNĐ | ';

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

    invoiceContent +=
        'Khuyến mãi: ${(widget.promotionValue ?? 0).toString()} ${widget.promotionType == 'percentage' ? '%' : 'VNĐ'}\n';
    invoiceContent += 'Phụ thu: ${widget.surcharge.toStringAsFixed(2)} VNĐ\n';
    if (widget.surchargeReason.isNotEmpty) {
      invoiceContent += 'Lý do phụ thu: ${widget.surchargeReason}\n';
    }
    invoiceContent +=
        'Tổng cộng: ${(widget.totalPrice - (widget.promotionValue != null ? widget.promotionType == 'percentage' ? widget.totalPrice * (widget.promotionValue! / 100) : widget.promotionValue! : 0)).toStringAsFixed(2)} VNĐ\n';
    if (widget.hasTaxMode) {
      invoiceContent += 'VAT (10%): ${widget.tax.toStringAsFixed(2)} VNĐ\n';
    }
    invoiceContent += '--------------------------------\n';
    if (widget.hasTaxMode) {
      invoiceContent +=
          'Thanh toán (đã bao gồm VAT): ${((widget.totalPrice + widget.tax) - (widget.promotionValue != null ? widget.promotionType == 'percentage' ? widget.totalPrice * (widget.promotionValue! / 100) : widget.promotionValue! : 0)).toStringAsFixed(2)} VNĐ\n';
    } else {
      invoiceContent +=
          'Thanh toán: ${((widget.totalPrice) - (widget.promotionValue != null ? widget.promotionType == 'percentage' ? widget.totalPrice * (widget.promotionValue! / 100) : widget.promotionValue! : 0)).toStringAsFixed(2)} VNĐ\n';
    }

    invoiceContent += '***** CẢM ƠN QUÝ KHÁCH *****\n';

    // Hiển thị nội dung hóa đơn trong một dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Center(
                  child: Text(
                    invoiceContent,
                    style: const TextStyle(
                        fontFamily: 'Courier New'), // Font monospace cho dễ đọc
                  ),
                ),
                // hình QR code
                FutureBuilder<Widget>(
                  future: qr_code(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return snapshot.data != null
                          ? SizedBox(
                              width: 300, // Adjust the width as needed
                              height: 300, // Adjust the height as needed
                              child: snapshot.data,
                            )
                          : const SizedBox();
                    }
                  },
                ),
              ])),
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
}
