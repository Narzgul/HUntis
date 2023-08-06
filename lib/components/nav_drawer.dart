import 'package:easy_localization/easy_localization.dart';
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
            title: Text('calendar'.tr()),
            leading: const Icon(Icons.calendar_month),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppScaffold(
                    body: CalendarPage(),
                    title: 'calendar',
                  ),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: Text('settings'.tr()),
            leading: const Icon(Icons.settings),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppScaffold(
                    body: Settings(),
                    title: 'settings',
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
