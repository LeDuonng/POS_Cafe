import 'package:coffeeapp/models/config_model.dart';
import 'package:coffeeapp/models/users_model.dart';
import 'package:coffeeapp/views/screens/admin/managerment_screen.dart';
import 'package:coffeeapp/views/screens/admin/bills_screen.dart';
import 'package:coffeeapp/views/screens/pos/pos_screen.dart';
import 'package:coffeeapp/views/screens/signin_screen.dart';
import 'package:coffeeapp/views/screens/admin/table_management.dart';
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
  Future<List<dynamic>>? _userFuture;
  @override
  void initState() {
    super.initState();
    _userFuture = fetchUserById(int.parse(widget.id!));
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
        if (hasTableMode && (widget.role == 'admin' || widget.role == 'staff'))
          Management(
            userID: widget.id.toString(),
            username: widget.username.toString(),
            role: widget.role.toString(),
          ),
        if (hasTableMode && (widget.role == 'admin' || widget.role == 'staff'))
          const BillsScreen(),
        if (hasTableMode && (widget.role == 'admin' || widget.role == 'staff'))
          TableManagementScreen(
            userID: widget.id.toString(),
            onTableSelected: (String tableId) {},
          ),
        UserInfoScreen(userId: int.parse(widget.id!)),
        const LoginScreen(),
      ];
    });
  }

  void _onDrawerItemTapped(int index) {
    if (index == 5) {
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
          const Spacer(), // Đẩy các phần tử còn lại sang bên phải
          Text(
            'Người dùng: ${widget.username}',
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
            child: FutureBuilder<List<dynamic>>(
              future: _userFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('Không tìm thấy thông tin người dùng'));
                } else {
                  Map<String, dynamic> userData =
                      snapshot.data![0] as Map<String, dynamic>;
                  final image = userData['image'];

                  if (image is String && image.isNotEmpty) {
                    // Use the image URL if valid
                    return CircleAvatar(
                      backgroundImage: NetworkImage(image),
                    );
                  } else {
                    // Fallback if image is not a valid String
                    return const CircleAvatar(
                      child: Icon(Icons.person),
                    );
                  }
                }
              },
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
              _drawerItem(Icons.receipt, 'Hóa đơn', 2),
            if (hasTableMode &&
                (widget.role == 'admin' || widget.role == 'staff'))
              _drawerItem(Icons.table_bar, 'Bàn', 3),
            _drawerItem(
                Icons.person, 'Thông tin người dùng', hasTableMode ? 4 : 2),
            _drawerItem(Icons.logout, 'Đăng xuất', hasTableMode ? 5 : 3),
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
