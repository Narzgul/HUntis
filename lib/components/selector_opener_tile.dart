import 'package:flutter/material.dart';

class SelectorOpenerTile extends StatefulWidget {
  final Widget selector;
  final String title;
  final Icon icon;

  const SelectorOpenerTile(
      {Key? key, required this.selector, required this.title, required this.icon})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SelectorOpenerTileState();
}

class _SelectorOpenerTileState extends State<SelectorOpenerTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: widget.icon,
      title: Text(widget.title),
      trailing: const Icon(Icons.arrow_forward),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Select your ${widget.title}',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.tight, // Makes the selector fill the dialog
                    child: widget.selector,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(), // Exit dialog
                      child: const Text('Exit'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
