import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  static const routeName = '/menu';
  const Menu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Kamu Berhasil Login"),
    );
  }
}
