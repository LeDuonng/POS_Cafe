import 'package:coffeeapp/models/users_model.dart';
import 'package:flutter/material.dart';

class FindCustomerScreen extends StatefulWidget {
  const FindCustomerScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FindCustomerScreenState createState() => _FindCustomerScreenState();
}

class _FindCustomerScreenState extends State<FindCustomerScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredCustomers = [];
  // ignore: unused_field
  String? _selectedCustomerId;

  @override
  void initState() {
    super.initState();
  }

  void _filterCustomers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredCustomers = [];
      });
      return;
    }

    try {
      final results = await findUser(query);
      setState(() {
        _filteredCustomers = results;
      });
    } catch (e) {
      // Handle error
      // ignore: avoid_print
      print(e);
    }
  }

  void _selectCustomer(Map<String, dynamic> customer) {
    setState(() {
      _searchController.text = customer['name'];
      _selectedCustomerId = customer['id'].toString();
      _filteredCustomers = [];
    });
    Navigator.pop(context,
        customer); // Trở về trang trước đó và truyền thông tin khách hàng đã chọn
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Nhập tên hoặc số điện thoại khách hàng',
                border: OutlineInputBorder(),
              ),
              onChanged: _filterCustomers,
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredCustomers.length,
                itemBuilder: (context, index) {
                  final customer = _filteredCustomers[index];
                  return ListTile(
                    title: Text(customer['name']),
                    onTap: () => _selectCustomer(customer),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
