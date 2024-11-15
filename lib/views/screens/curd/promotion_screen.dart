import 'package:coffeeapp/models/promotion_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../responsive.dart'; // Import the Responsive widget

class PromotionScreen extends StatefulWidget {
  const PromotionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PromotionScreenState createState() => _PromotionScreenState();
}

late Future<List<dynamic>> promotionsList;
String searchText = '';

class _PromotionScreenState extends State<PromotionScreen> {
  @override
  void initState() {
    super.initState();
    promotionsList = searchPromotions();
  }

  Future<void> _refreshPromotionsList([String? searchText]) async {
    var temp = searchPromotions(searchText);
    setState(() {
      promotionsList = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promotion List'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 300,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Search by Name...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                    _refreshPromotionsList(searchText);
                  });
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) => const AddPromotionScreen(),
              );
              _refreshPromotionsList();
            },
          ),
        ],
      ),
      body: Responsive(
        mobile: _buildPromotionsList(context),
        tablet: _buildPromotionsList(context),
        desktop: _buildPromotionsList(context),
      ),
    );
  }

  Widget _buildPromotionsList(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: promotionsList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        } else {
          return LayoutBuilder(
            builder: (context, constraints) {
              double totalWidth = constraints.maxWidth;
              double columnWidth = totalWidth / 7; // 7 là tổng số cột hiện có

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columnSpacing: 12,
                  // ignore: deprecated_member_use
                  dataRowHeight: 100,
                  columns: [
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'STT',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'Discount Type',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'Discount Value',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'Start Date',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'End Date',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'Actions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                    ),
                  ],
                  rows: List.generate(snapshot.data!.length, (index) {
                    return DataRow(
                      color: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                          return index.isEven
                              ? Colors.grey.withOpacity(0.1)
                              : Colors.white;
                        },
                      ),
                      cells: [
                        DataCell(Text((index + 1).toString())),
                        DataCell(Text(snapshot.data![index]['name'])),
                        DataCell(Text(snapshot.data![index]['discount_type'])),
                        DataCell(Text(snapshot.data![index]['discount_value']
                            .toString())),
                        DataCell(Text(snapshot.data![index]['start_date'])),
                        DataCell(Text(snapshot.data![index]['end_date'])),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (context) => EditPromotionScreen(
                                      promotion: snapshot.data![index],
                                      promotionItem: {
                                        'id': snapshot.data![index]['id'],
                                        'name': snapshot.data![index]['name'],
                                        'discount_type': snapshot.data![index]
                                            ['discount_type'],
                                        'discount_value': snapshot.data![index]
                                            ['discount_value'],
                                        'start_date': snapshot.data![index]
                                            ['start_date'],
                                        'end_date': snapshot.data![index]
                                            ['end_date'],
                                        'min_order_value': snapshot.data![index]
                                            ['min_order_value'],
                                        'code_limit': snapshot.data![index]
                                            ['code_limit'],
                                        'usage_limit': snapshot.data![index]
                                            ['usage_limit'],
                                        'active': snapshot.data![index]
                                            ['active'],
                                      },
                                    ),
                                  );
                                  _refreshPromotionsList();
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Confirm Delete'),
                                        content: const Text(
                                            'Are you sure you want to delete this promotion?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                // try {
                                                //   deletePromotion(snapshot
                                                //       .data![index]['id']);
                                                //   snapshot.data!
                                                //       .removeAt(index);
                                                // } catch (e) {
                                                //   ScaffoldMessenger.of(context)
                                                //       .showSnackBar(
                                                //     SnackBar(
                                                //         content:
                                                //             Text('Error: $e')),
                                                //   );
                                                // }
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              );
            },
          );
        }
      },
    );
  }
}

class AddPromotionScreen extends StatefulWidget {
  const AddPromotionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddPromotionScreenState createState() => _AddPromotionScreenState();
}

