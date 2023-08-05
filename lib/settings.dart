import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:huntis/components/input_dialog_setting.dart';
import 'package:huntis/components/login_button.dart';
import 'package:huntis/components/subject_color_list.dart';
import 'package:huntis/components/selector_opener_tile.dart';
import 'package:huntis/components/subject_list.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String serverURL = '', school = '', username = '', password = '';
  SharedPreferences prefs = GetIt.instance<SharedPreferences>();

  _loadSettings() {
    setState(() {
      serverURL = prefs.getString('serverURL') ?? '';
      school = prefs.getString('school') ?? '';
      username = prefs.getString('username') ?? '';
      password = prefs.getString('password') ?? '';
    });
  }

  _saveSettings() {
    setState(() {
      prefs.setString('serverURL', serverURL);
      prefs.setString('school', school);
      prefs.setString('username', username);
      prefs.setString('password', password);
    });
  }

  @override
  Widget build(BuildContext context) {
    _loadSettings();

    return ListView(
      children: [
        InputDialogSetting(
          title: 'Server URL',
          lastValue: serverURL,
          hintText: 'ajax.webuntis.com',
          onSubmit: (String serverURL) {
            this.serverURL = serverURL;
            _saveSettings();
          },
        ),
        InputDialogSetting(
          title: 'School',
          lastValue: school,
          hintText: 'lindengym-gummersbach',
          onSubmit: (String school) {
            this.school = school;
            _saveSettings();
          },
        ),
        InputDialogSetting(
          title: 'Username',
          lastValue: username,
          hintText: 'LastnameFirstname',
          onSubmit: (String username) {
            this.username = username;
            _saveSettings();
          },
        ),
        InputDialogSetting(
          title: 'Password',
          lastValue: password.replaceAll(RegExp('.'), '*'), // Censor password
          hintText: '',
          onSubmit: (String password) {
            this.password = password;
            _saveSettings();
          },
        ),
        LoginButton(context: context),
        const Divider(),
        const SelectorOpenerTile(
          title: 'Subjects',
          selector: SubjectList(),
          icon: Icon(Icons.book),
        ),
        const SelectorOpenerTile(
          title: 'Colors',
          selector: SubjectColorList(),
          icon: Icon(Icons.palette),
        ),
        const Divider(),
        CheckboxListTile(
          secondary: const Icon(Icons.date_range),
          title: const Text('Skip Weekends'),
          value: prefs.getBool('skipWeekends') ?? false,
          onChanged: (value) {
            prefs.setBool('skipWeekends', value ?? false);
            setState(() {});
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('About'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            PackageInfo.fromPlatform().then((packageInfo) {
              showAboutDialog(
                context: context,
                applicationName: packageInfo.appName,
                applicationVersion: packageInfo.version,
                applicationLegalese: '© 2023 by Titouan Guitton',
                children: [
                  const Text('This app is not affiliated with Untis GmbH.'),
                  TextButton(
                    onPressed: () {
                      launchUrl(
                        Uri.parse(
                          'https://github.com/Narzgul/HUntis/blob/master/privacy_policy.md',
                        ),
                      );
                    },
                    child: const Text('Privacy Policy'),
                  ),
                ],
              );
            });
          },
        ),
      ],
    );
  }
}
