import 'package:coffeeapp/views/widgets/nofication.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/models/config_model.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ConfigScreenState createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  String shopname = '';
  String phone = '';
  String address = '';
  String bankBin = '';
  String bankNumber = '';
  bool tax = false;
  String percentPoints = '';

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final configs = await fetchConfig();
      setState(() {
        phone =
            configs.firstWhere((config) => config['key'] == 'phone')['value'];
        address =
            configs.firstWhere((config) => config['key'] == 'address')['value'];
        shopname = configs
            .firstWhere((config) => config['key'] == 'shop_name')['value'];
        bankBin = configs
            .firstWhere((config) => config['key'] == 'bank_bin')['value'];
        bankNumber = configs
            .firstWhere((config) => config['key'] == 'bank_number')['value'];
        tax = configs.firstWhere((config) => config['key'] == 'tax')['value'] ==
            'true';
        percentPoints = configs
            .firstWhere((config) => config['key'] == 'percent_points')['value'];
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error loading config: $e');
    }
  }

  Future<void> _updateConfig(String key, String value) async {
    try {
      final id = await _fetchConfigIdByKey(key);
      await updateConfig(id, {'key': key, 'value': value});
    } catch (e) {
      // ignore: avoid_print
      print('Error updating config: $e');
    }
  }

  Future<int> _fetchConfigIdByKey(String key) async {
    final configs = await fetchConfig();
    return configs.firstWhere((config) => config['key'] == key)['id'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thiết lập cấu hình',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionTitle('Thông tin quán'),
            _buildShopInfoInput(),
            const Divider(),
            _buildSectionTitle('Thông tin ngân hàng'),
            _buildBankDetailsInput(),
            const Divider(),
            _buildSwitchTile(
              title: 'Thuế VAT 10%',
              value: tax,
              onChanged: (value) => _onSwitchChanged(
                key: 'tax',
                newValue: value,
                updateState: (val) => tax = val,
              ),
            ),
            // const Divider(),
            // _buildPercentPointsRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  // Widget _buildPercentPointsRow() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       const Text(
  //         'Phần trăm tích điểm',
  //         style: TextStyle(fontSize: 16),
  //       ),
  //       Row(
  //         children: [
  //           Text(
  //             '$percentPoints%',
  //             style: const TextStyle(fontSize: 16),
  //           ),
  //           IconButton(
  //             icon: const Icon(Icons.edit),
  //             onPressed: _editPercentPoints,
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  // Future<void> _editPercentPoints() async {
  //   final newValue = await showDialog<String>(
  //     context: context,
  //     builder: (context) {
  //       String tempValue = percentPoints;
  //       return AlertDialog(
  //         title: const Text('Chỉnh sửa phần trăm điểm'),
  //         content: TextField(
  //           keyboardType: TextInputType.number,
  //           onChanged: (value) => tempValue = value,
  //           decoration: const InputDecoration(labelText: 'Phần trăm điểm'),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: const Text('Hủy'),
  //           ),
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(tempValue),
  //             child: const Text('Lưu'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  //   if (newValue != null) {
  //     setState(() {
  //       percentPoints = newValue;
  //     });
  //     _updateConfig('percent_points', percentPoints);
  //     ToastNotification.showToast(
  //       message: 'Chế độ này sẽ có hiệu lực sau khi đăng nhập lại',
  //     );
  //   }
  // }

  Widget _buildShopInfoInput() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: TextEditingController(text: shopname),
              decoration: const InputDecoration(
                labelText: 'Tên quán',
                prefixIcon: Icon(Icons.store),
              ),
              onChanged: (value) {
                _updateConfig('shop_name', value);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: phone),
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                prefixIcon: Icon(Icons.phone),
              ),
              onChanged: (value) {
                _updateConfig('phone', value);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: address),
              decoration: const InputDecoration(
                labelText: 'Địa chỉ',
                prefixIcon: Icon(Icons.location_on),
              ),
              onChanged: (value) {
                _updateConfig('address', value);
              },
            ),
            const SizedBox(height: 16),
            //phần trăm tích điểm
            TextField(
              controller: TextEditingController(text: percentPoints),
              decoration: const InputDecoration(
                labelText: 'Phần trăm tích điểm',
                prefixIcon: Icon(Icons.star),
              ),
              onChanged: (value) {
                _updateConfig('percent_points', value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankDetailsInput() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: TextEditingController(text: bankBin),
              decoration: const InputDecoration(
                labelText: 'Bank BIN',
                prefixIcon: Icon(Icons.account_balance),
              ),
              onChanged: (value) {
                _updateConfig('bank_bin', value);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: bankNumber),
              decoration: const InputDecoration(
                labelText: 'Số tài khoản ngân hàng',
                prefixIcon: Icon(Icons.account_balance_wallet),
              ),
              onChanged: (value) {
                _updateConfig('bank_number', value);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onSwitchChanged({
    required String key,
    required bool newValue,
    required ValueSetter<bool> updateState,
  }) {
    setState(() {
      updateState(newValue);
    });
    _updateConfig(key, newValue.toString());
    ToastNotification.showToast(
      message: 'Chế độ này sẽ có hiệu lực sau khi đăng nhập lại',
    );
  }
}
