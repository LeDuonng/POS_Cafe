import 'package:coffeeapp/models/menu_model.dart';
import 'package:flutter/material.dart';
import '../../../controllers/menu_controller.dart';
import '../../../responsive.dart'; // Import the Responsive widget

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MenuScreenState createState() => _MenuScreenState();
}

late Future<List<dynamic>> menuList;
String searchText = '';

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    super.initState();
    menuList = fetchMenuCategory();
  }

  Future<void> _refreshMenuList([String? category]) async {
    var temp = fetchMenuCategory(category);
    setState(() {
      menuList = temp;
    });
  }

  void searchMenu(String query) {
    setState(() => searchText = query);
    _refreshMenuList(searchText); // Gọi _refreshMenuList với searchText mới
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu List'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 300,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                    _refreshMenuList(searchText);
                  });
                  searchMenu(value);
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) => const AddMenuItemScreen(),
              );
              _refreshMenuList();
            },
          ),
        ],
      ),
      body: Responsive(
        mobile: _buildMenuList(context),
        tablet: _buildMenuList(context),
        desktop: _buildMenuList(context),
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: menuList,
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

                // child: SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                child: RefreshIndicator(
                  onRefresh: () => _refreshMenuList(),
                  triggerMode: RefreshIndicatorTriggerMode.onEdge,
                  edgeOffset: 50,
                  displacement: 200,
                  strokeWidth: 5,
                  color: Colors.green,
                  backgroundColor: Colors.grey.withOpacity(0.1),
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
                            'Tên món',
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
                            'Mô tả',
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
                            'Giá',
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
                            'Hình ảnh',
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
                            'Danh mục',
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
                          DataCell(Text(snapshot.data![index]['name'])),
                          DataCell(Text(snapshot.data![index]['description'])),
                          DataCell(
                              Text(snapshot.data![index]['price'].toString())),
                          DataCell(
                            Image.asset(
                              'assets/menu/${snapshot.data![index]['name']}.png',
                              height: 100,
                              width: 100,
                              fit: BoxFit.fitHeight,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/menu/error.png',
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.fitHeight,
                                );
                              },
                            ),
                          ),
                          DataCell(Text(snapshot.data![index]['category'])),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () async {
                                    await showDialog(
                                      context: context,
                                      builder: (context) => EditMenuItemScreen(
                                        menu: snapshot.data![index],
                                        menuItem: {
                                          'id': snapshot.data![index]['id'],
                                          'name': snapshot.data![index]['name'],
                                          'description': snapshot.data![index]
                                              ['description'],
                                          'price': snapshot.data![index]
                                              ['price'],
                                          'image': snapshot.data![index]
                                              ['image'],
                                          'category': snapshot.data![index]
                                              ['category'],
                                        },
                                      ),
                                    );
                                    _refreshMenuList();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Confirm Delete'),
                                          content: const Text(
                                              'Are you sure you want to delete this item?'),
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
                                                    deleteMenu(snapshot
                                                        .data![index]['id']);
                                                    snapshot.data!
                                                        .removeAt(index);
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          content: Text(
                                                              'Error: $e')),
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
                ),
              );
            },
          );
        }
      },
    );
  }
}

class AddMenuItemScreen extends StatelessWidget {
  // Changed to StatelessWidget
  const AddMenuItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    final _formKey = GlobalKey<FormState>();
    String name = '', description = '', price = '', image = '', category = '';

    // ignore: no_leading_underscores_for_local_identifiers
    void _submitForm() {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        addMenu(
          name: name,
          description: description,
          price: price,
          image: image,
          category: category,
        );
        Navigator.pop(context);
      }
    }

    return Dialog(
        child: ConstrainedBox(
      // Limit the Dialog size
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
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) {
                  description = value!;
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
                  price = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Image URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image URL';
                  }
                  return null;
                },
                onSaved: (value) {
                  image = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
                onSaved: (value) {
                  category = value!;
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
    ));
  }
}

class EditMenuItemScreen extends StatefulWidget {
  final Map<String, dynamic> menuItem;
  final dynamic menu;

  const EditMenuItemScreen({
    super.key,
    required this.menuItem,
    required this.menu,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EditMenuItemScreenState createState() => _EditMenuItemScreenState();
}

class _EditMenuItemScreenState extends State<EditMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name, description, price, image, category;

  @override
  void initState() {
    super.initState();
    name = widget.menuItem['name'];
    description = widget.menuItem['description'];
    price = widget.menuItem['price']
        .toString(); // Convert to String if it's a number
    image = widget.menuItem['image'];
    category = widget.menuItem['category'];
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      updateMenu(
        id: widget.menuItem['id'],
        name: name,
        description: description,
        price: price,
        image: image,
        category: category,
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
              // Use ListView for scrolling
              children: <Widget>[
                TextFormField(
                  initialValue: widget.menuItem['id'].toString(),
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
                    name = value!;
                  },
                ),
                TextFormField(
                  initialValue: description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    description = value!;
                  },
                ),
                TextFormField(
                  initialValue: price,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number, // For numeric input
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    // Add more validation if needed (e.g., number format)

                    return null;
                  },
                  onSaved: (value) {
                    price = value!;
                  },
                ),
                TextFormField(
                  initialValue: image,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an image URL';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    image = value!;
                  },
                ),
                TextFormField(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a category';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    category = value!;
                  },
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
