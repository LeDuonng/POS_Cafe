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
  bool _tableMode = false;
  bool _onlinePayment = false;
  bool _allowTakeaway = false;
  bool _tax = false;
  // ignore: non_constant_identifier_names
  String _percent_points = '';

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      List<dynamic> configs = await fetchConfig();
      setState(() {
        _tableMode = configs.firstWhere(
                (config) => config['key'] == 'use_table_mode')['value'] ==
            'true';
        _onlinePayment = configs.firstWhere(
                (config) => config['key'] == 'online_payment')['value'] ==
            'true';
        _allowTakeaway = configs.firstWhere(
                (config) => config['key'] == 'allow_takeaway')['value'] ==
            'true';
        _tax =
            configs.firstWhere((config) => config['key'] == 'tax')['value'] ==
                'true';
        _percent_points = configs
            .firstWhere((config) => config['key'] == 'percent_points')['value'];
      });
    } catch (e) {
      // Handle error
      // ignore: avoid_print
      print('Failed to load config: $e');
    }
  }

  Future<void> _updateConfig(String key, String value) async {
    try {
      int id = await fetchConfigIdByKey(key);
      await updateConfig(id, {'key': key, 'value': value.toString()});
    } catch (e) {
      // Handle error
      // ignore: avoid_print
      print('Failed to update config: $e');
    }
  }

  Future<int> fetchConfigIdByKey(String key) async {
    List<dynamic> configs = await fetchConfig();
    return configs.firstWhere((config) => config['key'] == key)['id'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Config Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Chế độ bàn'),
              value: _tableMode,
              onChanged: (bool value) {
                setState(() {
                  _tableMode = value;
                });
                _updateConfig('use_table_mode', value.toString());
                ToastNotification.showToast(
                    message: 'Chế độ này sẽ có hiệu lực sau khi đăng nhập lại');
              },
            ),
            SwitchListTile(
              title: const Text('Thanh toán online'),
              value: _onlinePayment,
              onChanged: (bool value) {
                setState(() {
                  _onlinePayment = value;
                });
                _updateConfig('online_payment', value.toString());
                ToastNotification.showToast(
                    message: 'Chế độ này sẽ có hiệu lực sau khi đăng nhập lại');
              },
            ),
            SwitchListTile(
              title: const Text('Cho phép mang về'),
              value: _allowTakeaway,
              onChanged: (bool value) {
                setState(() {
                  _allowTakeaway = value;
                });
                _updateConfig('allow_takeaway', value.toString());
                ToastNotification.showToast(
                    message: 'Chế độ này sẽ có hiệu lực sau khi đăng nhập lại');
              },
            ),
            SwitchListTile(
              title: const Text('Thuế'),
              value: _tax,
              onChanged: (bool value) {
                setState(() {
                  _tax = value;
                });
                _updateConfig('tax', value.toString());
                ToastNotification.showToast(
                    message: 'Chế độ này sẽ có hiệu lực sau khi đăng nhập lại');
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Phần trăm điểm',
                  style: TextStyle(fontSize: 16),
                ),
                Row(
                  children: [
                    Text(
                      '$_percent_points%',
                      style: const TextStyle(fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        String? newValue = await showDialog<String>(
                          context: context,
                          builder: (BuildContext context) {
                            String tempValue = _percent_points;
                            return AlertDialog(
                              title: const Text('Chỉnh sửa phần trăm điểm'),
                              content: TextField(
                                keyboardType: TextInputType.number,
                                onChanged: (String value) {
                                  tempValue = value;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Phần trăm điểm',
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(tempValue);
                                  },
                                  child: const Text('Lưu'),
                                ),
                              ],
                            );
                          },
                        );
                        if (newValue != null) {
                          setState(() {
                            _percent_points = newValue;
                          });
                          _updateConfig('percent_points', _percent_points);
                          // ignore: use_build_context_synchronously
                          ToastNotification.showToast(
                              message:
                                  'Chế độ này sẽ có hiệu lực sau khi đăng nhập lại');
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            // SwitchListTile(
            //   title: const Text('Thiết lập thông tin chuyển khoản'),
            //   value: false, // You can replace this with a variable if needed
            //   onChanged: (bool value) {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => const PaymentForm()),
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
