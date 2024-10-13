import 'package:coffeeapp/controllers/customer_points_controller.dart';
import 'package:flutter/material.dart';
import '../../../models/customer_points_model.dart';

class CustomerPointsScreen extends StatefulWidget {
  const CustomerPointsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CustomerPointsScreenState createState() => _CustomerPointsScreenState();
}

late Future<List<dynamic>> customerPointsList;

class _CustomerPointsScreenState extends State<CustomerPointsScreen> {
  @override
  void initState() {
    super.initState();
    customerPointsList = fetchCustomerPoints();
  }

  Future<void> _refreshCustomerPointsList() async {
    setState(() {
      customerPointsList = fetchCustomerPoints();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Points'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              _refreshCustomerPointsList();
            },
          )
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: customerPointsList,
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
                    deleteCustomerPoints(snapshot.data![index]['id']);
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
                    title: Text('User ID: ${snapshot.data![index]['user_id']}'),
                    subtitle:
                        Text('Points: ${snapshot.data![index]['points']}'),
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
                builder: (context) => const AddCustomerPointsScreen()),
          );
          _refreshCustomerPointsList();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddCustomerPointsScreen extends StatefulWidget {
  const AddCustomerPointsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddCustomerPointsScreenState createState() =>
      _AddCustomerPointsScreenState();
}

class _AddCustomerPointsScreenState extends State<AddCustomerPointsScreen> {
  final _formKey = GlobalKey<FormState>();
  late int userId, points;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save the form fields
      addCustomerPoints(
        userId: userId,
        points: points,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Customer Points'),
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
                  try {
                    userId = int.parse(value!);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Invalid User ID: $e')),
                    );
                  }
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Points'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter points';
                  }
                  return null;
                },
                onSaved: (value) {
                  try {
                    points = int.parse(value!);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Invalid Points: $e')),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _submitForm();
                },
                child: const Text('Add Points'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
