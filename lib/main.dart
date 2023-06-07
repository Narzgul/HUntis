import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:huntis/components/app_scaffold.dart';
import 'package:huntis/untis_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'calendar.dart';

final navigatorKey = GlobalKey<NavigatorState>();
late SharedPreferences _prefs;
final _prefsFuture = SharedPreferences.getInstance().then((v) => _prefs = v);

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  void _initSession() async {
    GetIt getIt = GetIt.instance;
    if (!getIt.isRegistered<Session>()) {
      getIt.registerSingleton<Session>(
        Session.initNoLogin(
          _prefs.getString('serverURL') ?? '',
          _prefs.getString('school') ?? '',
          _prefs.getString('username') ?? '',
          _prefs.getString('password') ?? '',
        ),
      );
    }
    await getIt<Session>().login();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      exit(1);
    };

    return FutureBuilder(
      future: _prefsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _initSession();

          return MaterialApp(
            title: 'HUntis',
            theme: ThemeData(
              primarySwatch: Colors.orange,
            ),
            navigatorKey: navigatorKey,
            home: const AppScaffold(body: Calendar(), title: 'Calendar'),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
