import 'package:http/http.dart' as http;
import 'dart:convert';

// Thay thế bằng thông tin MoMo của bạn
const String partnerCode = 'YOUR_PARTNER_CODE';
const String accessKey = 'YOUR_ACCESS_KEY';
const String secretKey = 'YOUR_SECRET_KEY';

Future<void> payWithMoMo(double amount, String customerNumber) async {
  // Tạo request body
  var requestBody = {
    'partnerCode': partnerCode,
    'orderId': DateTime.now()
        .millisecondsSinceEpoch
        .toString(), // Tạo orderId duy nhất
    'amount': amount.toStringAsFixed(0),
    'orderInfo': 'Thanh toán đơn hàng',
    'redirectUrl':
        'https://your-app.com/payment-result', // URL redirect sau thanh toán
    'ipnUrl':
        'https://your-app.com/payment-notification', // URL nhận thông báo thanh toán
    'extraData': '',
    'requestType': 'captureMoMoWallet',
    'lang': 'vi',
    'customerNumber': customerNumber,
  };

  // Ký request
  String signature = generateSignature(requestBody, secretKey);
  requestBody['signature'] = signature;

  // Gửi request
  var response = await http.post(
    Uri.parse('https://test-payment.momo.vn/v2/gateway/api/create'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(requestBody),
  );

  // Xử lý response
  if (response.statusCode == 200) {
    var responseBody = jsonDecode(response.body);
    if (responseBody['resultCode'] == 0) {
      // Thanh toán thành công
      // ignore: unused_local_variable
      String payUrl = responseBody['payUrl'];
      // Chuyển hướng người dùng đến payUrl
    } else {
      // Thanh toán thất bại
      // Hiển thị thông báo lỗi
    }
  } else {
    // Lỗi kết nối
    // Hiển thị thông báo lỗi
  }
}

// Hàm tạo chữ ký (tham khảo tài liệu MoMo)
String generateSignature(Map<String, dynamic> requestBody, String secretKey) {
  // Implement the signature generation logic here
  // For now, let's return an empty string to avoid the error
  return '';
}
