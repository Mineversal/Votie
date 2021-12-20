import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBannerProvider extends ChangeNotifier {
  bool isShown = true;
  final Future<SharedPreferences> sharedPref;
  static String prefKey = 'isBannerShown';

  AppBannerProvider({required this.sharedPref}) {
    isBannerShown();
  }

  isBannerShown() async {
    final pref = await sharedPref;
    isShown = pref.getBool(prefKey) ?? true;
    notifyListeners();
  }

  hide() async {
    final pref = await sharedPref;
    isShown = false;
    notifyListeners();
    pref.setBool(prefKey, isShown);
  }
}
