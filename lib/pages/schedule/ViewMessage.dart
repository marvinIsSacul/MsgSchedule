
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:msgschedule_2/models/Message.dart';
import 'package:msgschedule_2/pages/schedule/CreateOrEditSmsMessagePage.dart';
import 'package:msgschedule_2/providers/DateTimeFormator.dart';
import 'package:msgschedule_2/providers/DialogProvider.dart';
import 'package:msgschedule_2/providers/MessageProvider.dart';


/// Displays a message in a more descriptive manner.

class ViewMessage extends StatefulWidget {
  final Message message;

  const ViewMessage(this.message);

  @override
  _ViewMessageState createState() => _ViewMessageState();
}


class _ViewMessageState extends State<ViewMessage> {
  
  Message _message;
  bool _isMessageEditable() => _message.status != MessageStatus.PENDING;


  @override
  void initState() {
    super.initState();

    // clone this object.
    _message = Message.fromJson(widget.message.toJson());
  }

  /// builds the app bar.
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('View Message'),
      actions: <Widget>[
        GestureDetector(
          child: Icon(
            Icons.edit,
            color: _isMessageEditable() ? Colors.grey : Colors.white
          ),
          onTap: _isMessageEditable() ? null :
            () {
              Navigator.push(
                context,
                MaterialPageRoute<bool>(builder: (context) => CreateOrEditSmsMessagePage(MessageMode.edit, _message)),
              )
                .then((bool result) async {
                  final Message message = await MessageProvider.getInstance().getMessage(_message.id);
                  setState(() => _message = message);
                });
            },
        ),
        Padding(
          padding: EdgeInsets.only(left: 8.0, right: 8.0),
          child: GestureDetector(
            child: Icon(Icons.delete),
            onTap: () async {
              await DialogProvider.showConfirmation(
                context: context,
                title: Text('Delete Message'),
                content: Text('Really delete message forever?'),
                onYes: () async {
                  if (await MessageProvider.getInstance().removeMessage(_message.id))
                    Navigator.pop(context);
                  else {
                    DialogProvider.showMessage(
                      context: context,
                      title: Text('Error'),
                      content: Text('Could not delete message.')
                    );
                  }
                }
              );
            }
          ),
        )
      ], 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),

      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 20.0),
                    child: Text('Message Details', style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold
                    )),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                    child: Table(
                    // defaultColumnWidth: ,
                      children: <TableRow>[
                        TableRow(
                          children: [
                            Text('Type:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(_message.driver.toString())
                          ]
                        ),
                        TableRow(
                          children: [
                            Text('To:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(_message.endpoint)
                          ]
                        ),
                        TableRow(
                          children: [
                            Text('Created:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(DateTimeFormator.formatDateTime(DateTime.fromMillisecondsSinceEpoch(_message.createdAt)))
                          ]
                        ),
                        TableRow(
                          children: [
                            Text('Scheduled:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(DateTimeFormator.formatDateTime(DateTime.fromMillisecondsSinceEpoch(_message.executedAt)))
                          ]
                        ),
                        TableRow(
                          children: [
                            Text('Attempts:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(_message.attempts.toString())
                          ]
                        ),
                        TableRow(
                          children: [
                            Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(_message.status.toString())
                          ]
                        ),
                      ],
                    )
                  )
                ]
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 25.0, right: 20.0, top: 8.0, bottom: 8.0),
            child: Row(
              children: <Widget>[
                Icon(Icons.person, size: 35.0, color: Colors.deepOrange),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: Card(
                    color: Colors.brown,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 2.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            _message.content,
                            maxLines: null,
                            style: TextStyle(
                              fontSize: 16.9,
                              color: Color(0xFFFFFFFF)
                            ),
                            textAlign: TextAlign.left,
                          ),
                          Divider(color: Color(0x00000000)),  // 0 alpha (invisible)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget> [
                              Text(
                                DateTimeFormator.timespan(DateTime.fromMillisecondsSinceEpoch(_message.executedAt), units: 1),
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: Color(0xDDFDFDFD),
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              Icon(
                                _message.status == MessageStatus.PENDING ? Icons.schedule :
                              _message.status == MessageStatus.SENT ? Icons.done : Icons.error,
                                color: Colors.white,
                                size: 16.0,
                              )
                            ]
                          )
                        ]
                      )
                    )
                  )
                )
              ],
            )
          )
        ],
      )
    );
  }
}