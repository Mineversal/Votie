import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:votie/common/navigation.dart';
import 'package:votie/common/style.dart';
import 'package:votie/data/model/poll_model.dart';
import 'package:votie/provider/result_vote_provider.dart';
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
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ),
                        onPressed: () => (Navigation.back()),
                      ),
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
                          Text(
                            poll.creator ?? '',
                            style: textRegular.apply(color: Colors.black),
                          )
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
                        onPressed: () {
                          Share.share(
                              "Download Votie now\nhttps://play.google.com/store/apps/details?id=com.mineversal.votie\n\nUse this code to give your vote\n${poll.id.toString()}",
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
                    ],
                  ),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
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
        },
      ),
    ));
  }
}
