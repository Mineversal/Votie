import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share/share.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:votie/common/navigation.dart';
import 'package:votie/common/style.dart';
import 'package:votie/data/model/option_model.dart';
import 'package:votie/data/model/poll_model.dart';
import 'package:votie/utils/date_time_helper.dart';

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
                    Container(
                      margin: const EdgeInsets.only(
                          left: 20.0, right: 25.0, top: 28.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                          TextButton(
                            onPressed: () {
                              Clipboard.setData(
                                      ClipboardData(text: poll.id.toString()))
                                  .then((_) {
                                const snackbar = SnackBar(
                                    content: Text(
                                        "Voting code copied successfully"));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackbar);
                              });
                            },
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
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          left: 20.0, right: 25.0, top: 18.0, bottom: 28.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                              Share.share(
                                  "Download Votie now\nhttps://play.google.com/store/apps/details?id=com.mineversal.votie\n\nUse this code to give your vote\n${poll.id.toString()}",
                                  subject:
                                      "Download Votie now & use ${poll.id.toString()} to give your vote");
                            },
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
                                  "Share   ",
                                  style: textRegular.apply(color: Colors.black),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ListOptions(
                pollModel: poll,
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [CountDownTimer(poll: poll)],
                ),
              ),
            ],
          );
        },
      ),
    ));
  }
}

class ListOptions extends StatelessWidget {
  const ListOptions({Key? key, required this.pollModel}) : super(key: key);

  final PollModel pollModel;

  @override
  Widget build(BuildContext context) {
    var _width = MediaQuery.of(context).size.width - 40;
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('polls')
            .doc(pollModel.id)
            .collection('options')
            .snapshots(),
        builder: (context, snapshot) {
          var docs = snapshot.data != null ? snapshot.data!.docs : [];
          var options = docs.map((doc) => OptionModel.fromDoc(doc)).toList();
          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              var option = options[index];
              return Container(
                margin: const EdgeInsets.only(
                    left: 20.0, right: 20.0, bottom: 15.0),
                child: Stack(
                  children: [
                    Container(
                      width: _width,
                      height: 55,
                      decoration: BoxDecoration(
                        color: colorSoftGray,
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                    ),
                    Container(
                      width: pollModel.voters!.isEmpty
                          ? 55.0
                          : ((option.voter!.length / pollModel.voters!.length) *
                                  (_width - 55)) +
                              55,
                      height: 55,
                      decoration: BoxDecoration(
                          color: getOptionColor(
                              pollModel.title.toString().codeUnitAt(0)),
                          borderRadius: BorderRadius.circular(50.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.06),
                              spreadRadius: 10,
                              blurRadius: 30,
                              offset: const Offset(
                                  2, 4), // changes position of shadow
                            ),
                          ]),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              height: 55,
                              margin: const EdgeInsets.only(
                                  left: 10.0, right: 15.0),
                              padding: const EdgeInsets.all(15.0),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${index + 1}',
                                style:
                                    textBoldBlack.apply(color: colorDarkBlue),
                              ),
                            ),
                            Text(
                              option.title,
                              style: textBoldBlack.apply(color: colorDarkBlue),
                            )
                          ],
                        ),
                        Container(
                          alignment: Alignment.center,
                          height: 55,
                          margin:
                              const EdgeInsets.only(left: 10.0, right: 15.0),
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${option.voter?.length} Votes',
                            style: textMedium.apply(color: colorDarkBlue),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              );
            }, childCount: options.length),
          );
        });
  }
}

class CountDownTimer extends StatelessWidget {
  final PollModel poll;
  final StopWatchTimer _stopWatchTimer =
      StopWatchTimer(mode: StopWatchMode.countDown);

  CountDownTimer({Key? key, required this.poll}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var endDate = poll.end ?? DateTime.now();
    var dateNow = DateTime.now();
    var difference = endDate.difference(dateNow).inMilliseconds;
    _stopWatchTimer.setPresetTime(mSec: difference);
    _stopWatchTimer.onExecute.add(StopWatchExecute.start);
    return StreamBuilder<int>(
      stream: _stopWatchTimer.rawTime,
      builder: (context, snapshot) {
        final value = snapshot.data ?? 0;
        return Container(
          margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
          alignment: Alignment.center,
          child: Stack(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: SvgPicture.asset(
                  getOptionBg(poll.title.toString().codeUnitAt(0)),
                  fit: BoxFit.fill,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20.0),
                margin: const EdgeInsets.only(bottom: 30.0),
                alignment: Alignment.center,
                child: SizedBox(
                  child: Column(
                    children: [
                      Text(
                        'End on ${DateTimeHelper.formatDateTime(endDate, "dd MMM yyy, HH':'mm'")}',
                        style: textRegular.apply(color: colorDarkBlue),
                      ),
                      Text(
                        '${(StopWatchTimer.getRawHours(value) / 24).floor()} : ${StopWatchTimer.getRawHours(value) % 24} : ${StopWatchTimer.getRawMinute(value) % 60} : ${StopWatchTimer.getDisplayTimeSecond(value)} ',
                        style: GoogleFonts.poppins(
                            fontSize: 35.0,
                            fontWeight: FontWeight.w600,
                            color: colorDarkBlue),
                      ),
                      Text(
                        '   days        Hours       Minutes       Second    ',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: colorDarkBlue),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
