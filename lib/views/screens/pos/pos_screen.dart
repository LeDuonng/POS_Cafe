import 'package:coffeeapp/models/config_model.dart';
import 'package:coffeeapp/models/menu_model.dart';
import 'package:coffeeapp/models/promotion_model.dart';
import 'package:coffeeapp/models/tables_model.dart';
import 'package:coffeeapp/responsive.dart';
import 'package:coffeeapp/views/screens/pos/customization_item_dialog.dart';
import 'package:coffeeapp/views/screens/pos/find_customer_dialog.dart';
import 'package:coffeeapp/views/screens/pos/menu_list_widget.dart';
import 'package:coffeeapp/views/screens/pos/order_type_dialog.dart';
import 'package:coffeeapp/views/screens/pos/payment_confirmation_dialog.dart';
import 'package:coffeeapp/views/screens/pos/promotion_dialog.dart';
import 'package:coffeeapp/views/screens/pos/cart_widget.dart';
import 'package:coffeeapp/views/screens/pos/surcharge_dialog.dart';
import 'package:coffeeapp/views/widgets/nofication.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class POSScreen extends StatefulWidget {
  POSScreen({super.key, required this.tableId, required this.userID});
  String? tableId;
  final String? userID;

  @override
  // ignore: library_private_types_in_public_api
  _POSScreenState createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  late Future<List<dynamic>> menuList;
  String selectedCategory = 'Tất cả';
  String? customerID;
  String? customerName;
  final String _selectedPaymentMethod = 'cash';
  String? tableName;
  bool hasTaxMode = false;
  String shopName = 'LEDUONG COFFEE SHOP';
  String selectedOrderType = 'Mang đi';
  String? _selectedPromotionCode;
  double? _promotionValue;
  String? _promotionType;
  double? _promotionMinValue;
  final List<Map<String, dynamic>> _cartItems = [];
  double _totalPrice = 0.0;
  double _tax = 0.0;
  double _surcharge = 0.0; // Thêm biến phụ thu
  String _surchargeReason = ""; // Biến để lưu lý do phụ thu
  bool _showCart = false; // State to control cart visibility
  bool _showMenu = true; // State to control menu visibility
  final GlobalKey _fabKey = GlobalKey(); // Use GlobalKey without type argument
  final Future<List<dynamic>> discountedProducts = fetchDiscountedProducts();
  final configData = fetchConfig();

  @override
  void initState() {
    super.initState();
    _initializeAsync();
    menuList = fetchMenuCategory(); // Fetch all menus initially
  }

  Future<void> _initializeAsync() async {
    final configData = await fetchConfig();
    setState(() {
      hasTaxMode = configData.any(
        (config) => config['key'] == 'tax' && config['value'] == 'true',
      );
      shopName = configData.any((config) => config['key'] == 'shop_name')
          ? configData
              .firstWhere((config) => config['key'] == 'shop_name')['value']
          : 'LEDUONG COFFEE SHOP';
    });
  }

  Future<void> _checkOrderType() async {
    if (selectedOrderType != 'Giao hàng' && selectedOrderType != 'Mang đi') {
      try {
        tableName = await getNameTableById(int.parse(selectedOrderType));
        setState(() {
          widget.tableId = selectedOrderType;
        });
      } catch (e) {
        // Handle error
        // ignore: avoid_print
        print('Error fetching table name: $e');
      }
    }
  }

  void _reset() {
    setState(() {
      _cartItems.clear();
      _calculateTotal();
      _selectedPromotionCode = null;
      _promotionValue = null;
      _promotionType = null;
      _surcharge = 0.0;
      _surchargeReason = '';
      customerID = null;
      customerName = null;
      selectedOrderType = 'Mang đi'; // Reset giá trị selectedOrderType
      widget.tableId = null;
    });
  }

  void _addToCart(Map<String, dynamic> item) {
    setState(() {
      _cartItems.add(item);
      _calculateTotal();
    });
  }

  void updateMenuList(String category) {
    setState(() {
      selectedCategory = category;
      menuList = fetchMenuCategory(category == 'Tất cả' ? null : category);
    });
  }

