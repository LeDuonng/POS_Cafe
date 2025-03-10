import 'package:flutter/material.dart';

class CartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final Function(Map<String, dynamic>) onEdit;
  final Function(int) onDelete;
  final Future<List<dynamic>> discountedProducts;

  const CartWidget({
    super.key,
    required this.cartItems,
    required this.onEdit,
    required this.onDelete,
    required this.discountedProducts,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: discountedProducts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Error loading discounted products');
        } else {
          final discounts = snapshot.data ?? [];
          return Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                final discount = discounts.firstWhere(
                  (discount) => discount['id'] == item['id'],
                  orElse: () => null,
                );
                return Column(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                      child: ListTile(
                        title: Text(
                          item['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (discount != null) ...[
                              Text(
                                'Giá cũ: ${item['price'].toString()} VNĐ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              Text(
                                'Giá mới: ${discount['discount_type'] == 'percentage' ? (double.parse(item['price'].toString()) * (1 - double.parse(discount['discount_value'].toString()) / 100)) : (double.parse(item['price'].toString()) - double.parse(discount['discount_value'].toString()))} VNĐ',
                              ),
                            ] else ...[
                              Text('Giá: ${item['price'].toString()} VNĐ'),
                            ],
                            Text('Số lượng: ${item['quantity']}'),
                            Text(
                                'Size: ${item.containsKey('size') ? item['size'] : 'M'}'),
                            Text(
                                'Đường: ${item.containsKey('sugar') ? item['sugar'] : 100}%'),
                            if (item.containsKey('toppings') &&
                                item['toppings'].isNotEmpty)
                              Text(
                                  'Topping: ${item['toppings'].map((topping) => '$topping').join(', ')}'),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => onEdit(item),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => onDelete(index),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        }
      },
    );
  }
}
