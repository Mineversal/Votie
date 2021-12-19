import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:votie/common/navigation.dart';
import 'package:votie/common/style.dart';
import 'package:votie/ui/menu_page.dart';
import 'package:votie/ui/register_page.dart';

class Login extends StatefulWidget {
  static const routeName = '/login';
  final String? from;
  const Login({Key? key, this.from}) : super(key: key);

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
    return WillPopScope(
      onWillPop: () {
        SystemNavigator.pop();
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: SafeArea(
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
                      'Sign In,',
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
                      'and start voting now',
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
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Email',
                          hintStyle: textRegular),
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
                          hintStyle: textRegular),
                      controller: _passwordController,
                      autocorrect: false,
                    ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints.tightFor(height: 50),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => login(),
                      child: _isLoading
                          ? const SizedBox(
                              height: 25.0,
                              width: 25.0,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text('Sign in'),
                    ),
                  ),
                  TextButton(
                    child: const Text('Dont Have an Account? Sign Up'),
                    onPressed: () {
                      Navigation.intent(Register.routeName, context);
                    },
                  ),
                ],
              ),
            ),
          ),
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
      if (widget.from != null) {
        Navigation.intentAndReplace(widget.from!, context);
      } else {
        Navigation.intentAndReplace(Menu.routeName, context);
      }
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
