// table_screen.dart
import 'package:coffeeapp/models/orders_model.dart';
import 'package:coffeeapp/models/tables_model.dart';
// import 'package:coffeeapp/views/screens/pos/pos_screen.dart';
import 'package:coffeeapp/views/screens/table/table_screen.dart';
import 'package:coffeeapp/views/widgets/nofication.dart';
import 'package:flutter/material.dart';
import '../table/area_screen.dart';

class TableManagementScreen extends StatefulWidget {
  final String userID;
  final Function(String) onTableSelected;

  const TableManagementScreen(
      {super.key, required this.userID, required this.onTableSelected});

  @override
  // ignore: library_private_types_in_public_api
  _TableScreenState createState() => _TableScreenState();
}

class _TableScreenState extends State<TableManagementScreen> {
  Future<List<dynamic>>? tableList;
  String selectedArea = 'Tất cả';
  String? selectedTable; // Biến lưu trữ bàn được chọn

  @override
  void initState() {
    super.initState();
    tableList = fetchTablesByArea(selectedArea);
    //load lại toàn bộ giao diện khi có thay đổi trạng thái bàn
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
      body: GestureDetector(
        onTap: () {
          setState(() {
            selectedTable = null;
          });
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              AreaScreen(onAreaSelected: onAreaSelected),
              FutureBuilder<List<dynamic>>(
                future: tableList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Không có dữ liệu'));
                  } else {
                    final tables = snapshot.data!;
                    return RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          tableList = fetchTablesByArea(selectedArea);
                        });
                      },
                      child: GridView.builder(
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
                              setState(() {
                                selectedTable = table['id'].toString();
                                widget.onTableSelected(selectedTable!);
                              });
                            },
                            onLongPress: () {
                              if (table['status'] == 'occupied') {
                                setState(() {
                                  selectedTable = table['id'].toString();
                                });
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Chọn hành động'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading:
                                                const Icon(Icons.merge_type),
                                            title: const Text('Gộp bàn'),
                                            onTap: () {
                                              Navigator.pop(
                                                  context); // Đóng dialog hiện tại trước
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Chọn bàn để gộp'),
                                                    content: SizedBox(
                                                      // Giới hạn chiều cao của dialog
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.5,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.3,
                                                      child: TableScreen(
                                                        userID: widget.userID
                                                            .toString(),
                                                        status: 2,
                                                        onTableSelected:
                                                            (selectedTableToMerge) {
                                                          // Xử lý gộp bàn tại đây
                                                          mergeTable(
                                                            int.parse(
                                                                selectedTable!), // Bàn hiện tại
                                                            int.parse(
                                                                selectedTableToMerge), // Bàn được chọn để gộp
                                                          ).then((_) {
                                                            setState(() {
                                                              tableList =
                                                                  fetchTablesByArea(
                                                                      selectedArea);
                                                              Navigator.pop(
                                                                  context); // Đóng dialog chọn bàn gộp
                                                            });
                                                            ToastNotification
                                                                .showToast(
                                                                    message:
                                                                        'Gộp bàn thành công');
                                                          }).catchError(
                                                              (error) {
                                                            // Xử lý lỗi nếu có
                                                            ToastNotification
                                                                .showToast(
                                                                    message:
                                                                        'Lỗi gộp bàn: $error');
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                          ListTile(
                                            leading:
                                                const Icon(Icons.call_split),
                                            title: const Text('Tách bàn'),
                                            onTap: () {
                                              Navigator.pop(
                                                  context); // Đóng dialog hiện tại trước
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Chọn bàn để tách'),
                                                    content: SizedBox(
                                                      // Giới hạn chiều cao của dialog
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.5,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.3,
                                                      child: TableScreen(
                                                        userID: widget.userID
                                                            .toString(),
                                                        status: 3,
                                                        onTableSelected:
                                                            (selectedTableToMerge) {
                                                          // Xử lý tách bàn tại đây
                                                          updateTableStatus(
                                                                  int.parse(
                                                                      selectedTableToMerge),
                                                                  'occupied')
                                                              .then((_) {
                                                            setState(() {
                                                              tableList =
                                                                  fetchTablesByArea(
                                                                      selectedArea);
                                                              setState(() {
                                                                tableList =
                                                                    fetchTablesByArea(
                                                                        selectedArea);
                                                              });
                                                            });
                                                            ToastNotification
                                                                .showToast(
                                                                    message:
                                                                        'Tách bàn thành công');
                                                          }).catchError(
                                                                  (error) {
                                                            // Xử lý lỗi nếu có
                                                            ToastNotification
                                                                .showToast(
                                                                    message:
                                                                        'Lỗi tách bàn: $error');
                                                          });
                                                          Navigator.pop(
                                                              context); // Đóng dialog chọn bàn tách
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                          ListTile(
                                            leading:
                                                const Icon(Icons.swap_horiz),
                                            title: const Text('Chuyển bàn'),
                                            onTap: () {
                                              Navigator.pop(
                                                  context); // Đóng dialog hiện tại trước
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Chọn bàn để chuyển'),
                                                    content: SizedBox(
                                                      // Giới hạn chiều cao của dialog
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.5,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.3,
                                                      child: TableScreen(
                                                        userID: widget.userID
                                                            .toString(),
                                                        status: 3,
                                                        onTableSelected:
                                                            (selectedTableToMerge) {
                                                          // Xử lý chuyển bàn tại đây
                                                          mergeTable(
                                                            int.parse(
                                                                selectedTable!), // Bàn hiện tại
                                                            int.parse(
                                                                selectedTableToMerge), // Bàn được chọn để chuyển
                                                          ).then((_) {
                                                            setState(() {
                                                              tableList =
                                                                  fetchTablesByArea(
                                                                      selectedArea);
                                                              setState(() {
                                                                tableList =
                                                                    fetchTablesByArea(
                                                                        selectedArea);
                                                              });
                                                            });
                                                            ToastNotification
                                                                .showToast(
                                                                    message:
                                                                        'Chuyển bàn thành công');
                                                          }).catchError(
                                                              (error) {
                                                            // Xử lý lỗi nếu có
                                                            ToastNotification
                                                                .showToast(
                                                                    message:
                                                                        'Lỗi chuyển bàn: $error');
                                                          });
                                                          Navigator.pop(
                                                              context); // Đóng dialog chọn bàn chuyển
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.cancel),
                                            title: const Text('Bàn trống'),
                                            onTap: () {
                                              if (selectedTable != null) {
                                                try {
                                                  updateTableStatus(
                                                      int.parse(selectedTable!),
                                                      'available');
                                                  ToastNotification.showToast(
                                                      message:
                                                          'Cập nhật trạng thái bàn thành công');
                                                } catch (e) {
                                                  ToastNotification.showToast(
                                                      message:
                                                          'Cập nhật trạng thái bàn thất bại: $e');
                                                }
                                              }

                                              setState(() {
                                                selectedTable = null;
                                                tableList =
                                                    fetchTablesByArea('Tất cả');
                                                setState(() {
                                                  selectedTable = null;
                                                  tableList = fetchTablesByArea(
                                                      'Tất cả');
                                                });
                                              });
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              } else {
                                ToastNotification.showToast(
                                    message:
                                        'Chỉ có thể chọn hành động khi bàn đang trống');
                              }
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              elevation: 5,
                              color: selectedTable == table['id'].toString()
                                  ? Colors.lightBlueAccent
                                      .withOpacity(0.7) // Màu khi được chọn
                                  : Colors.white, // Màu mặc định
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: TableBarIcon(
                                      status: table['status'],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Text(
                                      table['name'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.0),
                                    child: Text(
                                      'Tầng: ${table['floor']}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 4.0),
                                      decoration: BoxDecoration(
                                        color: table['status'] == 'occupied'
                                            ? Colors.orange.withOpacity(0.2)
                                            : table['status'] == 'available'
                                                ? Colors.green.withOpacity(0.2)
                                                : Colors.blue.withOpacity(0.2),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Text(
                                        '${table['status'] == 'occupied' ? 'Đang bận' : table['status'] == 'available' ? 'Sẵn sàng' : table['status']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: table['status'] == 'occupied'
                                              ? Colors.orange
                                              : table['status'] == 'available'
                                                  ? Colors.green
                                                  : Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TableBarIcon extends StatefulWidget {
  final String status;

  const TableBarIcon({super.key, required this.status});

  @override
  // ignore: library_private_types_in_public_api
  _TableBarIconState createState() => _TableBarIconState();
}

class _TableBarIconState extends State<TableBarIcon> {
  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.table_bar,
      size: 70.0,
      color: widget.status == 'available'
          ? Colors.green
          : widget.status == 'occupied'
              ? Colors.orange
              : widget.status == 'ordered'
                  ? Colors.blue
                  : Colors
                      .grey, // Màu mặc định hoặc màu khác cho trạng thái ordered
    );
  }
}
