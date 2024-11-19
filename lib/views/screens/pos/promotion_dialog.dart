import 'package:flutter/material.dart';
import 'package:coffeeapp/models/promotion_model.dart';

class PromotionScreen extends StatefulWidget {
  final Function(String?) onPromotionSelected;

  const PromotionScreen({super.key, required this.onPromotionSelected});

  @override
  // ignore: library_private_types_in_public_api
  _PromotionScreenState createState() => _PromotionScreenState();
}

class _PromotionScreenState extends State<PromotionScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _foundPromotions = [];

  @override
  void initState() {
    super.initState();
    _searchPromotions(''); // Fetch all promotions initially
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchPromotions(String query) async {
    try {
      List<dynamic> promotions = await searchPromotionscustomer(query);
      setState(() {
        _foundPromotions = promotions;
      });
    } catch (e) {
      // Handle error, e.g., show a snackbar
      // ignore: avoid_print
      print('Error searching promotions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn Mã Giảm Giá'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _searchPromotions(value);
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm mã giảm giá...',
                suffixIcon: IconButton(
                  onPressed: () => _searchPromotions(_searchController.text),
                  icon: const Icon(Icons.search),
                ),
              ),
            ),
          ),
          Expanded(
            child: _foundPromotions.isEmpty
                ? const Center(child: Text('Không tìm thấy mã giảm giá.'))
                : ListView.builder(
                    itemCount: _foundPromotions.length,
                    itemBuilder: (context, index) {
                      final promotion = _foundPromotions[index];
                      return ListTile(
                        title: Text(promotion['name'] ?? 'No Code'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Mô tả: ${promotion['description'] ?? 'No Description'}'),
                            Text(
                                'Giảm giá: ${promotion['discount_type'] == 'percentage' ? '${promotion['discount_value']}%' : '\$${promotion['discount_value']}'}'),
                            Text(
                                'Áp dụng cho đơn hàng từ: ${promotion['min_order_value'] ?? '0.00'} VNĐ'),
                          ],
                        ),
                        onTap: () {
                          widget.onPromotionSelected(promotion['name'] ?? '');
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
