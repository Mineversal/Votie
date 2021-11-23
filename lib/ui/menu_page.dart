import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:votie/data/model/user_model.dart';
import 'package:votie/ui/login_page.dart';

class Menu extends StatefulWidget {
  static const routeName = '/menu';
  const Menu({Key? key}) : super(key: key);

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  User? user = FirebaseAuth.instance.currentUser;

  UserModel userModel = UserModel();

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
    return Center(
      child: Column(children: [
        const Text("Kamu Berhasil Login"),
        Text(userModel.name.toString()),
        Text(userModel.username.toString()),
        Text(userModel.email.toString()),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: CupertinoButton.filled(
            onPressed: () => logout(),
            child: const Text("Logout"),
          ),
        ),
      ]),
    );
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, Login.routeName);
  }
}
