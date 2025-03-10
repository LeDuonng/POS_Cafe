import 'dart:convert';
import 'dart:typed_data';
import 'package:coffeeapp/models/config_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PaymentService paymentService =
      PaymentService(amount: 1000, addInfo: "Test Payment");
  try {
    await paymentService.initialize();
    Image qrImage = await paymentService.generatePaymentQR();
    runApp(MaterialApp(home: Scaffold(body: Center(child: qrImage))));
  } catch (e) {
    // ignore: avoid_print
    print('An error occurred: $e');
    runApp(const MaterialApp(
        home: Scaffold(body: Center(child: Text('Lỗi khi tạo QR code')))));
  }
}

class PaymentService {
  final String apiUrl = 'https://api.vietqr.io/v2/generate';
  late final String accountNo;
  late final String accountName;
  late final int acqId;
  final int amount;
  final String addInfo;

  PaymentService({
    required this.amount,
    required this.addInfo,
  });

  Future<void> initialize() async {
    await _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      List<dynamic> configs = await fetchConfig();
      accountNo = configs
          .firstWhere((config) => config['key'] == 'bank_number')['value'];
      accountName = "Your Account Name"; // Update this as needed
      acqId = int.parse(
          configs.firstWhere((config) => config['key'] == 'bank_bin')['value']);
    } catch (e) {
      // ignore: avoid_print
      print('Lỗii khi tải cấu hình: $e');
    }
  }

  Future<Image> generatePaymentQR({
    String template = 'compact',
  }) async {
    final Map<String, dynamic> apiRequest = {
      "accountNo": accountNo,
      "accountName": accountName,
      "acqId": acqId,
      "amount": amount,
      "addInfo": addInfo,
      "format": "text",
      "template": template,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(apiRequest),
      );

      if (response.statusCode == 200) {
        final dataResult = json.decode(response.body);
        if (dataResult['data'] != null &&
            dataResult['data']['qrDataURL'] != null) {
          String qrDataURL = dataResult['data']['qrDataURL']
              .replaceAll("data:image/png;base64,", "");
          Uint8List bytes = base64Decode(qrDataURL);
          return Image.memory(bytes);
        } else {
          throw Exception('Không tìm thấy dữ liệu QR code');
        }
      } else {
        throw Exception('Lỗi khi tạo QR code: ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi khi tạo QR code: $e');
    }
  }
}
