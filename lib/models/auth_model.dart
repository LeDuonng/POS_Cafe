import 'dart:io' show Platform; // Để kiểm tra nền tảng Android/iOS
import 'package:flutter/foundation.dart'
    show kIsWeb; // Để kiểm tra nền tảng Web

const String baseUrl =
    'http://127.0.0.1:5000'; // Địa chỉ IP của server Flask cho Web
const String baseUrlAndroid =
    'http://192.168.1.2:5000'; // Địa chỉ IP của máy tính chạy server Flask cho Android

String getPlatformBaseUrl() {
  if (kIsWeb) {
    // Nếu là nền tảng web, sử dụng baseUrl cho Web
    return baseUrl;
  } else if (Platform.isAndroid) {
    // Nếu là nền tảng Android, sử dụng baseUrlAndroid
    return baseUrlAndroid;
  } else {
    // Sử dụng baseUrl mặc định cho các nền tảng khác (iOS, Desktop)
    return baseUrl;
  }
}
