import 'dart:convert';

import 'package:coffeeapp/views/widgets/nofication.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/models/users_model.dart';

class ChangePasswordScreen extends StatefulWidget {
  final int userId;

  const ChangePasswordScreen({super.key, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        List<dynamic> user = await fetchUserById(widget.userId);
        if (user.isNotEmpty) {
          String oldPassword =
              base64Encode(utf8.encode(_oldPasswordController.text));
          if (user[0]['password'] == oldPassword) {
            String newPassword =
                base64Encode(utf8.encode(_newPasswordController.text));
            await updatePassword(widget.userId, newPassword);
            ToastNotification.showToast(message: 'Đổi mật khẩu thành công');
          } else {
            ToastNotification.showToast(message: 'Mật khẩu cũ không đúng');
          }
        } else {
          ToastNotification.showToast(message: 'Không tìm thấy người dùng');
        }
      } catch (e) {
        ToastNotification.showToast(message: 'Đã có lỗi xảy ra: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đổi mật khẩu'),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Container(
                width: 500,
                height: 500,
                padding: const EdgeInsets.all(75),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Đổi mật khẩu',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlue,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _oldPasswordController,
                      label: 'Mật khẩu cũ',
                      icon: Icons.lock,
                      obscureText: true,
                    ),
                    _buildTextField(
                      controller: _newPasswordController,
                      label: 'Mật khẩu mới',
                      icon: Icons.lock,
                      obscureText: true,
                    ),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      label: 'Nhập lại mật khẩu mới',
                      icon: Icons.lock,
                      obscureText: true,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _changePassword,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: Colors.lightBlue,
                      ),
                      child: const Text(
                        'Đổi mật khẩu',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.lightBlue),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.lightBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.lightBlue),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.lightBlue),
          ),
        ),
        obscureText: obscureText,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập $label';
          }
          if (label == 'Nhập lại mật khẩu mới' &&
              value != _newPasswordController.text) {
            return 'Mật khẩu không khớp';
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
