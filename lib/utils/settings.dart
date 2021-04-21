import 'dart:io';

import 'package:alarm_recorder/Translate/app_localizations.dart';
import 'package:alarm_recorder/Translate/change_language.dart';
import 'package:flutter/material.dart';

import 'about.dart';

class MySettings extends StatefulWidget {
  @override
  _MySettingsState createState() => _MySettingsState();
}

class _MySettingsState extends State<MySettings> {
  bool isIos;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkPlatform();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate("settings"),
            style: TextStyle(
              color: Colors.grey[700],
            )),
        leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back,
              color: Colors.grey[700],
            )),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey[100],
        child: Column(
          children: <Widget>[
            Card(
              child: ListTile(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return ChangeLanguage();
                  }));
                },
                leading: Icon(
                  Icons.language,
                  color: Colors.blueAccent,
                ),
                title: Text(
                    AppLocalizations.of(context).translate("change_language"),
                    style: TextStyle(color: Colors.grey[700])),
                trailing: Icon(
                  Icons.arrow_forward,
                  color: Colors.grey[700],
                ),
              ),
            ),
            isIos == false
                ? Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.info_outline,
                        color: Colors.blueAccent,
                      ),
                      title: Text(
                          AppLocalizations.of(context).translate("contact_us"),
                          style: TextStyle(color: Colors.grey[700])),
                      trailing: Icon(
                        Icons.arrow_forward,
                        color: Colors.grey[700],
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext context) {
                          return ContactUs();
                        }));
                      },
                    ),
                  )
                : Text(""),
          ],
        ),
      ),
    );
  }

  checkPlatform() {
    if (Platform.isIOS) {
      setState(() {
        isIos = true;
      });
    } else {
      isIos = false;
    }
  }
}
