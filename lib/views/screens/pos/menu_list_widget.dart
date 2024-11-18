// menu_list_widget.dart
import 'package:coffeeapp/views/screens/pos/classification_widget.dart';
import 'package:flutter/material.dart';

class MenuListWidget extends StatelessWidget {
  final Function(Map<String, dynamic>) onAddToCart;
  final Future<List<dynamic>> menuList;
  final String selectedCategory;
  final Function(String) updateMenuList;

  const MenuListWidget({
    super.key,
    required this.onAddToCart,
    required this.menuList,
    required this.selectedCategory,
    required this.updateMenuList,
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
              future: menuList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Không có sản phẩm'));
                } else {
                  final items = snapshot.data!;
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
                                    child: Image.asset(
                                      'assets/menu/${item['name']}.png',
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/menu/error.png',
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(item['name'] ?? 'Không có'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Giá: ${item['price'] != null ? double.parse(item['price'].toString()) : 'N/A'} VNĐ',
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
