
import 'package:flutter/material.dart';

abstract class DialogProvider {
  


  static Future<T> showConfirmation<T>({@required BuildContext context,
                                  Function onYes,
                                  Function onNo,
                                  Widget title,
                                  Widget content})
  {
    return showDialog<T>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => AlertDialog(
          title: title,
          content: content,
          actions: <Widget>[
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () {
                if (onNo != null) onNo();
                Navigator.pop(context);
              }
            ),
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                if (onYes != null) onYes();
                Navigator.pop(context);
              }
            ),
          ],
        )
      );
  }

  static Future<T> showMessage<T>({@required BuildContext context,
                                  Function onYes,
                                  Widget title,
                                  Widget content})
  {
    return showDialog<T>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => AlertDialog(
          title: title,
          content: content,
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                if (onYes != null) onYes();
                Navigator.pop(context);
              }
            )
          ],
        )
      );
  }
}