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
            return const SimpleDialog(
              title: Text('Enter your Subjects'),
              children: [
                SubjectList()
              ],
            );
          },
        );
      },
    );
  }
}
