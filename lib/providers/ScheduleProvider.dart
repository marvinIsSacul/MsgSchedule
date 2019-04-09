
import 'dart:async';

import 'package:msgschedule_2/models/Message.dart';
import 'package:msgschedule_2/models/Settings.dart';
import 'package:msgschedule_2/providers/MessageProvider.dart';
import 'package:msgschedule_2/providers/SettingsProvider.dart';
import 'package:sms/sms.dart';


///
class ScheduleProvider {

  Timer _timer;
  final StreamController<Message> _ctrlMsg = StreamController();
  final StreamController<List<Message>> _ctrlMsgs = StreamController();
  StreamSubscription _subMsg;
  StreamSubscription _subMsgs;


  /// Constructs a sheduler using the given [onMessageProcessed] and [onScheduleProcessed] listeners.
  ScheduleProvider({dynamic Function(Message) onMessageProcessed, dynamic Function(List<Message>) onScheduleProcessed}) {
    if (onMessageProcessed != null) this.onMessageProcessed = onMessageProcessed;
    if (onScheduleProcessed != null) this.onScheduleProcessed = onScheduleProcessed;
  }

  /// Starts executing the schedule periodically according to the given [duration].
  void start(Duration duration) {
    stop();
    _subMsg?.resume();
    _subMsgs?.resume();
    _timer = Timer.periodic(duration, (Timer t) => this._processSchedule());
  }

  /// Stops executing the schedule perdiodically, and stops calling any listeners/callbacks attached.
  /// Note that the listeners attached aren't removed, they just aren't called until start is called again.
  void stop() {
    _timer?.cancel();
    _subMsg?.pause();
    _subMsgs?.pause();
  }


  /// Sets the callback to be invoked whenever a single message has been processed.
  set onMessageProcessed(Function(Message) onData) {
    assert(onData != null);

    _subMsg?.cancel();
    _subMsg = _ctrlMsg.stream.listen((Message message) => onData(message));
  }

  /// Sets the callback to be invoked whenever the entire schedule has been processed.
  set onScheduleProcessed(Function(List<Message>) onDone) {
    assert(onDone != null);

    _subMsgs?.cancel();
    _subMsgs = _ctrlMsgs.stream.listen((List<Message> messages) => onDone(messages));
  }


  /// Frees the resources allocated with this object. Making the object un-usable.
  void dispose() {
    _timer.cancel();
    _subMsg?.cancel();
    _subMsgs?.cancel();
    _ctrlMsg.close();
    _ctrlMsgs.close();
  }

  void _processSms(Message message) async {
    final provider = SimCardsProvider();
    final int simSlot = (await SettingsProvider.getInstance().getSettings()).sms.simcard.index;
    final SimCard simToUse = (await provider.getSimCards())[simSlot];
   // final Settings settings = await SettingsProvider.getInstance().getSettings();

    final sender = SmsSender();
    final SmsMessage smsMessage = SmsMessage(message.endpoint, message.content, id: message.id);

    smsMessage.onStateChanged.listen((SmsMessageState state) async {
      
      if (state == SmsMessageState.Sent) {
        message.status = MessageStatus.SENT;
        message.attempts++;
        
        _ctrlMsg.sink.add(message);
      }
      else if (state == SmsMessageState.Fail) {
        message.status = MessageStatus.FAILED;
        message.attempts++;

        _ctrlMsg.sink.add(message);
      }

      // I might use this guy later.
      else if (state == SmsMessageState.Delivered) {
        
      }
    });

    await sender.sendSms(smsMessage, simCard: simToUse);
  }

  void _processSchedule() async {
    
    final Settings settings = await SettingsProvider.getInstance().getSettings();
    final messages = await MessageProvider.getInstance().getMessages();

    messages
    .takeWhile((Message message) =>
      (
        message.status == MessageStatus.PENDING
        ||
        (message.status == MessageStatus.FAILED &&
          (settings.message.maxAttempts == null || message.attempts < settings.message.maxAttempts)
        )
      )
      &&
      DateTime.now().millisecondsSinceEpoch >= message.executedAt
    )
    .forEach((Message message) {
      switch (message.driver){
        case MessageDriver.SMS:
          _processSms(message);
          break;

        case MessageDriver.FACEBOOK:
          break;
      }
    });

    if (messages.length > 0)
      _ctrlMsgs.sink.add(messages);
  }
}