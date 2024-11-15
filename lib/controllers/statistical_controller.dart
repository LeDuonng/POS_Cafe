import 'package:coffeeapp/models/statistical_model.dart';

List<RevenueDataDaily> dailyRevenueData = [];
List<RevenueData> rangeRevenueData = [];
List<RevenueData> categoryRevenueData = [];
List<RevenueData> staffRevenueData = [];
DateTime? _startDate;
DateTime? _endDate;
Future<void> _fetchDailyRevenue() async {
  try {
    final data = await fetchDailyRevenue(
        DateTime.now().toIso8601String().split('T').first);

    setState(() {
      dailyRevenueData = data
          .map((item) => RevenueDataDaily(
              totalCash: double.parse(item['total_cash']),
              totalCard: double.parse(item['total_card'])))
          .toList();
    });
  } catch (e) {
    debugPrint('Error fetching daily revenue: $e');
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
    debugPrint('Error fetching revenue by range: $e');
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
    debugPrint('Error fetching revenue by category range: $e');
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
    debugPrint('Error fetching revenue by staff range: $e');
  }
}
