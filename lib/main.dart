import 'dart:io';

import 'package:flutter/material.dart';
import 'package:huntis/components/app_scaffold.dart';
import 'calendar.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      exit(1);
    };

    return MaterialApp(
      title: 'HUntis',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const AppScaffold(body: Calendar(), title: 'Calendar'),
    );
  }
}
