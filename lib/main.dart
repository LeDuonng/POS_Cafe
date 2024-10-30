import 'package:coffeeapp/views/widgets/nofication.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coffeeapp/views/screens/dashboard.dart';
import 'package:coffeeapp/views/screens/signin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());

  // Display a toast notification upon app start-up
  ToastNotification.showToast(
    message: "Chào mừng đến với CoffeeApp!",
    gravity: ToastGravity.TOP,
    backgroundColor: Colors.orange,
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Map<String, String?>> getLoggedInUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userID = prefs.getString('userID');
    String? username = prefs.getString('username');
    String? role = prefs.getString('role');

    return {
      'userID': userID,
      'username': username,
      'role': role,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String?>>(
      future: getLoggedInUserInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else {
          if (snapshot.hasData &&
              snapshot.data!['userID'] != null &&
              snapshot.data!['username'] != null &&
              snapshot.data!['role'] != null) {
            return MaterialApp(
              title: 'CoffeeApp',
              theme: ThemeData(
                primarySwatch: Colors.orange,
              ),
              debugShowCheckedModeBanner: false,
              home: DashboardScreen(
                id: snapshot.data!['userID']!,
                username: snapshot.data!['username']!,
                role: snapshot.data!['role']!,
              ),
            );
          } else {
            return MaterialApp(
              title: 'CoffeeApp',
              theme: ThemeData(
                primarySwatch: Colors.orange,
              ),
              debugShowCheckedModeBanner: false,
              home: const LoginScreen(),
            );
          }
        }
      },
    );
  }
}
