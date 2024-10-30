import 'package:coffeeapp/models/users_model.dart';
import 'package:flutter/material.dart';
import '../../../controllers/users_controller.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserScreenState createState() => _UserScreenState();
}

late Future<List<dynamic>> userList;
String searchText = '';

class _UserScreenState extends State<UserScreen> {
  @override
  void initState() {
    super.initState();
    userList = fetchUsers();
  }

  Future<void> _refreshUserList() async {
    setState(() {
      userList = fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
        actions: [
          const AnimatedSearchBar(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              try {
                var users = await userSearch(2);
                // ignore: avoid_print
                print(users.toString());
                Navigator.push(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchResultScreen(
                      searchResults: Future.value(users),
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
        future: userList,
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
                    // Delete the item from the database
                    deleteUser(snapshot.data![index]['id']);
                    // Remove the item from the list
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
                      // Navigate to Edit screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditUserScreen(
                            user: snapshot.data![index],
                            userItem: {
                              'username': snapshot.data![index]['username'],
                              'password': snapshot.data![index]['password'],
                              'role': snapshot.data![index]['role'],
                              'id': snapshot.data![index]['id'],
                              'name': snapshot.data![index]['name'],
                              'email': snapshot.data![index]['email'],
                              'phone': snapshot.data![index]['phone'],
                              'address': snapshot.data![index]['address'],
                            },
                          ),
                        ),
                      );
                    },
                    title: Text(snapshot.data![index]['name'].toString()),
                    subtitle: Text(
                        'Email: ${snapshot.data![index]['email']}, Phone: ${snapshot.data![index]['phone']} \nAddress: ${snapshot.data![index]['address']}'),
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
            MaterialPageRoute(builder: (context) => const AddUserScreen()),
          );
          _refreshUserList();
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
    try {
      // ignore: avoid_print
      print('Search submitted: $value');
    } catch (e) {
      // ignore: avoid_print
      print('Error: $e');
    }
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

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late String username, password, role, name, email, phone, address;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save the form fields
      addUser(
        username: username,
        password: password,
        role: role,
        name: name,
        email: email,
        phone: phone,
        address: address,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a Username';
                  }
                  return null;
                },
                onSaved: (value) {
                  if (value != null) {
                    username = value;
                  }
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
                onSaved: (value) {
                  if (value != null) {
                    password = value;
                  }
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Role'),
                value: 'customer',
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'staff', child: Text('Staff')),
                  DropdownMenuItem(value: 'customer', child: Text('Customer')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      role = value;
                    });
                  }
                },
                onSaved: (value) {
                  if (value != null) {
                    role = value;
                  }
                },
              ),
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
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
                onSaved: (value) {
                  email = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
                onSaved: (value) {
                  phone = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
                onSaved: (value) {
                  address = value!;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _submitForm();
                },
                child: const Text('Add User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditUserScreen extends StatefulWidget {
  final Map<String, dynamic> userItem;

  const EditUserScreen({super.key, required this.userItem, required user});

  @override
  // ignore: library_private_types_in_public_api
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late String username, password, role, name, email, phone, address;

  @override
  void initState() {
    super.initState();
    username = widget.userItem['username'];
    password = widget.userItem['password'];
    role = widget.userItem['role'];
    name = widget.userItem['name'];
    email = widget.userItem['email'];
    phone = widget.userItem['phone'];
    address = widget.userItem['address'];
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save the form fields
      updateUser(
        id: widget.userItem['id'],
        username: username,
        password: password,
        role: role,
        name: name,
        email: email,
        phone: phone,
        address: address,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: widget.userItem['id'].toString(),
                decoration: const InputDecoration(labelText: 'ID'),
                readOnly: true,
              ),
              TextFormField(
                initialValue: username,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a Username';
                  }
                  return null;
                },
                onSaved: (value) {
                  if (value != null) {
                    username = value;
                  }
                },
              ),
              TextFormField(
                initialValue: password,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
                onSaved: (value) {
                  if (value != null) {
                    password = value;
                  }
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Role'),
                value: role,
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'staff', child: Text('Staff')),
                  DropdownMenuItem(value: 'customer', child: Text('Customer')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      role = value;
                    });
                  }
                },
                onSaved: (value) {
                  if (value != null) {
                    role = value;
                  }
                },
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
                initialValue: email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
                onSaved: (value) {
                  email = value!;
                },
              ),
              TextFormField(
                initialValue: phone,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
                onSaved: (value) {
                  phone = value!;
                },
              ),
              TextFormField(
                initialValue: address,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
                onSaved: (value) {
                  address = value!;
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
                      'Email: ${snapshot.data![index]['email']}, Phone: ${snapshot.data![index]['phone']} \nAddress: ${snapshot.data![index]['address']}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
