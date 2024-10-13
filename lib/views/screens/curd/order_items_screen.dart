import 'package:coffeeapp/controllers/order_items_controller.dart';
import 'package:flutter/material.dart';
import '../../../models/order_items_model.dart';

class OrderItemsScreen extends StatefulWidget {
  const OrderItemsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OrderItemsScreenState createState() => _OrderItemsScreenState();
}

late Future<List<dynamic>> orderItemsList;

class _OrderItemsScreenState extends State<OrderItemsScreen> {
  @override
  void initState() {
    super.initState();
    orderItemsList = fetchOrderItems();
  }

  Future<void> _refreshOrderItemsList() async {
    setState(() {
      orderItemsList = fetchOrderItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Items List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              _refreshOrderItemsList();
            },
          )
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: orderItemsList,
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
                    deleteOrderItem(snapshot.data![index]['id']);
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
                          builder: (context) => EditOrderItemScreen(
                            orderItem: snapshot.data![index],
                          ),
                        ),
                      );
                    },
                    title:
                        Text('Order ID: ${snapshot.data![index]['order_id']}'),
                    subtitle: Text(
                        'Menu ID: ${snapshot.data![index]['menu_id']}, Quantity: ${snapshot.data![index]['quantity']}, Price: ${snapshot.data![index]['price']}'),
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
            MaterialPageRoute(builder: (context) => const AddOrderItemScreen()),
          );
          _refreshOrderItemsList();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddOrderItemScreen extends StatefulWidget {
  const AddOrderItemScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddOrderItemScreenState createState() => _AddOrderItemScreenState();
}

class _AddOrderItemScreenState extends State<AddOrderItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late int orderId, menuId, quantity;
  late double price;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save the form fields
      addOrderItem(
        orderId: orderId,
        menuId: menuId,
        quantity: quantity,
        price: price,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Order Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Order ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an order ID';
                  }
                  return null;
                },
                onSaved: (value) {
                  orderId = int.parse(value!);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Menu ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a menu ID';
                  }
                  return null;
                },
                onSaved: (value) {
                  menuId = int.parse(value!);
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
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  return null;
                },
                onSaved: (value) {
                  price = double.parse(value!);
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

class EditOrderItemScreen extends StatefulWidget {
  final Map<String, dynamic> orderItem;

  const EditOrderItemScreen({super.key, required this.orderItem});

  @override
  // ignore: library_private_types_in_public_api
  _EditOrderItemScreenState createState() => _EditOrderItemScreenState();
}

class _EditOrderItemScreenState extends State<EditOrderItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late int orderId, menuId, quantity;
  late double price;

  @override
  void initState() {
    super.initState();
    orderId = widget.orderItem['order_id'];
    menuId = widget.orderItem['menu_id'];
    quantity = widget.orderItem['quantity'];
    price = double.parse(widget.orderItem['price']);
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save the form fields
      updateOrderItem(
        id: widget.orderItem['id'],
        orderId: orderId,
        menuId: menuId,
        quantity: quantity,
        price: price,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Order Item'),
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
                initialValue: orderId.toString(),
                decoration: const InputDecoration(labelText: 'Order ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an order ID';
                  }
                  return null;
                },
                onSaved: (value) {
                  orderId = int.parse(value!);
                },
              ),
              TextFormField(
                initialValue: menuId.toString(),
                decoration: const InputDecoration(labelText: 'Menu ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a menu ID';
                  }
                  return null;
                },
                onSaved: (value) {
                  menuId = int.parse(value!);
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
              TextFormField(
                initialValue: price.toString(),
                decoration: const InputDecoration(labelText: 'Price'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  return null;
                },
                onSaved: (value) {
                  price = double.parse(value!);
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
