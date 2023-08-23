import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:huntis/components/input_dialog_setting.dart';
import 'package:huntis/components/language_list.dart';
import 'package:huntis/components/login_button.dart';
import 'package:huntis/components/subject_color_list.dart';
import 'package:huntis/components/selector_opener_tile.dart';
import 'package:huntis/components/subject_list.dart';
import 'package:huntis/components/subject_name_list.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  static const String _defaultServerURL = 'ajax.webuntis.com';
  static const String _defaultSchool = 'lindengym-gummersbach';

  String serverURL = '', school = '', username = '', password = '';
  SharedPreferences prefs = GetIt.instance<SharedPreferences>();

  _loadSettings() {
    setState(() {
      serverURL = prefs.getString('serverURL') ?? '';
      school = prefs.getString('school') ?? '';
      username = prefs.getString('username') ?? '';
      password = prefs.getString('password') ?? '';
    });

    // If the user has not set the server URL and school, set the default values
    if (serverURL == '') {
      serverURL = _defaultServerURL;
      _saveSettings();
    }
    if (school == '') {
      school = _defaultSchool;
      _saveSettings();
    }
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
          title: 'settings-page.server-url'.tr(),
          lastValue: serverURL,
          hintText: 'ajax.webuntis.com',
          onSubmit: (String serverURL) {
            this.serverURL = serverURL;
            _saveSettings();
          },
        ),
        InputDialogSetting(
          title: 'settings-page.school'.tr(),
          lastValue: school,
          hintText: 'lindengym-gummersbach',
          onSubmit: (String school) {
            this.school = school;
            _saveSettings();
          },
        ),
        InputDialogSetting(
          title: 'settings-page.username'.tr(),
          lastValue: username,
          hintText: 'LastnameFirstname',
          onSubmit: (String username) {
            this.username = username;
            _saveSettings();
          },
        ),
        InputDialogSetting(
          title: 'settings-page.password'.tr(),
          lastValue: password.replaceAll(RegExp('.'), '*'), // Censor password
          hintText: '',
          onSubmit: (String password) {
            this.password = password;
            _saveSettings();
          },
        ),
        LoginButton(context: context),
        const Divider(),
        SelectorOpenerTile(
          title: 'settings-page.subjects'.tr(),
          selector: const SubjectList(),
          icon: const Icon(Icons.book),
        ),
        SelectorOpenerTile(
          title: 'settings-page.subject-names'.tr(),
          selector: const SubjectNameList(),
          icon: const Icon(Icons.abc),
        ),
        SelectorOpenerTile(
          title: 'settings-page.colors'.tr(),
          selector: const SubjectColorList(),
          icon: const Icon(Icons.palette),
        ),
        const Divider(),
        CheckboxListTile(
          secondary: const Icon(Icons.date_range),
          title: Text('settings-page.skip-weekends'.tr()),
          value: prefs.getBool('skipWeekends') ?? false,
          onChanged: (value) {
            prefs.setBool('skipWeekends', value ?? false);
            setState(() {});
          },
        ),
        SelectorOpenerTile(
          selector: const LanguageList(),
          title: 'settings-page.language'.tr(),
          icon: const Icon(Icons.language),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.info),
          title: Text('settings-page.about'.tr()),
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
