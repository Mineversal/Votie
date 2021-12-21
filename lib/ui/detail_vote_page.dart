import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:votie/common/navigation.dart';
import 'package:votie/common/style.dart';
import 'package:votie/data/model/poll_model.dart';
import 'package:votie/data/model/user_model.dart';
import 'package:votie/provider/detail_vote_provider.dart';
import 'package:votie/ui/menu_page.dart';
import 'package:votie/utils/date_time_helper.dart';
import 'package:votie/widget/app_banner.dart';
import 'package:votie/widget/list_options.dart';
import 'package:votie/widget/not_found_page.dart';
import 'package:votie/widget/qr_view.dart';

class DetailVote extends StatefulWidget {
  static const routeName = '/detailVote/';
  final String pollId;

  const DetailVote({Key? key, required this.pollId}) : super(key: key);

  @override
  _DetailVoteState createState() => _DetailVoteState();
}

class _DetailVoteState extends State<DetailVote> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel userModel = UserModel();
  PollModel pollModel = PollModel();

  @override
  void initState() {
    super.initState();
    getUser();
    getPoll();
  }

  getUser() async {
    if (user != null) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get()
          .then((value) {
        userModel = UserModel.fromMap(value.data());
        setState(() {});
      });
    }
  }

  getPoll() async {
    await FirebaseFirestore.instance
        .collection("polls")
        .doc(widget.pollId)
        .get()
        .then((value) {
      pollModel = PollModel.fromMap(value.data());
      setState(() {});
    }).catchError((error) =>
            Navigation.intentAndReplace(NotFoundPage.routeName, context));
  }

  addToUsers() {
    FirebaseFirestore.instance.collection("polls").doc(widget.pollId).update({
      'users': FieldValue.arrayUnion([userModel.username])
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userModel.uid == null || pollModel.id == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    addToUsers();
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: AppBanner(),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            Navigation.intentAndReplace(
                                Menu.routeName, context);
                            Provider.of<DetailVoteProvider>(context,
                                    listen: false)
                                .clear();
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            left: 20.0, right: 20.0, top: 10.0),
                        child: Text(
                          'End on ' +
                              DateTimeHelper.formatDateTime(
                                  pollModel.end!, "EE, dd MMM yyy HH':'mm'"),
                          style: textRegular.apply(
                              color: getColorByIndex(
                                  pollModel.title!.codeUnitAt(0))),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            left: 20.0, right: 20.0, top: 10.0),
                        child: Text(
                          pollModel.title ?? '',
                          style: textSemiBold,
                        ),
                      ),
                      pollModel.description != null
                          ? Container(
                              margin: const EdgeInsets.only(
                                  left: 20.0, right: 20.0, top: 18.0),
                              child: Text(
                                pollModel.description!,
                                style: textRegular,
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(20.0),
                  sliver: SliverGrid(
                    delegate: SliverChildListDelegate(
                      [
                        Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 14.0),
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: colorSoftGray,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: colorGray,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                pollModel.creator ?? '',
                                style: textRegular.apply(color: Colors.black),
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            showQrDialog(
                                context,
                                pollModel.id ?? '',
                                getColorByIndex(
                                    pollModel.title!.codeUnitAt(0)));
                          },
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 14.0),
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: colorSoftGray,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: const Icon(
                                  Icons.qr_code,
                                  color: colorGray,
                                ),
                              ),
                              Text(
                                pollModel.id.toString(),
                                style: textRegular.apply(color: Colors.black),
                              )
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Share.share(
                                "Let's vote on: \n'${pollModel.title}' poll \n\ngive your vote here: https://votie.mineversal.com/#/detailVote/${pollModel.id.toString()}",
                                subject:
                                    "Download Votie now & use ${pollModel.id.toString()} to give your vote");
                          },
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 14.0),
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: colorSoftGray,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: const Icon(
                                  Icons.share_outlined,
                                  color: colorGray,
                                ),
                              ),
                              Text(
                                "Share",
                                style: textRegular.apply(color: Colors.black),
                              )
                            ],
                          ),
                        ),
                        if (pollModel.multivote!)
                          Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 14.0),
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: colorSoftGray,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: const Icon(
                                  Icons.splitscreen,
                                  color: colorGray,
                                ),
                              ),
                              Text(
                                'Multivote',
                                style: textRegular.apply(color: Colors.black),
                              )
                            ],
                          ),
                        if (pollModel.multivote!)
                          Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 14.0),
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: colorSoftGray,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: const Icon(
                                  Icons.supervisor_account_rounded,
                                  color: colorGray,
                                ),
                              ),
                              Text(
                                'Anonymous',
                                style: textRegular.apply(color: Colors.black),
                              )
                            ],
                          ),
                      ],
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300.0,
                      crossAxisSpacing: 49.0,
                      childAspectRatio: 2.0,
                    ),
                  ),
                ),
                ListOptions(
                  pollModel: pollModel,
                  userModel: userModel,
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Container(
                        height: 80.0,
                      )
                    ],
                  ),
                )
              ],
            ),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Consumer<DetailVoteProvider>(
                builder: (context, state, _) {
                  return !state.getOptions.any((option) =>
                              option.voter!.contains(userModel.username)) &&
                          pollModel.show == true
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: state.getOptionStatus
                                    .any((option) => option != false)
                                ? getColorByIndex(
                                    pollModel.title!.codeUnitAt(0),
                                  )
                                : colorGray,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'VOTE NOW',
                                  style: textMedium.apply(color: Colors.white),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 20.0),
                                  child: const Icon(
                                    Icons.how_to_vote,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            ),
                          ),
                          onPressed: state.getOptionStatus
                                  .any((option) => option != false)
                              ? () {
                                  confirm(context, state);
                                }
                              : () {},
                        )
                      : Container();
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> confirm(BuildContext context, DetailVoteProvider state) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Are you sure?',
          style: Theme.of(context).textTheme.headline6,
        ),
        content: Text(
          'Do you want choose this?',
          style: Theme.of(context).textTheme.subtitle2,
        ),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8))),
        actions: [
          TextButton(
            child: const Text("CANCEL"),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            style: TextButton.styleFrom(
              primary: colorRed,
              backgroundColor: Colors.transparent,
              textStyle: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          const SizedBox(width: 1),
          ElevatedButton(
            child: const Text("CONFIRM"),
            onPressed: () {
              try {
                state.voteOption(pollModel.id!, userModel.username!);
                const snackbar = SnackBar(content: Text("Successfully vote"));
                ScaffoldMessenger.of(context).showSnackBar(snackbar);
                Navigator.of(context).pop(false);
                state.clear();
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(e.toString())));
                Navigator.of(context).pop(false);
              }
            },
            style: TextButton.styleFrom(
              primary: Colors.white,
              backgroundColor: colorGreen,
              textStyle: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  void showQrDialog(BuildContext context, String votingCode, Color color) {
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (_, __, ___) {
        var height = MediaQuery.of(context).size.height;
        return Scaffold(
          body: Container(
            height: height,
            color: color,
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () => (Navigation.back(context)),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          left: 30, right: 30, top: height * 0.1),
                      padding: const EdgeInsets.symmetric(vertical: 50),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: QrView(
                        votingCode: votingCode,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(anim),
          child: child,
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
