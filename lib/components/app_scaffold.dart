import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:huntis/components/nav_drawer.dart';

class AppScaffold extends StatelessWidget{
  final Widget body;
  final String title;

  const AppScaffold({Key? key, required this.body, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HUntis',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: Scaffold(
        drawer: const NavDrawer(),
        appBar: AppBar(
          title: Text(title.tr()),
        ),
        body: body,
      ),
    );
  }

}