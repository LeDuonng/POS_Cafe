// surcharge_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SurchargeDialog extends StatefulWidget {
  final double initialSurcharge;
  final String initialSurchargeReason;
  final Function(double, String) onConfirm;

  const SurchargeDialog({
    super.key,
    required this.initialSurcharge,
    required this.initialSurchargeReason,
    required this.onConfirm,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SurchargeDialogState createState() => _SurchargeDialogState();
}

class _SurchargeDialogState extends State<SurchargeDialog> {
  late TextEditingController _surchargeController;
  late TextEditingController _surchargeReasonController;

  @override
  void initState() {
    super.initState();
    _surchargeController = TextEditingController(
        text: widget.initialSurcharge > 0
            ? widget.initialSurcharge.toString()
            : '');
    _surchargeReasonController =
        TextEditingController(text: widget.initialSurchargeReason);
  }

  @override
  void dispose() {
    _surchargeController.dispose();
    _surchargeReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nhập phụ thu'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _surchargeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Nhập số tiền phụ thu",
              suffixText: "VNĐ",
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: _surchargeReasonController,
            decoration: const InputDecoration(hintText: "Nhập lý do phụ thu"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Huỷ'),
        ),
        ElevatedButton(
          onPressed: () {
            // Gọi hàm onConfirm và truyền giá trị mới của phụ thu và lý do
            widget.onConfirm(
              double.tryParse(_surchargeController.text) ?? 0.0,
              _surchargeReasonController.text,
            );
            Navigator.of(context).pop();
          },
          child: const Text('Xác nhận'),
        ),
      ],
    );
  }
}
