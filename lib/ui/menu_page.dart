import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:votie/data/model/user_model.dart';
import 'package:votie/ui/add_vote_page.dart';
import 'package:votie/ui/home_page.dart';
import 'package:votie/ui/login_page.dart';
import 'package:votie/ui/profile_page.dart';
import 'package:votie/common/style.dart';

class Menu extends StatefulWidget {
  static const routeName = '/menu';
  const Menu({Key? key}) : super(key: key);

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  User? user = FirebaseAuth.instance.currentUser;

  UserModel userModel = UserModel();

  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      userModel = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      decoration: NavBarDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.09),
            spreadRadius: 5,
            blurRadius: 20,
            offset: const Offset(0, -2), // changes position of shadow
          ),
        ],
      ),
    );
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, Login.routeName);
  }

  List<Widget> _buildScreens() {
    return [
      const Home(),
      const AddVote(),
      Profile(userModel: userModel),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home),
        title: ("Home"),
        activeColorPrimary: colorOrange,
        inactiveColorPrimary: colorGray,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.add_circle),
        title: ("Add"),
        activeColorPrimary: colorGreen,
        inactiveColorPrimary: colorGray,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person),
        title: ("Profile"),
        activeColorPrimary: colorBlue,
        inactiveColorPrimary: colorGray,
      ),
    ];
  }
}
