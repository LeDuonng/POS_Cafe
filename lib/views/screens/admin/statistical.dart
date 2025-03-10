import 'package:coffeeapp/views/screens/statistical/revenue_report.dart';
import 'package:flutter/material.dart';

class StatisticalScreen extends StatefulWidget {
  const StatisticalScreen({super.key});

  @override
  State<StatisticalScreen> createState() => _StatisticalScreenState();
}

class _StatisticalScreenState extends State<StatisticalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Thống kê'),
  //       bottom: TabBar(
  //         controller: _tabController,
  //         tabs: const [
  //           Tab(text: 'Doanh thu'),
  //           Tab(text: 'Đơn hàng'),
  //           Tab(text: 'Sản phẩm'),
  //         ],
  //       ),
  //     ),
  //     body: TabBarView(
  //       controller: _tabController,
  //       children: const [
  //         RevenueReportPage(),
  //         // OrderStatisticalScreen(),
  //         // ProductStatisticalScreen(),
  //       ],
  //     ),
  //   );
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // appBar: AppBar(
      //   title: const Text('Thống kê'),
      // ),
      body: RevenueReportPage(),
    );
  }
}
