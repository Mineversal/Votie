import 'package:flutter/material.dart';
import 'package:votie/common/navigation.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:votie/widget/no_connection_page.dart';

class ConnectionHelper {
  static Future<bool> checkConnection(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      Navigation.intent(NoConnectionPage.routeName, context);
      return false;
    }
    return true;
  }
}
