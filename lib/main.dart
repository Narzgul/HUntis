import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:get_it/get_it.dart';
import 'package:huntis/calendar_page.dart';
import 'package:huntis/components/app_scaffold.dart';
import 'package:huntis/settings.dart';
import 'package:huntis/untis_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  // Needs to be called so that we can await for EasyLocalization.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('de', 'DE')],
      path: 'assets/translations',
      fallbackLocale: const Locale('de', 'DE'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  bool hasLoginData() {
    SharedPreferences prefs = GetIt.instance<SharedPreferences>();
    bool notNull = prefs.getString('serverURL') != null &&
        prefs.getString('school') != null &&
        prefs.getString('username') != null &&
        prefs.getString('password') != null;
    bool notEmpty = prefs.getString('serverURL') != '' &&
        prefs.getString('school') != '' &&
        prefs.getString('username') != '' &&
        prefs.getString('password') != '';
    return notNull && notEmpty;
  }

  Future<void> _initPrefs() async {
    GetIt getIt = GetIt.instance;
    getIt.registerSingleton<SharedPreferences>(
      await SharedPreferences.getInstance(),
    );
  }

  Future<bool> _initSession() async {
    GetIt getIt = GetIt.instance;
    SharedPreferences prefs = getIt<SharedPreferences>();
    if (!getIt.isRegistered<Session>()) {
      getIt.registerSingleton<Session>(
        Session.initNoLogin(
          prefs.getString('serverURL') ?? '',
          prefs.getString('school') ?? '',
          prefs.getString('username') ?? '',
          prefs.getString('password') ?? '',
        ),
      );
    }
    int status = await getIt<Session>().login();
    if (status != 200) {
      return Future.error(status);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      exit(1);
    };

    var localizationsDelegates = context.localizationDelegates;
    localizationsDelegates.add(const LocaleNamesLocalizationsDelegate());

    return FutureBuilder(
      future: _initPrefs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (!hasLoginData()) {
            return MaterialApp(
              title: 'HUntis',
              navigatorKey: navigatorKey,
              localizationsDelegates: localizationsDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              home: const AppScaffold(
                body: Settings(),
                title: 'messages.missing-login-data',
              ),
            );
          } else {
            return FutureBuilder(
              future: _initSession(),
              builder: (context, AsyncSnapshot<void> snapshot) {
                if (snapshot.hasData) {
                  return MaterialApp(
                    title: 'HUntis',
                    navigatorKey: navigatorKey,
                    localizationsDelegates: localizationsDelegates,
                    supportedLocales: context.supportedLocales,
                    locale: context.locale,
                    home: const AppScaffold(
                      body: CalendarPage(),
                      title: 'calendar',
                    ),
                  );
                } else if (snapshot.hasError) {
                  return MaterialApp(
                    title: 'HUntis',
                    navigatorKey: navigatorKey,
                    localizationsDelegates: localizationsDelegates,
                    supportedLocales: context.supportedLocales,
                    locale: context.locale,
                    home: const AppScaffold(
                      body: Settings(),
                      title: 'messages.bad-login-data',
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            );
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
