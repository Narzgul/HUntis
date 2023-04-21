import 'dart:io';

import 'package:flutter/material.dart';
import 'package:huntis/components/app_scaffold.dart';
import 'package:huntis/untis_api.dart';
import 'package:provider/provider.dart';
import 'calendar.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  runApp(MultiProvider(providers: [Session(server:
  prefs.getString('serverURL') ?? '',, school: school, username: username, password: password)], child: const MyApp())
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
      navigatorKey: navigatorKey,
      home: const AppScaffold(body: Calendar(), title: 'Calendar'),
    );
  }
}
