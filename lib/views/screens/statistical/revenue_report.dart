import 'package:coffeeapp/models/statistical_model.dart';
import 'package:coffeeapp/responsive.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class RevenueReportPage extends StatefulWidget {
  const RevenueReportPage({super.key});

  @override
  State<RevenueReportPage> createState() => _RevenueReportPageState();
}

class _RevenueReportPageState extends State<RevenueReportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<RevenueDataDaily> dailyRevenueData = [];
  List<RevenueData> rangeRevenueData = [];
  List<RevenueData> categoryRevenueData = [];
  List<RevenueData> staffRevenueData = [];

  DateTime? _startDate;
  DateTime? _endDate;
  double totalCash = 0.0;
  double totalCard = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchDailyRevenue();
    _fetchRevenueByRange();
    _fetchRevenueByCategoryRange();
    _fetchRevenueByStaffRange();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchDailyRevenue() async {
    try {
      final data = await fetchDailyRevenue();
      // Giải nén giá trị total_cash và total_card từ dữ liệu trả về
      if (data.isNotEmpty) {
        setState(() {
          totalCash = data[0]['total_cash'] ?? 0.0;
          totalCard = data[0]['total_card'] ?? 0.0;
        });
      }
    } catch (e) {
      debugPrint('Lỗi khi tải doanh thu hàng ngày: $e');
    }
  }

  Future<void> _fetchRevenueByRange() async {
    try {
      final data = await fetchRevenueByRange(
          (_startDate ?? DateTime.now().subtract(const Duration(days: 7)))
              .toIso8601String()
              .split('T')
              .first,
          (_endDate ?? DateTime.now()).toIso8601String().split('T').first);
      final Map<String, double> consolidatedRevenue = {};

      for (var item in data) {
        String date = item['date'];
        double revenue = double.parse(item['total_revenue']);

        if (consolidatedRevenue.containsKey(date)) {
          consolidatedRevenue[date] = consolidatedRevenue[date]! + revenue;
        } else {
          consolidatedRevenue[date] = revenue;
        }
      }

      setState(() {
        rangeRevenueData = consolidatedRevenue.entries
            .map((entry) => RevenueData(entry.key, entry.value))
            .toList();
      });
    } catch (e) {
      debugPrint('Lỗi khi tải doanh thu trong khoảng thời gian: $e');
    }
  }

  Future<void> _fetchRevenueByCategoryRange() async {
    try {
      final data = await fetchRevenueByCategoryRange(
          (_startDate ?? DateTime.now().subtract(const Duration(days: 7)))
              .toIso8601String()
              .split('T')
              .first,
          (_endDate ?? DateTime.now()).toIso8601String().split('T').first);

      setState(() {
        categoryRevenueData = data
            .map((item) => RevenueData(
                item['category'], double.parse(item['total_revenue'])))
            .toList();
      });
    } catch (e) {
      debugPrint(
          'Lỗi khi tải doanh thu theo danh mục trong khoảng thời gian: $e');
    }
  }

  Future<void> _fetchRevenueByStaffRange() async {
    try {
      final data = await fetchRevenueByStaffRange(
          (_startDate ?? DateTime.now().subtract(const Duration(days: 7)))
              .toIso8601String()
              .split('T')
              .first,
          (_endDate ?? DateTime.now()).toIso8601String().split('T').first);
      setState(() {
        staffRevenueData = data
            .map((item) => RevenueData(
                item['staff_name'], double.parse(item['total_revenue'])))
            .toList();
      });
    } catch (e) {
      debugPrint(
          'Lỗi khi tải doanh thu theo nhân viên trong khoảng thời gian: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo doanh thu'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Hàng ngày'),
            Tab(text: 'Khoảng thời gian'),
            Tab(text: 'Loại sản phẩm'),
            Tab(text: 'Nhân viên'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDailyRevenueTab(),
          _buildRangeRevenueTab(),
          _buildCategoryRevenueTab(),
          _buildStaffRevenueTab(),
        ],
      ),
    );
  }

  Widget _buildDailyRevenueTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        const Text('Tiền mặt'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        const Text('Thẻ'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          totalCash > 0 || totalCard > 0
              ? Expanded(
                  child: SfCircularChart(
                    title: ChartTitle(
                      text:
                          'Doanh thu trong ngày\nTổng: ${NumberFormat.currency(locale: "vi_VN", symbol: "").format(totalCash + totalCard)} VNĐ',
                    ),
                    series: <CircularSeries>[
                      PieSeries<Map<String, dynamic>, String>(
                        dataSource: [
                          {'category': 'Tiền mặt', 'value': totalCash},
                          {'category': 'Thẻ', 'value': totalCard}
                        ],
                        xValueMapper: (Map<String, dynamic> data, _) =>
                            data['category'] as String,
                        yValueMapper: (Map<String, dynamic> data, _) =>
                            data['value'] as double,
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                          labelPosition: ChartDataLabelPosition.outside,
                        ),
                        dataLabelMapper: (Map<String, dynamic> data, _) {
                          if (Responsive.isDesktop(context)) {
                            return '${NumberFormat.currency(locale: "vi_VN", symbol: "").format(data['value'])} VNĐ\n(${_getReadableAmount(data['value'])})';
                          } else {
                            return '${NumberFormat.currency(locale: "vi_VN", symbol: "").format(data['value'])} VNĐ';
                          }
                        },
                        enableTooltip: true,
                        pointColorMapper: (Map<String, dynamic> data, _) =>
                            data['category'] == 'Tiền mặt'
                                ? Colors.blue
                                : Colors.green,
                      ),
                    ],
                  ),
                )
              : _buildEmptyDataWidget(),
        ],
      ),
    );
  }

  Widget _buildRangeRevenueTab() {
    bool isColumnChart = true;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _startDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null && picked != _startDate) {
                              setState(() {
                                _startDate = picked;
                              });
                              _fetchRevenueByRange();
                            }
                          },
                          child: Text(_startDate == null
                              ? 'Chọn ngày bắt đầu'
                              : DateFormat('dd/MM/yyyy').format(_startDate!)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _endDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null && picked != _endDate) {
                              setState(() {
                                _endDate = picked;
                              });
                              _fetchRevenueByRange();
                            }
                          },
                          child: Text(_endDate == null
                              ? 'Chọn ngày kết thúc'
                              : DateFormat('dd/MM/yyyy').format(_endDate!)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            _fetchRevenueByRange();
                          },
                          child: const Text('Xem'),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _startDate =
                              DateTime.now().subtract(const Duration(days: 7));
                          _endDate = DateTime.now();
                        });
                        _fetchRevenueByRange();
                      },
                      child: const Text('7 ngày qua'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _startDate = DateTime(
                              DateTime.now().year, DateTime.now().month - 1, 1);
                          _endDate = DateTime.now();
                        });
                        _fetchRevenueByRange();
                      },
                      child: const Text('Tháng trước đến nay'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _startDate = DateTime(
                              DateTime.now().year - 1, DateTime.now().month);
                          _endDate = DateTime.now();
                        });
                        _fetchRevenueByRange();
                      },
                      child: const Text('Năm qua'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isColumnChart = !isColumnChart;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: isColumnChart
                            ? Colors.blue
                            : Colors.green, // Text color
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child:
                          Text(isColumnChart ? 'Biểu đồ đường' : 'Biểu đồ cột'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              rangeRevenueData.isNotEmpty
                  ? Expanded(
                      child: SfCartesianChart(
                        title: ChartTitle(
                          text:
                              'Biểu đồ doanh thu ${_startDate != null ? 'từ ngày ${DateFormat('dd/MM/yyyy').format(_startDate!)}' : ''} ${_endDate != null ? 'đến ngày ${DateFormat('dd/MM/yyyy').format(_endDate!)}' : ''}',
                        ),
                        primaryXAxis: CategoryAxis(),
                        series: <ChartSeries>[
                          if (isColumnChart)
                            ColumnSeries<RevenueData, String>(
                              dataSource: rangeRevenueData,
                              xValueMapper: (RevenueData data, _) => data.label,
                              yValueMapper: (RevenueData data, _) => data.value,
                              dataLabelSettings: const DataLabelSettings(
                                isVisible: true,
                                labelPosition: ChartDataLabelPosition.outside,
                              ),
                              enableTooltip: true,
                              dataLabelMapper: (RevenueData data, _) {
                                if (Responsive.isDesktop(context)) {
                                  return '${NumberFormat.currency(locale: "vi_VN", symbol: "").format(data.value)} VNĐ\n(${_getReadableAmount(data.value)})';
                                } else {
                                  return '${NumberFormat.currency(locale: "vi_VN", symbol: "").format(data.value)} VNĐ';
                                }
                              },
                              pointColorMapper: (RevenueData data, _) =>
                                  Colors.primaries[
                                      rangeRevenueData.indexOf(data) %
                                          Colors.primaries.length],
                            )
                          else
                            LineSeries<RevenueData, String>(
                              dataSource: rangeRevenueData,
                              xValueMapper: (RevenueData data, _) => data.label,
                              yValueMapper: (RevenueData data, _) => data.value,
                              dataLabelSettings: const DataLabelSettings(
                                isVisible: true,
                                labelPosition: ChartDataLabelPosition.outside,
                              ),
                              enableTooltip: true,
                              dataLabelMapper: (RevenueData data, _) {
                                if (Responsive.isDesktop(context)) {
                                  return '${NumberFormat.currency(locale: "vi_VN", symbol: "").format(data.value)} VNĐ\n(${_getReadableAmount(data.value)})';
                                } else {
                                  return '${NumberFormat.currency(locale: "vi_VN", symbol: "").format(data.value)} VNĐ';
                                }
                              },
                              pointColorMapper: (RevenueData data, _) =>
                                  Colors.primaries[
                                      rangeRevenueData.indexOf(data) %
                                          Colors.primaries.length],
                            ),
                        ],
                        plotAreaBorderWidth: 0,
                        primaryYAxis: NumericAxis(
                          labelFormat: '{value} VNĐ',
                          axisLine: const AxisLine(width: 0),
                          majorTickLines: const MajorTickLines(size: 0),
                        ),
                        tooltipBehavior: TooltipBehavior(enable: true),
                        borderColor: Colors.grey,
                        borderWidth: 1,
                        margin: const EdgeInsets.all(8),
                      ),
                    )
                  : _buildEmptyDataWidget(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryRevenueTab() {
    bool isColumnChart = true;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _startDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null && picked != _startDate) {
                              setState(() {
                                _startDate = picked;
                              });
                              _fetchRevenueByCategoryRange();
                            }
                          },
                          child: Text(_startDate == null
                              ? 'Chọn ngày bắt đầu'
                              : DateFormat('dd/MM/yyyy').format(_startDate!)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _endDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null && picked != _endDate) {
                              setState(() {
                                _endDate = picked;
                              });
                              _fetchRevenueByCategoryRange();
                            }
                          },
                          child: Text(_endDate == null
                              ? 'Chọn ngày kết thúc'
                              : DateFormat('dd/MM/yyyy').format(_endDate!)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            _fetchRevenueByCategoryRange();
                          },
                          child: const Text('Xem'),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _startDate =
                              DateTime.now().subtract(const Duration(days: 7));
                          _endDate = DateTime.now();
                        });
                        _fetchRevenueByCategoryRange();
                      },
                      child: const Text('7 ngày qua'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _startDate = DateTime(
                              DateTime.now().year, DateTime.now().month - 1, 1);
                          _endDate = DateTime.now();
                        });
                        _fetchRevenueByCategoryRange();
                      },
                      child: const Text('Tháng trước đến nay'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _startDate = DateTime(
                              DateTime.now().year - 1, DateTime.now().month);
                          _endDate = DateTime.now();
                        });
                        _fetchRevenueByCategoryRange();
                      },
                      child: const Text('Năm qua'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isColumnChart = !isColumnChart;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: isColumnChart
                            ? Colors.blue
                            : Colors.green, // Text color
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child:
                          Text(isColumnChart ? 'Biểu đồ đường' : 'Biểu đồ cột'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              categoryRevenueData.isNotEmpty
                  ? Expanded(
                      child: SfCartesianChart(
                        title: ChartTitle(
                          text:
                              'Doanh thu theo danh mục sản phẩm ${_startDate != null ? 'từ ngày ${DateFormat('dd/MM/yyyy').format(_startDate!)}' : ''} ${_endDate != null ? 'đến ngày ${DateFormat('dd/MM/yyyy').format(_endDate!)}' : ''}',
                        ),
                        primaryXAxis: CategoryAxis(),
                        series: <ChartSeries>[
                          if (isColumnChart)
                            ColumnSeries<RevenueData, String>(
                              dataSource: categoryRevenueData,
                              xValueMapper: (RevenueData data, _) => data.label,
                              yValueMapper: (RevenueData data, _) => data.value,
                              dataLabelSettings: const DataLabelSettings(
                                isVisible: true,
                                labelPosition: ChartDataLabelPosition.outside,
                              ),
                              enableTooltip: true,
                              dataLabelMapper: (RevenueData data, _) {
                                if (Responsive.isDesktop(context)) {
                                  return '${NumberFormat.currency(locale: "vi_VN", symbol: "").format(data.value)} VNĐ\n(${_getReadableAmount(data.value)})';
                                } else {
                                  return '${NumberFormat.currency(locale: "vi_VN", symbol: "").format(data.value)} VNĐ';
                                }
                              },
                              pointColorMapper: (RevenueData data, _) =>
                                  Colors.primaries[
                                      categoryRevenueData.indexOf(data) %
                                          Colors.primaries.length],
                            )
                          else
                            LineSeries<RevenueData, String>(
                              dataSource: categoryRevenueData,
                              xValueMapper: (RevenueData data, _) => data.label,
                              yValueMapper: (RevenueData data, _) => data.value,
                              dataLabelSettings: const DataLabelSettings(
                                isVisible: true,
                                labelPosition: ChartDataLabelPosition.outside,
                              ),
                              enableTooltip: true,
                              dataLabelMapper: (RevenueData data, _) {
                                if (Responsive.isDesktop(context)) {
                                  return '${NumberFormat.currency(locale: "vi_VN", symbol: "").format(data.value)} VNĐ\n(${_getReadableAmount(data.value)})';
                                } else {
                                  return '${NumberFormat.currency(locale: "vi_VN", symbol: "").format(data.value)} VNĐ';
                                }
                              },
                              pointColorMapper: (RevenueData data, _) =>
                                  Colors.primaries[
                                      categoryRevenueData.indexOf(data) %
                                          Colors.primaries.length],
                            ),
                        ],
                        plotAreaBorderWidth: 0,
                        primaryYAxis: NumericAxis(
                          labelFormat: '{value} VNĐ',
                          axisLine: const AxisLine(width: 0),
                          majorTickLines: const MajorTickLines(size: 0),
                        ),
                        tooltipBehavior: TooltipBehavior(enable: true),
                        borderColor: Colors.grey,
                        borderWidth: 1,
                        margin: const EdgeInsets.all(8),
                      ),
                    )
                  : _buildEmptyDataWidget(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStaffRevenueTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null && picked != _startDate) {
                          setState(() {
                            _startDate = picked;
                          });
                          _fetchRevenueByStaffRange();
                        }
                      },
                      child: Text(_startDate == null
                          ? 'Chọn ngày bắt đầu'
                          : DateFormat('dd/MM/yyyy').format(_startDate!)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null && picked != _endDate) {
                          setState(() {
                            _endDate = picked;
                          });
                          _fetchRevenueByStaffRange();
                        }
                      },
                      child: Text(_endDate == null
                          ? 'Chọn ngày kết thúc'
                          : DateFormat('dd/MM/yyyy').format(_endDate!)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        _fetchRevenueByStaffRange();
                      },
                      child: const Text('Xem'),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _startDate =
                          DateTime.now().subtract(const Duration(days: 7));
                      _endDate = DateTime.now();
                    });
                    _fetchRevenueByStaffRange();
                  },
                  child: const Text('7 ngày qua'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _startDate = DateTime(
                          DateTime.now().year, DateTime.now().month - 1, 1);
                      _endDate = DateTime.now();
                    });
                    _fetchRevenueByStaffRange();
                  },
                  child: const Text('Tháng trước đến nay'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _startDate = DateTime(
                          DateTime.now().year - 1, DateTime.now().month);
                      _endDate = DateTime.now();
                    });
                    _fetchRevenueByStaffRange();
                  },
                  child: const Text('Năm qua'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          staffRevenueData.isNotEmpty
              ? Expanded(
                  child: SfCartesianChart(
                    title: ChartTitle(
                      text:
                          'Doanh thu theo nhân viên ${_startDate != null ? 'từ ngày ${DateFormat('dd/MM/yyyy').format(_startDate!)}' : ''} ${_endDate != null ? 'đến ngày ${DateFormat('dd/MM/yyyy').format(_endDate!)}' : ''}',
                    ),
                    primaryXAxis: CategoryAxis(),
                    series: <ChartSeries>[
                      ColumnSeries<RevenueData, String>(
                        dataSource: staffRevenueData,
                        xValueMapper: (RevenueData data, _) => data.label,
                        yValueMapper: (RevenueData data, _) => data.value,
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                          labelPosition: ChartDataLabelPosition.outside,
                        ),
                        enableTooltip: true,
                        dataLabelMapper: (RevenueData data, _) {
                          if (Responsive.isDesktop(context)) {
                            return '${NumberFormat.currency(locale: "vi_VN", symbol: "").format(data.value)} VNĐ\n(${_getReadableAmount(data.value)})';
                          } else {
                            return '${NumberFormat.currency(locale: "vi_VN", symbol: "").format(data.value)} VNĐ';
                          }
                        },
                        pointColorMapper: (RevenueData data, _) =>
                            Colors.primaries[staffRevenueData.indexOf(data) %
                                Colors.primaries.length],
                      ),
                    ],
                    plotAreaBorderWidth: 0,
                    primaryYAxis: NumericAxis(
                      labelFormat: '{value} VNĐ',
                      axisLine: const AxisLine(width: 0),
                      majorTickLines: const MajorTickLines(size: 0),
                    ),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    borderColor: Colors.grey,
                    borderWidth: 1,
                    margin: const EdgeInsets.all(8),
                  ),
                )
              : _buildEmptyDataWidget(),
        ],
      ),
    );
  }

  String _getReadableAmount(double amount) {
    if (amount >= 1000000000) {
      return '${_convertNumberToWords((amount / 1000000000).toInt())} tỷ ${_getReadableAmount(amount % 1000000000)}';
    } else if (amount >= 1000000) {
      return '${_convertNumberToWords((amount / 1000000).toInt())} triệu ${_getReadableAmount(amount % 1000000)}';
    } else if (amount >= 1000) {
      return '${_convertNumberToWords((amount / 1000).toInt())} nghìn ${_getReadableAmount(amount % 1000)}';
    } else {
      return '${_convertNumberToWords(amount.toInt())} đồng';
    }
  }

  String _convertNumberToWords(int number) {
    final units = [
      '',
      'một',
      'hai',
      'ba',
      'bốn',
      'năm',
      'sáu',
      'bảy',
      'tám',
      'chín'
    ];
    final tens = [
      '',
      'mười',
      'hai mươi',
      'ba mươi',
      'bốn mươi',
      'năm mươi',
      'sáu mươi',
      'bảy mươi',
      'tám mươi',
      'chín mươi'
    ];

    if (number == 0) return 'không';

    if (number < 10) return units[number];

    if (number < 100) {
      return '${tens[number ~/ 10]} ${units[number % 10]}'.trim();
    }

    if (number < 1000) {
      return '${units[number ~/ 100]} trăm ${_convertNumberToWords(number % 100)}'
          .trim();
    }

    if (number < 1000000) {
      return '${_convertNumberToWords(number ~/ 1000)} nghìn ${_convertNumberToWords(number % 1000)}'
          .trim();
    }

    if (number < 1000000000) {
      return '${_convertNumberToWords(number ~/ 1000000)} triệu ${_convertNumberToWords(number % 1000000)}'
          .trim();
    }

    return '${_convertNumberToWords(number ~/ 1000000000)} tỷ ${_convertNumberToWords(number % 1000000000)}'
        .trim();
  }
}

class RevenueData {
  final String label;
  final double value;

  RevenueData(this.label, this.value);
}

class RevenueDataDaily {
  final double totalCash;
  final double totalCard;

  RevenueDataDaily(this.totalCash, this.totalCard);
}

Widget _buildEmptyDataWidget() {
  return const Padding(
    padding: EdgeInsets.all(16.0),
    child: Center(
      child: Text(
        'Dữ liệu chưa sẵn sàng.',
        style: TextStyle(fontSize: 18, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
