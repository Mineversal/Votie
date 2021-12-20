import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shimmer/shimmer.dart';
import 'package:votie/common/navigation.dart';
import 'package:votie/common/style.dart';
import 'package:votie/data/model/poll_model.dart';
import 'package:votie/ui/detail_vote_page.dart';
import 'package:votie/utils/connection_helper.dart';

class QrScanner extends StatefulWidget {
  static String routeName = '/qrScanner';
  const QrScanner({Key? key}) : super(key: key);

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String desc = 'Scan voting QR code to continue';

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Expanded(
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            child: Center(
              child: Shimmer.fromColors(
                  child: SizedBox(
                    width: 250,
                    height: 250,
                    child: SvgPicture.asset('assets/images/qr_scanner.svg'),
                  ),
                  baseColor: Colors.red.withOpacity(0.5),
                  highlightColor: Colors.white),
            ),
          ),
          Positioned(
            top: 0,
            child: SafeArea(
              child: Container(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () => (Navigation.back(context)),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(25),
              color: Colors.black.withOpacity(0.5),
              child: Text(
                desc,
                style: textMedium.apply(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      var votingCode = scanData.code!
          .replaceAll('https://votie.mineversal.com/#/detailVote/', '');
      searchPoll(votingCode);
    });
  }

  searchPoll(String code) async {
    controller!.pauseCamera();
    if (!await ConnectionHelper.checkConnection(context)) {
      return;
    }
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill up voting code field')));
      return;
    } else {
      await firestore
          .collection('polls')
          .where("id", isEqualTo: code.toUpperCase())
          .get()
          .then((value) {
        if (value.size > 0) {
          PollModel pollModel = PollModel.fromDoc(value.docs[0]);
          if (pollModel.show == true) {
            Navigation.intentAndReplace(
                DetailVote.routeName + pollModel.id!, context);
            return;
          } else {
            setState(() {
              desc = "Voting code has been expired";
            });
            return;
          }
        } else {
          setState(() {
            desc = "Voting code is not found";
          });
          return;
        }
      });
    }

    controller!.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
