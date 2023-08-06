import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class InputDialogSetting extends StatelessWidget {
  final Function(String) onSubmit;
  final Function? onCancel;
  final String title;
  final String lastValue, hintText;
  final TextEditingController _textController = TextEditingController();

  InputDialogSetting({
    Key? key,
    required this.onSubmit,
    required this.title,
    this.lastValue = '',
    this.hintText = '',
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _textController.text = lastValue; // Set default value
    return ListTile(
      title: Text(title),
      subtitle: Text(lastValue),
      trailing: const Icon(Icons.arrow_forward),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(title),
              content: TextField(
                controller: _textController,
                decoration: InputDecoration(hintText: hintText),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    onCancel?.call();
                    Navigator.pop(context);
                  },
                  child: Text('cancel'.tr()),
                ),
                TextButton(
                  onPressed: () {
                    onSubmit(_textController.text);
                    Navigator.pop(context);
                  },
                  child: Text('save'.tr()),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
