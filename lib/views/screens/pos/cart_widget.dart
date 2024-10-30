import 'package:flutter/material.dart';

class CartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final Function(Map<String, dynamic>) onEdit;
  final Function(int) onDelete;

  const CartWidget({
    super.key,
    required this.cartItems,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final item = cartItems[index];
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
                      Text('Giá: ${item['price'].toString()} VNĐ'),
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
}
