import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:votie/common/navigation.dart';
import 'package:votie/common/style.dart';
import 'package:votie/data/model/poll_model.dart';
import 'package:votie/data/model/user_model.dart';
import 'package:intl/intl.dart';
import 'package:votie/ui/detail_vote_page.dart';
import 'package:votie/utils/date_time_helper.dart';

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
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 1.225,
          child: Column(
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
                              bottom: 20.0, top: 10.0, right: 20.0, left: 20.0),
                          child: Text(
                            'Welcome to Votie!',
                            style: titleBoldOrange,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20.0),
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
                                margin: const EdgeInsets.only(top: 20.0),
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
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ListRecentVote(
                    userModel: widget.userModel,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  searchPoll() async {
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
            firestore
                .collection("polls")
                .doc(_searchController.text.toUpperCase())
                .update({
              'users': FieldValue.arrayUnion([widget.userModel.username])
            });
            // const snackbar = SnackBar(
            //     content: Text("Voting code has been successfully reedemed"));
            // ScaffoldMessenger.of(context).showSnackBar(snackbar);
            _searchController.text = "";
            Navigation.intentWithMultipleData(
              DetailVote.routeName,
              {'pollModel': pollModel, 'userModel': widget.userModel},
            );
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

class ListRecentVote extends StatelessWidget {
  final UserModel userModel;

  const ListRecentVote({
    Key? key,
    required this.userModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("polls")
            .where("users", arrayContains: userModel.username)
            .orderBy("end", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: const EdgeInsets.only(top: 0),
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    PollModel pollModel =
                        PollModel.fromDoc(snapshot.data!.docs[index]);
                    DateTime aDate = DateTimeHelper.timeStampToDay(
                        snapshot.data!.docs[index].get("end"));
                    String updatedDate;

                    if (aDate == today) {
                      var newFormat = DateFormat("Hm");
                      updatedDate = newFormat.format(pollModel.end!);
                      if (pollModel.end!.isAtSameMomentAs(now) ||
                          pollModel.end!.isBefore(now)) {
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
                      if (pollModel.end!.isBefore(now)) {
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
                      child: TextButton(
                        onPressed: () {
                          if (aDate == today) {
                            if (pollModel.end!.isAtSameMomentAs(now) ||
                                pollModel.end!.isBefore(now)) {
                              var id = pollModel.id;
                              bool show = pollModel.show!;
                              if (show == true) {
                                FirebaseFirestore.instance
                                    .collection("polls")
                                    .doc(id)
                                    .update({"show": false});
                              }
                            }
                          } else {
                            if (pollModel.end!.isBefore(now)) {
                              var id = pollModel.id;
                              bool show = pollModel.show!;
                              if (show == true) {
                                FirebaseFirestore.instance
                                    .collection("polls")
                                    .doc(id)
                                    .update({"show": false});
                              }
                            }
                          }
                          Navigation.intentWithMultipleData(
                            DetailVote.routeName,
                            {'pollModel': pollModel, 'userModel': userModel},
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              Container(
                                width: 60.0,
                                height: 60.0,
                                color: getSoftColorByIndex(title.codeUnitAt(0)),
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
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin:
                                          const EdgeInsets.only(bottom: 5.0),
                                      child: Text(
                                        title,
                                        style: textMedium,
                                      ),
                                    ),
                                    Text(
                                      'End $updatedDate',
                                      style: textRegular,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              : const Center(child: Text("Your Vote List is Empty"));
        });
  }
}
