import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:votie/common/navigation.dart';
import 'package:votie/common/style.dart';
import 'package:votie/data/model/option_model.dart';
import 'package:votie/data/model/poll_model.dart';
import 'package:votie/provider/result_vote_provider.dart';
import 'package:votie/ui/menu_page.dart';
import 'package:votie/utils/dynamic_link_helper.dart';
import 'package:votie/widget/count_down_timer.dart';
import 'package:votie/widget/list_options_result.dart';

class ResultVote extends StatelessWidget {
  static const routeName = '/resultVote';
  final PollModel pollModel;

  const ResultVote({Key? key, required this.pollModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('polls')
            .doc(pollModel.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.exists) {
            var doc = snapshot.data;
            var poll = doc != null ? PollModel.fromDoc(doc) : PollModel();
            Future.delayed(
              Duration.zero,
              () async {
                Provider.of<ResultVoteProvider>(context, listen: false)
                    .setPollModel(poll);
              },
            );
            return CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.black,
                                ),
                                onPressed: () => (Navigation.back()),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.black,
                                ),
                                onPressed: () => confirm(context, poll),
                              ),
                            ]),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            left: 20.0, right: 20.0, top: 10.0),
                        child: Text(
                          poll.title ?? '',
                          style: textSemiBold,
                        ),
                      ),
                      poll.description != null
                          ? Container(
                              margin: const EdgeInsets.only(
                                  left: 20.0, right: 20.0, top: 18.0),
                              child: Text(
                                poll.description!,
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
                                Icons.how_to_vote,
                                color: colorGray,
                              ),
                            ),
                            Text(
                              '${poll.voters != null ? poll.voters!.length : '0'} Voter',
                              style: textRegular.apply(color: Colors.black),
                            )
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            Clipboard.setData(
                                    ClipboardData(text: poll.id.toString()))
                                .then((_) {
                              const snackbar = SnackBar(
                                  content:
                                      Text("Voting code copied successfully"));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackbar);
                            });
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
                                  Icons.tag,
                                  color: colorGray,
                                ),
                              ),
                              Text(
                                poll.id.toString(),
                                style: textRegular.apply(color: Colors.black),
                              )
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            String url = await DynamicLinkHelper()
                                .buildDynamicLink(pollModel.id.toString());
                            Share.share("Click Here to Give Your Vote: \n$url",

                                ///"Download Votie now on\n\nGoogle Play Store:\nhttps://play.google.com/store/apps/details?id=com.mineversal.votie\n\nAmazon Appstore:\nhttps://www.amazon.com/gp/product/B09NMXLJHM\n\nOr vote from our Web App:\nhttps://votie.mineversal.com\n\nUse this code to give your vote:\n${poll.id.toString()}",
                                subject:
                                    "Download Votie now & use ${poll.id.toString()} to give your vote");
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
                ListOptionsResult(
                  pollModel: poll,
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      CountDownTimer(
                        poll: poll,
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: Text('Data not found'),
            );
          }
        },
      ),
    ));
  }

  Future<void> confirm(BuildContext context, PollModel poll) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Are you sure?',
          style: Theme.of(context).textTheme.headline6,
        ),
        content: Text(
          'Do you want delete this poll?',
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
              primary: colorGreen,
              backgroundColor: Colors.transparent,
              textStyle: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          const SizedBox(width: 1),
          ElevatedButton(
            child: const Text("CONFIRM"),
            onPressed: () async {
              CollectionReference _options = FirebaseFirestore.instance
                  .collection("polls")
                  .doc(poll.id)
                  .collection("options");
              QuerySnapshot querySnapshot = await _options.get();
              var listOption = querySnapshot.docs
                  .map((doc) => OptionModel.fromDoc(doc))
                  .toList();
              var includeImage =
                  listOption.any((option) => option.images!.isNotEmpty);
              if (includeImage) {
                for (var option in listOption) {
                  if (option.images != "") {
                    FirebaseStorage.instance
                        .refFromURL(option.images!)
                        .delete();
                    _options.doc(option.id.toString()).delete();
                  } else {
                    _options.doc(option.id.toString()).delete();
                  }
                }
                FirebaseStorage.instance
                    .ref("images/polls/${poll.id}/")
                    .delete();
                FirebaseFirestore.instance
                    .collection("polls")
                    .doc(poll.id)
                    .delete();
                const snackbar = SnackBar(
                    content: Text("Polling has been successfully deleted"));
                ScaffoldMessenger.of(context).showSnackBar(snackbar);
                Navigator.popUntil(
                    context, (route) => route.settings.name == Menu.routeName);
              } else {
                for (var option in listOption) {
                  _options.doc(option.id.toString()).delete();
                }
                FirebaseFirestore.instance
                    .collection("polls")
                    .doc(poll.id)
                    .delete();
                const snackbar = SnackBar(
                    content: Text("Polling has been successfully deleted"));
                ScaffoldMessenger.of(context).showSnackBar(snackbar);
                Navigator.popUntil(
                    context, (route) => route.settings.name == Menu.routeName);
              }
            },
            style: TextButton.styleFrom(
              primary: Colors.white,
              backgroundColor: colorRed,
              textStyle: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
