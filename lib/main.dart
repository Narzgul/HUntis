import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:huntis/components/app_scaffold.dart';
import 'package:huntis/untis_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'calendar.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final getIt = GetIt.instance;

Future<void> main() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<Session>(
    await Session.init(
      prefs.getString('serverURL') ?? '',
      prefs.getString('school') ?? '',
      prefs.getString('username') ?? '',
      prefs.getString('password') ?? '',
    ),
  );
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
      navigatorKey: navigatorKey,
      home: const AppScaffold(body: Calendar(), title: 'Calendar'),
    );
  }
}
