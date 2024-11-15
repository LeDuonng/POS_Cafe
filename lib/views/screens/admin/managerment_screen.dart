import 'package:coffeeapp/views/screens/admin/config_screen.dart';
import 'package:coffeeapp/views/screens/admin/curd_screen.dart';
import 'package:coffeeapp/views/screens/admin/statistical.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class Management extends StatefulWidget {
  const Management(
      {super.key,
      required this.userID,
      required this.username,
      required this.role});
  final String userID;
  final String username;
  final String role;

  @override
  // ignore: library_private_types_in_public_api
  _ManagementState createState() => _ManagementState();
}

class _ManagementState extends State<Management> {
  @override
  Widget build(BuildContext context) {
    // Lấy kích thước của màn hình
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
            child: Column(
              children: [
                SizedBox(
                  // Đặt chiều cao cố định cho GridView để đảm bảo cuộn đúng cách
                  height: screenHeight,
                  child: GridView.builder(
                    itemCount: 7, // Số lượng panel bạn có
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: screenWidth > 600
                          ? 4
                          : 2, // Điều chỉnh số cột dựa trên kích thước màn hình
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio:
                          1, // Tỉ lệ giữa chiều rộng và chiều cao của các phần tử
                    ),
                    physics:
                        const NeverScrollableScrollPhysics(), // Tắt cuộn của GridView
                    itemBuilder: (context, index) {
                      switch (index) {
                        case 0:
                          return _buildStatisticalPanel(context);
                        case 1:
                          return _buildDateRevenuePanel();

                        case 2:
                          return _buildBarChartPanel();
                        case 3:
                          return _buildPieChartPanel();
                        case 4:
                          return _buildSettingPanel(context);

                        case 5:
                          return _buildCURDPanel(context, widget.userID,
                              widget.username, widget.role);
                        // case 6:
                        //   return _buildPOSPanel(context, widget.userID);
                        default:
                          return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Panel chứa biểu đồ cột
Widget _buildBarChartPanel() {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    elevation: 4,
    child: Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue vs Costs',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 1:
                              return const Text('Jan');
                            case 2:
                              return const Text('Feb');
                            case 3:
                              return const Text('Mar');
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    BarChartGroupData(
                      x: 1,
                      barRods: [BarChartRodData(toY: 30, color: Colors.blue)],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [BarChartRodData(toY: 40, color: Colors.orange)],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [BarChartRodData(toY: 50, color: Colors.red)],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Panel chứa biểu đồ tròn
Widget _buildPieChartPanel() {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    elevation: 4,
    child: Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.orange.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              'Sales by Category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 150,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: 40,
                      title: 'A',
                      color: Colors.blue,
                    ),
                    PieChartSectionData(
                      value: 30,
                      title: 'B',
                      color: Colors.orange,
                    ),
                    PieChartSectionData(
                      value: 30,
                      title: 'C',
                      color: Colors.red,
                    ),
                  ],
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Panel hiển thị thông tin ngày giờ
Widget _buildDateRevenuePanel() {
  String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    elevation: 4,
    child: Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 40, color: Colors.blue),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Date',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentDate,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildSettingPanel(BuildContext context) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    elevation: 4,
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ConfigScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Icon(Icons.settings, size: 40, color: Colors.blue),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'THIẾT LẬP',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'ĐI ĐẾN TRANG THIẾT LẬP',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Panel hiển thị tổng doanh thu
Widget _buildCURDPanel(
    BuildContext context, String userID, String username, String role) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    elevation: 4,
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CURDScreen(
              id: userID,
              username: username,
              role: role,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Icon(Icons.manage_accounts,
                      size: 40, color: Colors.green),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'QUẢN LÝ DỮ LIỆU',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Người dùng: $username\nVai trò: $role',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Widget _buildPOSPanel(BuildContext context, String userID) {
//   return Card(
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(15),
//     ),
//     elevation: 4,
//     child: InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => POSScreen(
//               tableId: null,
//               userID: userID,
//             ),
//           ),
//         );
//       },
//       child: Container(
//         padding: const EdgeInsets.all(16.0),
//         child: const Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   Icon(Icons.shopping_cart, size: 40, color: Colors.blue),
//                   SizedBox(width: 16),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'BÁN HÀNG',
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                       SizedBox(height: 10),
//                       Text(
//                         'ĐI ĐẾN TRANG BÁN HÀNG',
//                         style: TextStyle(fontSize: 16),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }
Widget _buildStatisticalPanel(BuildContext context) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    elevation: 4,
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StatisticalScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Icon(Icons.bar_chart, size: 40, color: Colors.red),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'THỐNG KÊ',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'ĐI ĐẾN TRANG THỐNG KÊ',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
