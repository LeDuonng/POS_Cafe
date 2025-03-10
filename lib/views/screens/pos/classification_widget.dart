import 'package:coffeeapp/models/menu_model.dart';
import 'package:flutter/material.dart';

class ClassificationScreen extends StatefulWidget {
  final Function(String) onCategorySelected;

  const ClassificationScreen({super.key, required this.onCategorySelected});

  @override
  // ignore: library_private_types_in_public_api
  _ClassificationScreenState createState() => _ClassificationScreenState();
}

class _ClassificationScreenState extends State<ClassificationScreen> {
  late Future<List<dynamic>> futureToppings;
  String selectedCategory = 'Tất cả';

  @override
  void initState() {
    super.initState();
    futureToppings = fetchToppingDistinct();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: futureToppings,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không có dữ liệu'));
        } else {
          return Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(15.0),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedCategory == 'Tất cả'
                                    ? const Color.fromARGB(255, 217, 214, 214)
                                    : null,
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedCategory = 'Tất cả';
                                });
                                widget.onCategorySelected('Tất cả');
                              },
                              child: const Text('Tất cả'),
                            ),
                            Positioned(
                              right: -5,
                              top: -10, // Adjusted to prevent clipping
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red,
                                child: Text(
                                  '${snapshot.data!.fold<int>(0, (sum, item) => sum + (item['total_items'] as int))}',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...snapshot.data!.map((item) {
                        return Container(
                          margin: const EdgeInsets.all(15.0),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: selectedCategory ==
                                          (item['category'] ?? 'Không có')
                                      ? const Color.fromARGB(255, 217, 214, 214)
                                      : null,
                                ),
                                onPressed: () {
                                  setState(() {
                                    selectedCategory =
                                        item['category'] ?? 'Không có';
                                  });
                                  widget.onCategorySelected(
                                      item['category'] ?? 'Không có');
                                },
                                child: Text(item['category'] ?? 'Không có'),
                              ),
                              Positioned(
                                right: -5,
                                top: -10, // Adjusted to prevent clipping
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.red,
                                  child: Text(
                                    '${item['total_items']}',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                        // ignore: unnecessary_to_list_in_spreads
                      }).toList(),
                    ],
                  ),
                ),
              ),
              // Spacer to push the search button to the right
              const SizedBox(
                  width: 10), // Add spacing to push the search bar to the right
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm...',
                    suffixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onChanged: (value) {
                    // Xử lý tìm kiếm khi người dùng nhấn enter
                    widget.onCategorySelected(value);

                    // ignore: avoid_print
                    print('Tìm kiếm: $value');
                  },
                ),
              )
            ],
          );
        }
      },
    );
  }
}
