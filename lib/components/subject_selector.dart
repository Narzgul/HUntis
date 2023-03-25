import 'package:flutter/material.dart';
import 'package:huntis/components/subject_list.dart';

class SubjectSelector extends StatefulWidget {
  const SubjectSelector({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SubjectSelectorState();
}

class _SubjectSelectorState extends State<SubjectSelector> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Subjects'),
      trailing: const Icon(Icons.arrow_forward),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              child: Column(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Select your Subjects',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Flexible(child: SubjectList()),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
