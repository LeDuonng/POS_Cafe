// ignore_for_file: use_build_context_synchronously

import 'package:coffeeapp/models/users_model.dart';
import 'package:flutter/material.dart';
import '../../../controllers/users_controller.dart';
import '../../../responsive.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserScreenState createState() => _UserScreenState();
}

late Future<List<dynamic>> userList;
String searchText = '';

class _UserScreenState extends State<UserScreen> {
  @override
  void initState() {
    super.initState();
    userList = searchUsers();
  }

  Future<void> _refreshUserList([String? search]) async {
    var temp = searchUsers(search);

    setState(() {
      userList = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 300,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm người dùng...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                    _refreshUserList(searchText);
                  });
                },
              ),
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Thêm người dùng'),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) => const AddUserScreen(),
              );
              _refreshUserList();
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.file_download),
            label: const Text('Xuất Excel'),
            onPressed: () {
              exportUsersToExcel();
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.file_upload),
            label: const Text('Nhập Excel'),
            onPressed: () {
              importUsersFromExcel();
              _refreshUserList();
            },
          ),
        ],
      ),
      body: Responsive(
        mobile: _buildUserList(context),
        tablet: _buildUserList(context),
        desktop: _buildUserList(context),
      ),
    );
  }

  Future<void> exportUsersToExcel() async {
    try {
      var excel = Excel.createExcel();
      excel.rename('Sheet1', 'Danh sách người dùng');
      Sheet sheetObject = excel['Danh sách người dùng'];
      sheetObject.appendRow([
        TextCellValue('Mã người dùng'),
        TextCellValue('Tên người dùng'),
        TextCellValue('Quyền'),
        TextCellValue('Tên đăng nhập'),
        TextCellValue('Email'),
        TextCellValue('Điện thoại'),
        TextCellValue('Địa chỉ'),
      ]);

      // Lấy dữ liệu người dùng
      final usersData = await userList;
      for (var user in usersData) {
        sheetObject.appendRow([
          IntCellValue(user['id']),
          TextCellValue(user['name'] ?? 'Không có'),
          TextCellValue(user['role'] ?? 'Không có'),
          TextCellValue(user['username'] ?? 'Không có'),
          TextCellValue(user['email'] ?? 'Không có'),
          TextCellValue(user['phone'] ?? 'Không có'),
          TextCellValue(user['address'] ?? 'Không có'),
        ]);
      }

      // Tạo tên file với ngày hiện tại
      String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String fileName = "users_$currentDate.xlsx";

      // Tạo file Excel
      final excelBytes = excel.save();
      final blob = html.Blob([Uint8List.fromList(excelBytes!)],
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Tải file về với tên chứa ngày hiện tại
      // ignore: unused_local_variable
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..click();
      html.Url.revokeObjectUrl(url);

      // Thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Dữ liệu người dùng đã được xuất thành công: $fileName')),
      );
    } catch (e) {
      // Thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xuất Excel: $e')),
      );
    }
  }

  Future<void> importUsersFromExcel() async {
    try {
      // Mở File Picker để chọn file Excel
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'], // Chỉ cho phép file Excel
      );

      if (result != null) {
        Uint8List? bytes = result.files.single.bytes; // Lấy dữ liệu file
        if (bytes == null) throw 'Không thể đọc file Excel';

        var excel = Excel.decodeBytes(bytes);

        // Đọc dữ liệu từ file Excel
        for (var table in excel.tables.keys) {
          var sheet = excel.tables[table];
          for (var i = 1; i < sheet!.rows.length; i++) {
            var row = sheet.rows[i];
            await addUser(
              username: row[3]?.value.toString() ?? 'Không có',
              password: 'defaultPassword', // Set a default password
              role: row[2]?.value.toString() ?? 'customer',
              name: row[1]?.value.toString() ?? 'Không có',
              email: row[4]?.value.toString() ?? 'Không có',
              phone: row[5]?.value.toString() ?? 'Không có',
              address: row[6]?.value.toString() ?? 'Không có',
            );
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Dữ liệu người dùng đã được nhập thành công!')),
        );
      } else {
        throw 'Không có file nào được chọn.';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi nhập Excel: $e')),
      );
    }
  }

  Widget _buildUserList(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: userList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không có dữ liệu'));
        } else {
          return LayoutBuilder(
            builder: (context, constraints) {
              double totalWidth = constraints.maxWidth;
              double columnWidth = totalWidth / 7; // 8 là tổng số cột hiện có

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columnSpacing: 12,
                  // ignore: deprecated_member_use
                  dataRowHeight: 100,
                  columns: [
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'Tên người dùng',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'Quyền',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'Username',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'Email',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'Điện thoại',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'Địa chỉ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'Actions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                    ),
                  ],
                  rows: List.generate(snapshot.data!.length, (index) {
                    return DataRow(
                      color: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                          return index.isEven
                              ? Colors.grey.withOpacity(0.1)
                              : Colors.white;
                        },
                      ),
                      cells: [
                        DataCell(
                            Text(snapshot.data![index]['name'] ?? 'Không có')),
                        DataCell(
                            Text(snapshot.data![index]['role'] ?? 'Không có')),
                        DataCell(Text(
                            snapshot.data![index]['username'] ?? 'Không có')),
                        DataCell(
                            Text(snapshot.data![index]['email'] ?? 'Không có')),
                        DataCell(
                            Text(snapshot.data![index]['phone'] ?? 'Không có')),
                        DataCell(Text(
                            snapshot.data![index]['address'] ?? 'Không có')),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (context) => EditUserScreen(
                                      user: snapshot.data![index],
                                      userItem: {
                                        'id': snapshot.data![index]['id'],
                                        'username': snapshot.data![index]
                                            ['username'],
                                        'password': snapshot.data![index]
                                            ['password'],
                                        'role': snapshot.data![index]['role'],
                                        'name': snapshot.data![index]['name'],
                                        'email': snapshot.data![index]['email'],
                                        'phone': snapshot.data![index]['phone'],
                                        'address': snapshot.data![index]
                                            ['address'],
                                      },
                                    ),
                                  );
                                  _refreshUserList();
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Xác nhận xoá'),
                                        content: const Text(
                                            'Bạn có chắc chắn muốn xoá người dùng này không?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Huỷ'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                try {
                                                  deleteUser(snapshot
                                                      .data![index]['id']);
                                                  snapshot.data!
                                                      .removeAt(index);
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content:
                                                            Text('Lỗi: $e')),
                                                  );
                                                }
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Xoá'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              );
            },
          );
        }
      },
    );
  }
}

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late String username, password, role, name, email, phone, address;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save the form fields
      addUser(
        username: username,
        password: password,
        role: role,
        name: name,
        email: email,
        phone: phone,
        address: address,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(10),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 900),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Tên đăng nhập'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên đăng nhập';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      username = value;
                    }
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Mật khẩu'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      password = value;
                    }
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Quyền'),
                  value: 'customer',
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'staff', child: Text('Nhân viên')),
                    DropdownMenuItem(
                        value: 'customer', child: Text('Khách hàng')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        role = value;
                      });
                    }
                  },
                  onSaved: (value) {
                    if (value != null) {
                      role = value;
                    }
                  },
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Tên người dùng'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên người dùng';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      name = value;
                    }
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    email = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Số điện thoại'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    phone = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Địa chỉ'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập địa chỉ';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    address = value!;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _submitForm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Green for Add Item
                  ),
                  child: const Text('Thêm người dùng'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Red for Cancel
                  ),
                  child: const Text('Hủy'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EditUserScreen extends StatefulWidget {
  final Map<String, dynamic> userItem;
  final dynamic user;

  const EditUserScreen({super.key, required this.userItem, required this.user});

  @override
  // ignore: library_private_types_in_public_api
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late String username, password, role, name, email, phone, address;

  @override
  void initState() {
    super.initState();
    username = widget.userItem['username'] ?? 'Không có';
    password = widget.userItem['password'] ?? 'Không có';
    role = widget.userItem['role'] ?? 'customer';
    name = widget.userItem['name'] ?? 'Không có';
    email = widget.userItem['email'] ?? 'Không có';
    phone = widget.userItem['phone'] ?? 'Không có';
    address = widget.userItem['address'] ?? 'Không có';
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save the form fields
      updateUser(
        id: widget.userItem['id'],
        username: username,
        password: password,
        role: role,
        name: name,
        email: email,
        phone: phone,
        address: address,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(10),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 900),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                TextFormField(
                  initialValue: widget.userItem['id'].toString(),
                  decoration: const InputDecoration(labelText: 'Mã người dùng'),
                  readOnly: true,
                ),
                TextFormField(
                  initialValue: username,
                  decoration: const InputDecoration(labelText: 'Tên đăng nhập'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên đăng nhập';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      username = value;
                    }
                  },
                ),
                TextFormField(
                  initialValue: password,
                  decoration: const InputDecoration(labelText: 'Mật khẩu'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      password = value;
                    }
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Quyền'),
                  value: role,
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'staff', child: Text('Nhân viên')),
                    DropdownMenuItem(
                        value: 'customer', child: Text('Khách hàng')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        role = value;
                      });
                    }
                  },
                  onSaved: (value) {
                    if (value != null) {
                      role = value;
                    }
                  },
                ),
                TextFormField(
                  initialValue: name,
                  decoration:
                      const InputDecoration(labelText: 'Tên người dùng'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên người dùng';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      name = value;
                    }
                  },
                ),
                TextFormField(
                  initialValue: email,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    email = value!;
                  },
                ),
                TextFormField(
                  initialValue: phone,
                  decoration: const InputDecoration(labelText: 'Số điện thoại'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    phone = value!;
                  },
                ),
                TextFormField(
                  initialValue: address,
                  decoration: const InputDecoration(labelText: 'Địa chỉ'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập địa chỉ';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    address = value!;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _submitForm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Green for Add Item
                  ),
                  child: const Text('Cập nhật người dùng'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Red for Cancel
                  ),
                  child: const Text('Hủy'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
