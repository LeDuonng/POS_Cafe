import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastNotification {
  /// Hiển thị thông báo với nội dung được truyền vào.
  /// [message] Nội dung của thông báo.
  /// [toastLength] Độ dài thời gian hiển thị (mặc định là Toast.LENGTH_SHORT).
  /// [gravity] Vị trí hiển thị của thông báo.
  /// [backgroundColor] Màu nền của thông báo.
  /// [textColor] Màu chữ của thông báo.
  /// [fontSize] Kích thước chữ.
  static void showToast({
    required String message,
    Toast toastLength = Toast.LENGTH_SHORT,
    ToastGravity gravity = ToastGravity.TOP,
    Color backgroundColor = Colors.black,
    Color textColor = Colors.white,
    double fontSize = 18.0,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength,
      gravity: gravity,
      timeInSecForIosWeb: 3,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
    );
  }
}
