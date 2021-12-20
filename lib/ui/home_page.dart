import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ntp/ntp.dart';
import 'package:share/share.dart';
import 'package:votie/common/navigation.dart';
import 'package:votie/common/style.dart';
import 'package:votie/data/model/poll_model.dart';
import 'package:votie/data/model/user_model.dart';
import 'package:intl/intl.dart';
import 'package:votie/ui/detail_vote_page.dart';
import 'package:votie/utils/connection_helper.dart';
import 'package:votie/utils/date_time_helper.dart';
import 'package:votie/widget/app_banner.dart';
import 'package:votie/widget/qr_scanner.dart';
import 'package:votie/widget/shimmer_loading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Home extends StatefulWidget {
  final UserModel userModel;

  const Home({Key? key, required this.userModel}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _searchController = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: AppBanner(),
          ),
          SliverAppBar(
            expandedHeight: 311.0,
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
                        'Recent Vote',
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
                              'assets/images/bg_orange.svg',
                              fit: BoxFit.fill,
                            ),
                          ),
                          SafeArea(
                            child: Column(
                              children: [
                                Container(
                                  alignment: Alignment.centerLeft,
                                  margin: const EdgeInsets.only(
                                      bottom: 20.0,
                                      top: 10.0,
                                      right: 20.0,
                                      left: 20.0),
                                  child: Text(
                                    'Welcome to Votie!',
                                    style: titleBoldOrange,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  padding: const EdgeInsets.all(25.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.06),
                                        spreadRadius: 10,
                                        blurRadius: 30,
                                        offset: const Offset(
                                            2, 4), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Enter voting code',
                                          style: titleBoldBlack,
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        margin: const EdgeInsets.only(top: 5.0),
                                        child: Text(
                                          'To give your vote',
                                          style: textRegular,
                                        ),
                                      ),
                                      Container(
                                        color: const Color(0xFFFAFAFA),
                                        margin:
                                            const EdgeInsets.only(top: 20.0),
                                        padding: const EdgeInsets.only(
                                            left: 20.0,
                                            top: 5.0,
                                            right: 5.0,
                                            bottom: 5.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: _searchController,
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: 'Ex: 234RGG',
                                                  hintStyle: textRegular,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                Navigation.intentWithData(
                                                    QrScanner.routeName,
                                                    widget.userModel,
                                                    context);
                                              },
                                              icon: const Icon(
                                                  Icons.qr_code_scanner,
                                                  color: colorGray),
                                            ),
                                            ElevatedButton(
                                              onPressed: () => searchPoll(),
                                              child: const Text('Enter'),
                                              style: ElevatedButton.styleFrom(
                                                  primary: colorOrange),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.all(20.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Recent Vote',
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
            sliver: ListRecentVote(userModel: widget.userModel),
          )
        ],
      ),
    );
  }

  searchPoll() async {
    if (!await ConnectionHelper.checkConnection(context)) {
      return;
    }
    if (_searchController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill up voting code field')));
      return;
    } else {
      await firestore
          .collection('polls')
          .where("id", isEqualTo: _searchController.text.toUpperCase())
          .get()
          .then((value) {
        if (value.size > 0) {
          PollModel pollModel = PollModel.fromDoc(value.docs[0]);
          if (pollModel.show == true) {
            // const snackbar = SnackBar(
            //     content: Text("Voting code has been successfully reedemed"));
            // ScaffoldMessenger.of(context).showSnackBar(snackbar);
            _searchController.text = "";
            Navigation.intent(DetailVote.routeName + pollModel.id!, context);
            return;
          } else {
            const snackbar =
                SnackBar(content: Text("Voting code has been expired"));
            ScaffoldMessenger.of(context).showSnackBar(snackbar);
            return;
          }
        } else {
          const snackbar = SnackBar(content: Text("Voting code is not found"));
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
          return;
        }
      });
    }
  }
}

class ListRecentVote extends StatefulWidget {
  final UserModel userModel;

  const ListRecentVote({
    Key? key,
    required this.userModel,
  }) : super(key: key);

  @override
  State<ListRecentVote> createState() => _ListRecentVoteState();
}

class _ListRecentVoteState extends State<ListRecentVote> {
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
          .where("users", arrayContains: widget.userModel.username)
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

                      var title = snapshot.data!.docs[index].get("title");

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
                              offset: const Offset(
                                  2, 2), // changes position of shadow
                            ),
                          ],
                        ),
                        width: MediaQuery.of(context).size.width,
                        child: Slidable(
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
                                        DetailVote.routeName + pollModel.id!,
                                        {
                                          'pollModel': pollModel,
                                          'userModel': widget.userModel
                                        },
                                        context);
                                  } else {
                                    Navigation.intentWithData(
                                        DetailVote.routeName + pollModel.id!,
                                        {
                                          'pollModel': pollModel,
                                          'userModel': widget.userModel
                                        },
                                        context);
                                  }
                                } else {
                                  Navigation.intentWithData(
                                      DetailVote.routeName + pollModel.id!,
                                      {
                                        'pollModel': pollModel,
                                        'userModel': widget.userModel
                                      },
                                      context);
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60.0,
                                    height: 60.0,
                                    color: getSoftColorByIndex(
                                        title.codeUnitAt(0)),
                                    child: Center(
                                      child: Text(
                                        title[0].toString().toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 25.0,
                                          fontWeight: FontWeight.bold,
                                          color: getColorByIndex(
                                            title.codeUnitAt(0),
                                          ),
                                        ),
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
                                              maxLines: 1,
                                              overflow: TextOverflow.fade,
                                              softWrap: false,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                'End $updatedDate',
                                                style: textRegular,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          startActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  Share.share(
                                      "Let's vote on: \n'${pollModel.title}' poll \n\ngive your vote here: https://votie.mineversal.com/detailVote/${pollModel.id.toString()}",
                                      subject:
                                          "Download Votie now & use ${pollModel.id.toString()} to give your vote");
                                },
                                backgroundColor: getColorByIndex(
                                  title.codeUnitAt(0),
                                ),
                                foregroundColor: Colors.white,
                                icon: Icons.share,
                                label: 'Share vote',
                              ),
                            ],
                          ),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  confirmDelete(context, pollModel.id!);
                                },
                                backgroundColor: getColorByIndex(
                                  title.codeUnitAt(0),
                                ),
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Remove vote',
                              ),
                            ],
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
                                const EdgeInsets.only(top: 60, bottom: 30.0),
                            child: SvgPicture.asset(
                              'assets/images/recent_vote_placeholder.svg',
                              fit: BoxFit.fill,
                            ),
                          ),
                          Text(
                            'No  recent vote found, give your vote now by entering voting code!',
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
                        margin: const EdgeInsets.only(top: 60, bottom: 30.0),
                        child: SvgPicture.asset(
                          'assets/images/recent_vote_placeholder.svg',
                          fit: BoxFit.fill,
                        ),
                      ),
                      Text(
                        'No  recent vote found, give your vote now by entering voting code!',
                        style: textRegular,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
      },
    );
  }

  Future<void> confirmDelete(BuildContext context, String pollId) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Are you sure?',
          style: Theme.of(context).textTheme.headline6,
        ),
        content: Text(
          'Do you want delete this poll in your polling list?',
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
            onPressed: () {
              FirebaseFirestore.instance
                  .collection("polls")
                  .doc(pollId)
                  .update({
                'users': FieldValue.arrayRemove([widget.userModel.username])
              });
              const snackbar = SnackBar(
                  content: Text(
                      "Polling has been successfully removed from your vote list"));
              ScaffoldMessenger.of(context).showSnackBar(snackbar);
              Navigation.back(context);
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
