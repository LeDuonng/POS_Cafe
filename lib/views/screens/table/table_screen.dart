import 'package:coffeeapp/models/tables_model.dart';
import 'package:flutter/material.dart';
import 'area_screen.dart';

class TableScreen extends StatefulWidget {
  final String userID;
  final Function(String) onTableSelected;

  const TableScreen(
      {super.key, required this.userID, required this.onTableSelected});

  @override
  // ignore: library_private_types_in_public_api
  _TableScreenState createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  Future<List<dynamic>>? tableList;
  String selectedArea = 'Tất cả';

  @override
  void initState() {
    super.initState();
    tableList = fetchTablesByArea(selectedArea);
  }

  Future<List<dynamic>> fetchTablesByArea(String area) async {
    if (area == 'Tất cả') {
      return fetchTableArea();
    } else {
      return fetchTableArea(area);
    }
  }

  void onAreaSelected(String area) {
    setState(() {
      selectedArea = area;
      tableList = fetchTablesByArea(area);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount =
        (screenWidth / 400).floor().clamp(2, double.infinity).toInt();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AreaScreen(onAreaSelected: onAreaSelected),
            FutureBuilder<List<dynamic>>(
              future: tableList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No tables found'));
                } else {
                  final tables = snapshot.data!;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: tables.length,
                    itemBuilder: (context, index) {
                      final table = tables[index];
                      return GestureDetector(
                        onTap: () {
                          widget.onTableSelected('Bàn: ${table['name']}');
                          Navigator.pop(context);
                        },
                        child: Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Expanded(
                                child: Icon(
                                  Icons.table_bar,
                                  size: 48.0,
                                  color: Colors.orange,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Text(table['name']),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Text('Tầng: ${table['floor']}'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '${table['status'] == 'occupied' ? 'đang bận' : table['status'] == 'available' ? 'sẵn sàng' : table['status']}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
