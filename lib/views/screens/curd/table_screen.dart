import 'package:coffeeapp/models/tables_model.dart';
import 'package:coffeeapp/responsive.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/controllers/tables_controller.dart';

class TableScreen extends StatefulWidget {
  const TableScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TableScreenState createState() => _TableScreenState();
}

late Future<List<dynamic>> tableList;
String searchText = '';

class _TableScreenState extends State<TableScreen> {
  @override
  void initState() {
    super.initState();
    tableList = searchTables();
  }

  Future<void> _refreshTableList([String? searchtext]) async {
    var temp = searchTables(searchtext);

    setState(() {
      tableList = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Table List'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 300,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Search by Area...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                    _refreshTableList(searchText);
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
                builder: (context) => const AddTableScreen(),
              );
              _refreshTableList();
            },
          ),
        ],
      ),
      body: Responsive(
        mobile: _buildTableList(context),
        tablet: _buildTableList(context),
        desktop: _buildTableList(context),
      ),
    );
  }

  Widget _buildTableList(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: tableList,
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
              double columnWidth = totalWidth / 6; // 7 là tổng số cột hiện có

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
                          'Name',
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
                          'Floor',
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
                          'Area',
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
                        DataCell(Text(snapshot.data![index]['name'])),
                        DataCell(
                            Text(snapshot.data![index]['floor'].toString())),
                        DataCell(Text(snapshot.data![index]['area'])),
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
                                    builder: (context) => EditTableScreen(
                                      table: snapshot.data![index],
                                      tableItem: {
                                        'id': snapshot.data![index]['id'],
                                        'name': snapshot.data![index]['name'],
                                        'floor': snapshot.data![index]['floor'],
                                        'area': snapshot.data![index]['area'],
                                        'status': snapshot.data![index]
                                            ['status'],
                                      },
                                    ),
                                  );
                                  _refreshTableList();
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
                                            'Are you sure you want to delete this table?'),
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
                                                  deleteTable(snapshot
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

class AddTableScreen extends StatefulWidget {
  const AddTableScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddTableScreenState createState() => _AddTableScreenState();
}

class _AddTableScreenState extends State<AddTableScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name, area, status;
  late int floor;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      addTable(
        name: name,
        floor: floor,
        area: area,
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
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      name = value;
                    }
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Floor'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a floor';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    floor = int.tryParse(value!) ?? floor;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Area'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an area';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    area = value!;
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Status'),
                  value: 'available',
                  items: const [
                    DropdownMenuItem(
                      value: 'available',
                      child: Text('Available'),
                    ),
                    DropdownMenuItem(
                      value: 'occupied',
                      child: Text('Occupied'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      status = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a status';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    status = value!;
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
                  child: const Text('Add Table'),
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

class EditTableScreen extends StatefulWidget {
  final Map<String, dynamic> tableItem;
  final dynamic table;

  const EditTableScreen({
    super.key,
    required this.tableItem,
    required this.table,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EditTableScreenState createState() => _EditTableScreenState();
}

class _EditTableScreenState extends State<EditTableScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name, area, status;
  late int floor;

  @override
  void initState() {
    super.initState();
    name = widget.tableItem['name'];
    floor = widget.tableItem['floor'];
    area = widget.tableItem['area'];
    status = widget.tableItem['status'];
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      updateTable(
        id: widget.tableItem['id'] as int,
        name: name,
        floor: floor,
        area: area,
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
                  initialValue: widget.tableItem['id'].toString(),
                  decoration: const InputDecoration(labelText: 'ID'),
                  readOnly: true,
                ),
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      name = value;
                    }
                  },
                ),
                TextFormField(
                  initialValue: floor.toString(),
                  decoration: const InputDecoration(labelText: 'Floor'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a floor';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    floor = int.tryParse(value!) ?? floor;
                  },
                ),
                TextFormField(
                  initialValue: area,
                  decoration: const InputDecoration(labelText: 'Area'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an area';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    area = value!;
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Status'),
                  value: status,
                  items: const [
                    DropdownMenuItem(
                      value: 'available',
                      child: Text('Available'),
                    ),
                    DropdownMenuItem(
                      value: 'occupied',
                      child: Text('Occupied'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      status = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a status';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    status = value!;
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
