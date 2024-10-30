// order_type_dialog.dart
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
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
                  title: const Text('Chọn loại đơn hàng'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Giao hàng'),
                                value: 'Giao hàng',
                                groupValue: selectedOrderType,
                                onChanged: (value) {
                                  setState(() {
                                    selectedOrderType = value!;
                                    isTableSelected = false;
                                  });
                                },
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
                              ),
                            ),
                          ],
                        ),
                        if (isTableSelected) ...[
                          SizedBox(
                            height: 500, // Adjust height as needed
                            child: SingleChildScrollView(
                              child: SizedBox(
                                height: 300, // Ensure the height is fixed
                                child: TableScreen(
                                  userID: widget.userID.toString(),
                                  onTableSelected: (selectedTable) {
                                    setState(() {
                                      selectedOrderType = selectedTable;
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
                      child: const Text('Hủy'),
                    ),
                    ElevatedButton(
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
      child: Text(selectedOrderType),
    );
  }
}
