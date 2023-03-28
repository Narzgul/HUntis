import 'package:flutter/material.dart';
import 'package:huntis/components/input_dialog_setting.dart';
import 'package:huntis/components/subject_selector.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String serverURL = '', school = '', username = '', password = '';

  _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      serverURL = prefs.getString('serverURL') ?? '';
      school = prefs.getString('school') ?? '';
      username = prefs.getString('username') ?? '';
      password = prefs.getString('password') ?? '';
    });
  }

  _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
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
        const SubjectSelector()
      ],
    );
  }
}
