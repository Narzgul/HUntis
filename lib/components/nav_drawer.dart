import 'package:flutter/material.dart';
import 'package:huntis/components/app_scaffold.dart';
import 'package:huntis/settings.dart';

import '../calendar.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: const Text('Calendar'),
            leading: const Icon(Icons.calendar_month),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppScaffold(
                    body: Calendar(),
                    title: 'Calendar',
                  ),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Settings'),
            leading: const Icon(Icons.settings),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppScaffold(
                    body: Settings(),
                    title: 'Settings',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
