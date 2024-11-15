import 'package:coffeeapp/models/orders_model.dart' as controller;
import 'package:coffeeapp/controllers/orders_controller.dart';
import 'package:flutter/material.dart';
import '../../../responsive.dart'; // Import the Responsive widget

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OrdersScreenState createState() => _OrdersScreenState();
}

late Future<List<dynamic>> ordersList;
String searchText = '';

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    ordersList = controller.fetchOrders();
  }

  Future<void> _refreshOrdersList([String? orderId]) async {
    var temp = controller.searchOrders(orderId);
    setState(() {
      ordersList = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders List'),
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
                    _refreshOrdersList(searchText);
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
                builder: (context) => const AddOrderScreen(),
              );
              _refreshOrdersList();
            },
          ),
        ],
      ),
      body: Responsive(
        mobile: _buildOrdersList(context),
        tablet: _buildOrdersList(context),
        desktop: _buildOrdersList(context),
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: ordersList,
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
              double columnWidth = totalWidth / 7; // 7 là tổng số cột hiện có

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
                          'Order ID',
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
                          'Table ID',
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
                          'Customer ID',
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
                          'Staff ID',
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
                          'Status',
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
                          'Actions',
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
                        DataCell(Text(snapshot.data![index]['id'].toString())),
                        DataCell(
                            Text(snapshot.data![index]['table_id'].toString())),
                        DataCell(Text(
                            snapshot.data![index]['customer_id'].toString())),
                        DataCell(
                            Text(snapshot.data![index]['staff_id'].toString())),
                        DataCell(Text(snapshot.data![index]['status'])),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (context) => EditOrderScreen(
                                      order: snapshot.data![index],
                                      orderItem: {
                                        'id': snapshot.data![index]['id'],
                                        'table_id': snapshot.data![index]
                                            ['table_id'],
                                        'customer_id': snapshot.data![index]
                                            ['customer_id'],
                                        'staff_id': snapshot.data![index]
                                            ['staff_id'],
                                        'order_date': snapshot.data![index]
                                            ['order_date'],
                                        'status': snapshot.data![index]
                                            ['status'],
                                      },
                                    ),
                                  );
                                  _refreshOrdersList();
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
                                            'Are you sure you want to delete this order?'),
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
                                                  deleteOrder(snapshot
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

class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddOrderScreenState createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  late int tableId, customerId, staffId;
  late String status;
  late DateTime orderDate;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      addOrder(
        tableId: tableId,
        customerId: customerId,
        staffId: staffId,
        orderDate: orderDate,
        status: status,
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
                  decoration: const InputDecoration(labelText: 'Table ID'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a table ID';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    tableId = int.parse(value!);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Customer ID'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a customer ID';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    customerId = int.parse(value!);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Staff ID'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a staff ID';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    staffId = int.parse(value!);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Order Date'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an order date';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    orderDate = DateTime.parse(value!);
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Status'),
                  value: 'received',
                  items: ['received', 'preparing', 'paid']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    status = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a status';
                    }
                    return null;
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
                  child: const Text('Add Order'),
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

class EditOrderScreen extends StatefulWidget {
  final Map<String, dynamic> orderItem;
  final dynamic order;

  const EditOrderScreen({
    super.key,
    required this.orderItem,
    required this.order,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EditOrderScreenState createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  late int tableId, customerId, staffId;
  late String status;
  late DateTime orderDate;

  @override
  void initState() {
    super.initState();
    tableId = widget.orderItem['table_id'];
    customerId = widget.orderItem['customer_id'];
    staffId = widget.orderItem['staff_id'];
    orderDate = DateTime.parse(widget.orderItem['order_date']);
    status = widget.orderItem['status'];
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      updateOrder(
        id: widget.orderItem['id'],
        tableId: tableId,
        customerId: customerId,
        staffId: staffId,
        orderDate: orderDate,
        status: status,
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
                  initialValue: tableId.toString(),
                  decoration: const InputDecoration(labelText: 'Table ID'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a table ID';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    tableId = int.parse(value!);
                  },
                ),
                TextFormField(
                  initialValue: customerId.toString(),
                  decoration: const InputDecoration(labelText: 'Customer ID'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a customer ID';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    customerId = int.parse(value!);
                  },
                ),
                TextFormField(
                  initialValue: staffId.toString(),
                  decoration: const InputDecoration(labelText: 'Staff ID'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a staff ID';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    staffId = int.parse(value!);
                  },
                ),
                TextFormField(
                  initialValue: orderDate.toString(),
                  decoration: const InputDecoration(labelText: 'Order Date'),
                  readOnly: true,
                ),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: ['received', 'preparing', 'paid']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    status = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a status';
                    }
                    return null;
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
