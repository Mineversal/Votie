import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ntp/ntp.dart';
import 'package:votie/common/navigation.dart';
import 'package:votie/common/style.dart';
import 'package:votie/data/model/poll_model.dart';
import 'package:votie/data/model/user_model.dart';
import 'package:intl/intl.dart';
import 'package:votie/ui/create_vote_page.dart';
import 'package:votie/ui/result_vote_page.dart';
import 'package:votie/utils/connection_helper.dart';
import 'package:votie/utils/date_time_helper.dart';
import 'package:votie/widget/app_banner.dart';
import 'package:votie/widget/shimmer_loading.dart';

class AddVote extends StatelessWidget {
  final UserModel userModel;

  const AddVote({Key? key, required this.userModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var paddingTop = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: AppBanner(),
          ),
          SliverAppBar(
            expandedHeight: 269.0 - paddingTop,
            floating: false,
            pinned: true,
            elevation: 0.9,
            toolbarHeight: 60,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                var top = constraints.biggest.height;
                return FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  centerTitle: true,
                  title: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: top == MediaQuery.of(context).padding.top + 60
                        ? 1.0
                        : 0.0,
                    child: Container(
                      alignment: Alignment.bottomLeft,
                      margin: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        'Vote You Made',
                        style: titleMediumBlack,
                      ),
                    ),
                  ),
                  background: Column(
                    children: [
                      Stack(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: SvgPicture.asset(
                              'assets/images/bg_green.svg',
                              fit: BoxFit.fill,
                            ),
                          ),
                          SafeArea(
                            child: Column(
                              children: [
                                Container(
                                  alignment: Alignment.centerLeft,
                                  margin: const EdgeInsets.only(
                                      bottom: 2.0,
                                      top: 10.0,
                                      right: 20.0,
                                      left: 20.0),
                                  child: Text(
                                    'Start your voting campaign',
                                    style: titleBoldWhite,
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  margin: const EdgeInsets.only(
                                      bottom: 15.0, right: 20.0, left: 20.0),
                                  child: Text(
                                    'And get best decision',
                                    style:
                                        textMedium.apply(color: Colors.white),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  margin: const EdgeInsets.only(
                                      bottom: 2.0, right: 20.0, left: 20.0),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (!await ConnectionHelper
                                          .checkConnection(context)) {
                                        return;
                                      }
                                      Navigation.intentWithData(
                                          CreateVote.routeName,
                                          userModel,
                                          context);
                                    },
                                    child: const Text('Create Voting Now'),
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.white,
                                      onPrimary: colorGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.all(20.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Vote You Made',
                          style: titleMediumBlack,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            sliver: ListYourVote(
              userModel: userModel,
            ),
          )
        ],
      ),
    );
  }
}

class ListYourVote extends StatefulWidget {
  final UserModel userModel;

  const ListYourVote({
    Key? key,
    required this.userModel,
  }) : super(key: key);

  @override
  State<ListYourVote> createState() => _ListYourVoteState();
}

class _ListYourVoteState extends State<ListYourVote> {
  var _dateNow = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadNTPTime();
  }

  void _loadNTPTime() async {
    var ntpDateNow = await NTP.now();
    setState(() {
      _dateNow = ntpDateNow;
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = _dateNow;
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime detailNow =
        DateTime(now.year, now.month, now.day, now.hour, now.minute);
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("polls")
            .where("creator", isEqualTo: widget.userModel.username)
            .orderBy("end", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              widget.userModel.username == null) {
            return const ShimmerLoading(count: 3);
          }

          return snapshot.hasData
              ? (snapshot.data!.docs.isNotEmpty
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        PollModel pollModel =
                            PollModel.fromDoc(snapshot.data!.docs[index]);
                        DateTime aDate = DateTimeHelper.timeStampToDay(
                            snapshot.data!.docs[index].get("end"));
                        String updatedDate;

                        if (aDate == today) {
                          var newFormat = DateFormat("Hm");
                          updatedDate = newFormat.format(pollModel.end!);
                          if (pollModel.end!.isBefore(detailNow) ||
                              pollModel.end!.isAtSameMomentAs(detailNow)) {
                            var id = pollModel.id;
                            bool show = pollModel.show!;
                            if (show == true) {
                              var newFormat = DateFormat("Hm");
                              updatedDate = newFormat.format(pollModel.end!);
                              FirebaseFirestore.instance
                                  .collection("polls")
                                  .doc(id)
                                  .update({"show": false});
                            }
                          }
                        } else {
                          var newFormat = DateFormat("yMMMd");
                          updatedDate = newFormat.format(pollModel.end!);
                          if (pollModel.end!.isBefore(detailNow)) {
                            var id = pollModel.id;
                            bool show = pollModel.show!;
                            if (show == true) {
                              var newFormat = DateFormat("yMMMd");
                              updatedDate = newFormat.format(pollModel.end!);
                              FirebaseFirestore.instance
                                  .collection("polls")
                                  .doc(id)
                                  .update({"show": false});
                            }
                          }
                        }

                        var jumlahOpsi = pollModel.options;
                        List voter = pollModel.voters!;
                        var jumlahVoter = voter.length;

                        if (jumlahVoter.isNaN) {
                          jumlahVoter = 0;
                        } else {
                          jumlahVoter = jumlahVoter;
                        }

                        var title = pollModel.title!;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 15.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.06),
                                spreadRadius: 5,
                                blurRadius: 20,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          width: MediaQuery.of(context).size.width,
                          child: TextButton(
                            onPressed: () async {
                              if (!await ConnectionHelper.checkConnection(
                                  context)) {
                                return;
                              } else {
                                if (pollModel.end!.isBefore(detailNow) ||
                                    pollModel.end!
                                        .isAtSameMomentAs(detailNow)) {
                                  var id = pollModel.id;
                                  bool show = pollModel.show!;
                                  if (show == true) {
                                    FirebaseFirestore.instance
                                        .collection("polls")
                                        .doc(id)
                                        .update({"show": false});
                                    Navigation.intentWithData(
                                        ResultVote.routeName,
                                        pollModel,
                                        context);
                                  } else {
                                    Navigation.intentWithData(
                                        ResultVote.routeName,
                                        pollModel,
                                        context);
                                  }
                                } else {
                                  Navigation.intentWithData(
                                      ResultVote.routeName, pollModel, context);
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                children: [
                                  Container(
                                    width: 66.0,
                                    height: 66.0,
                                    color: getSoftColorByIndex(
                                        title.codeUnitAt(0)),
                                    child: Center(
                                      child: Text(
                                        title[0].toString().toUpperCase(),
                                        style: TextStyle(
                                            fontSize: 25.0,
                                            fontWeight: FontWeight.bold,
                                            color: getColorByIndex(
                                                title.codeUnitAt(0))),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 5.0),
                                            child: Text(
                                              title,
                                              style: textMedium,
                                              overflow: TextOverflow.fade,
                                              maxLines: 1,
                                              softWrap: false,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    right: 5.0),
                                                child: const Icon(
                                                  Icons.person,
                                                  color: colorGray,
                                                  size: 18,
                                                ),
                                              ),
                                              Text(
                                                '$jumlahVoter Voter',
                                                style: textRegular,
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    right: 5.0, left: 15.0),
                                                child: const Icon(
                                                  Icons.style,
                                                  color: colorGray,
                                                  size: 18,
                                                ),
                                              ),
                                              Text(
                                                '$jumlahOpsi Option',
                                                style: textRegular,
                                              ),
                                            ],
                                          ),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Text(
                                              'End $updatedDate',
                                              style: GoogleFonts.poppins(
                                                  color: getColorByIndex(
                                                      title.codeUnitAt(0)),
                                                  fontSize: 14.0,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }, childCount: snapshot.data!.docs.length),
                    )
                  : SliverToBoxAdapter(
                      child: Center(
                        child: Column(
                          children: [
                            Container(
                              margin:
                                  const EdgeInsets.only(top: 90, bottom: 30.0),
                              child: SvgPicture.asset(
                                'assets/images/your_vote_placeholder.svg',
                                fit: BoxFit.fill,
                              ),
                            ),
                            Text(
                              'You haven\'t made a vote yet, start your voting campaign now!',
                              style: textRegular,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ))
              : SliverToBoxAdapter(
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 90, bottom: 30.0),
                          child: SvgPicture.asset(
                            'assets/images/your_vote_placeholder.svg',
                            fit: BoxFit.fill,
                          ),
                        ),
                        Text(
                          'You haven\'t made a vote yet, start your voting campaign now!',
                          style: textRegular,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
        });
  }
}
