import 'package:coffeeapp/models/tables_model.dart';
import 'package:flutter/material.dart';

class AreaScreen extends StatefulWidget {
  final Function(String) onAreaSelected;

  const AreaScreen({super.key, required this.onAreaSelected});

  @override
  // ignore: library_private_types_in_public_api
  _AreaScreenState createState() => _AreaScreenState();
}

class _AreaScreenState extends State<AreaScreen> {
  late Future<List<dynamic>> futureAreas;
  String selectedArea = 'Tất cả';

  @override
  void initState() {
    super.initState();
    futureAreas = fetchTableDistinct();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: futureAreas,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không có dữ liệu'));
        } else {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildAreaButton(
                    'Tất cả',
                    snapshot.data!.fold<int>(
                        0, (sum, item) => sum + (item['total_tables'] as int))),
                ...snapshot.data!.map((item) {
                  return _buildAreaButton(item['area'], item['total_tables']);
                  // ignore: unnecessary_to_list_in_spreads
                }).toList(),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildAreaButton(String area, int totalTables) {
    return Container(
      margin: const EdgeInsets.all(15.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedArea == area
                  ? const Color.fromARGB(255, 217, 214, 214)
                  : null,
            ),
            onPressed: () {
              setState(() {
                selectedArea = area;
              });
              widget.onAreaSelected(area);
            },
            child: Text(area),
          ),
          Positioned(
            right: -5,
            top: -10, // Adjusted to prevent clipping
            child: CircleAvatar(
              radius: 12,
              backgroundColor: Colors.red,
              child: Text(
                '$totalTables',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
