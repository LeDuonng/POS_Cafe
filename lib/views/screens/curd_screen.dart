import 'package:coffeeapp/views/screens/curd/menu_screen.dart';
import 'package:coffeeapp/views/screens/curd/topping_screen.dart';
import 'package:coffeeapp/views/screens/curd/users_screen.dart';
import 'package:coffeeapp/views/screens/curd/table_screen.dart';
import 'package:coffeeapp/views/screens/curd/staff_screen.dart';
import 'package:coffeeapp/views/screens/curd/ingredients_screen.dart';
import 'package:coffeeapp/views/screens/curd/orders_screen.dart';
import 'package:coffeeapp/views/screens/curd/order_items_screen.dart';
import 'package:coffeeapp/views/screens/curd/bills_screen.dart';
import 'package:coffeeapp/views/screens/curd/inventory_screen.dart';
import 'package:coffeeapp/views/screens/curd/customer_points_screen.dart';
import 'package:coffeeapp/views/screens/signin_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Dashboard',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ));
  }
}

class CURDScreen extends StatelessWidget {
  final List<Map<String, dynamic>> screens = const [
    {'name': 'Menu Món', 'screen': MenuScreen()},
    {'name': 'Topping', 'screen': ToppingScreen()},
    {'name': 'Người dùng', 'screen': UserScreen()},
    {'name': 'Bàn', 'screen': TableScreen()},
    {'name': 'Nhân viên', 'screen': StaffScreen()},
    {'name': 'Nguyên liệu', 'screen': IngredientsScreen()},
    {'name': 'Đơn', 'screen': OrdersScreen()},
    {'name': 'Chi tiết đơn', 'screen': OrderItemsScreen()},
    {'name': 'Hoá đơn', 'screen': BillsScreen()},
    {'name': 'Tồn kho', 'screen': InventoryScreen()},
    {'name': 'Điểm khách hàng', 'screen': CustomerPointsScreen()},
  ];

  final String? id;
  final String? username;
  final String? role;

  const CURDScreen({
    super.key,
    required this.id,
    required this.username,
    required this.role,
  });

  List<Map<String, dynamic>> getAccessibleScreens(String role) {
    switch (role.toLowerCase().toString()) {
      case 'admin':
        return screens;
      case 'staff':
        return screens.where((screen) {
          return [
            'Bàn',
            'Menu Món',
            'Topping'
                'Đơn',
            'Chi tiết đơn',
            'Hoá đơn',
            'Tồn kho',
          ].contains(screen['name']);
        }).toList();
      case 'customer':
        return screens.where((screen) {
          return [
            'Người dùng',
            'Đơn',
            'Chi tiết đơn',
            'Hoá đơn',
            'Điểm khách hàng'
          ].contains(screen['name']);
        }).toList();
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra nếu `role` là null, điều hướng về màn hình đăng nhập
    if (role == null || role!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final accessibleScreens = getAccessibleScreens(role!);

    // Kiểm tra nếu danh sách các màn hình truy cập được là rỗng
    if (accessibleScreens.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: const Center(
          child: Text('No accessible screens for this role.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: ListView.builder(
        itemCount: accessibleScreens.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(accessibleScreens[index]['name']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => accessibleScreens[index]['screen'],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
