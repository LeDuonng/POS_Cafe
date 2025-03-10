import 'package:flutter/material.dart';
import 'package:coffeeapp/views/screens/admin/config_screen.dart';
import 'package:coffeeapp/views/screens/admin/statistical.dart';
import 'package:coffeeapp/views/screens/curd/menu_screen.dart';
import 'package:coffeeapp/views/screens/curd/topping_screen.dart';
import 'package:coffeeapp/views/screens/curd/users_screen.dart';
import 'package:coffeeapp/views/screens/curd/table_screen.dart';
import 'package:coffeeapp/views/screens/curd/staff_screen.dart';
import 'package:coffeeapp/views/screens/curd/orders_screen.dart';
import 'package:coffeeapp/views/screens/curd/bills_screen.dart';
import 'package:coffeeapp/views/screens/curd/customer_points_screen.dart';
import 'package:coffeeapp/views/screens/curd/promotion_screen.dart';

class Management extends StatefulWidget {
  const Management({
    super.key,
    required this.userID,
    required this.username,
    required this.role,
  });

  final String userID;
  final String username;
  final String role;

  @override
  // ignore: library_private_types_in_public_api
  _ManagementState createState() => _ManagementState();
}

class _ManagementState extends State<Management> {
  final List<Map<String, dynamic>> panels = [
    {
      'icon': Icons.bar_chart,
      'color': Colors.red,
      'title': 'THỐNG KÊ',
      'subtitle': 'Xem các thống kê chi tiết',
      'screen': const StatisticalScreen(),
    },
    {
      'icon': Icons.settings,
      'color': Colors.blue,
      'title': 'THIẾT LẬP',
      'subtitle': 'Cấu hình hệ thống và cài đặt',
      'screen': const ConfigScreen(),
    },
    {
      'icon': Icons.restaurant_menu,
      'color': Colors.orange,
      'title': 'MENU MÓN',
      'subtitle': 'Quản lý và cập nhật menu món',
      'screen': const MenuScreen(),
    },
    {
      'icon': Icons.local_drink,
      'color': Colors.purple,
      'title': 'TOPPING',
      'subtitle': 'Quản lý các loại topping',
      'screen': const ToppingScreen(),
    },
    {
      'icon': Icons.person,
      'color': Colors.teal,
      'title': 'NGƯỜI DÙNG',
      'subtitle': 'Quản lý thông tin người dùng',
      'screen': const UserScreen(),
    },
    {
      'icon': Icons.table_chart,
      'color': Colors.brown,
      'title': 'BÀN',
      'subtitle': 'Quản lý và sắp xếp bàn',
      'screen': const TableScreen(),
    },
    {
      'icon': Icons.people,
      'color': Colors.cyan,
      'title': 'NHÂN VIÊN',
      'subtitle': 'Quản lý thông tin nhân viên',
      'screen': const StaffScreen(),
    },
    {
      'icon': Icons.receipt,
      'color': Colors.indigo,
      'title': 'ĐƠN',
      'subtitle': 'Quản lý và theo dõi đơn hàng',
      'screen': const OrdersScreen(),
    },
    {
      'icon': Icons.receipt_long,
      'color': Colors.deepPurple,
      'title': 'HOÁ ĐƠN',
      'subtitle': 'Quản lý và xem hoá đơn',
      'screen': const BillsScreen(),
    },
    {
      'icon': Icons.star,
      'color': Colors.pink,
      'title': 'ĐIỂM KHÁCH HÀNG',
      'subtitle': 'Quản lý điểm thưởng khách hàng',
      'screen': const CustomerPointsScreen(),
    },
    {
      'icon': Icons.local_offer,
      'color': Colors.lightGreen,
      'title': 'KHUYẾN MÃI',
      'subtitle': 'Quản lý các chương trình khuyến mãi',
      'screen': const PromotionScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
            child: SizedBox(
              height: screenHeight,
              child: GridView.builder(
                itemCount: panels.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: screenWidth > 600 ? 4 : 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                // physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final panel = panels[index];
                  return CustomPanel(
                    icon: panel['icon'],
                    iconColor: panel['color'],
                    title: panel['title'],
                    subtitle: panel['subtitle'],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => panel['screen']),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomPanel extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const CustomPanel({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [iconColor.withOpacity(0.7), iconColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
