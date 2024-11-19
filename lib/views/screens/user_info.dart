import 'package:coffeeapp/models/promotion_model.dart';
import 'package:coffeeapp/views/widgets/nofication.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/models/users_model.dart';
import 'package:coffeeapp/models/staff_model.dart';
import 'package:coffeeapp/models/customer_points_model.dart';
import 'package:intl/intl.dart';

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
    _userFuture = fetchUserById(widget.userId).then((user) {
      if (user.isNotEmpty && user[0]['role'] != 'customer') {
        _staffFuture = fetchStaffById(widget.userId);
      }
      return user;
    });
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
              colors: [Colors.orange, Colors.deepOrangeAccent],
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
                          Container(
                            width: 700,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset:
                                      const Offset(0, 4), // Shadow below box
                                ),
                              ],
                            ),
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
                                const SizedBox(height: 20),
                                _buildInfoRow(
                                    icon: Icons.person,
                                    title: 'Tên đăng nhập',
                                    subtitle: user['username'] ?? 'N/A'),
                                _buildInfoRow(
                                    icon: Icons.badge,
                                    title: 'Họ Tên',
                                    subtitle: user['name'] ?? 'N/A'),
                                _buildInfoRow(
                                    icon: Icons.email,
                                    title: 'Email',
                                    subtitle: user['email'] ?? 'N/A'),
                                _buildInfoRow(
                                    icon: Icons.phone,
                                    title: 'Điện thoại',
                                    subtitle: user['phone'] ?? 'N/A'),
                                _buildInfoRow(
                                    icon: Icons.home,
                                    title: 'Địa chỉ',
                                    subtitle: user['address'] ?? 'N/A'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (user['role'] == 'admin' ||
                              user['role'] == 'staff')
                            _buildStaffInfoCard(context),
                          if (user['role'] == 'admin' ||
                              user['role'] == 'staff')
                            const SizedBox(height: 20),
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

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(width: 16.0),
          Text('$title:',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(subtitle, style: const TextStyle(fontSize: 16)),
          ),
        ],
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
          return Container(
            width: 700,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4), // Shadow below box
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text('Thông tin nhân viên',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.deepOrangeAccent,
                                fontWeight: FontWeight.bold,
                              )),
                ),
                const SizedBox(height: 20),
                _buildInfoRow(
                    icon: Icons.monetization_on,
                    title: 'Lương',
                    subtitle: staff['salary'] != null
                        ? '${staff['salary']} VNĐ'
                        : 'N/A'),
                _buildInfoRow(
                    icon: Icons.calendar_today,
                    title: 'Ngày bắt đầu',
                    subtitle: staff['start_date'] != null
                        ? staff['start_date'].toString()
                        : 'N/A'),
                _buildInfoRow(
                    icon: Icons.work,
                    title: 'Vị trí',
                    subtitle: staff['position'] ?? 'N/A'),
              ],
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
          return Container(
            width: 700,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4), // Shadow below box
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text('Điểm tích luỹ',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.deepOrangeAccent,
                                fontWeight: FontWeight.bold,
                              )),
                ),
                const SizedBox(height: 20),
                _buildInfoRow(
                    icon: Icons.star,
                    title: 'Điểm',
                    subtitle: customerPoints['points'].toString()),
                ElevatedButton(
                  onPressed: () {
                    if (customerPoints['points'] < 10000) {
                      ToastNotification.showToast(
                          message:
                              'Số điểm không đủ để đổi. Cần ít nhất 10000 điểm');
                      return;
                    }
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: _buildExchangePoints(context, customerPoints),
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: const Text('Đổi điểm'),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildExchangePoints(
      BuildContext context, Map<String, dynamic> customerPoints) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController discountValueController =
        TextEditingController();
    final DateTime startDate = DateTime.now();
    final DateTime endDate = startDate.add(const Duration(days: 7));
    const int minOrderValue = 0;
    const int codeLimit = 1;
    const int usageLimit = 1;
    const bool active = true;
    String description = 'users_id = ${widget.userId}';

    return Container(
      width: 300,
      height: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4), // Shadow below box
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text('Đổi điểm',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.deepOrangeAccent,
                      fontWeight: FontWeight.bold,
                    )),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Mã giảm giá',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: discountValueController,
            decoration: InputDecoration(
              labelText: 'Số tiền giảm giá  <= ${customerPoints['points']}',
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () {
                try {
                  final String name = nameController.text;
                  final int discountValue =
                      int.parse(discountValueController.text);
                  if (discountValue > customerPoints['points']) {
                    ToastNotification.showToast(
                        message: 'Số điểm không đủ để đổi');
                    return;
                  }

                  addPromotion({
                    'name': name,
                    'discount_type': 'fixed_amount',
                    'discount_value': discountValue,
                    'start_date': DateFormat('yyyy-MM-dd').format(startDate),
                    'end_date': DateFormat('yyyy-MM-dd').format(endDate),
                    'min_order_value': minOrderValue,
                    'code_limit': codeLimit,
                    'usage_limit': usageLimit,
                    'active': active,
                    'description': description,
                  });
                  promotionPoints({
                    'user_id': widget.userId,
                    'points': discountValue,
                  });
                  setState(() {
                    _customerPointsFuture =
                        fetchCustomerPointsById(widget.userId);

                    Navigator.of(context).pop();
                  });
                  ToastNotification.showToast(message: 'Đổi điểm thành công');
                } catch (e) {
                  ToastNotification.showToast(
                      message: 'Đã xảy ra lỗi: ${e.toString()}');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              child: const Text('Đổi điểm'),
            ),
          ),
        ],
      ),
    );
  }
}
