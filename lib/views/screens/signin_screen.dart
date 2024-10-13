import 'package:coffeeapp/views/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/models/users_model.dart';
import 'package:rive/rive.dart';
import 'package:coffeeapp/views/screens/dashboard.dart';
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login failed. No user data.')),
          );
        }
      } catch (e) {
        if (mounted) {
          _riveArtboard!.removeController(_handsUpController);
          _riveArtboard!.addController(_failController);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An error occurred: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text('Login', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 40.0),
                SizedBox(
                  height: 220,
                  child: _riveArtboard == null
                      ? const SizedBox.shrink()
                      : Rive(artboard: _riveArtboard!),
                ),
                const SizedBox(height: 40.0),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: const TextStyle(color: Colors.lightBlue),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.lightBlue),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.lightBlue, width: 2.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    prefixIcon:
                        const Icon(Icons.person, color: Colors.lightBlue),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
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
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.lightBlue),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.lightBlue),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Colors.lightBlue, width: 2.0),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        prefixIcon:
                            const Icon(Icons.lock, color: Colors.lightBlue),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
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
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  onPressed: _login,
                  child: const Text('Login',
                      style: TextStyle(fontSize: 18.0, color: Colors.white)),
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
                    'Don\'t have an account? Sign up here',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.lightBlue,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40.0),
              ],
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
