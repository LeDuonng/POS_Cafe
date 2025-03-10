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
      final results = await searchUsers(query);
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
      appBar: AppBar(
        title: const Text('Tìm kiếm khách hàng'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Nhập tên hoặc số điện thoại khách hàng',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: _filterCustomers,
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: _filteredCustomers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_search,
                            size: 100,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            'Không tìm thấy khách hàng',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 18.0,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = _filteredCustomers[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.lightBlue,
                              child: Text(
                                customer['name'][0],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(customer['name']),
                            subtitle: Text(customer['phone']),
                            onTap: () => _selectCustomer(customer),
                          ),
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
