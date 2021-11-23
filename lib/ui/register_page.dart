import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:votie/data/model/user_model.dart';
import 'package:votie/ui/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Register extends StatefulWidget {
  static const routeName = '/register';
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _auth = FirebaseAuth.instance;
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        middle: Text("Register"),
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
                controller: _nameController,
                textInputAction: TextInputAction.next,
                restorationId: 'name_text_field',
                placeholder: 'Masukkan Nama',
                keyboardType: TextInputType.name,
                clearButtonMode: OverlayVisibilityMode.editing,
                autocorrect: false,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: CupertinoTextField(
                controller: _usernameController,
                textInputAction: TextInputAction.next,
                restorationId: 'username_text_field',
                placeholder: 'Masukkan Username',
                keyboardType: TextInputType.name,
                clearButtonMode: OverlayVisibilityMode.editing,
                autocorrect: false,
              ),
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
                onPressed: () => register(),
                child: const Text("Register"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: CupertinoButton(
                onPressed: () {
                  Navigator.pushNamed(context, Login.routeName);
                },
                child: const Text("Have an Account? Login"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void register() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final email = _emailController.text;
      final password = _passwordController.text;

      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) => postDetailsToFirestore())
          .catchError((e) {
        final snackbar = SnackBar(content: Text(e.toString()));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      });
      Navigator.pop(context);
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  postDetailsToFirestore() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    UserModel userModel = UserModel();

    userModel.email = user!.email;
    userModel.uid = user.uid;
    userModel.username = _usernameController.text;
    userModel.name = _nameController.text;

    await firebaseFirestore
        .collection("users")
        .doc(user.uid)
        .set(userModel.toMap());

    const snackbar = SnackBar(content: Text("Register Succesfully"));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
