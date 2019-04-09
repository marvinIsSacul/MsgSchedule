
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

class AppPermissions extends StatefulWidget {

  _AppPermissionsState createState() => _AppPermissionsState();
}

class _AppPermissionsState extends State<AppPermissions> {
  bool _isGranted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Permissions'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Permissions Requested',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30.0
                ),
              ),
              Text(
                'Please accept permissions in order to be able to use the app.',
                style: TextStyle(
                  fontSize: 15.0
                )
              ),
              Text('is granted: ' + (_isGranted.toString()))
            ],
          )
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onAcceptPermissions(),
        child: Icon(Icons.perm_device_information, color: Colors.white),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }

  void _onAcceptPermissions() async {
    final List<PermissionGroup> neededPermissions = [
      PermissionGroup.sms, PermissionGroup.phone, PermissionGroup.contacts
    ];
    final List<PermissionGroup> nonGrantedPermissions = [];
    
    neededPermissions.forEach((p) async {
      PermissionStatus permission = await PermissionHandler().checkPermissionStatus(p);
      if (permission != PermissionStatus.granted)
        nonGrantedPermissions.add(p);
    });

    final Map<PermissionGroup, PermissionStatus> requestedPermissions = await PermissionHandler().requestPermissions(nonGrantedPermissions);
    //bool status = true;
    requestedPermissions.forEach((p, s) {
      if (s != PermissionStatus.granted) {
        setState(() {
          _isGranted = false;
        });
      }
    });
  }
}