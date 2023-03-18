import 'package:flutter/material.dart';
import 'package:huntis/components/input_dialog_setting.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  var serverURL = '', school = '', username = '', password = '';

  _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      serverURL = prefs.getString('serverURL') ?? '';
      username = prefs.getString('username') ?? '';
    });
  }

  _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('serverURL', serverURL);
      prefs.setString('username', username);
    });
  }

  @override
  Widget build(BuildContext context) {
    _loadSettings();

    return ListView(
      children: [
        InputDialogSetting(
          title: 'Server URL',
          subTitle: serverURL,
          hintText: 'ajax.webuntis.com',
          onSubmit: (String serverURL) {
            this.serverURL = serverURL;
            _saveSettings();
          },
        ),
        InputDialogSetting(
          title: 'School',
          subTitle: school,
          hintText: 'lindengym-gummersbach',
          onSubmit: (String school) {
            this.school = school;
            _saveSettings();
          },
        ),
        InputDialogSetting(
          title: 'Username',
          subTitle: username,
          hintText: 'ajax.webuntis.com',
          onSubmit: (String username) {
            this.username = username;
            _saveSettings();
          },
        ),
        InputDialogSetting(
          title: 'Password',
          subTitle: password.replaceAll(RegExp('.'), '*'), // Censor password
          hintText: password,
          onSubmit: (String password) {
            this.password = password;
            _saveSettings();
          },
        ),
      ],
    );
  }
}
