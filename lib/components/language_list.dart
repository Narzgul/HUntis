import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';

class LanguageList extends StatefulWidget {
  const LanguageList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LanguageListState();
}

class _LanguageListState extends State<LanguageList> {
  @override
  Widget build(BuildContext context) {
    setState(() {}); // Crashes app if not used :(
    List<Locale> myLanguages = context.supportedLocales;
    return ListView.builder(
      physics: const ScrollPhysics(),
      shrinkWrap: true,
      itemCount: myLanguages.length,
      itemBuilder: (BuildContext context, int index) => RadioListTile<Locale>(
        value: myLanguages[index],
        groupValue: context.locale,
        title: Text(
          LocaleNames.of(context)!.nameOf(
                myLanguages[index].toStringWithSeparator(),
              ) ??
              myLanguages[index].languageCode,
        ),
        onChanged: (Locale? value) {
          setState(() {
            context.setLocale(value!);
          });
        },
      ),
    );
  }
}
