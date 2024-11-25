import 'package:coffeeapp/models/orders_model.dart' as controller;
import 'package:coffeeapp/controllers/orders_controller.dart';
import 'package:coffeeapp/models/staff_model.dart';
import 'package:coffeeapp/models/tables_model.dart';
import 'package:coffeeapp/models/users_model.dart';
import 'package:flutter/material.dart';
import '../../../responsive.dart'; // Import the Responsive widget

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
    ordersList = controller.searchOrders();
  }

  Future<void> _refreshOrdersList([String? orderId]) async {
    var temp = controller.searchOrders(orderId);
    setState(() {
      ordersList = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý đơn hàng'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 300,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm đơn hàng...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                    _refreshOrdersList(searchText);
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
                builder: (context) => const AddOrderScreen(),
              );
              _refreshOrdersList();
            },
          ),
        ],
      ),
      body: Responsive(
        mobile: _buildOrdersList(context),
        tablet: _buildOrdersList(context),
        desktop: _buildOrdersList(context),
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: ordersList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không có dữ liệu'));
        } else {
          return LayoutBuilder(
            builder: (context, constraints) {
              double totalWidth = constraints.maxWidth;
              double columnWidth = totalWidth / 8; // 8 là tổng số cột hiện có

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
                          'Mã đơn hàng',
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
                          'Bàn',
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
                          'Khách hàng',
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
                          'Nhân viên phục vụ',
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
                          'Trạng thái',
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
                          'Mô tả',
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
                          'Hành động',
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
                        DataCell(Text(snapshot.data![index]['id']?.toString() ??
                            'Không có')),
                        DataCell(
                          FutureBuilder<String>(
                            future: snapshot.data![index]['table_id'] != null
                                ? getNameTableById(int.parse(snapshot
                                    .data![index]['table_id']
                                    .toString()))
                                : Future.value('Không có'),
                            builder: (context, nameSnapshot) {
                              if (nameSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (nameSnapshot.hasError) {
                                return Text('Lỗi: ${nameSnapshot.error}');
                              } else {
                                return Text(nameSnapshot.data ?? 'Không có');
                              }
                            },
                          ),
                        ),
                        DataCell(
                          FutureBuilder<String>(
                            future: snapshot.data![index]['customer_id'] != null
                                ? getNameUserById(int.parse(snapshot
                                    .data![index]['customer_id']
                                    .toString()))
                                : Future.value('Không có'),
                            builder: (context, nameSnapshot) {
                              if (nameSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (nameSnapshot.hasError) {
                                return Text('Lỗi: ${nameSnapshot.error}');
                              } else {
                                return Text(nameSnapshot.data ?? 'Không có');
                              }
                            },
                          ),
                        ),
                        DataCell(FutureBuilder<String>(
                          future: getNameStaffById(int.parse(
                              snapshot.data![index]['staff_id'].toString())),
                          builder: (context, nameSnapshot) {
                            if (nameSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (nameSnapshot.hasError) {
                              return Text('Lỗi: ${nameSnapshot.error}');
                            } else {
                              return Text(nameSnapshot.data ?? 'Không có');
                            }
                          },
                        )),
                        DataCell(Text(
                          snapshot.data![index]['status'] == 'received'
                              ? 'Đã nhận đơn'
                              : snapshot.data![index]['status'] == 'preparing'
                                  ? 'Đang chuẩn bị'
                                  : 'Đã hoàn thành',
                        )),
                        DataCell(Text(snapshot.data![index]['description'] ??
                            'Khôngg có mô tả')),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (context) => EditOrderScreen(
                                      order: snapshot.data![index],
                                      orderItem: {
                                        'id': snapshot.data![index]['id'],
                                        'table_id': snapshot.data![index]
                                            ['table_id'],
                                        'customer_id': snapshot.data![index]
                                            ['customer_id'],
                                        'staff_id': snapshot.data![index]
                                            ['staff_id'],
                                        'order_date': snapshot.data![index]
                                            ['order_date'],
                                        'status': snapshot.data![index]
                                            ['status'],
                                      },
                                    ),
                                  );
                                  _refreshOrdersList();
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
                                        title: const Text('Xác nhận xoá'),
                                        content: const Text(
                                            'Bạn có chắc chắn muốn xoá đơn hàng này không?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Huỷ'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                try {
                                                  deleteOrder(snapshot
                                                      .data![index]['id']);
                                                  snapshot.data!
                                                      .removeAt(index);
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content:
                                                            Text('Lỗi: $e')),
                                                  );
                                                }
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Xoá'),
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

class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddOrderScreenState createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  late int tableId, customerId, staffId;
  late String status, description;
  late DateTime orderDate;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      addOrder(
        tableId: tableId,
        customerId: customerId,
        staffId: staffId,
        orderDate: orderDate,
        status: status,
        description: description,
      );
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
                  decoration: const InputDecoration(labelText: 'Mã bàn'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mã bàn';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    tableId = int.parse(value!);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Mã khách hàng'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mã khách hàng';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    customerId = int.parse(value!);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Mã nhân viên'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mã nhân viên';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    staffId = int.parse(value!);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Ngày đặt hàng'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn ngày đặt hàng';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    orderDate = DateTime.parse(value!);
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Trạng thái'),
                  value: 'received',
                  items: const [
                    DropdownMenuItem(
                      value: 'received',
                      child: Text('Đã nhận đơn'),
                    ),
                    DropdownMenuItem(
                      value: 'preparing',
                      child: Text('Đang chuẩn bị'),
                    ),
                    DropdownMenuItem(
                      value: 'paid',
                      child: Text('Đã hoàn thành'),
                    ),
                  ],
                  onChanged: (value) {
                    status = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn trạng thái';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  onSaved: (value) {
                    description = value!;
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
                  child: const Text('Thêm đơn hàng'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Red for Cancel
                  ),
                  child: const Text('Hủy'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EditOrderScreen extends StatefulWidget {
  final Map<String, dynamic> orderItem;
  final dynamic order;

  const EditOrderScreen({
    super.key,
    required this.orderItem,
    required this.order,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EditOrderScreenState createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  late int tableId, customerId, staffId;
  late String status, description;
  late DateTime orderDate;

  @override
  void initState() {
    super.initState();
    tableId = widget.orderItem['table_id'] ?? 0;
    staffId = widget.orderItem['staff_id'] ?? 0;

    orderDate = widget.orderItem['order_date'] != null
        ? DateTime.parse(widget.orderItem['order_date'])
        : DateTime.now();

    description = widget.order['description'] ?? '';
    status = widget.orderItem['status'] ?? 'received';
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      updateOrder(
        id: widget.orderItem['id'],
        tableId: tableId,
        customerId: customerId,
        staffId: staffId,
        orderDate: orderDate,
        status: status,
        description: description,
      );
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
                  initialValue: widget.orderItem['id'].toString(),
                  decoration: const InputDecoration(labelText: 'Mã đơn hàng'),
                  readOnly: true,
                ),
                TextFormField(
                  initialValue: tableId.toString(),
                  decoration: const InputDecoration(labelText: 'Mã bàn'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mã bàn';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    tableId = int.parse(value!);
                  },
                ),
                TextFormField(
                  initialValue: customerId.toString(),
                  decoration: const InputDecoration(labelText: 'Mã khách hàng'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mã khách hàng';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    customerId = int.parse(value!);
                  },
                ),
                TextFormField(
                  initialValue: staffId.toString(),
                  decoration: const InputDecoration(labelText: 'Mã nhân viên'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mã nhân viên';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    staffId = int.parse(value!);
                  },
                ),
                TextFormField(
                  initialValue: orderDate.toString(),
                  decoration: const InputDecoration(labelText: 'Ngày đặt hàng'),
                  readOnly: true,
                ),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(labelText: 'Trạng thái'),
                  items: const [
                    DropdownMenuItem(
                      value: 'received',
                      child: Text('Đã nhận đơn'),
                    ),
                    DropdownMenuItem(
                      value: 'preparing',
                      child: Text('Đang chuẩn bị'),
                    ),
                    DropdownMenuItem(
                      value: 'paid',
                      child: Text('Đã hoàn thành'),
                    ),
                  ],
                  onChanged: (value) {
                    status = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn trạng thái';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: description,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  onSaved: (value) {
                    description = value!;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _submitForm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Green for Save
                  ),
                  child: const Text('Lưu thay đổi'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Red for Cancel
                  ),
                  child: const Text('Hủy'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
