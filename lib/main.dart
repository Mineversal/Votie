import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:votie/common/navigation.dart';
import 'package:votie/data/model/poll_model.dart';
import 'package:votie/data/model/user_model.dart';
import 'package:votie/provider/create_vote_provider.dart';
import 'package:votie/provider/detail_vote_provider.dart';
import 'package:votie/provider/result_vote_provider.dart';
import 'package:votie/ui/create_vote_page.dart';
import 'package:votie/ui/detail_vote_page.dart';
import 'package:votie/ui/login_page.dart';
import 'package:votie/ui/menu_page.dart';
import 'package:votie/ui/register_page.dart';
import 'package:votie/ui/result_vote_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              DetailVoteProvider(firestore: FirebaseFirestore.instance),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              CreateVoteProvider(firestore: FirebaseFirestore.instance),
        ),
        ChangeNotifierProvider(
          create: (_) => ResultVoteProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Votie',
        theme: ThemeData(visualDensity: VisualDensity.adaptivePlatformDensity),
        debugShowCheckedModeBanner: false,
        initialRoute: currentUser == null ? Login.routeName : Menu.routeName,
        navigatorKey: navigatorKey,
        routes: {
          Login.routeName: (context) => const Login(),
          Register.routeName: (context) => const Register(),
          Menu.routeName: (context) => const Menu(),
          CreateVote.routeName: (context) => CreateVote(
                userModel:
                    ModalRoute.of(context)?.settings.arguments as UserModel,
              ),
          DetailVote.routeName: (context) {
            var argsMap = ModalRoute.of(context)?.settings.arguments as Map;
            return DetailVote(
              pollModel: argsMap['pollModel'],
              userModel: argsMap['userModel'],
            );
          },
          ResultVote.routeName: (context) => ResultVote(
                pollModel:
                    ModalRoute.of(context)?.settings.arguments as PollModel,
              ),
        },
      ),
    );
  }
}
