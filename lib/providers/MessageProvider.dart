import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'package:msgschedule_2/models/Message.dart';


class MessageProvider {

  static final MessageProvider _instance = MessageProvider._();
  static bool _isInit = false;
  
  Database _database;

  final String _tblMessages = 'Messages';
 // final String _tblMessageExecutions = 'MessageExecutions';

  MessageProvider._() {
    
    _init();
  }

  bool get isReady => _isInit;

  Future<Database> _init() async {
    
    Directory appDocDir = await getApplicationDocumentsDirectory();
    final documentsDirectory = appDocDir.path;
    Database _db;

    _database = await openDatabase(
      join(documentsDirectory, 'messages.db'),
      version: 1,
      onCreate: (Database db, int version)  { _db = db; debugPrint('on database create'); _createTables(db: db); },
      onUpgrade: (Database db, int oldVersion, int newVersion) { _db = db; debugPrint('on database upgrade'); _dropTables(db: db); _createTables(db: db); },
      onOpen: (Database db) { _db = db; debugPrint('on database open');  }
    );

    _isInit = true;

    return _database ?? (_database = _db);
  }

  _dropTables({Database db}) async {
    db ??= _database;
    await db.execute('DROP TABLE $_tblMessages');
  }

  _createTables({Database db}) async {
    debugPrint('database tables created.');

    db ??= _database;

    await db.transaction((Transaction tx) async {
      await tx.execute('''
      CREATE TABLE $_tblMessages (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          content TEXT,
          driver INTEGER,
          endpoint TEXT,
          createdAt INTEGER,
          executedAt INTEGER,
          status INTEGER,
          attempts INTEGER,
          isArchived INTEGER
        );
      ''');

      /*await tx.execute('''CREATE TABLE $_tblMessageExecutions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          message_id INTEGER,
          status INTEGER
        );
      '''); */
    });
  }

  static MessageProvider getInstance() {
    if (_isInit == false){
     _instance._init();
    }
    return _instance;
  }

  /// Deletes a message based on its id.
  Future<bool> removeMessage(int messageId) async {
    Database db = await _init();
    _database ??= db;

    int r = 0;
    
    await _database.transaction((Transaction tx) async {
      r = await tx.rawDelete(
        'DELETE FROM $_tblMessages '
        'WHERE id = ?',
        [messageId]
      );

      /*await tx.rawDelete('''
        DELETE FROM $_tblMessageExecutions
        WHERE id = $messageId;
      ''');*/
    });

    return r != 0;
  }

  /// Inserts a new message.
  Future<bool> addMessage(final Message message) async {
    Database db = await _init();
    _database ??= db;

    final int i = await _database.rawInsert(
      'INSERT INTO $_tblMessages '
      'VALUES (NULL, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      message.content,
      message.driver.index,
      message.endpoint,
      message.createdAt,
      message.executedAt,
      message.status.index,
      message.attempts,
      message.isArchived
    ]);

    return i >= 1;
  }

  /// Updates the given message using [Message.id]
  Future<bool> updateMessage(final Message message) async {
    Database db = await _init();
    _database ??= db;

    final int i = await _database.rawUpdate(
      'UPDATE $_tblMessages '
      'SET content = ?, '
          'driver = ?, '
          'endpoint = ?, '
          'createdAt = ?, '
          'executedAt = ?, '
          'status = ?, '
          'attempts = ?, '
          'isArchived = ? '
      'WHERE id = ?', [
      message.content,
      message.driver.index,
      message.endpoint,
      message.createdAt,
      message.executedAt,
      message.status.index,
      message.attempts,
      message.isArchived ? 1 : 0,
      message.id
    ]);

    return i >= 1;
  }

  /// Gets a message using its id.
  Future<Message> getMessage(int id) async {
    Database db = await _init();
    _database ??= db;

    final List<Map<String, dynamic>> rows = await _database.rawQuery('SELECT * FROM $_tblMessages WHERE id = $id;');

    if (rows.length == 0)
      return null;
    else{
      return Message.fromJson(rows[0]);
    }
  }

  /// Gets the messages.
  Future<List<Message>> getMessages({MessageStatus status, int count, String order}) async {
    String where = '';
    String limit = '';

    Database db = await _init();
    _database ??= db;

    if (status != null) where += 'status = ${status.index}';
    if (count != null) {}
    if (order == null) order = 'ORDER BY id DESC';

    final List<Map<String, dynamic>> rows = await _database.rawQuery('SELECT * FROM $_tblMessages $where $limit $order;');
    final List<Message> messages = List();

    rows.forEach((Map<String, dynamic> row) => messages.add(Message.fromJson(row)));

    return messages;
  }

  Future<List<Message>> getFailedMessages({int count}) =>
    getMessages(status: MessageStatus.FAILED, count: count);
  
  Future<List<Message>> getSentMessages({int count}) =>
    getMessages(status: MessageStatus.SENT, count: count);
  
  Future<List<Message>> getPendingMessages({int count}) =>
    getMessages(status: MessageStatus.PENDING, count: count);

  /// Empties the tables.
  Future<bool> deleteAllMessages() {
    return truncateTables();
  }

  /// Frees the database resources.
  void dispose() {
    if (_database != null && _database.isOpen) {
      debugPrint('on close database');
      _database.close()
        .then((_) => _database = null);
    }
  }

  /// Empties the tables.
  Future<bool> truncateTables() async {
    await _database.rawQuery("DELETE FROM $_tblMessages;");
    return true;
  }

  static Message get randomMessage {
    final message = Message();

    message.id = 32;
    message.attempts = 1;
    message.driver = MessageDriver.SMS;
    message.content = 'Die today or die';
    message.createdAt = DateTime.now().millisecondsSinceEpoch;
    message.executedAt = DateTime.now().millisecondsSinceEpoch;
    message.endpoint = '409350345';
    message.status = MessageStatus.PENDING;
    message.isArchived = false;

    return message;
  }
}