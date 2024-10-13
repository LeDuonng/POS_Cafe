import 'package:coffeeapp/controllers/orders_controller.dart' as controller;
import 'package:coffeeapp/models/orders_model.dart';
import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OrdersScreenState createState() => _OrdersScreenState();
}

late Future<List<dynamic>> ordersList;
String searchText = '';

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    ordersList = controller.fetchOrders();
  }

  Future<void> _refreshOrdersList() async {
    setState(() {
      ordersList = controller.fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders List'),
        actions: [
          const AnimatedSearchBar(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              try {
                var orders = await controller.fetchOrderById(1);
                Navigator.push(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchResultScreen(
                      searchResults: Future.value(orders),
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
        future: ordersList,
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
                    deleteOrder(snapshot.data![index]['id']);
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
                          builder: (context) => EditOrderScreen(
                            order: snapshot.data![index],
                            orderItem: {
                              'id': snapshot.data![index]['id'],
                              'table_id': snapshot.data![index]['table_id'],
                              'customer_id': snapshot.data![index]
                                  ['customer_id'],
                              'staff_id': snapshot.data![index]['staff_id'],
                              'order_date': snapshot.data![index]['order_date'],
                              'status': snapshot.data![index]['status'],
                            },
                          ),
                        ),
                      );
                    },
                    title: Text('Order ID: ${snapshot.data![index]['id']}'),
                    subtitle: Text(
                        'Table ID: ${snapshot.data![index]['table_id']}, Customer ID: ${snapshot.data![index]['customer_id']}, Staff ID: ${snapshot.data![index]['staff_id']}, Status: ${snapshot.data![index]['status']}'),
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
            MaterialPageRoute(builder: (context) => const AddOrderScreen()),
          );
          _refreshOrdersList();
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

class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddOrderScreenState createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  late int tableId, customerId, staffId;
  late String status;
  late DateTime orderdate;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      addOrder(
        tableId: tableId,
        customerId: customerId,
        staffId: staffId,
        orderDate: orderdate,
        status: status,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Order'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Table ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a table ID';
                  }
                  return null;
                },
                onSaved: (value) {
                  tableId = int.parse(value!);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Customer ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a customer ID';
                  }
                  return null;
                },
                onSaved: (value) {
                  customerId = int.parse(value!);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Staff ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a staff ID';
                  }
                  return null;
                },
                onSaved: (value) {
                  staffId = int.parse(value!);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Order Date'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an order date';
                  }
                  return null;
                },
                onSaved: (value) {
                  orderdate = DateTime.parse(value!);
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Status'),
                items: ['received', 'preparing', 'paid']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {
                  status = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a status';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _submitForm();
                },
                child: const Text('Add Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditOrderScreen extends StatefulWidget {
  final Map<String, dynamic> orderItem;

  const EditOrderScreen({super.key, required this.orderItem, required order});

  @override
  // ignore: library_private_types_in_public_api
  _EditOrderScreenState createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  late int tableId, customerId, staffId;
  late String status;
  late DateTime orderdate;

  @override
  void initState() {
    super.initState();
    tableId = widget.orderItem['table_id'];
    customerId = widget.orderItem['customer_id'];
    staffId = widget.orderItem['staff_id'];
    orderdate = DateTime.parse(widget.orderItem['order_date']);
    status = widget.orderItem['status'];
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      updateOrder(
        id: widget.orderItem['id'],
        tableId: tableId,
        customerId: customerId,
        staffId: staffId,
        orderDate: orderdate,
        status: status,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Order'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: widget.orderItem['id'].toString(),
                decoration: const InputDecoration(labelText: 'ID'),
                readOnly: true,
              ),
              TextFormField(
                initialValue: tableId.toString(),
                decoration: const InputDecoration(labelText: 'Table ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a table ID';
                  }
                  return null;
                },
                onSaved: (value) {
                  tableId = int.parse(value!);
                },
              ),
              TextFormField(
                initialValue: customerId.toString(),
                decoration: const InputDecoration(labelText: 'Customer ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a customer ID';
                  }
                  return null;
                },
                onSaved: (value) {
                  customerId = int.parse(value!);
                },
              ),
              TextFormField(
                initialValue: staffId.toString(),
                decoration: const InputDecoration(labelText: 'Staff ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a staff ID';
                  }
                  return null;
                },
                onSaved: (value) {
                  staffId = int.parse(value!);
                },
              ),
              TextFormField(
                initialValue: orderdate.toString(),
                decoration: const InputDecoration(labelText: 'Order Date'),
                readOnly: true,
              ),
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ['received', 'preparing', 'paid']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {
                  status = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a status';
                  }
                  return null;
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
                  title: Text('Order ID: ${snapshot.data![index]['id']}'),
                  subtitle: Text(
                      'Table ID: ${snapshot.data![index]['table_id']}, Customer ID: ${snapshot.data![index]['customer_id']}, Staff ID: ${snapshot.data![index]['staff_id']}, Status: ${snapshot.data![index]['status']}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
