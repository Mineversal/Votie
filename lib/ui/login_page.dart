import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:votie/ui/menu_page.dart';
import 'package:votie/ui/register_page.dart';

class Login extends StatefulWidget {
  static const routeName = '/login';
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        middle: Text("Login"),
      ),
      child: SafeArea(
        child: ListView(
          restorationId: 'text_field_demo_list_view',
          padding: const EdgeInsets.all(16),
          children: [
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(),
            Image.asset(
              "assets/images/logo.png",
              width: 200,
              height: 200,
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: CupertinoTextField(
                controller: _emailController,
                textInputAction: TextInputAction.next,
                restorationId: 'email_address_text_field',
                placeholder: 'Masukkan Email',
                keyboardType: TextInputType.emailAddress,
                clearButtonMode: OverlayVisibilityMode.editing,
                autocorrect: false,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: CupertinoTextField(
                controller: _passwordController,
                textInputAction: TextInputAction.next,
                restorationId: 'login_password_text_field',
                placeholder: 'Masukkan Password',
                clearButtonMode: OverlayVisibilityMode.editing,
                obscureText: true,
                autocorrect: false,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: CupertinoButton.filled(
                onPressed: () => login(),
                child: const Text("Login"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: CupertinoButton(
                onPressed: () {
                  Navigator.pushNamed(context, Register.routeName);
                },
                child: const Text("Dont Have an Account? Register"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void login() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final email = _emailController.text;
      final password = _passwordController.text;

      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Navigator.pushReplacementNamed(context, Menu.routeName);
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
