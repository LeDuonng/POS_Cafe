import 'package:coffeeapp/models/tables_model.dart';
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
    tableList = fetchTables();
  }

  Future<void> _refreshTableList() async {
    setState(() {
      tableList = fetchTables();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Table List'),
        actions: [
          const AnimatedSearchBar(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              try {
                var tables = await tableSearch(1);
                Navigator.push(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchResultScreen(
                      searchResults: Future.value(tables),
                    ),
                  ),
                );
              } catch (e) {
                // ignore: avoid_print
                print('Failed to get item: $e');
              }
            },
          )
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: tableList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(snapshot.data![index]['id'].toString()),
                  onDismissed: (direction) {
                    deleteTable(snapshot.data![index]['id']);
                    setState(() {
                      snapshot.data!.removeAt(index);
                    });
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditTableScreen(
                            table: snapshot.data![index],
                            tableItem: {
                              'id': snapshot.data![index]['id'],
                              'name': snapshot.data![index]['name'],
                              'floor': snapshot.data![index]['floor'],
                              'area': snapshot.data![index]['area'],
                              'status': snapshot.data![index]['status'],
                            },
                          ),
                        ),
                      );
                    },
                    title: Text(snapshot.data![index]['name'].toString()),
                    subtitle: Text(
                        'Floor: ${snapshot.data![index]['floor']}, Area: ${snapshot.data![index]['area']} \nStatus: ${snapshot.data![index]['status']}'),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTableScreen()),
          );
          _refreshTableList();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AnimatedSearchBar extends StatefulWidget {
  const AnimatedSearchBar({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AnimatedSearchBarState createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar> {
  bool _isSearchActive = false;
  final _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
    });
    if (!_isSearchActive) {
      _focusNode.unfocus();
      if (_searchController.text.isNotEmpty) {
        searchText = _searchController.text;
        _searchController.clear();
      }
    }
  }

  void _onSearchSubmitted(String value) {
    if (value.isNotEmpty) {
      searchText = _searchController.text;
      _searchController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleSearch,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: _isSearchActive ? 200 : 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 254, 247, 247),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade800,
              offset: const Offset(1.5, 1.5),
              blurRadius: 3.0,
            ),
            BoxShadow(
              color: Colors.grey.shade600,
              offset: const Offset(-1.5, -1.5),
              blurRadius: 3.0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(left: _isSearchActive ? 10 : 0),
              child:
                  const Icon(Icons.search, color: Color.fromARGB(255, 0, 0, 0)),
            ),
            _isSearchActive
                ? Expanded(
                    child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        focusNode: _focusNode,
                        style: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0)),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Type to search...",
                          hintStyle:
                              TextStyle(color: Color.fromARGB(179, 81, 81, 81)),
                        ),
                        onSubmitted: _onSearchSubmitted,
                        onChanged: _onSearchSubmitted,
                        onEditingComplete: () =>
                            _onSearchSubmitted(_searchController.text)),
                  ))
                : Container(),
          ],
        ),
      ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Table'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
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
                child: const Text('Add Table'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditTableScreen extends StatefulWidget {
  final Map<String, dynamic> tableItem;

  const EditTableScreen({super.key, required this.tableItem, required table});

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Table'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
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
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchResultScreen extends StatelessWidget {
  final Future<List<dynamic>> searchResults;

  const SearchResultScreen({super.key, required this.searchResults});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: searchResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No results found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index]['name'].toString()),
                  subtitle: Text(
                      'Floor: ${snapshot.data![index]['floor']}, Area: ${snapshot.data![index]['area']} \nStatus: ${snapshot.data![index]['status']}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
