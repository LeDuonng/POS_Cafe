// import 'dart:convert';
// import 'package:coffeeapp/controllers/config_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;

// class PaymentForm extends StatefulWidget {
//   const PaymentForm({super.key});

//   @override
//   // ignore: library_private_types_in_public_api
//   _PaymentFormState createState() => _PaymentFormState();
// }

// class _PaymentFormState extends State<PaymentForm> {
//   final TextEditingController txtSTKController = TextEditingController();
//   final TextEditingController txtTenTaiKhoanController =
//       TextEditingController();
//   final TextEditingController txtSoTienController = TextEditingController();
//   final TextEditingController txtNoiDungController = TextEditingController();

//   String? selectedBank;
//   String selectedTemplate = 'compact';
// //   Giá trị	Size	Ghi chú
// // compact2	540x640	Bao gồm : Mã QR, các logo , thông tin chuyển khoản
// // compact	540x540	QR kèm logo VietQR, Napas, ngân hàng
// // qr_only	480x480	Trả về ảnh QR đơn giản, chỉ bao gồm QR
// // print	600x776	Bao gồm : Mã QR, các logo và đầy đủ thông tin chuyển khoản
//   List<dynamic> banks = [];
//   Image? qrImage;

//   @override
//   void initState() {
//     super.initState();
//     fetchBanks();
//   }

//   Future<void> fetchBanks() async {
//     final url = Uri.parse('https://api.vietqr.io/v2/banks');
//     final response = await http.get(url);
//     if (response.statusCode == 200) {
//       setState(() {
//         banks = json.decode(response.body)['data'];
//         selectedBank = banks.first['bin'].toString();
//       });
//     } else {
//       // ignore: avoid_print
//       print('Error fetching banks');
//     }
//   }

//   Future<void> generateQRCode() async {
//     if (selectedBank == null ||
//         txtSTKController.text.isEmpty ||
//         txtTenTaiKhoanController.text.isEmpty ||
//         txtSoTienController.text.isEmpty ||
//         txtNoiDungController.text.isEmpty) {
//       // ignore: avoid_print
//       print('Vui lòng nhập đầy đủ thông tin');
//       return;
//     }

//     final apiRequest = {
//       "accountNo": txtSTKController.text,
//       "accountName": txtTenTaiKhoanController.text,
//       "acqId": int.parse(selectedBank!),
//       "amount": int.parse(txtSoTienController.text),
//       "addInfo": txtNoiDungController.text,
//       "format": "text",
//       "template": selectedTemplate
//     };

//     final jsonRequest = json.encode(apiRequest);
//     final url = Uri.parse('https://api.vietqr.io/v2/generate');
//     final response = await http.post(
//       url,
//       headers: {
//         'Accept': 'application/json',
//         'Content-Type': 'application/json',
//       },
//       body: jsonRequest,
//     );

//     if (response.statusCode == 200) {
//       final dataResult = json.decode(response.body);

