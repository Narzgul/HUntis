import 'package:flutter/material.dart';
import 'package:huntis/calendar_page.dart';
import 'package:huntis/components/app_scaffold.dart';
import 'package:huntis/settings.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange,
            ),
            child: Text(
              'HUntis',
              style: TextStyle(
                fontSize: 26,
              ),
            ),
          ),
          ListTile(
            title: const Text('Calendar'),
            leading: const Icon(Icons.calendar_month),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppScaffold(
                    body: CalendarPage(),
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
                  builder: (context) => const AppScaffold(
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
