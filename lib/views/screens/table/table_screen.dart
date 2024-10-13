import 'package:coffeeapp/controllers/tables_controller.dart';
import 'package:coffeeapp/views/screens/pos/pos_screen.dart';
import 'package:flutter/material.dart';
import 'area_screen.dart';

class TableScreen extends StatefulWidget {
  final String userID;

  const TableScreen({super.key, required this.userID});

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
        (screenWidth / 200).floor(); // Adjust 200 to your desired item width

    return Scaffold(
      appBar: AppBar(
        title: const Text('Table Screen'),
      ),
      body: Column(
        children: [
          AreaScreen(onAreaSelected: onAreaSelected),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => POSScreen(
                                  tableId: table['id'].toString(),
                                  userID: widget.userID.toString()),
                            ),
                          );
                        },
                        child: Card(
                          child: Column(
                            children: [
                              const Expanded(
                                child: Icon(
                                  Icons.table_chart,
                                  size: 100,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(table['name']),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Tầng: ${table['floor']}'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Trạng thái: ${table['status'] == 'occupied' ? 'đang bận' : table['status'] == 'available' ? 'sẵn sàng' : table['status']}',
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
          ),
        ],
      ),
    );
  }
}
