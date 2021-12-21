import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:votie/common/navigation.dart';
import 'package:votie/common/style.dart';

class NoConnectionPage extends StatefulWidget {
  static const routeName = '/noConnectionPage';
  const NoConnectionPage({Key? key}) : super(key: key);

  @override
  State<NoConnectionPage> createState() => _NoConnectionPageState();
}

class _NoConnectionPageState extends State<NoConnectionPage> {
  bool _isLoading = false;

  checkConnection() async {
    setState(() {
      _isLoading = true;
    });
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      Navigation.back(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Still no connection.')));
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigation.back(context);
                  },
                ),
              ),
              SvgPicture.asset(
                'assets/images/no_connection.svg',
                fit: BoxFit.fill,
              ),
              Container(
                margin: const EdgeInsets.only(
                    left: 40.0, right: 40.0, top: 40.0, bottom: 30.0),
                child: Text(
                  _isLoading
                      ? 'Connecting.....'
                      : 'There is problem when connecting to server, check your internet connection and try again.',
                  style: textMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  checkConnection();
                },
                child: const Text('Try Again'),
                style: ElevatedButton.styleFrom(primary: colorGreen),
              )
            ],
          ),
        ),
      ),
    );
  }
}
