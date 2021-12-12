import 'package:votie/common/navigation.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:votie/widget/no_connection_page.dart';

class ConnectionHelper {
  static Future<bool> checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      Navigation.intent(NoConnectionPage.routeName);
      return false;
    }
    return true;
  }
}