// Hàm tính toán tổng giá trị đơn hàng
  void _calculateTotal() async {
    _totalPrice = 0.0;
    for (var item in _cartItems) {
      final discountedProductsList = await discountedProducts;
      final discountedProduct = discountedProductsList.firstWhere(
        (discountedProduct) => discountedProduct['id'] == item['id'],
        orElse: () => null,
      );
      final itemPrice = discountedProduct != null
          ? (discountedProduct['discount_type'] == 'percentage'
              ? (double.parse(item['price'].toString()) *
                  (1 -
                      double.parse(
                              discountedProduct['discount_value'].toString()) /
                          100))
              : (double.parse(item['price'].toString()) -
                  double.parse(discountedProduct['discount_value'].toString())))
          : double.parse(item['price'].toString());
      _totalPrice += itemPrice * item['quantity'];
    }

    // Áp dụng mã giảm giá nếu có
    if (_selectedPromotionCode != null) {
      // Kiểm tra giá trị đơn hàng tối thiểu
      if (_totalPrice >= _promotionMinValue!) {
        if (_promotionType == 'percentage') {
          // Giảm giá theo phần trăm
          _totalPrice -= _totalPrice * (_promotionValue! / 100);
        } else if (_promotionType == 'fixed_amount') {
          // Giảm giá theo số tiền cố định
          _totalPrice -= _promotionValue!;
        }
      } else {
        _selectedPromotionCode = null; // Xóa mã giảm giá
        _promotionValue = null;
        _promotionType = null;
        _promotionMinValue = null;
      }
    }

    _tax = _totalPrice * 0.1;
    _totalPrice += _surcharge; // Cộng thêm phụ thu vào tổng tiền
  }

  void _showSurchargeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SurchargeDialog(
          // Truyền các giá trị hiện tại của _surcharge và _surchargeReason
          initialSurcharge: _surcharge,
          initialSurchargeReason: _surchargeReason,
          // Hàm callback để cập nhật state sau khi người dùng xác nhận
          onConfirm: (double newSurcharge, String newSurchargeReason) {
            setState(() {
              _surcharge = newSurcharge;
              _surchargeReason = newSurchargeReason;
              _calculateTotal(); // Tính lại tổng tiền
            });
          },
        );
      },
    );
  }

