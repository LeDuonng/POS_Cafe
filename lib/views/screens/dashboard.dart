import 'package:coffeeapp/controllers/config_controller.dart';
import 'package:coffeeapp/views/screens/managerment_screen.dart';
import 'package:coffeeapp/views/screens/pos/pos_screen.dart';
import 'package:coffeeapp/views/screens/signin_screen.dart';
import 'package:coffeeapp/views/screens/table/table_screen.dart';
import 'package:coffeeapp/views/screens/user_info.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  final String? id;
  final String? username;
  final String? role;

  const DashboardScreen({
    super.key,
    required this.id,
    required this.username,
    required this.role,
  });

  @override
  // ignore: library_private_types_in_public_api
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // Lưu chỉ mục hiện tại
  List<Widget> _pages = []; // Các trang widget cho mỗi mục trên Drawer
  List<Map<String, dynamic>> configs = []; // Khởi tạo biến configs rỗng
  bool hasTableMode = false; // Biến cờ để theo dõi trạng thái chế độ bàn

  @override
  void initState() {
    super.initState();
    _initializeAsync(); // Gọi hàm khởi tạo bất đồng bộ
  }

  Future<void> _initializeAsync() async {
    // Lấy cấu hình từ fetchConfig() và cập nhật state
    final configData = await fetchConfig();
    setState(() {
      configs = List<Map<String, dynamic>>.from(
          configData); // Gán configs với dữ liệu nhận được

      // Kiểm tra xem có chế độ "Bàn" không
      hasTableMode = configs.any(
            (config) =>
                config['key'] == 'use_table_mode' && config['value'] == 'true',
          ) &&
          widget.role != 'customer'; // Nếu role là customer thì là false

      // Khởi tạo các trang dựa trên configs và role của người dùng
      _pages = [
        POSScreen(tableId: null, userID: widget.id.toString()),
        Management(
          userID: widget.id.toString(),
          username: widget.username.toString(),
          role: widget.role.toString(),
        ),
        if (hasTableMode && (widget.role == 'admin' || widget.role == 'staff'))
          TableScreen(
            userID: widget.id.toString(),
            onTableSelected: (String tableId) {},
          ),
        UserInfoScreen(userId: int.parse(widget.id!)),
        const LoginScreen(),
      ];
    });
  }

  void _onDrawerItemTapped(int index) {
    if (index == 4) {
      _showLogoutConfirmationDialog();
    } else {
      setState(() {
        // Điều chỉnh lại chỉ mục được chọn nếu chế độ bàn thay đổi
        _selectedIndex = hasTableMode ? index : (index > 2 ? index - 1 : index);
      });
      Navigator.pop(context); // Đóng Drawer sau khi chọn
    }
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
            ),
            TextButton(
              child: const Text('Đăng xuất'),
              onPressed: () async {
                Navigator.of(context).pop(); // Đóng hộp thoại

                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs
                    .remove('userID'); // Xóa userID khỏi SharedPreferences

                // Điều hướng về màn hình đăng nhập
                Navigator.pushAndRemoveUntil(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: [
          // Text + Image bên trái
          Text('Xin chào ${widget.username}'),

          const Spacer(), // Đẩy các phần tử còn lại sang bên phải

          // PopupMenuButton khi nhấn vào cờ Việt Nam
          PopupMenuButton<String>(
            onSelected: (value) {
              // Xử lý logic khi chọn cờ từ danh sách
              // ignore: avoid_print
              print('Bạn đã chọn: $value');
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'vn',
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/Flag_of_Vietnam.svg/1200px-Flag_of_Vietnam.svg.png',
                        scale: 1.0,
                      ),
                      radius: 12,
                    ),
                    SizedBox(width: 10),
                    Text('Việt Nam'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'us',
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Flag_of_the_United_States.svg/1920px-Flag_of_the_United_States.svg.png',
                          scale: 1.0),
                      radius: 12,
                    ),
                    SizedBox(width: 10),
                    Text('Mỹ'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'uk',
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Flag_of_the_United_Kingdom_%281-2%29.svg/1920px-Flag_of_the_United_Kingdom_%281-2%29.svg.png',
                          scale: 1.0),
                      radius: 12,
                    ),
                    SizedBox(width: 10),
                    Text('Anh'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'cn',
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Flag_of_the_People%27s_Republic_of_China.svg/1280px-Flag_of_the_People%27s_Republic_of_China.svg.png',
                          scale: 1.0),
                      radius: 12,
                    ),
                    SizedBox(width: 10),
                    Text('Trung Quốc'),
                  ],
                ),
              ),
            ],
            child: const CircleAvatar(
              backgroundImage: NetworkImage(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/Flag_of_Vietnam.svg/1200px-Flag_of_Vietnam.svg.png',
              ),
            ),
          ),

          const SizedBox(width: 10), // Khoảng cách giữa 2 hình

          // Avatar còn lại bên phải
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      UserInfoScreen(userId: int.parse(widget.id!)),
                ),
              );
            },
            child: const CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/Flag_of_Vietnam.svg/1200px-Flag_of_Vietnam.svg.png',
                  scale: 1.0),
            ),
          ),
        ],
      )),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.purple,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            if (hasTableMode &&
                (widget.role == 'admin' || widget.role == 'staff'))
              _drawerItem(Icons.sell, 'Bán hàng', 0),
            if (!hasTableMode || widget.role == 'customer')
              _drawerItem(Icons.sell, 'Đặt hàng', 0),
            if (hasTableMode && (widget.role == 'admin'))
              _drawerItem(Icons.dashboard, 'Quản lý', 1),
            if (hasTableMode &&
                (widget.role == 'admin' || widget.role == 'staff'))
              _drawerItem(Icons.table_bar, 'Bàn', 2),
            _drawerItem(Icons.person, 'User Info', hasTableMode ? 3 : 2),
            _drawerItem(Icons.logout, 'Đăng xuất', hasTableMode ? 4 : 4),
          ],
        ),
      ),
      body: _pages.isNotEmpty
          ? _pages[_selectedIndex] // Hiển thị trang dựa trên chỉ mục được chọn
          : const Center(
              child: CircularProgressIndicator()), // Hiển thị khi chờ dữ liệu
    );
  }

  // Widget để tạo item cho Drawer
  ListTile _drawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: _selectedIndex == index,
      onTap: () => _onDrawerItemTapped(index),
    );
  }
}
