import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:votie/common/navigation.dart';
import 'package:votie/common/style.dart';
import 'package:votie/data/model/user_model.dart';
import 'package:votie/ui/login_page.dart';

class Profile extends StatelessWidget {
  final UserModel userModel;

  const Profile({Key? key, required this.userModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: SvgPicture.asset(
                    'assets/images/bg_blue.svg',
                    fit: BoxFit.fill,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 40.0),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.logout),
                          color: Colors.white,
                          onPressed: () {
                            logout(context);
                          },
                        ),
                      ),
                      Image.asset('assets/images/profile_placeholder.png'),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.06),
                    spreadRadius: 5,
                    blurRadius: 20,
                    offset: const Offset(2, 2), // changes position of shadow
                  ),
                ],
              ),
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              padding: const EdgeInsets.all(20.0),
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 5.0),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Name',
                      style: textRegular,
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(bottom: 15.0),
                    child: Text(
                      userModel.name.toString(),
                      style: textBoldBlack,
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(bottom: 5.0),
                    child: Text(
                      'Username',
                      style: textRegular,
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(bottom: 15.0),
                    child: Text(
                      userModel.username.toString(),
                      style: textBoldBlack,
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(bottom: 5.0),
                    child: Text(
                      'Email',
                      style: textRegular,
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(bottom: 15.0),
                    child: Text(
                      userModel.email.toString(),
                      style: textBoldBlack,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> logout(context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Are you sure?',
          style: Theme.of(context).textTheme.headline6,
        ),
        content: Text(
          'Do you want Logout?',
          style: Theme.of(context).textTheme.subtitle2,
        ),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8))),
        actions: [
          TextButton(
            child: const Text("CANCEL"),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            style: TextButton.styleFrom(
              primary: colorBlue,
              backgroundColor: Colors.transparent,
              textStyle: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          const SizedBox(width: 1),
          ElevatedButton(
            child: const Text("LOGOUT"),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigation.intentAndReplace(Login.routeName);
            },
            style: TextButton.styleFrom(
              primary: Colors.white,
              backgroundColor: colorRed,
              textStyle: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
