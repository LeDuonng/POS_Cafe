// order_type_dialog.dart
import 'package:coffeeapp/models/tables_model.dart';
import 'package:coffeeapp/responsive.dart';
import 'package:coffeeapp/views/screens/table/table_screen.dart';
import 'package:flutter/material.dart';

class OrderTypeDialog extends StatefulWidget {
  final String initialOrderType;
  final Function(String) onOrderTypeSelected;
  final String? userID;

  const OrderTypeDialog({
    super.key,
    required this.initialOrderType,
    required this.onOrderTypeSelected,
    required this.userID,
  });

  @override
  // ignore: library_private_types_in_public_api
  _OrderTypeDialogState createState() => _OrderTypeDialogState();
}

class _OrderTypeDialogState extends State<OrderTypeDialog> {
  late String selectedOrderType;
  bool isTableSelected = false;
  int? selectedTable;

  @override
  void initState() {
    super.initState();
    selectedOrderType = widget.initialOrderType;
    isTableSelected = selectedOrderType == 'Tại bàn';
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        textStyle: const TextStyle(fontSize: 18),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  title: const Text(
                    'Chọn loại đơn hàng',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlue,
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (Responsive.isMobile(context)) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text('Mang đi'),
                                  value: 'Mang đi',
                                  groupValue: selectedOrderType,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedOrderType = value!;
                                      isTableSelected = false;
                                    });
                                  },
                                  activeColor: Colors.lightBlue,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text('Tại bàn'),
                                  value: 'Tại bàn',
                                  groupValue: selectedOrderType,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedOrderType = value!;
                                      isTableSelected = true;
                                    });
                                  },
                                  activeColor: Colors.lightBlue,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text('Mang đi'),
                                  value: 'Mang đi',
                                  groupValue: selectedOrderType,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedOrderType = value!;
                                      isTableSelected = false;
                                    });
                                  },
                                  activeColor: Colors.lightBlue,
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text('Tại bàn'),
                                  value: 'Tại bàn',
                                  groupValue: selectedOrderType,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedOrderType = value!;
                                      isTableSelected = true;
                                    });
                                  },
                                  activeColor: Colors.lightBlue,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (isTableSelected) ...[
                          SizedBox(
                            width: 500, // Adjust width as needed
                            height: 300, // Adjust height as needed
                            child: SingleChildScrollView(
                              child: SizedBox(
                                height: 300, // Ensure the height is fixed
                                child: TableScreen(
                                  userID: widget.userID.toString(),
                                  status: 1,
                                  onTableSelected: (selectedTable) {
                                    setState(() {
                                      selectedOrderType =
                                          selectedTable.toString();
                                      isTableSelected =
                                          true; // Cập nhật isTableSelected
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Hủy',
                        style: TextStyle(color: Colors.lightBlue),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onOrderTypeSelected(selectedOrderType);
                      },
                      child: const Text('Chọn'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
      child: FutureBuilder<String>(
        future: selectedOrderType != 'Giao hàng' &&
                selectedOrderType != 'Mang đi'
            ? getNameTableById(int.parse(selectedOrderType))
            : Future.value(
                selectedOrderType), // Trả về trực tiếp giá trị đồng bộ nếu không cần gọi hàm bất đồng bộ
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text(
                'Loading...'); // Hoặc hiển thị biểu tượng chờ (spinner)
          } else if (snapshot.hasError) {
            return Text('Lỗi: ${snapshot.error}');
          } else if (snapshot.hasData) {
            return Text(snapshot.data!);
          } else {
            return const Text('Không có dữ liệu');
          }
        },
      ),
    );
  }
}
