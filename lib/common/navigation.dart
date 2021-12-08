import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class Navigation {
  static intent(String routeName) {
    navigatorKey.currentState?.pushNamed(routeName);
  }

  static intentWithData(String routeName, Object arguments) {
    navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }

  static intentWithMultipleData(
      String routeName, Map<String, Object> arguments) {
    navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }

  static intentAndReplace(String routeName) {
    navigatorKey.currentState?.pushReplacementNamed(routeName);
  }

  static back() => navigatorKey.currentState?.pop();
}
