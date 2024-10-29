import 'package:flutter/material.dart';
import 'package:coffeeapp/controllers/users_controller.dart';
import 'package:coffeeapp/controllers/staff_controller.dart';
import 'package:coffeeapp/controllers/customer_points_controller.dart';

class UserInfoScreen extends StatefulWidget {
  final int userId;

  const UserInfoScreen({super.key, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  late Future<List<dynamic>> _userFuture;
  late Future<List<dynamic>> _staffFuture;
  late Future<List<dynamic>> _customerPointsFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = fetchUserById(int.parse(widget.userId.toString()));
    _staffFuture = fetchStaffById(widget.userId);
    _customerPointsFuture = fetchCustomerPointsById(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin người dùng'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange,
                Colors.deepOrangeAccent
              ], // Sửa lại để đảm bảo có ít nhất 2 màu
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('Không tìm thấy thông tin người dùng'));
          } else {
            Map<String, dynamic> user =
                snapshot.data![0] as Map<String, dynamic>;
            return LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.orangeAccent,
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16.0),

                          // User Info Card
                          Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            shadowColor: Colors.orangeAccent,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.orange.shade100
                                  ], // Đảm bảo gradient có 2 màu trở lên
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Text('Thông tin người dùng',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(
                                                color: Colors.deepOrangeAccent,
                                                fontWeight: FontWeight.bold,
                                              )),
                                    ),
                                    const SizedBox(height: 10),
                                    ListTile(
                                      leading: const Icon(Icons.person,
                                          color: Colors.orange),
                                      title: const Text('Tên đăng nhập'),
                                      subtitle: Text(user['username'],
                                          style: const TextStyle(fontSize: 16)),
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.badge,
                                          color: Colors.orange),
                                      title: const Text('Họ Tên'),
                                      subtitle: Text(user['name'],
                                          style: const TextStyle(fontSize: 16)),
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.email,
                                          color: Colors.orange),
                                      title: const Text('Email'),
                                      subtitle: Text(user['email'],
                                          style: const TextStyle(fontSize: 16)),
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.phone,
                                          color: Colors.orange),
                                      title: const Text('Điện thoại'),
                                      subtitle: Text(user['phone'],
                                          style: const TextStyle(fontSize: 16)),
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.home,
                                          color: Colors.orange),
                                      title: const Text('Địa chỉ'),
                                      subtitle: Text(user['address'],
                                          style: const TextStyle(fontSize: 16)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const Divider(),

                          if (user['role'] == 'admin' ||
                              user['role'] == 'staff')
                            _buildStaffInfoCard(context),

                          _buildCustomerPointsCard(context),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildStaffInfoCard(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _staffFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text('Không tìm thấy thông tin nhân viên'));
        } else {
          Map<String, dynamic> staff =
              snapshot.data![0] as Map<String, dynamic>;
          return Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            margin: const EdgeInsets.symmetric(vertical: 10),
            shadowColor: Colors.orangeAccent,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.orange.shade100
                  ], // Đảm bảo gradient có ít nhất 2 màu
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text('Thông tin nhân viên',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.deepOrangeAccent,
                                fontWeight: FontWeight.bold,
                              )),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      leading: const Icon(Icons.monetization_on,
                          color: Colors.orange),
                      title: const Text('Lương'),
                      subtitle: Text('${staff['salary']} VNĐ',
                          style: const TextStyle(fontSize: 16)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.calendar_today,
                          color: Colors.orange),
                      title: const Text('Ngày bắt đầu'),
                      subtitle: Text(staff['start_date'].toString(),
                          style: const TextStyle(fontSize: 16)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.work, color: Colors.orange),
                      title: const Text('Vị trí'),
                      subtitle: Text(staff['position'],
                          style: const TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildCustomerPointsCard(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _customerPointsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Người dùng chưa có điểm tích luỹ'));
        } else {
          Map<String, dynamic> customerPoints =
              snapshot.data![0] as Map<String, dynamic>;
          return Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            margin: const EdgeInsets.symmetric(vertical: 10),
            shadowColor: Colors.orangeAccent,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.orange.shade100
                  ], // Đảm bảo gradient có ít nhất 2 màu
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text('Điểm tích luỹ',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.deepOrangeAccent,
                                fontWeight: FontWeight.bold,
                              )),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      leading: const Icon(Icons.star, color: Colors.orange),
                      title: const Text('Điểm'),
                      subtitle: Text(customerPoints['points'].toString(),
                          style: const TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
