import 'package:coffeeapp/controllers/users_controller.dart';
import 'package:coffeeapp/views/widgets/nofication.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _roleController = TextEditingController(text: 'customer');
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (await registerUser(
          username: _usernameController.text,
          password: _passwordController.text,
          role: _roleController.text,
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          address: _addressController.text,
        )) {
          // ignore: use_build_context_synchronously
          ToastNotification.showToast(message: 'Đăng ký thành công');
        } else {
          // ignore: use_build_context_synchronously
          ToastNotification.showToast(message: 'Đăng ký thất bại');
        }
      } catch (e) {
        // ignore: avoid_print
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký tài khoản'),
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
                height: 800,
                padding: const EdgeInsets.all(75),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4), // Shadow ở dưới khung
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Tạo tài khoản',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Vui lòng điền thông tin để tạo tài khoản',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        _buildTextField(
                            controller: _usernameController,
                            label: 'Tên đăng nhập',
                            icon: Icons.person),
                        _buildTextField(
                            controller: _passwordController,
                            label: 'Mật khẩu',
                            icon: Icons.lock,
                            obscureText: true),
                        _buildTextField(
                            controller: _confirmPasswordController,
                            label: 'Nhập lại mật khẩu',
                            icon: Icons.lock,
                            obscureText: true),
                        _buildTextField(
                            controller: _nameController,
                            label: 'Tên người dùng',
                            icon: Icons.account_circle),
                        _buildTextField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email),
                        _buildTextField(
                            controller: _phoneController,
                            label: 'Số điện thoại',
                            icon: Icons.phone),
                        _buildTextField(
                            controller: _addressController,
                            label: 'Địa chỉ',
                            icon: Icons.home),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _registerUser,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            backgroundColor: Colors.lightBlue,
                          ),
                          child: const Text(
                            'Đăng ký',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
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

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      required IconData icon,
      bool obscureText = false}) {
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
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.lightBlue),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        obscureText: obscureText,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập $label';
          }
          if (label == 'Confirm Password' &&
              value != _passwordController.text) {
            return 'Mật khẩu không khớp';
          }
          return null;
        },
      ),
    );
  }
}
