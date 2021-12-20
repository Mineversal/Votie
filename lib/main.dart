import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:votie/data/model/poll_model.dart';
import 'package:votie/data/model/user_model.dart';
import 'package:votie/provider/app_banner_provider.dart';
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
import 'package:votie/widget/no_connection_page.dart';
import 'package:votie/widget/not_found_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //     options: const FirebaseOptions(
  //         storageBucket: "mineversal-dev.appspot.com",
  //         apiKey: "AIzaSyC6hzSxX8v_OqQoVmbFs2-NGWZ5JzG0-5A",
  //         appId: "1:266768349104:web:06d63a2680284f550c4875",
  //         messagingSenderId: "266768349104",
  //         projectId: "mineversal-dev"));
  await Firebase.initializeApp();
  var user = await FirebaseAuth.instance.authStateChanges().first;
  runApp(MyApp(
    currentUser: user,
  ));
}

class MyApp extends StatelessWidget {
  final User? currentUser;
  const MyApp({Key? key, required this.currentUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _router = GoRouter(
      routes: [
        GoRoute(
          path: Login.routeName,
          builder: (context, state) => Login(
            from: state.queryParams['from'],
          ),
        ),
        GoRoute(
          path: Register.routeName,
          builder: (context, state) => const Register(),
        ),
        GoRoute(
          path: Menu.routeName,
          builder: (context, state) => const Menu(),
        ),
        GoRoute(
          path: CreateVote.routeName,
          builder: (context, state) => CreateVote(
            userModel: state.extra as UserModel,
          ),
        ),
        GoRoute(
          path: DetailVote.routeName + ':pollId',
          builder: (context, state) {
            String pollId = state.params['pollId']!;
            return DetailVote(
              pollId: pollId,
            );
          },
        ),
        GoRoute(
          path: ResultVote.routeName,
          builder: (context, state) =>
              ResultVote(pollModel: state.extra as PollModel),
        ),
        GoRoute(
          path: NoConnectionPage.routeName,
          builder: (context, state) => const NoConnectionPage(),
        ),
      ],
      initialLocation:
          (FirebaseAuth.instance.currentUser ?? currentUser) == null
              ? Login.routeName
              : Menu.routeName,
      redirect: (state) {
        final user = FirebaseAuth.instance.currentUser;
        final goingToLogin = Uri.parse(state.location).path == '/login';

        final goingToRegister = Uri.parse(state.location).path == '/register';
        final loc = Uri.parse(state.location).path;

        if (user == null && goingToRegister) return null;

        if (user == null && !goingToLogin) return '/login?from=$loc';

        if (user != null && goingToLogin) return '/menu';

        if (state.location.contains('/#')) {
          return state.location.replaceAll('/#', '');
        }

        return null;
      },
      errorBuilder: (context, state) => const NotFoundPage(),
    );
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
        ChangeNotifierProvider(
          create: (_) =>
              AppBannerProvider(sharedPref: SharedPreferences.getInstance()),
        ),
      ],
      child: MaterialApp.router(
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
        title: 'Votie',
        theme: ThemeData(visualDensity: VisualDensity.adaptivePlatformDensity),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