//
  void _showCustomizationDialog(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomizationDialog(
          product: product,
          onConfirm: (updatedProduct) {
            setState(() {
              final existingItemIndex = _cartItems
                  .indexWhere((item) => item['name'] == updatedProduct['name']);
              if (existingItemIndex != -1) {
                _cartItems[existingItemIndex] = updatedProduct;
              } else {
                _addToCart(updatedProduct);
              }
              _calculateTotal();
            });
          },
        );
      },
    );
  }

  void _showPaymentConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PaymentConfirmationDialog(
          tableId: widget.tableId,
          userID: widget.userID,
          customerId: customerID,
          cartItems: _cartItems,
          totalPrice: _totalPrice,
          orderType:
              selectedOrderType != 'Mang đi' && selectedOrderType != 'Giao hàng'
                  ? 'Tại bàn'
                  : selectedOrderType,
          tax: _tax,
          surcharge: _surcharge,
          surchargeReason: _surchargeReason,
          selectedPaymentMethod: _selectedPaymentMethod,
          selectedPromotionCode: _selectedPromotionCode,
          promotionValue: _promotionValue,
          promotionType: _promotionType,
          hasTaxMode: hasTaxMode,
          onPaymentSuccess: () {
            _reset();
          },
          discountedProducts: discountedProducts,
        );
      },
    );
  }

  void _showConfirmationDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: Text('Bạn có muốn thêm ${item['name']} vào giỏ hàng?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng popup
              },
              child: const Text('Huỷ'),
            ),
            ElevatedButton(
              onPressed: () {
                _addToCart(item); // Thêm vào giỏ hàng
                Navigator.of(context).pop(); // Đóng popup
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  void takeDiscountValue(String query) async {
    try {
      List<dynamic> promotions = await searchPromotionscustomer(query);
      if (promotions.isNotEmpty) {
        // Gán giá trị giảm giá cho _selectedPromotionCode và trả về discount_value
        setState(() {
          if (_totalPrice >= double.parse(promotions[0]['min_order_value'])) {
            _promotionValue = double.parse(promotions[0]['discount_value']);
            _promotionType = promotions[0]['discount_type'];
            _promotionMinValue = double.parse(promotions[0]['min_order_value']);
          } else {
            ToastNotification.showToast(
                message:
                    'Mã giảm giá chỉ áp dụng với đơn hàng trên ${promotions[0]['min_order_value']} VNĐ');
            _selectedPromotionCode = null;
            _promotionValue = null;
            _promotionType = null;
            _promotionMinValue = null;
          }
        });
      }
      // ignore: avoid_print
      print(_selectedPromotionCode);
    } catch (e) {
      // ignore: avoid_print
      print('Lỗi mã giảm giá: $e');
    }

    return null; // Trả về null nếu không tìm thấy kết quả
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(shopName),
      ),
      body: Responsive(
        mobile: _buildMobileLayout(context),
        tablet: _buildTabletLayout(context),
        desktop: _buildDesktopLayout(context),
      ),
      floatingActionButton: Responsive(
        mobile: Draggable<String>(
          // Wrap with Draggable
          data: 'cart', // Data to be dragged
          feedback: FloatingActionButton(
            key: _fabKey, // Assign the GlobalKey
            onPressed: () {}, // No action needed for feedback
            child: const Icon(Icons.shopping_cart),
          ),
          child: FloatingActionButton(
            key: _fabKey, // Assign the GlobalKey
            onPressed: () {
              setState(() {
                _showCart = !_showCart;
                _showMenu = !_showCart; // Toggle menu visibility
              });
            },
            child: const Icon(Icons.shopping_cart),
          ),
          onDragEnd: (details) {
            // Update the FloatingActionButton's position based on drag end
            final RenderBox renderBox =
                _fabKey.currentContext!.findRenderObject() as RenderBox;
            // ignore: unused_local_variable
            final Offset offset = renderBox.localToGlobal(Offset.zero);
            setState(() {});
          },
        ),
        tablet: const SizedBox.shrink(), // Hide on tablet
        desktop: const SizedBox.shrink(), // Hide on desktop
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        // Menu (hidden when cart is visible)
        if (_showMenu)
          Expanded(
            flex: 2,
            child: MenuListWidget(
              onAddToCart: (item) {
                if (Responsive.isMobile(context)) {
                  // Kiểm tra xem đang ở chế độ mobile
                  _showConfirmationDialog(item); // Hiển thị popup xác nhận
                } else {
                  _addToCart(item); // Thêm trực tiếp vào giỏ hàng
                }
              },
              menuList: menuList,
              selectedCategory: selectedCategory,
              updateMenuList: updateMenuList,
              discountedProducts: discountedProducts,
            ),
          ),
        // Cart Button

        // Cart (visible when cart button is pressed)
        if (_showCart)
          Expanded(
            flex: 1,
            child: _buildCartContent(context),
          ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      children: [
        // Menu
        Expanded(
          flex: 2,
          child: MenuListWidget(
            onAddToCart: _addToCart,
            menuList: menuList,
            selectedCategory: selectedCategory,
            updateMenuList: updateMenuList,
            discountedProducts: discountedProducts,
          ),
        ),
        // Order Summary and Actions
        Expanded(
          flex: 1,
          child: _buildCartContent(context),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Menu
        Expanded(
          flex: 2,
          child: MenuListWidget(
            onAddToCart: _addToCart,
            menuList: menuList,
            selectedCategory: selectedCategory,
            updateMenuList: updateMenuList,
            discountedProducts: discountedProducts,
          ),
        ),
        // Order Summary and Actions
        Expanded(
          flex: 1,
          child: _buildCartContent(context),
        ),
      ],
    );
  }

  Widget _buildCartContent(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  //Loại đơn hàng

                  // const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Text(
                      'ĐƠN HÀNG',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),

            // Cart

            // Giỏ hàng
            CartWidget(
              cartItems: _cartItems,
              onEdit: (item) {
                _showCustomizationDialog(item);
              },
              onDelete: (index) {
                setState(() {
                  _cartItems.removeAt(index);
                  _calculateTotal();
                });
              },
              discountedProducts: discountedProducts,
            ),

            // Khuyến mãi, phụ thu, tổng cộng
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tổng cộng:',
                              style: TextStyle(fontSize: 18.0)),
                          Text('${_totalPrice.toStringAsFixed(2)} VNĐ',
                              style: const TextStyle(fontSize: 18.0)),
                        ],
                      ),
                      if (_selectedPromotionCode != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Mã giảm giá:',
                                style: TextStyle(fontSize: 18.0)),
                            Text(
                              '- ${_promotionValue.toString()} ${_promotionType == 'percentage' ? '%' : 'VNĐ'}',
                              style: const TextStyle(fontSize: 18.0),
                            ),
                          ],
                        ),
                      ],
                      if (_surcharge > 0) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Phụ thu:',
                                style: TextStyle(fontSize: 18.0)),
                            Text('${_surcharge.toStringAsFixed(2)} VNĐ',
                                style: const TextStyle(fontSize: 18.0)),
                          ],
                        ),
                      ],
                      if (hasTaxMode) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('VAT (10%):',
                                style: TextStyle(fontSize: 18.0)),
                            Text('${_tax.toStringAsFixed(2)} VNĐ',
                                style: const TextStyle(fontSize: 18.0)),
                          ],
                        ),
                      ],
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Thanh toán:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20.0),
                          ),
                          Text(
                            // ignore: unnecessary_null_comparison
                            '${(hasTaxMode ? (_totalPrice + _tax - (_promotionValue != null ? _promotionType == 'percentage' ? _totalPrice * (_promotionValue! / 100) : _promotionValue! : 0)) : _totalPrice - (_promotionValue != null ? _promotionType == 'percentage' ? _totalPrice * (_promotionValue! / 100) : _promotionValue! : 0)).toStringAsFixed(0)} VNĐ',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20.0),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Customer Loyalty, Discount Code
                const SizedBox(height: 16.0),
                if (Responsive.isMobile(context) ||
                    Responsive.isTablet(context))
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height:
                                  50.0, // Fixed height for uniform appearance
                              child: OrderTypeDialog(
                                initialOrderType: selectedOrderType,
                                onOrderTypeSelected: (newType) {
                                  setState(() {
                                    selectedOrderType = newType;
                                    _checkOrderType();
                                  });
                                },
                                userID: widget.userID,
                              ),
                            ),
                          ),
                          const SizedBox(
                              width: 16.0), // Add spacing for consistent layout
                          Expanded(
                            child: SizedBox(
                              height:
                                  50.0, // Fixed height for uniform appearance
                              child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        // title:
                                        //     const Text('Tìm kiếm khách hàng'),
                                        content: const SizedBox(
                                          width: 300,
                                          height: 400,
                                          child: FindCustomerScreen(),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Đóng'),
                                          ),
                                        ],
                                      );
                                    },
                                  ).then((value) {
                                    if (value != null) {
                                      setState(() {
                                        customerID = value['id'].toString();
                                        customerName = value['name'].toString();
                                      });
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  textStyle: const TextStyle(fontSize: 18.0),
                                ),
                                child: customerName != null
                                    ? SingleChildScrollView(
                                        child: Center(
                                        child: Text('KH: $customerName'),
                                      ))
                                    : const Text('Tích điểm',
                                        textAlign: TextAlign.center),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0), // Add spacing between rows
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height:
                                  50.0, // Fixed height for uniform appearance
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_cartItems.isEmpty) {
                                    ToastNotification.showToast(
                                        message:
                                            'Vui lòng thêm sản phẩm vào giỏ hàng trước khi áp mã giảm giá.');
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          // title:
                                          //     const Text('Chọn mã khuyến mãi'),
                                          content: SizedBox(
                                            width: 300,
                                            height: 400,
                                            child: PromotionScreen(
                                              onPromotionSelected: (code) {
                                                setState(() {
                                                  _selectedPromotionCode = code;
                                                  takeDiscountValue(
                                                      _selectedPromotionCode!);
                                                });
                                              },
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Đóng'),
                                            ),
                                          ],
                                        );
                                      },
                                    ).then((value) {
                                      if (value != null) {
                                        setState(() {
                                          _selectedPromotionCode =
                                              value.toString();
                                        });
                                      }
                                    });
                                  }
                                },
                                child: Text(
                                  _selectedPromotionCode != null
                                      ? 'MGG: $_selectedPromotionCode'
                                      : 'Khuyến mãi',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 18.0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                              width: 16.0), // Add spacing for consistent layout
                          Expanded(
                            child: SizedBox(
                              height:
                                  50.0, // Fixed height for uniform appearance
                              child: ElevatedButton(
                                onPressed: () {
                                  _showSurchargeDialog(); // Gọi hàm hiển thị dialog nhập phụ thu
                                },
                                style: ElevatedButton.styleFrom(
                                  textStyle: const TextStyle(fontSize: 18.0),
                                ),
                                child: Text(
                                  _surcharge > 0
                                      ? 'Phụ thu: ${_surcharge.toStringAsFixed(2)} VNĐ'
                                      : 'Phụ thu',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50.0, // Fixed height for uniform appearance
                          child: OrderTypeDialog(
                            initialOrderType: selectedOrderType,
                            onOrderTypeSelected: (newType) {
                              setState(() {
                                selectedOrderType = newType;
                                _checkOrderType();
                              });
                            },
                            userID: widget.userID,
                          ),
                        ),
                      ),
                      const SizedBox(
                          width: 16.0), // Add spacing for consistent layout
                      Expanded(
                        child: SizedBox(
                          height: 50.0, // Fixed height for uniform appearance
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    // title: const Text('Tìm kiếm khách hàng'),
                                    content: const SizedBox(
                                      width: 300,
                                      height: 400,
                                      child: FindCustomerScreen(),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Đóng'),
                                      ),
                                    ],
                                  );
                                },
                              ).then((value) {
                                if (value != null) {
                                  setState(() {
                                    customerID = value['id'].toString();
                                    customerName = value['name'].toString();
                                  });
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 18.0),
                            ),
                            child: customerName != null
                                ? SingleChildScrollView(
                                    child: Center(
                                    child: Text('KH: $customerName'),
                                  ))
                                : const Text('Tích điểm',
                                    textAlign: TextAlign.center),
                          ),
                        ),
                      ),
                      const SizedBox(
                          width: 16.0), // Add spacing for consistent layout
                      Expanded(
                        child: SizedBox(
                          height: 50.0, // Fixed height for uniform appearance
                          child: ElevatedButton(
                            onPressed: () {
                              if (_cartItems.isEmpty) {
                                ToastNotification.showToast(
                                    message:
                                        'Vui lòng thêm sản phẩm vào giỏ hàng trước khi áp mã giảm giá.');
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      // title: const Text('Chọn mã khuyến mãi'),
                                      content: SizedBox(
                                        width: 300,
                                        height: 400,
                                        child: PromotionScreen(
                                          onPromotionSelected: (code) {
                                            setState(() {
                                              _selectedPromotionCode = code;
                                              takeDiscountValue(
                                                  _selectedPromotionCode!);
                                            });
                                          },
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Đóng'),
                                        ),
                                      ],
                                    );
                                  },
                                ).then((value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedPromotionCode = value.toString();
                                    });
                                  }
                                });
                              }
                            },
                            child: Text(
                              _selectedPromotionCode != null
                                  ? 'MGG: $_selectedPromotionCode'
                                  : 'Khuyến mãi',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 18.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                          width: 16.0), // Add spacing for consistent layout
                      Expanded(
                        child: SizedBox(
                          height: 50.0, // Fixed height for uniform appearance
                          child: ElevatedButton(
                            onPressed: () {
                              _showSurchargeDialog(); // Gọi hàm hiển thị dialog nhập phụ thu
                            },
                            style: ElevatedButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 18.0),
                            ),
                            child: Text(
                              _surcharge > 0
                                  ? 'Phụ thu: ${_surcharge.toStringAsFixed(2)} VNĐ'
                                  : 'Phụ thu',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                // Cancel and Payment Buttons
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50.0, // Chiều cao cố định cho cả hai nút
                        child: ElevatedButton(
                          onPressed: () {
                            _reset();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            textStyle: const TextStyle(fontSize: 18.0),
                          ),
                          child: const Text('Huỷ'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: SizedBox(
                        height: 50.0, // Chiều cao cố định cho cả hai nút
                        child: ElevatedButton(
                          onPressed: () {
                            if (_cartItems.isNotEmpty) {
                              _showPaymentConfirmationDialog(); // Hiển thị dialog xác nhận thanh toán
                            } else {
                              ToastNotification.showToast(
                                  message: 'Giỏ hàng của bạn đang trống.');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            textStyle: const TextStyle(fontSize: 18.0),
                          ),
                          child: const Text('Thanh toán'),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
