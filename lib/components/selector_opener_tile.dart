import 'package:flutter/material.dart';

class SelectorOpenerTile extends StatefulWidget {
  final Widget selector;
  final String title;

  const SelectorOpenerTile(
      {Key? key, required this.selector, required this.title})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SelectorOpenerTileState();
}

class _SelectorOpenerTileState extends State<SelectorOpenerTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
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
                  Flexible(child: widget.selector),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
