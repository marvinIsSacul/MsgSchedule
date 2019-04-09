
import 'dart:async';

import 'package:msgschedule_2/models/Message.dart';
import 'package:msgschedule_2/providers/MessageProvider.dart';


/// Message Bloc.

class MessageBloc {
  final _mp = MessageProvider.getInstance();
  final _ctrl = StreamController<List<Message>>.broadcast();
  List<Message> _list = List();

  Stream get stream => _ctrl.stream;


  void dispose() {
    _ctrl.close();
    //_mp.dispose(); // since MessageProvider is a singleton. it should only be disposed once, globally. 
  }

  void loadMessages({MessageStatus status, int count}) async {
    final messages = await _mp.getMessages(status: status, count: count);
    _list = messages;
    _ctrl.sink.add(messages);
  }

  void truncateTables() async {
    await _mp.truncateTables();
    await _ctrl.stream.drain();
    _list.clear();
    _ctrl.sink.add(List<Message>());
  }

  void deleteAllMessages() {
    truncateTables();
  }

  Future<bool> addMessage(final Message message) async {
    final bool r = await _mp.addMessage(message);
    _ctrl.sink.add(_list..add(message));
    return r;
  }

  Future<bool> updateMessage(final Message message) async {
    final bool r = await _mp.updateMessage(message);

    for (int i = 0; i < _list.length; ++i)
      // if message already exists, then just update the message in the list,
      // and emit the list as is (without any new elements).
      if (_list[i].id == message.id){
        _list[i] = message;
        _ctrl.sink.add(_list);
        return r;
      }

    // if message doesn't already exist, the add the message in the list,
    // and emit the list (with a newly added element).
    _ctrl.sink.add(_list..add(message));

    return r;
  }
}