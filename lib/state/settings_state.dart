import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState with ChangeNotifier {
  bool darkTheme = false;
  SharedPreferences _sharedPreferences;

  SettingsState() {

  }

  Future init() async {
    this._sharedPreferences = await SharedPreferences.getInstance();

    darkTheme = _sharedPreferences.getBool('darkTheme');
    if (darkTheme == null) {
      darkTheme = false;
      await setDarkTheme(false);
    }
  }

  Future setDarkTheme(bool darkThemeState) async {
    this.darkTheme = darkThemeState;
    notifyListeners();

    await _sharedPreferences.setBool('darkTheme', darkThemeState);
  }
}