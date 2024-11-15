import 'package:coffeeapp/models/ingredients_model.dart';
import 'package:flutter/material.dart';
import '../../../controllers/ingredients_controller.dart';
import '../../../responsive.dart'; // Import the Responsive widget

class IngredientsScreen extends StatefulWidget {
  const IngredientsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _IngredientsScreenState createState() => _IngredientsScreenState();
}

late Future<List<dynamic>> ingredientsList;
String searchText = '';

class _IngredientsScreenState extends State<IngredientsScreen> {
  @override
  void initState() {
    super.initState();
    ingredientsList = fetchIngredients();
  }

  Future<void> _refreshIngredientsList([String? searchText]) async {
    var temp = searchIngredients(searchText);
    setState(() {
      ingredientsList = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredients List'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 300,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Search by Name...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                    _refreshIngredientsList(searchText);
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
                builder: (context) => const AddIngredientScreen(),
              );
              _refreshIngredientsList();
            },
          ),
        ],
      ),
      body: Responsive(
        mobile: _buildIngredientsList(context),
        tablet: _buildIngredientsList(context),
        desktop: _buildIngredientsList(context),
      ),
    );
  }

  Widget _buildIngredientsList(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: ingredientsList,
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
                          'Unit',
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
                          'Quantity',
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
                        DataCell(Text(snapshot.data![index]['unit'])),
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
                                    builder: (context) => EditIngredientScreen(
                                      ingredient: snapshot.data![index],
                                      ingredientItem: {
                                        'id': snapshot.data![index]['id'],
                                        'name': snapshot.data![index]['name'],
                                        'unit': snapshot.data![index]['unit'],
                                        'quantity': snapshot.data![index]
                                            ['quantity'],
                                      },
                                    ),
                                  );
                                  _refreshIngredientsList();
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
                                            'Are you sure you want to delete this ingredient?'),
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
                                                  deleteIngredient(snapshot
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

class AddIngredientScreen extends StatefulWidget {
  const AddIngredientScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddIngredientScreenState createState() => _AddIngredientScreenState();
}

class _AddIngredientScreenState extends State<AddIngredientScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name, unit;
  late int quantity;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      addIngredient(
        name: name,
        unit: unit,
        quantity: quantity,
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
                  decoration: const InputDecoration(labelText: 'Unit'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a unit';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    unit = value!;
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
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _submitForm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Green for Add Item
                  ),
                  child: const Text('Add Ingredient'),
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

class EditIngredientScreen extends StatefulWidget {
  final Map<String, dynamic> ingredientItem;
  final dynamic ingredient;

  const EditIngredientScreen({
    super.key,
    required this.ingredientItem,
    required this.ingredient,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EditIngredientScreenState createState() => _EditIngredientScreenState();
}

class _EditIngredientScreenState extends State<EditIngredientScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name, unit;
  late int quantity;

  @override
  void initState() {
    super.initState();
    name = widget.ingredientItem['name'];
    unit = widget.ingredientItem['unit'];
    quantity = widget.ingredientItem['quantity'];
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      updateIngredient(
        id: widget.ingredientItem['id'],
        name: name,
        unit: unit,
        quantity: quantity,
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
                  initialValue: widget.ingredientItem['id'].toString(),
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
                  initialValue: unit,
                  decoration: const InputDecoration(labelText: 'Unit'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a unit';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    unit = value!;
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
