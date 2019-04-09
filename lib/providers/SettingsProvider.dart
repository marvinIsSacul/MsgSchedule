
import 'dart:convert';

import 'package:msgschedule_2/models/Settings.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// Settings Provider.

class SettingsProvider {

  SharedPreferences _sp;
  
  static final SettingsProvider _ins = SettingsProvider._();

  static const _KEY = '_settings';


  SettingsProvider._() {
    _init();
  }

  _init() async {
    _sp = await SharedPreferences.getInstance();
  }

  static SettingsProvider getInstance() => _ins;

  /// Gets the default settings.
  static Settings getDefaultSettings() {
    final Settings settings = Settings();

    settings.version = Settings.revision;

    settings.message.maxAttempts = MessageSettings.maxMessageAttempts;
    
    settings.sms.maxSmsCount = 1;
    settings.sms.simcard = SimCards.sim1;    // simcard as sim slot 1.

    settings.system.shouldAutoCheckUpdates = false;
    settings.system.shouldShowMessageFailedNotifications = true;
    settings.system.shouldShowMessageSentNotifications = true;
    settings.system.shouldShowNotifications = false;

    return settings;
  }

  /// Gets the currently set settings,
  /// or the default settings should there be no currenlty set settings or settings have been upgraded.
  Future<Settings> getSettings() async {
    await _init();

    final String stringData = _sp.getString(_KEY);

    // if settings don't exist
    // or they are too old (version is less than the current version),
    // then set default (new) settings.
    if (stringData == null || (Settings.fromJson(jsonDecode(stringData)).version != Settings.revision)){
      setDefaultSettings();
      return getDefaultSettings();
    }

    return Settings.fromJson(jsonDecode(stringData));
  }

  Future<bool> setSettings (Settings settings) async {
    await _init();

    bool i = await _sp.setString(_KEY, jsonEncode(settings));
    return i;
  }

  /// Sets the current settings, to be that of the default settings.
  void setDefaultSettings() {
    setSettings(getDefaultSettings());
  }
}