import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:votie/common/style.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrView extends StatelessWidget {
  final String votingCode;

  const QrView({Key? key, required this.votingCode}) : super(key: key);

  get colorSoftGray => null;

  @override
  Widget build(BuildContext context) {
    var voteLink = 'https://votie.mineversal.com/#/detailVote/$votingCode';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Scan this QR Code to start giving your vote',
            style: textMedium,
            textAlign: TextAlign.center,
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 15.0),
            child: QrImage(
              data: voteLink,
              version: QrVersions.auto,
              size: 200,
            ),
          ),
          Text(
            'or copy this code',
            style: textMedium,
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: votingCode)).then((_) {
                const snackbar =
                    SnackBar(content: Text("Voting code copied successfully"));
                ScaffoldMessenger.of(context).showSnackBar(snackbar);
              });
            },
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: Text(
                    votingCode,
                    style: textSemiBold,
                  ),
                ),
                const Icon(
                  Icons.content_copy,
                  color: colorGray,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
