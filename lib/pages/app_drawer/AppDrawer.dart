

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:msgschedule_2/pages/about/AboutPage.dart';
import 'package:msgschedule_2/pages/settings/SettingsPage.dart';


class AppDrawer extends StatefulWidget {

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  
  final double _iconSize = 30.0;
  final _textStyle = TextStyle(
    //fontWeight: FontWeight.bold,
    color: Colors.white,
    fontSize: 22.0
  );
  final _iconColor = Colors.white;
  

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      semanticLabel: 'Application Drawer',
      child: Container(
        color: Colors.brown,
        padding: EdgeInsets.all(1.0),
        child: ListView(
          children: <Widget>[
            ListTile(
              dense: true,
              leading: Icon(Icons.settings, size: _iconSize, color: _iconColor),
              title: Text('Settings', style: _textStyle),
              onTap: () => _openPage(SettingsPage()),
            ),
            Divider(color: Colors.white),
            ListTile(
              leading: Icon(Icons.info, size: _iconSize, color: _iconColor),
              title: Text('About', style: _textStyle),
              onTap: () => _openPage(AboutPage())
            )
          ],
        ),
      ),
    );
  }

  void _openPage(Widget page) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute<bool>(builder: (context) => page),
    );
  }

}