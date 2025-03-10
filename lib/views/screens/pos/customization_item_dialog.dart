import 'package:coffeeapp/models/menu_model.dart';
import 'package:flutter/material.dart';

class CustomizationDialog extends StatefulWidget {
  final Map<String, dynamic> product;
  final Function(Map<String, dynamic>) onConfirm;

  const CustomizationDialog({
    super.key,
    required this.product,
    required this.onConfirm,
  });

  @override
  State<CustomizationDialog> createState() => _CustomizationDialogState();
}

class _CustomizationDialogState extends State<CustomizationDialog> {
  String selectedSize = 'M';
  List<String> selectedToppings = [];
  int selectedSugar = 100;
  int selectedQuantity = 1;
  double updatedPrice = 0.0;

  @override
  void initState() {
    super.initState();
    selectedSize = widget.product['size'] ?? 'M';
    selectedToppings = List<String>.from(widget.product['toppings'] ?? []);
    selectedSugar = widget.product['sugar'] ?? 100;
    selectedQuantity = widget.product['quantity'] ?? 1;
    updatedPrice = widget.product['price'];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Tuỳ chọn ${widget.product['name']}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSizeSelection(),
            const SizedBox(height: 8.0),
            _buildSugarSelection(),
            const SizedBox(height: 8.0),
            _buildQuantitySelection(),
            const SizedBox(height: 8.0),
            _buildToppingsSelection(),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Huỷ'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onConfirm({
              'id': widget.product['id'],
              'name': widget.product['name'],
              'size': selectedSize,
              'toppings': selectedToppings,
              'sugar': selectedSugar,
              'quantity': selectedQuantity,
              'price': updatedPrice,
            });
            Navigator.of(context).pop();
          },
          child: const Text('Xác nhận'),
        ),
      ],
    );
  }

  Widget _buildSizeSelection() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 192, 87, 87)),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          const Text('Chọn size',
              style: TextStyle(fontWeight: FontWeight.bold)),
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DropdownButton<String>(
                value: selectedSize,
                items: ['S', 'M', 'L'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text('Size: $value'),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedSize = newValue!;
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSugarSelection() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 192, 87, 87)),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          const Text('Chọn lượng đường',
              style: TextStyle(fontWeight: FontWeight.bold)),
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DropdownButton<int>(
                value: selectedSugar,
                items: [0, 20, 40, 60, 80, 100].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('Lượng đường: $value%'),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedSugar = newValue!;
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelection() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 192, 87, 87)),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          const Text('Chọn số lượng',
              style: TextStyle(fontWeight: FontWeight.bold)),
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        if (selectedQuantity > 1) {
                          selectedQuantity--;
                        }
                      });
                    },
                  ),
                  Text('$selectedQuantity'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        selectedQuantity++;
                      });
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToppingsSelection() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const Text('Chọn topping',
              style: TextStyle(fontWeight: FontWeight.bold)),
          FutureBuilder<List<dynamic>>(
            future: fetchTopping(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Lỗi: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No toppings found'));
              } else {
                final toppings = snapshot.data!;
                return Column(
                  children: toppings.map((topping) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return Column(
                            children: [
                              const SizedBox(height: 8.0),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: Image.asset(
                                  'assets/menu/${topping['name']}.png',
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.fitHeight,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/menu/${topping['image']}',
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.fitHeight,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(Icons.error);
                                      },
                                    );
                                  },
                                ),
                              ),
                              ListTile(
                                title: Text(topping['name']),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Giá: ${topping['price']} VNĐ'),
                                    Text(
                                        'Description: ${topping['description']}'),
                                  ],
                                ),
                                trailing: Checkbox(
                                  value: selectedToppings
                                      .contains(topping['name']),
                                  onChanged: (selected) {
                                    setState(() {
                                      if (selected!) {
                                        selectedToppings.add(topping['name']);
                                        updatedPrice += double.parse(
                                            topping['price'].toString());
                                      } else {
                                        selectedToppings
                                            .remove(topping['name']);
                                        updatedPrice -= double.parse(
                                            topping['price'].toString());
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
