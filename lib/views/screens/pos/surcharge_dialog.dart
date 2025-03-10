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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      title: const Text(
        'Nhập phụ thu',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.lightBlue,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _surchargeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Nhập số tiền",
                suffixText: "VNĐ",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.lightBlue[50],
                prefixIcon:
                    const Icon(Icons.attach_money, color: Colors.lightBlue),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _surchargeReasonController,
              decoration: InputDecoration(
                hintText: "Nhập lý do",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.lightBlue[50],
                prefixIcon: const Icon(Icons.note, color: Colors.lightBlue),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Huỷ',
            style: TextStyle(color: Colors.lightBlue),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          onPressed: () {
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
