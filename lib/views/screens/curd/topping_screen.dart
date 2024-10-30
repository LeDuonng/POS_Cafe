import 'package:coffeeapp/models/menu_model.dart';
import 'package:flutter/material.dart';
import '../../../controllers/menu_controller.dart';

class ToppingScreen extends StatefulWidget {
  const ToppingScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ToppingScreenState createState() => _ToppingScreenState();
}

late Future<List<dynamic>> toppingList;
String searchText = '';

class _ToppingScreenState extends State<ToppingScreen> {
  @override
  void initState() {
    super.initState();
    toppingList = fetchTopping();
  }

  Future<void> _refreshToppingList() async {
    setState(() {
      toppingList = fetchTopping();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topping List'),
        actions: [
          const AnimatedSearchBar(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              try {
                var topping = await searchTopping(1);
                // ignore: avoid_print
                print(topping.toString());
                Navigator.push(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchResultScreen(
                      searchResults: Future.value(topping),
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
        future: toppingList,
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
                    deleteTopping(snapshot.data![index]['id']);
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
                          builder: (context) => EditToppingItemScreen(
                            topping: snapshot.data![index],
                            toppingItem: {
                              'id': snapshot.data![index]['id'],
                              'name': snapshot.data![index]['name'],
                              'description': snapshot.data![index]
                                  ['description'],
                              'price': snapshot.data![index]['price'],
                              'image': snapshot.data![index]['image'],
                              'category': snapshot.data![index]['category'],
                            },
                          ),
                        ),
                      );
                    },
                    title: Text(snapshot.data![index]['name'].toString()),
                    subtitle: Text(
                        'Price: ${snapshot.data![index]['price']}, Category: ${snapshot.data![index]['category']} \nDescription: ${snapshot.data![index]['description']}, Image: ${snapshot.data![index]['image']}'),
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
            MaterialPageRoute(
                builder: (context) => const AddToppingItemScreen()),
          );
          _refreshToppingList();
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

class AddToppingItemScreen extends StatefulWidget {
  const AddToppingItemScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddToppingItemScreenState createState() => _AddToppingItemScreenState();
}

class _AddToppingItemScreenState extends State<AddToppingItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name, description, price, image, category;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save the form fields
      addTopping(
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Topping Item'),
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
                child: const Text('Add Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditToppingItemScreen extends StatefulWidget {
  final Map<String, dynamic> toppingItem;

  const EditToppingItemScreen(
      {super.key, required this.toppingItem, required topping});

  @override
  // ignore: library_private_types_in_public_api
  _EditToppingItemScreenState createState() => _EditToppingItemScreenState();
}

class _EditToppingItemScreenState extends State<EditToppingItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name, description, price, image, category;

  @override
  void initState() {
    super.initState();
    name = widget.toppingItem['name'];
    description = widget.toppingItem['description'];
    price = widget.toppingItem['price'];
    image = widget.toppingItem['image'];
    category = widget.toppingItem['category'];
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save the form fields
      updateTopping(
        id: widget.toppingItem['id'],
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Topping Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: widget.toppingItem['id'].toString(),
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
                      'Price: ${snapshot.data![index]['price']}, Category: ${snapshot.data![index]['category']} \nDescription: ${snapshot.data![index]['description']}, Image: ${snapshot.data![index]['image']}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
