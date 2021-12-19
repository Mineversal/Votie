import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:votie/common/navigation.dart';
import 'package:votie/common/style.dart';
import 'package:votie/ui/menu_page.dart';

class NotFoundPage extends StatelessWidget {
  static String routeName = '/notFoundPage';
  const NotFoundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SvgPicture.asset(
                  'assets/images/no_connection.svg',
                  fit: BoxFit.fill,
                ),
                Container(
                  margin: const EdgeInsets.only(
                      left: 40.0, right: 40.0, top: 40.0, bottom: 30.0),
                  child: Text(
                    'Page not found.',
                    style: textMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigation.intent(Menu.routeName, context);
                  },
                  child: const Text('Home'),
                  style: ElevatedButton.styleFrom(primary: colorGreen),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
