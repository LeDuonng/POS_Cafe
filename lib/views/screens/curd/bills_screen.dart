import 'package:coffeeapp/models/bills_model.dart';
import 'package:flutter/material.dart';
import '../../../controllers/bills_controller.dart';
import '../../../responsive.dart'; // Import the Responsive widget

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BillsScreenState createState() => _BillsScreenState();
}

late Future<List<dynamic>> billsList;
String searchText = '';

class _BillsScreenState extends State<BillsScreen> {
  @override
  void initState() {
    super.initState();
    billsList = fetchBills();
  }

  Future<void> _refreshBillsList([String? paymentMethod]) async {
    var temp = searchBills(paymentMethod);
    setState(() {
      billsList = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bills List'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 300,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Search by Payment Method...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                    _refreshBillsList(searchText);
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
                builder: (context) => const AddBillScreen(),
              );
              _refreshBillsList();
            },
          ),
        ],
      ),
      body: Responsive(
        mobile: _buildBillsList(context),
        tablet: _buildBillsList(context),
        desktop: _buildBillsList(context),
      ),
    );
  }

  Widget _buildBillsList(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: billsList,
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
              double columnWidth = totalWidth / 6; // 6 là tổng số cột hiện có

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
                          'Thành tiền',
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
                          'Phương thức thanh toán',
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
                          'Ngày thanh toán',
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
                        DataCell(Text(
                            snapshot.data![index]['order_id']?.toString() ??
                                'N/A')),
                        DataCell(Text(
                            snapshot.data![index]['total_amount']?.toString() ??
                                'N/A')),
                        DataCell(Text(
                            snapshot.data![index]['payment_method'] ?? 'N/A')),
                        DataCell(Text(
                            snapshot.data![index]['payment_date'] ?? 'N/A')),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (context) => EditBillScreen(
                                      bill: snapshot.data![index],
                                      billItem: {
                                        'id': snapshot.data![index]['id'],
                                        'order_id': snapshot.data![index]
                                            ['order_id'],
                                        'total_amount': snapshot.data![index]
                                            ['total_amount'],
                                        'payment_method': snapshot.data![index]
                                            ['payment_method'],
                                        'payment_date': snapshot.data![index]
                                            ['payment_date'],
                                      },
                                    ),
                                  );
                                  _refreshBillsList();
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
                                            'Are you sure you want to delete this bill?'),
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
                                                  deleteBill(snapshot
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

class AddBillScreen extends StatefulWidget {
  const AddBillScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddBillScreenState createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();
  late String orderId, totalAmount, paymentMethod;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      addBill(
        orderId: int.parse(orderId),
        totalAmount: double.parse(totalAmount),
        paymentMethod: paymentMethod,
        paymentDate: DateTime.now().toString(),
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
                    if (value != null) {
                      orderId = value;
                    }
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Total Amount'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a total amount';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    totalAmount = value!;
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration:
                      const InputDecoration(labelText: 'Payment Method'),
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('Cash')),
                    DropdownMenuItem(value: 'card', child: Text('Card')),
                  ],
                  onChanged: (value) {
                    paymentMethod = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a payment method';
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
                  child: const Text('Add Bill'),
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

class EditBillScreen extends StatefulWidget {
  final Map<String, dynamic> billItem;
  final dynamic bill;

  const EditBillScreen({
    super.key,
    required this.billItem,
    required this.bill,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EditBillScreenState createState() => _EditBillScreenState();
}

class _EditBillScreenState extends State<EditBillScreen> {
  final _formKey = GlobalKey<FormState>();
  late String orderId, totalAmount, paymentMethod;
  late DateTime paymentDate;

  @override
  void initState() {
    super.initState();
    orderId = widget.billItem['order_id']?.toString() ?? '';
    totalAmount = widget.billItem['total_amount']?.toString() ?? '';
    paymentMethod = widget.billItem['payment_method'] ?? '';
    paymentDate = DateTime.parse(widget.billItem['payment_date'] ?? '');
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      updateBill(
        id: widget.billItem['id'],
        orderId: int.parse(orderId),
        totalAmount: double.parse(totalAmount),
        paymentMethod: paymentMethod,
        paymentDate: paymentDate.toString(),
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
                  initialValue: widget.billItem['id'].toString(),
                  decoration: const InputDecoration(labelText: 'ID'),
                  readOnly: true,
                ),
                TextFormField(
                  initialValue: orderId,
                  decoration: const InputDecoration(labelText: 'Order ID'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an order ID';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      orderId = value;
                    }
                  },
                ),
                TextFormField(
                  initialValue: totalAmount,
                  decoration: const InputDecoration(labelText: 'Total Amount'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a total amount';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    totalAmount = value!;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: paymentMethod,
                  decoration:
                      const InputDecoration(labelText: 'Payment Method'),
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('Cash')),
                    DropdownMenuItem(value: 'card', child: Text('Card')),
                  ],
                  onChanged: (value) {
                    paymentMethod = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a payment method';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: paymentDate.toString(),
                  decoration: const InputDecoration(labelText: 'Payment Date'),
                  readOnly: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
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
