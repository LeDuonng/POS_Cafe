import 'package:coffeeapp/models/bills_model.dart';
import 'package:flutter/material.dart';
import '../../../controllers/bills_controller.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BillsScreenState createState() => _BillsScreenState();
}

late Future<List<dynamic>> billsList;
String searchText = '';

class _BillsScreenState extends State<BillsScreen> {
  @override
  void initState() {
    super.initState();
    billsList = fetchBills();
  }

  Future<void> _refreshBillsList() async {
    setState(() {
      billsList = fetchBills();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bills List'),
        actions: [
          const AnimatedSearchBar(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              try {
                var bills = await billsSearch(1);
                Navigator.push(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchResultScreen(
                      searchResults: Future.value(bills),
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
        future: billsList,
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
                    deleteBill(snapshot.data![index]['id']);
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
                          builder: (context) => EditBillScreen(
                            bill: snapshot.data![index],
                            billItem: {
                              'id': snapshot.data![index]['id'],
                              'order_id': snapshot.data![index]['order_id'],
                              'total_amount': snapshot.data![index]
                                  ['total_amount'],
                              'payment_method': snapshot.data![index]
                                  ['payment_method'],
                              'payment_date': snapshot.data![index]
                                  ['payment_date'],
                            },
                          ),
                        ),
                      );
                    },
                    title:
                        Text('Order ID: ${snapshot.data![index]['order_id']}'),
                    subtitle: Text(
                        'Total Amount: ${snapshot.data![index]['total_amount']}, Payment Method: ${snapshot.data![index]['payment_method']} \nPayment Date: ${snapshot.data![index]['payment_date']}'),
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
            MaterialPageRoute(builder: (context) => const AddBillScreen()),
          );
          _refreshBillsList();
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

class AddBillScreen extends StatefulWidget {
  const AddBillScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddBillScreenState createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();
  late String orderId, totalAmount, paymentMethod;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      addBill(
        orderId: int.parse(orderId),
        totalAmount: double.parse(totalAmount),
        paymentMethod: paymentMethod,
        paymentDate: DateTime.now().toString(),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Bill'),
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
                  if (value != null) {
                    orderId = value;
                  }
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Total Amount'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a total amount';
                  }
                  return null;
                },
                onSaved: (value) {
                  totalAmount = value!;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Payment Method'),
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'card', child: Text('Card')),
                ],
                onChanged: (value) {
                  paymentMethod = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a payment method';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Bill'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditBillScreen extends StatefulWidget {
  final Map<String, dynamic> billItem;

  const EditBillScreen({super.key, required this.billItem, required bill});

  @override
  // ignore: library_private_types_in_public_api
  _EditBillScreenState createState() => _EditBillScreenState();
}

class _EditBillScreenState extends State<EditBillScreen> {
  final _formKey = GlobalKey<FormState>();
  late String orderId, totalAmount, paymentMethod;
  late DateTime paymentDate;

  @override
  void initState() {
    super.initState();
    orderId = widget.billItem['order_id'].toString();
    totalAmount = widget.billItem['total_amount'].toString();
    paymentMethod = widget.billItem['payment_method'];
    paymentDate = DateTime.parse(widget.billItem['payment_date']);
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      updateBill(
        id: widget.billItem['id'],
        orderId: int.parse(orderId),
        totalAmount: double.parse(totalAmount),
        paymentMethod: paymentMethod,
        paymentDate: paymentDate.toString(),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Bill'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: widget.billItem['id'].toString(),
                decoration: const InputDecoration(labelText: 'ID'),
                readOnly: true,
              ),
              TextFormField(
                initialValue: orderId,
                decoration: const InputDecoration(labelText: 'Order ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an order ID';
                  }
                  return null;
                },
                onSaved: (value) {
                  if (value != null) {
                    orderId = value;
                  }
                },
              ),
              TextFormField(
                initialValue: totalAmount,
                decoration: const InputDecoration(labelText: 'Total Amount'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a total amount';
                  }
                  return null;
                },
                onSaved: (value) {
                  totalAmount = value!;
                },
              ),
              DropdownButtonFormField<String>(
                value: paymentMethod,
                decoration: const InputDecoration(labelText: 'Payment Method'),
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'card', child: Text('Card')),
                ],
                onChanged: (value) {
                  paymentMethod = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a payment method';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: paymentDate.toString(),
                decoration: const InputDecoration(labelText: 'Payment Date'),
                readOnly: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
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
                  title: Text('Order ID: ${snapshot.data![index]['order_id']}'),
                  subtitle: Text(
                      'Total Amount: ${snapshot.data![index]['total_amount']}, Payment Method: ${snapshot.data![index]['payment_method']} \nPayment Date: ${snapshot.data![index]['payment_date']}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
