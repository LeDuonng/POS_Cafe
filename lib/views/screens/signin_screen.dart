import 'dart:convert';

import 'package:coffeeapp/views/screens/signup_screen.dart';
import 'package:coffeeapp/views/widgets/nofication.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/controllers/users_controller.dart';
import 'package:rive/rive.dart';
import 'package:coffeeapp/views/screens/admin/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Artboard? _riveArtboard;
  late RiveAnimationController _idleController;
  late RiveAnimationController _handsUpController;
  late RiveAnimationController _handsDownController;
  late RiveAnimationController _successController;
  late RiveAnimationController _failController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _initializeRive();
  }

  Future<void> _initializeRive() async {
    await RiveFile.initialize();
    _idleController = SimpleAnimation('idle');
    _handsUpController = SimpleAnimation('Hands_up');
    _handsDownController = SimpleAnimation('hands_down');
    _successController = SimpleAnimation('success');
    _failController = SimpleAnimation('fail');
    rootBundle.load('assets/animations/login_animation.riv').then((data) {
      final file = RiveFile.import(data);
      final artboard = file.mainArtboard;
      artboard.addController(_idleController);
      setState(() => _riveArtboard = artboard);
    });
  }

  void _togglePasswordFieldFocus(bool hasFocus) {
    setState(() {
      if (_riveArtboard != null) {
        _riveArtboard!.removeController(_idleController);
        _riveArtboard!.removeController(_handsUpController);
        _riveArtboard!.removeController(_handsDownController);
        _riveArtboard!.addController(
            hasFocus ? _handsUpController : _handsDownController);
      }
    });
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text;
      String password = _passwordController.text;
      password = base64Encode(utf8.encode(password));
      try {
        List<dynamic> result = await signin(username, password);

        if (result.isNotEmpty) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userID', result[0]['id'].toString());
          await prefs.setString('username', result[0]['name'].toString());
          await prefs.setString('role', result[0]['role'].toString());
          _riveArtboard!.removeController(_handsUpController);
          _riveArtboard!.addController(_successController);
          await Future.delayed(const Duration(milliseconds: 500));
          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
              builder: (context) => DashboardScreen(
                id: result[0]['id'].toString(),
                username: result[0]['name'].toString(),
                role: result[0]['role'].toString(),
              ),
            ),
          );
        } else {
          _riveArtboard!.removeController(_handsUpController);
          _riveArtboard!.addController(_failController);
          // ignore: use_build_context_synchronously
          ToastNotification.showToast(
              message: 'Lỗi đăng nhập, vui lòng thử lại.');
        }
      } catch (e) {
        if (mounted) {
          _riveArtboard!.removeController(_handsUpController);
          _riveArtboard!.addController(_failController);
          ToastNotification.showToast(message: 'Đã có lỗi xảy ra: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Đổi màu nền sáng hơn và hiện đại hơn
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Container(
                width: 500,
                height: 650,
                padding: const EdgeInsets.all(75),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4), // Shadow ở dưới khung
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // const SizedBox(height: 20.0),
                    SizedBox(
                      height: 200,
                      child: _riveArtboard == null
                          ? const SizedBox.shrink()
                          : Rive(artboard: _riveArtboard!),
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Tên đăng nhập',
                        labelStyle: const TextStyle(color: Colors.lightBlue),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.lightBlue),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Colors.lightBlue, width: 2.0),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        prefixIcon:
                            const Icon(Icons.person, color: Colors.lightBlue),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tên đăng nhập';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    FocusScope(
                      child: Focus(
                        onFocusChange: _togglePasswordFieldFocus,
                        child: TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Mật khẩu',
                            labelStyle:
                                const TextStyle(color: Colors.lightBlue),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.lightBlue),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.lightBlue, width: 2.0),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            prefixIcon:
                                const Icon(Icons.lock, color: Colors.lightBlue),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.lightBlue,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Mật khẩu';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        padding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 15.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      onPressed: _login,
                      child: const Text('Đăng nhập',
                          style:
                              TextStyle(fontSize: 18.0, color: Colors.white)),
                    ),
                    const SizedBox(height: 16.0),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignupScreen()),
                        );
                      },
                      child: const Text(
                        'Đăng kí nếu chưa có tài khoản',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.lightBlue,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        textAlign: TextAlign.center,
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

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
