import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:votie/common/navigation.dart';
import 'package:votie/ui/login_page.dart';
import 'package:votie/ui/menu_page.dart';
import 'package:votie/ui/register_page.dart';
import 'package:votie/ui/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Votie',
      theme: ThemeData(visualDensity: VisualDensity.adaptivePlatformDensity),
      debugShowCheckedModeBanner: false,
      initialRoute: SplashScreen.routeName,
      navigatorKey: navigatorKey,
      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        Login.routeName: (context) => const Login(),
        Register.routeName: (context) => const Register(),
        Menu.routeName: (context) => const Menu(),
        /*
        RestaurantDetailPage.routeName: (context) => RestaurantDetailPage(
            restaurant:
                ModalRoute.of(context)?.settings.arguments as Restaurant),
        */
      },
    );
  }
}