//       // Check if qrDataURL exists and is not null
//       if (dataResult['data'] != null &&
//           dataResult['data']['qrDataURL'] != null) {
//         String qrDataURL = dataResult['data']['qrDataURL']
//             .replaceAll("data:image/png;base64,", "");
//         setState(() {
//           qrImage = Image.memory(base64Decode(qrDataURL));
//         });
//       } else {
//         // ignore: avoid_print
//         print('QR Data URL not found in the response');
//         // You might want to display an error message to the user here.
//       }
//     } else {
//       // ignore: avoid_print
//       print('Error generating QR code');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("VietQR Payment")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: DropdownButton<String>(
//                 value: selectedBank,
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     selectedBank = newValue!;
//                   });
//                 },
//                 items: banks.map<DropdownMenuItem<String>>((dynamic bank) {
//                   return DropdownMenuItem<String>(
//                     value: bank['bin'].toString(),
//                     child: Row(
//                       children: [
//                         Image.network(
//                           bank['logo'].toString(),
//                           width: 75,
//                           height: 75,
//                           errorBuilder: (context, error, stackTrace) {
//                             return const Icon(
//                               Icons.error,
//                               color: Colors.red,
//                               size: 24,
//                             );
//                           },
//                         ),
//                         const SizedBox(width: 8),
//                         Text(bank['name'].toString()),
//                         Text('BIN: ${bank['bin']}'),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//             TextField(
//               controller: txtSTKController,
//               decoration: const InputDecoration(labelText: "Số tài khoản"),
//               keyboardType: TextInputType.number,
//               maxLength: 19,
//             ),
//             TextField(
//               controller: txtTenTaiKhoanController,
//               decoration: const InputDecoration(labelText: "Tên tài khoản"),
//               inputFormatters: [
//                 FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
//                 LengthLimitingTextInputFormatter(50),
//               ],
//               onChanged: (value) {
//                 if (value.length < 5) {
//                   // ignore: avoid_print
//                   print('Tên tài khoản phải có ít nhất 5 ký tự');
//                 }
//               },
//             ),
//             TextField(
//               controller: txtSoTienController,
//               decoration: const InputDecoration(labelText: "Số tiền"),
//               keyboardType: TextInputType.number,
//               inputFormatters: [
//                 FilteringTextInputFormatter.digitsOnly,
//                 LengthLimitingTextInputFormatter(13),
//               ],
//             ),
//             TextField(
//               controller: txtNoiDungController,
//               decoration: const InputDecoration(labelText: "Nội dung"),
//               maxLength: 25,
//               inputFormatters: [
//                 FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
//                 LengthLimitingTextInputFormatter(25),
//               ],
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: generateQRCode,
//               child: const Text("Tạo QR"),
//             ),
//             const SizedBox(height: 16),
//             qrImage != null
//                 ? Center(child: qrImage!)
//                 : const Center(child: Text("QR code sẽ hiển thị ở đây")),
//           ],
//         ),
//       ),
//     );
//   }
// }

// void main() {
//   runApp(const MaterialApp(
//     home: PaymentForm(),
//   ));
// }

// class PaymentService {
//   final String apiUrl = 'https://api.vietqr.io/v2/generate';
//   late final String accountNo;
//   late final String accountName;
//   late final int acqId;
//   final int amount;
//   final String addInfo;

//   PaymentService({
//     required this.amount,
//     required this.addInfo,
//   });

//   Future<void> initialize() async {
//     await _loadConfig();
//   }

//   Future<void> _loadConfig() async {
//     try {
//       List<dynamic> configs = await fetchConfig();
//       accountNo = configs
//           .firstWhere((config) => config['key'] == 'bank_number')['value'];
//       accountName = "Your Account Name"; // Update this as needed
//       acqId = int.parse(
//           configs.firstWhere((config) => config['key'] == 'bank_bin')['value']);
//     } catch (e) {
//       // ignore: avoid_print
//       print('Failed to load config: $e');
//       throw Exception('Failed to load config: $e');
//     }
//   }

//   Future<void> generatePaymentQR({
//     String template = 'compact',
//   }) async {
//     final Map<String, dynamic> apiRequest = {
//       "accountNo": accountNo,
//       "accountName": accountName,
//       "acqId": acqId,
//       "amount": amount,
//       "addInfo": addInfo,
//       "format": "text",
//       "template": template,
//     };

//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: json.encode(apiRequest),
//       );

//       if (response.statusCode == 200) {
//         final dataResult = json.decode(response.body);
//         if (dataResult['data'] != null &&
//             dataResult['data']['qrDataURL'] != null) {
//           String qrDataURL = dataResult['data']['qrDataURL']
//               .replaceAll("data:image/png;base64,", "");
//           // ignore: unused_local_variable
//           Image qrImage = Image.memory(base64Decode(qrDataURL));
//           // ignore: unnecessary_null_comparison
//           qrImage != null
//               ? Center(child: qrImage)
//               : const Center(child: Text("QR code sẽ hiển thị ở đây"));
//         } else {
//           throw Exception('QR Data URL not found in the response');
//         }
//       } else {
//         throw Exception('Error generating QR code: ${response.body}');
//       }
//     } catch (e) {
//       throw Exception('Failed to generate QR: $e');
//     }
//   }
// }

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
        home: Scaffold(body: Center(child: Text('Failed to load QR code')))));
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
      print('Failed to load config: $e');
      throw Exception('Failed to load config: $e');
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
          throw Exception('QR Data URL not found in the response');
        }
      } else {
        throw Exception('Error generating QR code: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to generate QR: $e');
    }
  }
}
