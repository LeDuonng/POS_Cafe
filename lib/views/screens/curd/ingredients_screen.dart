import 'package:coffeeapp/models/ingredients_model.dart';
import 'package:flutter/material.dart';
import '../../../controllers/ingredients_controller.dart';

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

  Future<void> _refreshIngredientsList() async {
    setState(() {
      ingredientsList = fetchIngredients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredients List'),
        actions: [
          const AnimatedSearchBar(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              try {
                var ingredients = await ingredientsSearch(1);
                Navigator.push(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchResultScreen(
                      searchResults: Future.value(ingredients),
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
        future: ingredientsList,
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
                    deleteIngredient(snapshot.data![index]['id']);
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
                          builder: (context) => EditIngredientScreen(
                            ingredient: snapshot.data![index],
                            ingredientItem: {
                              'id': snapshot.data![index]['id'],
                              'name': snapshot.data![index]['name'],
                              'unit': snapshot.data![index]['unit'],
                              'quantity': snapshot.data![index]['quantity'],
                            },
                          ),
                        ),
                      );
                    },
                    title: Text(snapshot.data![index]['name'].toString()),
                    subtitle: Text(
                        'Unit: ${snapshot.data![index]['unit']}, Quantity: ${snapshot.data![index]['quantity']}'),
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
                builder: (context) => const AddIngredientScreen()),
          );
          _refreshIngredientsList();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Ingredient'),
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
                child: const Text('Add Ingredient'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditIngredientScreen extends StatefulWidget {
  final Map<String, dynamic> ingredientItem;

  const EditIngredientScreen(
      {super.key, required this.ingredientItem, required ingredient});

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Ingredient'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
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
                      'Unit: ${snapshot.data![index]['unit']}, Quantity: ${snapshot.data![index]['quantity']}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
