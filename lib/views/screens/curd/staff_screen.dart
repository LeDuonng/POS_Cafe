import 'package:coffeeapp/models/staff_model.dart';
import 'package:coffeeapp/models/users_model.dart';
import 'package:flutter/material.dart';
import '../../../controllers/staff_controller.dart';
import '../../../responsive.dart'; // Import the Responsive widget

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StaffScreenState createState() => _StaffScreenState();
}

late Future<List<dynamic>> staffList;
String searchText = '';

class _StaffScreenState extends State<StaffScreen> {
  @override
  void initState() {
    super.initState();
    staffList = fetchStaff();
  }

  Future<void> _refreshStaffList([String? searchText]) async {
    var temp = searchStaff(searchText);
    setState(() {
      staffList = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff List'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 300,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Search by Name or Position...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                    _refreshStaffList(searchText);
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
                builder: (context) => const AddStaffItemScreen(),
              );
              _refreshStaffList();
            },
          ),
        ],
      ),
      body: Responsive(
        mobile: _buildStaffList(context),
        tablet: _buildStaffList(context),
        desktop: _buildStaffList(context),
      ),
    );
  }

  Widget _buildStaffList(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: staffList,
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
                          'Tên nhân viên',
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
                          'Lương',
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
                          'Ngày bắt đầu',
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
                          'Vị trí',
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
                            Text(snapshot.data![index]['salary'].toString())),
                        DataCell(Text(snapshot.data![index]['start_date'])),
                        DataCell(Text(snapshot.data![index]['position'])),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (context) => EditStaffItemScreen(
                                      staff: snapshot.data![index],
                                      staffItem: {
                                        'id': snapshot.data![index]['id'],
                                        'user_id': snapshot.data![index]
                                            ['user_id'],
                                        'salary': snapshot.data![index]
                                            ['salary'],
                                        'start_date': snapshot.data![index]
                                            ['start_date'],
                                        'position': snapshot.data![index]
                                            ['position'],
                                      },
                                    ),
                                  );
                                  _refreshStaffList();
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
                                            'Are you sure you want to delete this staff member?'),
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
                                                  deleteStaff(snapshot
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

class AddStaffItemScreen extends StatefulWidget {
  const AddStaffItemScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddStaffItemScreenState createState() => _AddStaffItemScreenState();
}

class _AddStaffItemScreenState extends State<AddStaffItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late String userId, salary, startDate, position;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      addStaff(
        userId: int.parse(userId),
        salary: double.parse(salary),
        startDate: DateTime.parse(startDate),
        position: position,
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
                    if (value != null) {
                      userId = value;
                    }
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Salary'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a salary';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    salary = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Start Date'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a start date';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    startDate = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Position'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a position';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    position = value!;
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
                  child: const Text('Add Staff Member'),
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

class EditStaffItemScreen extends StatefulWidget {
  final Map<String, dynamic> staffItem;
  final dynamic staff;

  const EditStaffItemScreen({
    super.key,
    required this.staffItem,
    required this.staff,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EditStaffItemScreenState createState() => _EditStaffItemScreenState();
}

class _EditStaffItemScreenState extends State<EditStaffItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late String userId, salary, startDate, position;

  @override
  void initState() {
    super.initState();
    userId = widget.staffItem['user_id'].toString();
    salary = widget.staffItem['salary'].toString();
    startDate = widget.staffItem['start_date'];
    position = widget.staffItem['position'];
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      updateStaff(
        id: widget.staffItem['id'],
        userId: int.parse(userId),
        salary: double.parse(salary),
        startDate: DateTime.parse(startDate),
        position: position,
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
                  initialValue: widget.staffItem['id'].toString(),
                  decoration: const InputDecoration(labelText: 'ID'),
                  readOnly: true,
                ),
                TextFormField(
                  initialValue: userId,
                  decoration: const InputDecoration(labelText: 'User ID'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a user ID';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      userId = value;
                    }
                  },
                ),
                TextFormField(
                  initialValue: salary,
                  decoration: const InputDecoration(labelText: 'Salary'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a salary';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    salary = value!;
                  },
                ),
                TextFormField(
                  initialValue: startDate,
                  decoration: const InputDecoration(labelText: 'Start Date'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a start date';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    startDate = value!;
                  },
                ),
                TextFormField(
                  initialValue: position,
                  decoration: const InputDecoration(labelText: 'Position'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a position';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    position = value!;
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
