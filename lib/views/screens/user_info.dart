import 'package:coffeeapp/models/promotion_model.dart';
import 'package:coffeeapp/views/screens/change_password_screen.dart';
import 'package:coffeeapp/views/widgets/nofication.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/models/users_model.dart';
import 'package:coffeeapp/models/staff_model.dart';
import 'package:coffeeapp/models/customer_points_model.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    try {
      _userFuture = fetchUserById(widget.userId);
      final user = await _userFuture;
      if (user.isNotEmpty &&
          user[0]['role']?.toString().toLowerCase() != 'customer') {
        _staffFuture = fetchStaffById(widget.userId);
      }
      // _staffFuture = fetchStaffById(widget.userId);
      _customerPointsFuture = fetchCustomerPointsById(widget.userId);
    } catch (e) {
      debugPrint('Error initializing data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _initializeData,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        _userFuture.catchError((e) => []),
        _staffFuture.catchError((e) => []),
        _customerPointsFuture.catchError((e) => [])
      ]),
      builder: (context, snapshot) {
        if (_isLoading) return _buildLoadingShimmer();

        if (snapshot.hasError) {
          return _buildErrorWidget();
        }

        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.isEmpty ||
            snapshot.data![0].isEmpty) {
          return _buildNoDataWidget();
        }

        final userData = snapshot.data![0][0] as Map<String, dynamic>?;
        if (userData == null) {
          return _buildInvalidDataWidget();
        }

        return _buildUserInfo(context, userData);
      },
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 3,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Có lỗi xảy ra khi tải dữ liệu',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _initializeData,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrangeAccent,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Không tìm thấy thông tin người dùng',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildInvalidDataWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber_rounded, size: 60, color: Colors.orange),
          SizedBox(height: 16),
          Text(
            'Dữ liệu người dùng không hợp lệ',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Thông tin người dùng',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.deepOrangeAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _initializeData,
        ),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context, Map<String, dynamic> user) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildUserHeader(user),
                const SizedBox(height: 24),
                _buildUserDetailsCard(context, user),
                const SizedBox(height: 24),
                if (user['role']?.toString().toLowerCase() == 'admin' ||
                    user['role']?.toString().toLowerCase() == 'staff')
                  _buildStaffInfoCard(context),
                if (user['role']?.toString().toLowerCase() == 'admin' ||
                    user['role']?.toString().toLowerCase() == 'staff')
                  const SizedBox(height: 24),
                _buildCustomerPointsCard(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserHeader(Map<String, dynamic> user) {
    return Column(
      children: [
        Hero(
          tag: 'userAvatar${user['id']}',
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.orange.shade100,
            child: ClipOval(
              child: Image.network(
                '${user['image']}',
                height: 120,
                width: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user['name'] ?? 'N/A',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrangeAccent,
          ),
        ),
        Text(
          user['role']?.toString().toUpperCase() ?? 'USER',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildUserDetailsCard(
      BuildContext context, Map<String, dynamic> user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin cá nhân',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrangeAccent,
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoRow(
              icon: Icons.person,
              title: 'Tên đăng nhập',
              subtitle: user['username'] ?? 'N/A',
            ),
            _buildInfoRow(
              icon: Icons.email,
              title: 'Email',
              subtitle: user['email'] ?? 'N/A',
            ),
            _buildInfoRow(
              icon: Icons.phone,
              title: 'Điện thoại',
              subtitle: user['phone'] ?? 'N/A',
            ),
            _buildInfoRow(
              icon: Icons.home,
              title: 'Địa chỉ',
              subtitle: user['address'] ?? 'N/A',
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangePasswordScreen(
                        userId: widget.userId,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.lock_reset),
                label: const Text('Đổi mật khẩu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.deepOrangeAccent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
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
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox();
        }

        Map<String, dynamic> staff = snapshot.data![0] as Map<String, dynamic>;

        // Parse salary string to number
        final salaryStr = staff['salary']?.toString() ?? '0';
        final salary = double.tryParse(salaryStr) ?? 0;

        // Parse date with custom format
        String formattedDate;
        try {
          final dateStr = staff['start_date']?.toString() ?? '';
          final date = DateFormat('dd-MM-yyyy').parse(dateStr);
          formattedDate = DateFormat('dd/MM/yyyy').format(date);
        } catch (e) {
          formattedDate = 'N/A';
        }

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.work, color: Colors.deepOrangeAccent),
                    SizedBox(width: 12),
                    Text(
                      'Thông tin công việc',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrangeAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildInfoRow(
                  icon: Icons.monetization_on,
                  title: 'Lương',
                  // ignore: prefer_interpolation_to_compose_strings
                  subtitle: NumberFormat('#,###').format(salary) + ' VNĐ',
                ),
                _buildInfoRow(
                  icon: Icons.calendar_today,
                  title: 'Ngày bắt đầu',
                  subtitle: formattedDate,
                ),
                _buildInfoRow(
                  icon: Icons.badge,
                  title: 'Vị trí',
                  subtitle: staff['position'] ?? 'N/A',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomerPointsCard(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _customerPointsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.isEmpty ||
            snapshot.data![0].isEmpty) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('Chưa có điểm tích luỹ'),
              ),
            ),
          );
        }

        Map<String, dynamic> points =
            snapshot.data![0][0] as Map<String, dynamic>;
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.stars,
                      color: Colors.deepOrangeAccent,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Điểm tích luỹ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrangeAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      Text(
                        // ignore: unnecessary_string_interpolations
                        '${NumberFormat('#,###').format(points['points'])}',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrangeAccent,
                        ),
                      ),
                      Text(
                        'điểm',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (points['points'] >= 10000)
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _showExchangePointsDialog(context, points),
                      icon: const Icon(Icons.card_giftcard),
                      label: const Text('Đổi điểm'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrangeAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  )
                else
                  Center(
                    child: Text(
                      'Cần tích luỹ thêm ${NumberFormat('#,###').format(10000 - points['points'])} điểm để đổi quà',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showExchangePointsDialog(
    BuildContext context,
    Map<String, dynamic> points,
  ) async {
    final nameController = TextEditingController();
    final discountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Đổi điểm thành mã giảm giá',
          style: TextStyle(color: Colors.deepOrangeAccent),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Tên mã giảm giá',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.card_giftcard),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Vui lòng nhập tên mã giảm giá';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: discountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Số điểm muốn đổi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.stars),
                    suffixText: 'điểm',
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Vui lòng nhập số điểm';
                    }
                    final points = int.tryParse(value!) ?? 0;
                    if (points < 10000) {
                      return 'Số điểm tối thiểu là 10.000';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Huỷ',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                try {
                  final name = nameController.text;
                  final discountValue = int.parse(discountController.text);

                  if (discountValue > points['points']) {
                    ToastNotification.showToast(
                      message: 'Số điểm không đủ để đổi',
                    );
                    return;
                  }

                  await addPromotion({
                    'name': name,
                    'discount_type': 'fixed_amount',
                    'discount_value': discountValue,
                    'start_date':
                        DateFormat('yyyy-MM-dd').format(DateTime.now()),
                    'end_date': DateFormat('yyyy-MM-dd')
                        .format(DateTime.now().add(const Duration(days: 7))),
                    'min_order_value': 0,
                    'code_limit': 1,
                    'usage_limit': 1,
                    'active': true,
                    'description': 'users_id = ${widget.userId}',
                  });

                  await promotionPoints({
                    'user_id': widget.userId,
                    'points': discountValue,
                  });

                  setState(() {
                    _customerPointsFuture =
                        fetchCustomerPointsById(widget.userId);
                  });

                  if (mounted) {
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                    ToastNotification.showToast(
                      message: 'Đổi điểm thành công',
                    );
                  }
                } catch (e) {
                  ToastNotification.showToast(
                    message: 'Đã xảy ra lỗi: ${e.toString()}',
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrangeAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }
}
