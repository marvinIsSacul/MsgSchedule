
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:msgschedule_2/models/Message.dart';
import 'package:msgschedule_2/pages/schedule/ViewMessage.dart';
import 'package:msgschedule_2/providers/DateTimeFormator.dart';
import 'package:sms/contact.dart';



class Schedule extends StatefulWidget {
  final List<Message> _list;
  final Function _onListChanged;

  const Schedule(this._list, [this._onListChanged]);

  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  Map<String, String> _numberNameMapper = Map();

  void _listChanged() {
    if (widget._onListChanged != null)
      widget._onListChanged();
    _mapNamesToNumbers();
  }

  @override
  void initState() {
    super.initState();
    _mapNamesToNumbers();

    Timer(Duration(seconds: 1), () {
      if (this.mounted)
        setState(() => _mapNamesToNumbers());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),

      child: widget._list == null ? Center(
        child: CircularProgressIndicator()
      ) 
      :
      widget._list.length == 0 ? Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text('No Messages.', style: TextStyle(fontSize: 22)),
          ],
        ) 
        :
        _buildList(context)
    );
  }

  Widget _buildList(BuildContext context) {

    return ListView.builder(
      itemCount: widget._list.length,
      itemBuilder: (BuildContext context, int index) {
        final Message message = widget._list.elementAt(index);
       // final DateTime executedAt = DateTime.fromMillisecondsSinceEpoch(message.executedAt);
        const maxMsgLen = 20;
        const iconSize = 20.0;

        return /* Dismissible(
            onDismissed: (DismissDirection dd) async {
              message.isArchived = true;
              await MessageProvider.getInstance().updateMessage(message);
              _listChanged();
            },
            direction: DismissDirection.horizontal,
            dismissThresholds: {
              DismissDirection.horizontal: 0.2,
            },
            secondaryBackground: Icon(Icons.archive, color: Colors.brown),
            background: Icon(Icons.archive, color: Colors.brown),
            confirmDismiss: (DismissDirection dd) async {
              return true;
            },
            key: Key(message.id.toString()),
            child: */ ListTile(
                isThreeLine: true,
                leading: Icon(message.driver == MessageDriver.SMS ? Icons.textsms : Icons.cloud),
                title: Text(_numberNameMapper[message.endpoint] ?? message.endpoint),
                subtitle: Text(
                  message.content.substring(0, message.content.length > maxMsgLen ? maxMsgLen : null) +
                  (message.content.length > maxMsgLen ? '...' : ''),
                  overflow: TextOverflow.ellipsis,
                  //maxLines: 1,
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Icon(
                      message.status == MessageStatus.SENT ? Icons.done
                        : message.status == MessageStatus.PENDING ? Icons.schedule : Icons.error,
                      size: iconSize
                    ),

                    Text(DateTimeFormator.timespan(DateTime.fromMillisecondsSinceEpoch(message.executedAt), units: 1))
                  ]
                ),
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute<bool>(builder: (context) => ViewMessage(message)),
                  )
                    .then((bool result) {
                      _listChanged();
                    });
                },
       //   )
        );
      }
    );
  }

  void _mapNamesToNumbers() {
    ContactQuery contacts = ContactQuery();
    
    widget?._list?.forEach((Message message) async {
      final Contact contact = await contacts.queryContact(message.endpoint);
      if (contact?.fullName != null) {
        _numberNameMapper[message.endpoint] = contact.fullName;
      }
    });

    
  }
}