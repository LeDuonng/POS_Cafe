import 'package:coffeeapp/models/customer_points_model.dart';
import 'package:coffeeapp/models/users_model.dart';
import 'package:coffeeapp/views/widgets/nofication.dart';
import 'package:flutter/material.dart';
import '../../../controllers/customer_points_controller.dart';
import '../../../responsive.dart';

class CustomerPointsScreen extends StatefulWidget {
  const CustomerPointsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CustomerPointsScreenState createState() => _CustomerPointsScreenState();
}

late Future<List<dynamic>> customerPointsList;
String searchText = '';

class _CustomerPointsScreenState extends State<CustomerPointsScreen> {
  @override
  void initState() {
    super.initState();
    customerPointsList = fetchCustomerPoints();
  }

  Future<void> _refreshCustomerPointsList([String? userId]) async {
    var temp = searchCustomerPoints(userId);
    setState(() {
      customerPointsList = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Points'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 300,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Search by User ID...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                    _refreshCustomerPointsList(searchText);
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
                builder: (context) => const AddCustomerPointsScreen(),
              );
              _refreshCustomerPointsList();
            },
          ),
        ],
      ),
      body: Responsive(
        mobile: _buildCustomerPointsList(context),
        tablet: _buildCustomerPointsList(context),
        desktop: _buildCustomerPointsList(context),
      ),
    );
  }

  Widget _buildCustomerPointsList(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: customerPointsList,
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
              double columnWidth = totalWidth / 4; // 4 là tổng số cột hiện có

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
                          'Khách hàng',
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
                          'Điểm tích luỹ',
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
                        DataCell(FutureBuilder<String>(
                          future: getNameUserById(int.parse(
                              snapshot.data![index]['user_id'].toString())),
                          builder: (context, nameSnapshot) {
                            if (nameSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (nameSnapshot.hasError) {
                              return Text('Error: ${nameSnapshot.error}');
                            } else {
                              return Text(nameSnapshot.data ?? 'Unknown');
                            }
                          },
                        )),
                        DataCell(
                            Text(snapshot.data![index]['points'].toString())),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (context) =>
                                        EditCustomerPointsScreen(
                                      customerPoints: snapshot.data![index],
                                      customerPointsItem: {
                                        'id': snapshot.data![index]['id'],
                                        'user_id': snapshot.data![index]
                                            ['user_id'],
                                        'points': snapshot.data![index]
                                            ['points'],
                                      },
                                    ),
                                  );
                                  _refreshCustomerPointsList();
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
                                            'Are you sure you want to delete this customer points?'),
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
                                                  deleteCustomerPoints(snapshot
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

class AddCustomerPointsScreen extends StatefulWidget {
  const AddCustomerPointsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddCustomerPointsScreenState createState() =>
      _AddCustomerPointsScreenState();
}

class _AddCustomerPointsScreenState extends State<AddCustomerPointsScreen> {
  final _formKey = GlobalKey<FormState>();
  late int userId;
  late String points;
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save the form fields
      addCustomerPoints(
        userId: userId,
        points: points as int,
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
                  decoration: const InputDecoration(labelText: 'User ID'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a user ID';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    try {
                      userId = int.parse(value!);
                    } catch (e) {
                      ToastNotification.showToast(
                          message: 'Invalid User ID: $e');
                    }
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Points'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter points';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    try {
                      points = value!;
                    } catch (e) {
                      ToastNotification.showToast(
                          message: 'Invalid Points: $e');
                    }
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
                  child: const Text('Add Points'),
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

class EditCustomerPointsScreen extends StatefulWidget {
  final Map<String, dynamic> customerPointsItem;
  final dynamic customerPoints;

  const EditCustomerPointsScreen({
    super.key,
    required this.customerPointsItem,
    required this.customerPoints,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EditCustomerPointsScreenState createState() =>
      _EditCustomerPointsScreenState();
}

class _EditCustomerPointsScreenState extends State<EditCustomerPointsScreen> {
  final _formKey = GlobalKey<FormState>();
  late int userId;
  late String points;

  @override
  void initState() {
    super.initState();
    userId = widget.customerPointsItem['user_id'];
    points = widget.customerPointsItem['points'];
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save the form fields
      updateCustomerPoints(
        id: widget.customerPointsItem['id'],
        points: points as int,
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
                  initialValue: widget.customerPointsItem['id'].toString(),
                  decoration: const InputDecoration(labelText: 'ID'),
                  readOnly: true,
                ),
                TextFormField(
                  initialValue: widget.customerPointsItem['user_id'].toString(),
                  decoration: const InputDecoration(labelText: 'User ID'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a user ID';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    try {
                      userId = int.parse(value!);
                    } catch (e) {
                      ToastNotification.showToast(
                          message: 'Invalid User ID: $e');
                    }
                  },
                ),
                TextFormField(
                  initialValue: widget.customerPointsItem['points'].toString(),
                  decoration: const InputDecoration(labelText: 'Points'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter points';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    try {
                      points = value!;
                    } catch (e) {
                      ToastNotification.showToast(
                          message: 'Invalid Points: $e');
                    }
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
