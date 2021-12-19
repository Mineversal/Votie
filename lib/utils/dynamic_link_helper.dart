import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class DynamicLinkHelper {
  FirebaseDynamicLinks dynamicLink = FirebaseDynamicLinks.instance;

  ///Build a dynamic link firebase
  Future<String> buildDynamicLink(String id) async {
    String url = "https://votie.page.link";
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: url,
      link: Uri.parse('$url/poll/$id'),
      androidParameters: const AndroidParameters(
        packageName: "com.mineversal.votie",
        minimumVersion: 0,
      ),
      iosParameters: const IOSParameters(
        bundleId: "com.mineversal.votie",
        minimumVersion: '0',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
          description: "Start your own voting campaign",
          imageUrl: Uri.parse("https://mineversal.com/assets/img/votie.png"),
          title: "Ready to Vote?"),
    );

    final ShortDynamicLink dynamicUrl =
        await dynamicLink.buildShortLink(parameters);
    return dynamicUrl.shortUrl.toString();
  }
}
