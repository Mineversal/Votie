import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:votie/common/style.dart';
import 'package:votie/provider/app_banner_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AppBanner extends StatelessWidget {
  const AppBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android)) {
      return Consumer<AppBannerProvider>(
        builder: (context, state, _) {
          return state.isShown
              ? Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.10),
                        spreadRadius: 5,
                        blurRadius: 20,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          state.hide();
                        },
                        icon: const Icon(Icons.close),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 40,
                            margin: const EdgeInsets.only(right: 10),
                            child: Image.asset('assets/images/logo.png'),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Votie App',
                                style: textMedium,
                              ),
                              Text(
                                'Vote made easy',
                                style: textRegular,
                              ),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _launchUrl();
                        },
                        child: const Text('Open Now'),
                      ),
                    ],
                  ),
                )
              : Container();
        },
      );
    } else {
      return Container();
    }
  }

  _launchUrl() async {
    if (!await launch('https://votie.page.link/app')) {
      throw 'could not open url';
    }
  }
}
