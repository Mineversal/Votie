import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:votie/common/style.dart';
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

  // @override
  // Widget build(BuildContext context) {
  //   return CupertinoPageScaffold(
  //     navigationBar: const CupertinoNavigationBar(
  //       automaticallyImplyLeading: false,
  //       middle: Text("Register"),
  //     ),
  //     child: SafeArea(
  //       child: ListView(
  //         restorationId: 'text_field_demo_list_view',
  //         padding: const EdgeInsets.all(16),
  //         children: [
  //           _isLoading
  //               ? const Center(child: CircularProgressIndicator())
  //               : Container(),
  //           Image.asset(
  //             "assets/images/logo.png",
  //             width: 200,
  //             height: 200,
  //           ),
  //           const SizedBox(
  //             height: 20,
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.symmetric(vertical: 8),
  //             child: CupertinoTextField(
  //               controller: _nameController,
  //               textInputAction: TextInputAction.next,
  //               restorationId: 'name_text_field',
  //               placeholder: 'Masukkan Nama',
  //               keyboardType: TextInputType.name,
  //               clearButtonMode: OverlayVisibilityMode.editing,
  //               autocorrect: false,
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.symmetric(vertical: 8),
  //             child: CupertinoTextField(
  //               controller: _usernameController,
  //               textInputAction: TextInputAction.next,
  //               restorationId: 'username_text_field',
  //               placeholder: 'Masukkan Username',
  //               keyboardType: TextInputType.name,
  //               clearButtonMode: OverlayVisibilityMode.editing,
  //               autocorrect: false,
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.symmetric(vertical: 8),
  //             child: CupertinoTextField(
  //               controller: _emailController,
  //               textInputAction: TextInputAction.next,
  //               restorationId: 'email_address_text_field',
  //               placeholder: 'Masukkan Email',
  //               keyboardType: TextInputType.emailAddress,
  //               clearButtonMode: OverlayVisibilityMode.editing,
  //               autocorrect: false,
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.symmetric(vertical: 8),
  //             child: CupertinoTextField(
  //               controller: _passwordController,
  //               textInputAction: TextInputAction.next,
  //               restorationId: 'login_password_text_field',
  //               placeholder: 'Masukkan Password',
  //               clearButtonMode: OverlayVisibilityMode.editing,
  //               obscureText: true,
  //               autocorrect: false,
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.symmetric(vertical: 8),
  //             child: CupertinoButton.filled(
  //               onPressed: () => register(),
  //               child: const Text("Register"),
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.symmetric(vertical: 8),
  //             child: CupertinoButton(
  //               onPressed: () {
  //                 Navigator.pushNamed(context, Login.routeName);
  //               },
  //               child: const Text("Have an Account? Login"),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/logo.svg',
                    width: 35.0,
                  ),
                  Text(
                    'Votie',
                    style: GoogleFonts.lato(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 80.0, left: 10),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Register,',
                  style: GoogleFonts.poppins(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 10),
                alignment: Alignment.centerLeft,
                child: Text(
                  'crate new account',
                  style: GoogleFonts.poppins(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                color: const Color(0xFFF4F4F4),
                margin: const EdgeInsets.only(top: 30.0),
                padding: const EdgeInsets.only(
                    left: 20.0, top: 5.0, right: 5.0, bottom: 5.0),
                child: TextField(
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Name',
                      hintStyle: textRegularGray),
                  controller: _nameController,
                  autocorrect: false,
                ),
              ),
              Container(
                color: const Color(0xFFF4F4F4),
                margin: const EdgeInsets.only(top: 10.0),
                padding: const EdgeInsets.only(
                    left: 20.0, top: 5.0, right: 5.0, bottom: 5.0),
                child: TextField(
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Username',
                      hintStyle: textRegularGray),
                  controller: _usernameController,
                  autocorrect: false,
                ),
              ),
              Container(
                color: const Color(0xFFF4F4F4),
                margin: const EdgeInsets.only(top: 10.0),
                padding: const EdgeInsets.only(
                    left: 20.0, top: 5.0, right: 5.0, bottom: 5.0),
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Email',
                      hintStyle: textRegularGray),
                  controller: _emailController,
                  autocorrect: false,
                ),
              ),
              Container(
                color: const Color(0xFFF4F4F4),
                margin: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                padding: const EdgeInsets.only(
                    left: 20.0, top: 5.0, right: 5.0, bottom: 5.0),
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Password',
                      hintStyle: textRegularGray),
                  controller: _passwordController,
                  autocorrect: false,
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints.tightFor(height: 50),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => register(),
                  child: _isLoading
                      ? const SizedBox(
                          height: 25.0,
                          width: 25.0,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : const Text('Register'),
                ),
              ),
              TextButton(
                child: const Text('Dont Have an Account? Register'),
                onPressed: () {
                  Navigator.pushNamed(context, Login.routeName);
                },
              ),
            ],
          ),
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
