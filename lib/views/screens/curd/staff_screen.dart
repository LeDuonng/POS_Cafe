import 'package:coffeeapp/controllers/staff_controller.dart';
import 'package:flutter/material.dart';
import '../../../models/staff_model.dart';

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

  Future<void> _refreshStaffList() async {
    setState(() {
      staffList = fetchStaff();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff List'),
        actions: [
          const AnimatedSearchBar(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              try {
                var staff = await staffSearch(1);
                Navigator.push(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchResultScreen(
                      searchResults: Future.value(staff),
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
        future: staffList,
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
                    deleteStaff(snapshot.data![index]['id']);
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
                          builder: (context) => EditStaffItemScreen(
                            staff: snapshot.data![index],
                            staffItem: {
                              'id': snapshot.data![index]['id'],
                              'user_id': snapshot.data![index]['user_id'],
                              'salary': snapshot.data![index]['salary'],
                              'start_date': snapshot.data![index]['start_date'],
                              'position': snapshot.data![index]['position'],
                            },
                          ),
                        ),
                      );
                    },
                    title: Text(snapshot.data![index]['position'].toString()),
                    subtitle: Text(
                        'Salary: ${snapshot.data![index]['salary']}, Start Date: ${snapshot.data![index]['start_date']} \nUser ID: ${snapshot.data![index]['user_id']}'),
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
            MaterialPageRoute(builder: (context) => const AddStaffItemScreen()),
          );
          _refreshStaffList();
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
        startDate: DateTime.parse('$startDate 00:00:00'),
        position: position,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Staff Member'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
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
                child: const Text('Add Staff Member'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditStaffItemScreen extends StatefulWidget {
  final Map<String, dynamic> staffItem;

  const EditStaffItemScreen(
      {super.key, required this.staffItem, required staff});

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Staff Member'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
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
                  title: Text(snapshot.data![index]['position'].toString()),
                  subtitle: Text(
                      'Salary: ${snapshot.data![index]['salary']}, Start Date: ${snapshot.data![index]['start_date']} \nUser ID: ${snapshot.data![index]['user_id']}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
