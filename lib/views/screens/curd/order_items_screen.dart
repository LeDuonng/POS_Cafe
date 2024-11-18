import 'package:coffeeapp/models/menu_model.dart';
import 'package:coffeeapp/models/order_items_model.dart';
import 'package:flutter/material.dart';
import '../../../controllers/order_items_controller.dart';
import '../../../responsive.dart'; // Import the Responsive widget

class OrderItemsScreen extends StatefulWidget {
  const OrderItemsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OrderItemsScreenState createState() => _OrderItemsScreenState();
}

late Future<List<dynamic>> orderItemsList;
String searchText = '';

class _OrderItemsScreenState extends State<OrderItemsScreen> {
  @override
  void initState() {
    super.initState();
    orderItemsList = fetchOrderItems();
  }

  Future<void> _refreshOrderItemsList([String? orderId]) async {
    var temp = searchOrderItems(orderId);
    setState(() {
      orderItemsList = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Items List'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 300,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Search by Order ID...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                    _refreshOrderItemsList(searchText);
                  });
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) => const AddOrderItemScreen(),
              );
              _refreshOrderItemsList();
            },
          ),
        ],
      ),
      body: Responsive(
        mobile: _buildOrderItemsList(context),
        tablet: _buildOrderItemsList(context),
        desktop: _buildOrderItemsList(context),
      ),
    );
  }

  Widget _buildOrderItemsList(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: orderItemsList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        } else {
          return LayoutBuilder(
            builder: (context, constraints) {
              double totalWidth = constraints.maxWidth;
              double columnWidth = totalWidth / 5; // 5 là tổng số cột hiện có

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columnSpacing: 12,
                  // ignore: deprecated_member_use
                  dataRowHeight: 100,
                  columns: [
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'STT',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'Mã đơn hàng',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'Tên sản phẩm',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'Số lượng',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'Hành động',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                    ),
                  ],
                  rows: List.generate(snapshot.data!.length, (index) {
                    return DataRow(
                      color: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                          return index.isEven
                              ? Colors.grey.withOpacity(0.1)
                              : Colors.white;
                        },
                      ),
                      cells: [
                        DataCell(Text((index + 1).toString())),
                        DataCell(
                            Text(snapshot.data![index]['order_id'].toString())),
                        DataCell(FutureBuilder<String>(
                          future: getNameMenuItemById(int.parse(
                              snapshot.data![index]['menu_id'].toString())),
                          builder: (context, nameSnapshot) {
                            if (nameSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (nameSnapshot.hasError) {
                              return Text('Error: ${nameSnapshot.error}');
                            } else {
                              return Text(nameSnapshot.data ?? 'Không có');
                            }
                          },
                        )),
                        DataCell(
                            Text(snapshot.data![index]['quantity'].toString())),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (context) => EditOrderItemScreen(
                                      orderItem: snapshot.data![index],
                                    ),
                                  );
                                  _refreshOrderItemsList();
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Confirm Delete'),
                                        content: const Text(
                                            'Are you sure you want to delete this order item?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                try {
                                                  deleteOrderItem(snapshot
                                                      .data![index]['id']);
                                                  snapshot.data!
                                                      .removeAt(index);
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content:
                                                            Text('Error: $e')),
                                                  );
                                                }
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              );
            },
          );
        }
      },
    );
  }
}

class AddOrderItemScreen extends StatefulWidget {
  const AddOrderItemScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddOrderItemScreenState createState() => _AddOrderItemScreenState();
}

class _AddOrderItemScreenState extends State<AddOrderItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late int orderId, menuId, quantity;
  late double price;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save the form fields
      addOrderItem(
        orderId: orderId,
        menuId: menuId,
        quantity: quantity,
        price: price,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(10),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 900),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Order ID'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an order ID';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    orderId = int.parse(value!);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Menu ID'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a menu ID';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    menuId = int.parse(value!);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a quantity';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    quantity = int.parse(value!);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Price'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    price = double.parse(value!);
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _submitForm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Green for Add Item
                  ),
                  child: const Text('Add Item'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Red for Cancel
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EditOrderItemScreen extends StatefulWidget {
  final Map<String, dynamic> orderItem;

  const EditOrderItemScreen({super.key, required this.orderItem});

  @override
  // ignore: library_private_types_in_public_api
  _EditOrderItemScreenState createState() => _EditOrderItemScreenState();
}

class _EditOrderItemScreenState extends State<EditOrderItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late int orderId, menuId, quantity;
  late double price;

  @override
  void initState() {
    super.initState();
    orderId = widget.orderItem['order_id'];
    menuId = widget.orderItem['menu_id'];
    quantity = widget.orderItem['quantity'];
    price = double.parse(widget.orderItem['price']);
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save the form fields
      updateOrderItem(
        id: widget.orderItem['id'],
        orderId: orderId,
        menuId: menuId,
        quantity: quantity,
        price: price,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(10),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 900),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                TextFormField(
                  initialValue: widget.orderItem['id'].toString(),
                  decoration: const InputDecoration(labelText: 'ID'),
                  readOnly: true,
                ),
                TextFormField(
                  initialValue: orderId.toString(),
                  decoration: const InputDecoration(labelText: 'Order ID'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an order ID';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    orderId = int.parse(value!);
                  },
                ),
                TextFormField(
                  initialValue: menuId.toString(),
                  decoration: const InputDecoration(labelText: 'Menu ID'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a menu ID';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    menuId = int.parse(value!);
                  },
                ),
                TextFormField(
                  initialValue: quantity.toString(),
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a quantity';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    quantity = int.parse(value!);
                  },
                ),
                TextFormField(
                  initialValue: price.toString(),
                  decoration: const InputDecoration(labelText: 'Price'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    price = double.parse(value!);
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _submitForm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Green for Save
                  ),
                  child: const Text('Save Changes'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Red for Cancel
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
