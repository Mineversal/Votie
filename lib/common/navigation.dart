import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Navigation {
  static intent(String routeName, BuildContext context) {
    GoRouter.of(context).push(routeName);
  }

  static intentWithData(
      String routeName, Object arguments, BuildContext context) {
    GoRouter.of(context).push(routeName, extra: arguments);
  }

  static intentAndReplace(String routeName, BuildContext context) {
    GoRouter.of(context).go(routeName);
  }

  static back(BuildContext context) => Navigator.pop(context);
}
