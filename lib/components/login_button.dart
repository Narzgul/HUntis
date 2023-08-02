import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../untis_api.dart';

class LoginButton extends ElevatedButton {
  LoginButton({Key? key, required BuildContext context})
      : super(
          key: key,
          onPressed: () async {
            GetIt getIt = GetIt.instance;
            SharedPreferences prefs = getIt<SharedPreferences>();

            if (getIt.isRegistered<Session>()) {
              getIt.unregister<Session>();
            }
            getIt.registerSingleton<Session>(
              Session.initNoLogin(
                prefs.getString('serverURL') ?? '',
                prefs.getString('school') ?? '',
                prefs.getString('username') ?? '',
                prefs.getString('password') ?? '',
              ),
            );

            if (getIt<Session>().isLoggedIn) {
              await getIt<Session>().logout();
            }
            int status = await getIt<Session>().login();
            if (context.mounted) {
              // Check if SnackBar can still be shown
              switch (status) {
                case 401:
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bad credentials'),
                    ),
                  );
                  break;
                case 200:
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Login successful'),
                    ),
                  );
                  break;
              }
            }
          },
          child: const Text('Login'),
        );
}
