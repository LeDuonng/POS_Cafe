import 'package:coffeeapp/models/promotion_model.dart';
import 'package:coffeeapp/views/widgets/nofication.dart';
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
        title: const Text('Quản lý mã giảm giá'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 300,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm mã giảm giá...',
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
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không có dữ liệu'));
        } else {
          return LayoutBuilder(
            builder: (context, constraints) {
              double totalWidth = constraints.maxWidth;
              double columnWidth = totalWidth / 12; // 8 là tổng số cột hiện có

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
                          'Mã giảm giá',
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
                          'Kiểu giảm giá',
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
                          'Giá trị giảm giá',
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
                          'Ngày bắt đầu',
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
                          'Ngày kết thúc',
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
                          'Đơn hàng từ',
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
                          'Số lượng mã',
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
                          'Số lần sử dụng',
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
                        DataCell(Text(snapshot.data![index]['name'] ?? '')),
                        DataCell(
                            Text(snapshot.data![index]['description'] ?? '')),
                        DataCell(Text(snapshot.data![index]['discount_type'] ==
                                'percentage'
                            ? 'Phần trăm'
                            : 'Tiền mặt')),
                        DataCell(Text(snapshot.data![index]['discount_type'] ==
                                'percentage'
                            ? '${snapshot.data![index]['discount_value']} %'
                            : '${snapshot.data![index]['discount_value']} VNĐ')),
                        DataCell(
                            Text(snapshot.data![index]['start_date'] ?? '')),
                        DataCell(Text(snapshot.data![index]['end_date'] ?? '')),
                        DataCell(Text(
                            '${snapshot.data![index]['min_order_value']} VNĐ')),
                        DataCell(Text(
                            snapshot.data![index]['code_limit'].toString())),
                        DataCell(Text(
                            snapshot.data![index]['usage_limit'].toString())),
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
                                        'description': snapshot.data![index]
                                            ['description'],
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
                                  setState(() {
                                    promotionsList = fetchPromotions();
                                    setState(() {
                                      promotionsList = fetchPromotions();
                                    });
                                  });
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
                                            'Bạn có chắc chắn muốn xoá mã giảm giá này không?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Huỷ'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              try {
                                                deletePromotion(snapshot
                                                    .data![index]['id']);
                                                snapshot.data!.removeAt(index);
                                                ToastNotification.showToast(
                                                    message:
                                                        'Xoá mã giảm giá thành công');
                                              } catch (e) {
                                                ToastNotification.showToast(
                                                    message:
                                                        'Lỗi xoá mã giảm giá: $e');
                                              }
                                              Navigator.of(context).pop();
                                              setState(() {
                                                promotionsList =
                                                    fetchPromotions();
                                                setState(() {
                                                  promotionsList =
                                                      fetchPromotions();
                                                });
                                              });
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

class AddPromotionScreen extends StatefulWidget {
  const AddPromotionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddPromotionScreenState createState() => _AddPromotionScreenState();
}

class _AddPromotionScreenState extends State<AddPromotionScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name, discountType, description;
  late double discountValue, minOrderValue;
  late DateTime startDate = DateTime.now(), endDate = DateTime.now();
  late int codeLimit, usageLimit;
  late bool active = false;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      addPromotion(
        {
          'name': name,
          'discount_type': discountType,
          'discount_value': discountValue,
          'start_date': DateFormat('yyyy-MM-dd').format(startDate),
          'end_date': DateFormat('yyyy-MM-dd').format(endDate),
          'min_order_value': minOrderValue,
          'code_limit': codeLimit,
          'usage_limit': usageLimit,
          'active': active,
          'description': description,
        },
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
                  decoration:
                      const InputDecoration(labelText: 'Tên mã giảm giá'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên mã giảm giá';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      name = value;
                    }
                  },
                ),
                //description
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mô tả';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    description = value!;
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Kiểu giảm giá'),
                  value: 'percentage',
                  items: const [
                    DropdownMenuItem(
                      value: 'percentage',
                      child: Text('Phần trăm'),
                    ),
                    DropdownMenuItem(
                      value: 'fixed_amount',
                      child: Text('Tiền mặt'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      discountType = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn kiểu giảm giá';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    discountType = value!;
                  },
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Giá trị giảm giá'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập giá trị giảm giá';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    discountValue = double.parse(value!);
                  },
                ),
                TextFormField(
                  controller: TextEditingController(
                    // ignore: unnecessary_null_comparison
                    text: startDate == null
                        ? DateFormat('yyyy-MM-dd').format(DateTime.now())
                        : DateFormat('yyyy-MM-dd').format(startDate),
                  ),
                  decoration: const InputDecoration(labelText: 'Ngày bắt đầu'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
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
                    // ignore: unnecessary_null_comparison
                    if (startDate == null) {
                      return 'Vui lòng chọn ngày bắt đầu';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: TextEditingController(
                    // ignore: unnecessary_null_comparison
                    text: endDate == null
                        ? DateFormat('yyyy-MM-dd').format(DateTime.now())
                        : DateFormat('yyyy-MM-dd').format(endDate),
                  ),
                  decoration: const InputDecoration(labelText: 'Ngày kết thúc'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
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
                    // ignore: unnecessary_null_comparison
                    if (endDate == null) {
                      return 'Vui lòng chọn ngày kết thúc';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Giá trị đơn hàng tối thiểu'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập giá trị đơn hàng tối thiểu';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    minOrderValue = double.parse(value!);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Số lượng mã'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số lượng mã';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    codeLimit = int.parse(value!);
                  },
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Số lần sử dụng'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số lần sử dụng';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    usageLimit = int.parse(value!);
                  },
                ),
                SwitchListTile(
                  title: const Text('Kích hoạt'),
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
                  child: const Text('Thêm mã giảm giá'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Red for Cancel
                  ),
                  child: const Text('Huỷ'),
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
  late String name, discountType, discountValue, minOrderValue, description;
  late DateTime startDate, endDate;
  late int codeLimit, usageLimit;
  late bool active;

  @override
  void initState() {
    super.initState();
    name = widget.promotionItem['name'] ?? '';
    discountType = widget.promotionItem['discount_type'] ?? 'percentage';
    discountValue = widget.promotionItem['discount_value']?.toString() ?? '0';
    startDate = widget.promotionItem['start_date'] != null
        ? DateTime.parse(widget.promotionItem['start_date'])
        : DateTime.now();
    endDate = widget.promotionItem['end_date'] != null
        ? DateTime.parse(widget.promotionItem['end_date'])
        : DateTime.now();
    minOrderValue = widget.promotionItem['min_order_value'] ?? 0.0;
    codeLimit = widget.promotionItem['code_limit'] ?? 0;
    usageLimit = widget.promotionItem['usage_limit'] ?? 0;
    active = widget.promotionItem['active'] == 1 ? true : false;
    description = widget.promotionItem['description'] ?? '';
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        updatePromotion(
          widget.promotion['id'],
          {
            'name': name,
            'discount_type': discountType,
            'discount_value': discountValue,
            'start_date': DateFormat('yyyy-MM-dd').format(startDate),
            'end_date': DateFormat('yyyy-MM-dd').format(endDate),
            'min_order_value': minOrderValue,
            'code_limit': codeLimit,
            'usage_limit': usageLimit,
            'active': active,
            'description': description,
          },
        );
        Navigator.pop(context);
        ToastNotification.showToast(message: 'Cập nhật mã giảm giá thành công');
      } catch (e) {
        ToastNotification.showToast(
            message: 'Cập nhật mã giảm giá thất bại: $e');
      }
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
                  decoration:
                      const InputDecoration(labelText: 'Tên mã giảm giá'),
                  initialValue: name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên mã giảm giá';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      name = value;
                    }
                  },
                ),
                //description
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  initialValue: description,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mô tả';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    description = value!;
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Kiểu giảm giá'),
                  value: discountType,
                  items: const [
                    DropdownMenuItem(
                      value: 'percentage',
                      child: Text('Phần trăm'),
                    ),
                    DropdownMenuItem(
                      value: 'fixed_amount',
                      child: Text('Tiền mặt'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      discountType = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn kiểu giảm giá';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    discountType = value!;
                  },
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Giá trị giảm giá'),
                  initialValue: discountValue.toString(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập giá trị giảm giá';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    discountValue = value.toString();
                  },
                ),
                TextFormField(
                  controller: TextEditingController(
                      text: DateFormat('yyyy-MM-dd').format(startDate)),
                  decoration: const InputDecoration(labelText: 'Ngày bắt đầu'),
                  readOnly: true,
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
                      TextEditingController(
                              text: DateFormat('yyyy-MM-dd').format(startDate))
                          .text = DateFormat('yyyy-MM-dd').format(startDate);
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn ngày bắt đầu';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    startDate = DateTime.parse(value!);
                  },
                ),
                TextFormField(
                  controller: TextEditingController(
                      text: DateFormat('yyyy-MM-dd').format(endDate)),
                  decoration: const InputDecoration(labelText: 'Ngày kết thúc'),
                  readOnly: true,
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
                      TextEditingController(
                              text: DateFormat('yyyy-MM-dd').format(endDate))
                          .text = DateFormat('yyyy-MM-dd').format(endDate);
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn ngày kết thúc';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    endDate = DateTime.parse(value!);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Giá trị đơn hàng tối thiểu'),
                  initialValue: minOrderValue.toString(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập giá trị đơn hàng tối thiểu';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    minOrderValue = value.toString();
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Số lượng mã'),
                  initialValue: codeLimit.toString(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số lượng mã';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    codeLimit = int.parse(value!);
                  },
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Số lần sử dụng'),
                  initialValue: usageLimit.toString(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số lần sử dụng';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    usageLimit = int.parse(value!);
                  },
                ),
                SwitchListTile(
                  title: const Text('Kích hoạt'),
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
                    setState(() {
                      promotionsList = fetchPromotions();
                      setState(() {
                        promotionsList = fetchPromotions();
                      });
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Green for Add Item
                  ),
                  child: const Text('Cập nhật'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      promotionsList = fetchPromotions();
                      setState(() {
                        promotionsList = fetchPromotions();
                      });
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Red for Cancel
                  ),
                  child: const Text('Huỷ'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