class _AddPromotionScreenState extends State<AddPromotionScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name, discountType;
  late double discountValue, minOrderValue;
  late DateTime startDate, endDate;
  late int codeLimit, usageLimit;
  late bool active;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // addPromotion(
      //   name: name,
      //   discountType: discountType,
      //   discountValue: discountValue,
      //   startDate: startDate,
      //   endDate: endDate,
      //   minOrderValue: minOrderValue,
      //   codeLimit: codeLimit,
      //   usageLimit: usageLimit,
      //   active: active,
      // );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(10),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 900),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
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
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Discount Type'),
                  value: 'percentage',
                  items: const [
                    DropdownMenuItem(
                      value: 'percentage',
                      child: Text('Percentage'),
                    ),
                    DropdownMenuItem(
                      value: 'fixed_amount',
                      child: Text('Fixed Amount'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      discountType = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a discount type';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    discountType = value!;
                  },
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Discount Value'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a discount value';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    discountValue = double.parse(value!);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Start Date'),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        startDate = pickedDate;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a start date';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    startDate = DateTime.parse(value!);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'End Date'),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        endDate = pickedDate;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an end date';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    endDate = DateTime.parse(value!);
                  },
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Min Order Value'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a min order value';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    minOrderValue = double.parse(value!);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Code Limit'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a code limit';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    codeLimit = int.parse(value!);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Usage Limit'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a usage limit';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    usageLimit = int.parse(value!);
                  },
                ),
                SwitchListTile(
                  title: const Text('Active'),
                  value: active,
                  onChanged: (value) {
                    setState(() {
                      active = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _submitForm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Green for Add Item
                  ),
                  child: const Text('Add Promotion'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Red for Cancel
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EditPromotionScreen extends StatefulWidget {
  final Map<String, dynamic> promotionItem;
  final dynamic promotion;

  const EditPromotionScreen({
    super.key,
    required this.promotionItem,
    required this.promotion,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EditPromotionScreenState createState() => _EditPromotionScreenState();
}

class _EditPromotionScreenState extends State<EditPromotionScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name, discountType;
  late double discountValue, minOrderValue;
  late DateTime startDate, endDate;
  late int codeLimit, usageLimit;
  late bool active;

  @override
  void initState() {
    super.initState();
    name = widget.promotionItem['name'];
    discountType = widget.promotionItem['discount_type'];
    discountValue = widget.promotionItem['discount_value'];
    startDate = DateTime.parse(widget.promotionItem['start_date']);
    endDate = DateTime.parse(widget.promotionItem['end_date']);
    minOrderValue = widget.promotionItem['min_order_value'];
    codeLimit = widget.promotionItem['code_limit'];
    usageLimit = widget.promotionItem['usage_limit'];
    active = widget.promotionItem['active'];
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // updatePromotion(
      //   id: widget.promotionItem['id'],
      //   name: name,
      //   discountType: discountType,
      //   discountValue: discountValue,
      //   startDate: startDate,
      //   endDate: endDate,
      //   minOrderValue: minOrderValue,
      //   codeLimit: codeLimit,
      //   usageLimit: usageLimit,
      //   active: active,
      // );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(10),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 900),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  initialValue: name,
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
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Discount Type'),
                  value: discountType,
                  items: const [
                    DropdownMenuItem(
                      value: 'percentage',
                      child: Text('Percentage'),
                    ),
                    DropdownMenuItem(
                      value: 'fixed_amount',
                      child: Text('Fixed Amount'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      discountType = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a discount type';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    discountType = value!;
                  },
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Discount Value'),
                  initialValue: discountValue.toString(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a discount value';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    discountValue = double.parse(value!);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Start Date'),
                  initialValue: DateFormat('yyyy-MM-dd').format(startDate),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        startDate = pickedDate;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a start date';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    startDate = DateTime.parse(value!);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'End Date'),
                  initialValue: DateFormat('yyyy-MM-dd').format(endDate),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: endDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        endDate = pickedDate;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an end date';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    endDate = DateTime.parse(value!);
                  },
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Min Order Value'),
                  initialValue: minOrderValue.toString(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a min order value';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    minOrderValue = double.parse(value!);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Code Limit'),
                  initialValue: codeLimit.toString(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a code limit';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    codeLimit = int.parse(value!);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Usage Limit'),
                  initialValue: usageLimit.toString(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a usage limit';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    usageLimit = int.parse(value!);
                  },
                ),
                SwitchListTile(
                  title: const Text('Active'),
                  value: active,
                  onChanged: (value) {
                    setState(() {
                      active = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _submitForm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Green for Add Item
                  ),
                  child: const Text('Update Promotion'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Red for Cancel
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
