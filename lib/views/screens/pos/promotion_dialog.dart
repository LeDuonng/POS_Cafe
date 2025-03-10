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
      print('Lỗi khi tìm kiếm mã giảm giá: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chọn Mã Giảm Giá',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
                filled: true,
                fillColor: Colors.lightBlue[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
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
                      if (promotion['code_limit'] == 0 ||
                          promotion['usage_limit'] == 0) {
                        return const SizedBox
                            .shrink(); // Don't display this promotion
                      }
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 4,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          title: Text(
                            promotion['name'] ?? 'No Code',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8.0),
                              Text(
                                  'Mô tả: ${promotion['description'] ?? 'No Description'}'),
                              const SizedBox(height: 4.0),
                              Text(
                                'Giảm giá: ${promotion['discount_type'] == 'percentage' ? '${promotion['discount_value']}% VNĐ' : ' ${promotion['discount_value']} VNĐ'}',
                                style: const TextStyle(color: Colors.green),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                  'Áp dụng cho đơn hàng từ: ${promotion['min_order_value'] ?? '0.00'} VNĐ'),
                            ],
                          ),
                          onTap: () {
                            widget.onPromotionSelected(
                                promotion['name'] ?? 'Không có');
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
