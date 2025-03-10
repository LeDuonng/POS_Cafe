import 'package:coffeeapp/views/screens/curd/menu_screen.dart';
import 'package:coffeeapp/views/screens/curd/topping_screen.dart';
import 'package:coffeeapp/views/screens/curd/users_screen.dart';
import 'package:coffeeapp/views/screens/curd/table_screen.dart';
import 'package:coffeeapp/views/screens/curd/staff_screen.dart';
import 'package:coffeeapp/views/screens/curd/ingredients_screen.dart';
import 'package:coffeeapp/views/screens/curd/orders_screen.dart';
import 'package:coffeeapp/views/screens/curd/bills_screen.dart';
import 'package:coffeeapp/views/screens/curd/inventory_screen.dart';
import 'package:coffeeapp/views/screens/curd/customer_points_screen.dart';
import 'package:coffeeapp/views/screens/curd/promotion_screen.dart';
import 'package:coffeeapp/views/screens/signin_screen.dart';
import 'package:flutter/material.dart';

class CURDScreen extends StatefulWidget {
  final String? id;
  final String? username;
  final String? role;

  const CURDScreen({
    super.key,
    required this.id,
    required this.username,
    required this.role,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CURDScreenState createState() => _CURDScreenState();
}

class _CURDScreenState extends State<CURDScreen> {
  final List<Map<String, dynamic>> screens = const [
    {'name': 'Menu Món', 'screen': MenuScreen()},
    {'name': 'Topping', 'screen': ToppingScreen()},
    {'name': 'Người dùng', 'screen': UserScreen()},
    {'name': 'Bàn', 'screen': TableScreen()},
    {'name': 'Nhân viên', 'screen': StaffScreen()},
    {'name': 'Nguyên liệu', 'screen': IngredientsScreen()},
    {'name': 'Đơn', 'screen': OrdersScreen()},
    {'name': 'Hoá đơn', 'screen': BillsScreen()},
    {'name': 'Tồn kho', 'screen': InventoryScreen()},
    {'name': 'Điểm khách hàng', 'screen': CustomerPointsScreen()},
    {'name': 'Khuyến mãi', 'screen': PromotionScreen()},
  ];

  int _selectedIndex = 0;

  List<Map<String, dynamic>> getAccessibleScreens(String role) {
    switch (role.toLowerCase().toString()) {
      case 'admin':
        return screens;
      case 'staff':
        return screens.where((screen) {
          return [
            'Bàn',
            'Menu Món',
            'Topping',
            'Đơn',
            // 'Chi tiết đơn',
            'Hoá đơn',
            'Tồn kho',
            'Khuyến mãi',
          ].contains(screen['name']);
        }).toList();
      case 'customer':
        return screens.where((screen) {
          return [
            'Người dùng',
            'Đơn',
            // 'Chi tiết đơn',
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
    if (widget.role == null || widget.role!.isEmpty) {
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

    final accessibleScreens = getAccessibleScreens(widget.role!);

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
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: accessibleScreens.map((screen) {
              IconData iconData;
              switch (screen['name']) {
                case 'Menu Món':
                  iconData = Icons.restaurant_menu;
                  break;
                case 'Topping':
                  iconData = Icons.local_pizza;
                  break;
                case 'Người dùng':
                  iconData = Icons.person;
                  break;
                case 'Bàn':
                  iconData = Icons.table_chart;
                  break;
                case 'Nhân viên':
                  iconData = Icons.people;
                  break;
                case 'Nguyên liệu':
                  iconData = Icons.kitchen;
                  break;
                case 'Đơn':
                  iconData = Icons.receipt;
                  break;
                // case 'Chi tiết đơn':
                //   iconData = Icons.list_alt;
                //   break;
                case 'Hoá đơn':
                  iconData = Icons.attach_money;
                  break;
                case 'Tồn kho':
                  iconData = Icons.inventory;
                  break;
                case 'Điểm khách hàng':
                  iconData = Icons.star;
                  break;
                case 'Khuyến mãi':
                  iconData = Icons.local_offer;
                  break;
                default:
                  iconData = Icons.circle;
              }
              return NavigationRailDestination(
                icon: Icon(iconData),
                selectedIcon: Icon(iconData, color: Colors.blue),
                label: Text(screen['name']),
              );
            }).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // This is the main content.
          Expanded(
            child: accessibleScreens[_selectedIndex]['screen'],
          )
        ],
      ),
    );
  }
}
