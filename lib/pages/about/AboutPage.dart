import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AboutPage extends StatelessWidget {

  AboutPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
        primary: true
      ),
      body: AboutDialog(
       // applicationName: 'MsgSchedule',
        applicationVersion: '0.0.1',
        children: <Widget>[
          Text('hi')
        ],
      )
    );
  }
}