import 'package:flutter/material.dart';

class InputDialogSetting extends StatelessWidget {
  Function(String) onSubmit;
  Function? onCancel;
  final String title;
  final String subTitle, hintText;
  final TextEditingController _textController = TextEditingController();

  InputDialogSetting({
    Key? key,
    required this.onSubmit,
    required this.title,
    this.subTitle = '',
    this.hintText = '',
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subTitle),
      trailing: const Icon(Icons.arrow_forward),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Enter your $title'),
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
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    onSubmit(_textController.text);
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
