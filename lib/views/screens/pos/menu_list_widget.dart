// menu_list_widget.dart
import 'package:coffeeapp/views/screens/pos/classification_widget.dart';
import 'package:flutter/material.dart';

class MenuListWidget extends StatelessWidget {
  final Function(Map<String, dynamic>) onAddToCart;
  final Future<List<dynamic>> menuList;
  final String selectedCategory;
  final Function(String) updateMenuList;
  final Future<List<dynamic>> discountedProducts;

  const MenuListWidget({
    super.key,
    required this.onAddToCart,
    required this.menuList,
    required this.selectedCategory,
    required this.updateMenuList,
    required this.discountedProducts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 233, 229, 229),
      child: Column(
        children: [
          // Classification (Milk Tea, Iced Coffee, ...)
          ClassificationScreen(onCategorySelected: updateMenuList),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: Future.wait([menuList, discountedProducts]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Không có sản phẩm'));
                } else {
                  final items = snapshot.data![0];
                  final discounts = snapshot.data![1];
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = 2; // Default to 2 columns
                      if (constraints.maxWidth > 1200) {
                        crossAxisCount = 4; // 4 columns for large screens
                      } else if (constraints.maxWidth > 800) {
                        crossAxisCount = 3; // 3 columns for medium screens
                      }
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final discount = discounts.firstWhere(
                              (d) => d['id'] == item['id'],
                              orElse: () => null);
                          return GestureDetector(
                            onTap: () {
                              try {
                                onAddToCart({
                                  'id': item['id'],
                                  'name': item['name'],
                                  'price':
                                      double.parse(item['price'].toString()),
                                  'image': item['image'],
                                  'quantity': 1,
                                });
                              } catch (e) {
                                // Handle error if item information is incomplete
                                // ignore: avoid_print
                                print('Error adding to cart: $e');
                              }
                            },
                            child: Card(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        Image.asset(
                                          'assets/menu/${item['name']}.png',
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            try {
                                              return Image.network(
                                                '${item['image']}',
                                                height: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Image.asset(
                                                    'assets/menu/error.png',
                                                    height: double.infinity,
                                                    fit: BoxFit.cover,
                                                  );
                                                },
                                              );
                                            } catch (e) {
                                              return Image.asset(
                                                'assets/menu/error.png',
                                                height: double.infinity,
                                                fit: BoxFit.cover,
                                              );
                                            }
                                          },
                                        ),
                                        if (discount != null)
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Container(
                                              color: Colors.red,
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Text(
                                                discount['discount_type'] ==
                                                        'percentage'
                                                    ? ' - ${discount['discount_value']}%'
                                                    : ' - ${discount['discount_value']} VNĐ',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(item['name'] ?? 'Không có'),
                                  ),
                                  if (discount != null)
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            'Giá: ${item['price'] != null ? double.parse(item['price'].toString()) : 'Không có'} VNĐ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          ),
                                          Text(
                                            'Giá mới: ${discount['discount_type'] == 'percentage' ? (double.parse(item['price'].toString()) * (1 - double.parse(discount['discount_value'].toString()) / 100)) : (double.parse(item['price'].toString()) - double.parse(discount['discount_value'].toString()))} VNĐ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Giá: ${item['price'] != null ? double.parse(item['price'].toString()) : 'Không có'} VNĐ',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
