import 'package:coffeeapp/models/promotion_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PromotionScreen extends StatefulWidget {
  const PromotionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PromotionScreenState createState() => _PromotionScreenState();
}

class _PromotionScreenState extends State<PromotionScreen> {
  late Future<List<dynamic>> _promotionsFuture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _promotionsFuture = PromotionController.fetchPromotions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshPromotions() async {
    setState(() {
      _promotionsFuture = PromotionController.fetchPromotions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Khuyến mãi'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm...',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      if (_searchController.text.isEmpty) {
                        _promotionsFuture =
                            PromotionController.fetchPromotions();
                      } else {
                        _promotionsFuture =
                            PromotionController.searchPromotions(
                                _searchController.text);
                      }
                    });
                  },
                  icon: const Icon(Icons.search),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  if (value.isEmpty) {
                    _promotionsFuture = PromotionController.fetchPromotions();
                  } else {
                    _promotionsFuture =
                        PromotionController.searchPromotions(value);
                  }
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _promotionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Không có khuyến mãi.'));
                } else {
                  return RefreshIndicator(
                    onRefresh: _refreshPromotions,
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final promotion =
                            Promotion.fromJson(snapshot.data![index]);
                        return ListTile(
                          title: Text(promotion.name.toString()),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  '${promotion.discountType == 'percentage' ? '${double.parse(promotion.discountValue.toStringAsFixed(0))}%' : '${double.parse(promotion.discountValue.toStringAsFixed(0))} VND'} off'),
                              Text(
                                  'Giá trị đơn hàng tối thiểu: ${promotion.minOrderValue.toStringAsFixed(0)} VND'),
                              Text(
                                  'Từ ${DateFormat('dd/MM/yyyy').format(promotion.startDate!)} đến ${DateFormat('dd/MM/yyyy').format(promotion.endDate!)}'),
                              Text(
                                  'Trạng thái: ${promotion.active ? 'Đã kích hoạt' : 'Chưa kích hoạt'}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _showEditPromotionDialog(context, promotion);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _showDeleteConfirmationDialog(
                                      context, promotion);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddPromotionDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddPromotionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddEditPromotionDialog(
          onSave: (promotion) async {
            try {
              await PromotionController.addPromotion(promotion.toJson());
              _refreshPromotions();
              // ignore: use_build_context_synchronously
              Navigator.pop(context); // Close the dialog
            } catch (e) {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          },
        );
      },
    );
  }

  void _showEditPromotionDialog(BuildContext context, Promotion promotion) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddEditPromotionDialog(
          promotion: promotion,
          onSave: (updatedPromotion) async {
            try {
              await PromotionController.updatePromotion(
                  updatedPromotion.id, updatedPromotion.toJson());
              _refreshPromotions();
              // ignore: use_build_context_synchronously
              Navigator.pop(context); // Close the dialog
            } catch (e) {
              // Handle error
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, Promotion promotion) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text(
              'Bạn có chắc chắn muốn xóa chương trình khuyến mãi này?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                await PromotionController.deletePromotion(promotion.id);
                _refreshPromotions();
                // ignore: use_build_context_synchronously
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }
}

class AddEditPromotionDialog extends StatefulWidget {
  final Promotion? promotion;
  final Function(Promotion) onSave;

  const AddEditPromotionDialog({
    super.key,
    this.promotion,
    required this.onSave,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AddEditPromotionDialogState createState() => _AddEditPromotionDialogState();
}

class _AddEditPromotionDialogState extends State<AddEditPromotionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _discountTypeController = TextEditingController();
  final _discountValueController = TextEditingController();
  final _minOrderValueController = TextEditingController();
  final _codeLimitController = TextEditingController();
  final _usageLimitController = TextEditingController();
  bool _active = true;

  @override
  void initState() {
    super.initState();
    if (widget.promotion != null) {
      _nameController.text = widget.promotion!.name;
      _descriptionController.text = widget.promotion!.description;
      _startDateController.text =
          DateFormat('yyyy-MM-dd').format(widget.promotion!.startDate!);
      _endDateController.text =
          DateFormat('yyyy-MM-dd').format(widget.promotion!.endDate!);
      _discountTypeController.text = widget.promotion!.discountType;
      _discountValueController.text =
          widget.promotion!.discountValue.toString();
      _minOrderValueController.text =
          widget.promotion!.minOrderValue.toString();
      _codeLimitController.text = widget.promotion!.codeLimit.toString();
      _usageLimitController.text = widget.promotion!.usageLimit.toString();
      _active = widget.promotion!.active;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _discountTypeController.dispose();
    _discountValueController.dispose();
    _minOrderValueController.dispose();
    _codeLimitController.dispose();
    _usageLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.promotion != null
          ? 'Chỉnh sửa Khuyến mãi'
          : 'Thêm Khuyến mãi'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên khuyến mãi';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
              ),
              TextFormField(
                controller: _startDateController,
                decoration: const InputDecoration(labelText: 'Ngày bắt đầu'),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                    setState(() {
                      _startDateController.text = formattedDate;
                    });
                  }
                },
              ),
              TextFormField(
                controller: _endDateController,
                decoration: const InputDecoration(labelText: 'Ngày kết thúc'),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                    setState(() {
                      _endDateController.text = formattedDate;
                    });
                  }
                },
              ),
              DropdownButtonFormField<String>(
                value: _discountTypeController.text.isNotEmpty
                    ? _discountTypeController.text
                    : null,
                decoration: const InputDecoration(labelText: 'Loại giảm giá'),
                items: const [
                  DropdownMenuItem(
                    value: 'percentage',
                    child: Text('Phần trăm'),
                  ),
                  DropdownMenuItem(
                    value: 'fixed_amount',
                    child: Text('Số tiền cố định'),
                  ),
                ],
                onChanged: (value) {
                  _discountTypeController.text = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn loại giảm giá';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _discountValueController,
                decoration:
                    const InputDecoration(labelText: 'Giá trị giảm giá'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập giá trị giảm giá';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _minOrderValueController,
                decoration: const InputDecoration(
                    labelText: 'Giá trị đơn hàng tối thiểu'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _codeLimitController,
                decoration:
                    const InputDecoration(labelText: 'Giới hạn số lượng mã'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _usageLimitController,
                decoration:
                    const InputDecoration(labelText: 'Giới hạn số lần sử dụng'),
                keyboardType: TextInputType.number,
              ),
              SwitchListTile(
                title: const Text('Kích hoạt'),
                value: _active,
                onChanged: (value) {
                  setState(() {
                    _active = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final promotion = Promotion(
                id: widget.promotion?.id ?? 0,
                name: _nameController.text,
                description: _descriptionController.text,
                startDate: DateTime.parse(_startDateController.text),
                endDate: DateTime.parse(_endDateController.text),
                discountType: _discountTypeController.text,
                discountValue: double.parse(_discountValueController.text),
                minOrderValue: double.parse(
                    _minOrderValueController.text.isEmpty
                        ? '0'
                        : _minOrderValueController.text),
                codeLimit: int.parse(_codeLimitController.text.isEmpty
                    ? '0'
                    : _codeLimitController.text),
                usageLimit: int.parse(_usageLimitController.text.isEmpty
                    ? '0'
                    : _usageLimitController.text),
                active: _active,
              );
              widget.onSave(promotion);
            }
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}
