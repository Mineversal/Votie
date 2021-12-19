import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:votie/common/navigation.dart';
import 'package:votie/data/model/poll_model.dart';
import 'package:votie/data/model/user_model.dart';
import 'package:votie/ui/add_vote_page.dart';
import 'package:votie/ui/detail_vote_page.dart';
import 'package:votie/ui/home_page.dart';
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
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  UserModel userModel = UserModel();
  PollModel pollModel = PollModel();

  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  @override
  void initState() {
    initDynamicLinks();
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

  ///Retreive dynamic link firebase.
  void initDynamicLinks() async {
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      handleDynamicLink(deepLink);
    }
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      if (deepLink != null) {
        handleDynamicLink(deepLink);
      }
    }).onError((error) {
      var snackbar = SnackBar(content: Text(error));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    });
    /*
    (
        onSuccess: (PendingDynamicLinkData? dynamicLink) async {
      final Uri? deepLink = dynamicLink?.link;

      if (deepLink != null) {
        handleDynamicLink(deepLink);
      }
    }, onError: (OnLinkErrorException e) async {
      print(e.message);
    });
    */
  }

  handleDynamicLink(Uri url) {
    List<String> separatedString = [];
    separatedString.addAll(url.path.split('/'));
    if (separatedString[1] == "poll") {
      String id = separatedString[2];
      firestore
          .collection('polls')
          .where("id", isEqualTo: id.toUpperCase())
          .get()
          .then((value) {
        if (value.size > 0) {
          pollModel = PollModel.fromDoc(value.docs[0]);
          if (pollModel.show == true) {
            firestore.collection("polls").doc(id.toUpperCase()).update({
              'users': FieldValue.arrayUnion([userModel.username])
            });
            // const snackbar = SnackBar(
            //     content: Text("Voting code has been successfully reedemed"));
            // ScaffoldMessenger.of(context).showSnackBar(snackbar);
            Navigation.intentWithMultipleData(
              DetailVote.routeName,
              {'pollModel': pollModel, 'userModel': userModel},
            );
            return;
          } else {
            const snackbar =
                SnackBar(content: Text("Voting code has been expired"));
            ScaffoldMessenger.of(context).showSnackBar(snackbar);
            return;
          }
        } else {
          const snackbar = SnackBar(content: Text("Voting code is not found"));
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
          return;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        exitDialog();
        return Future.value(false);
      },
      child: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        screenTransitionAnimation: const ScreenTransitionAnimation(
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        ),
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
      ),
    );
  }

  Future<dynamic> exitDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Are you sure?',
          style: Theme.of(context).textTheme.headline6,
        ),
        content: Text(
          'Do you want exit Votie?',
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
              primary: colorRed,
              backgroundColor: Colors.transparent,
              textStyle: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          const SizedBox(width: 1),
          ElevatedButton(
            child: const Text("EXIT"),
            onPressed: () {
              SystemNavigator.pop();
            },
            style: TextButton.styleFrom(
              primary: Colors.white,
              backgroundColor: colorGreen,
              textStyle: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  List<Widget> _buildScreens() {
    return [
      Home(userModel: userModel),
      AddVote(userModel: userModel),
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
