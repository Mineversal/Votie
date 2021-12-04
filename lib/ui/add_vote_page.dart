import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:votie/common/navigation.dart';
import 'package:votie/common/style.dart';
import 'package:votie/data/model/poll_model.dart';
import 'package:votie/data/model/user_model.dart';
import 'package:intl/intl.dart';
import 'package:votie/ui/create_vote_page.dart';
import 'package:votie/ui/detail_vote_page.dart';

class AddVote extends StatelessWidget {
  final UserModel userModel;

  const AddVote({Key? key, required this.userModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 1.125,
          child: Column(
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
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(
                            bottom: 2.0, top: 60.0, right: 20.0, left: 20.0),
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
                          style: textMedium.apply(color: Colors.white),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(
                            bottom: 2.0, right: 20.0, left: 20.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigation.intentWithData(
                                CreateVote.routeName, userModel);
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
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ListYourVote(userModel: userModel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ListYourVote extends StatelessWidget {
  final UserModel userModel;

  const ListYourVote({
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
            .where("creator", isEqualTo: userModel.username)
            .orderBy("end", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: const EdgeInsets.only(top: 0),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    Timestamp time = snapshot.data!.docs[index].get("end");
                    DateTime dateToCheck = DateTime.fromMicrosecondsSinceEpoch(
                        time.microsecondsSinceEpoch);
                    DateTime aDate = DateTime(
                        dateToCheck.year, dateToCheck.month, dateToCheck.day);
                    String updatedDate;

                    if (aDate == today) {
                      var newFormat = DateFormat("Hm");
                      updatedDate = newFormat.format(dateToCheck);
                    } else if (aDate.isBefore(today)) {
                      var id = snapshot.data!.docs[index].get("id");
                      bool show = snapshot.data!.docs[index].get("show");
                      if (show == true) {
                        var newFormat = DateFormat("yMMMd");
                        updatedDate = newFormat.format(dateToCheck);
                        FirebaseFirestore.instance
                            .collection("polls")
                            .doc(id)
                            .update({"show": false});
                      } else {
                        var newFormat = DateFormat("yMMMd");
                        updatedDate = newFormat.format(dateToCheck);
                      }
                    } else {
                      var newFormat = DateFormat("yMMMd");
                      updatedDate = newFormat.format(dateToCheck);
                    }

                    var jumlahOpsi = snapshot.data!.docs[index].get("options");

                    List voter = snapshot.data!.docs[index].get("users");
                    var jumlahVoter = voter.length;

                    if (jumlahVoter.isNaN) {
                      jumlahVoter = 0;
                    } else {
                      jumlahVoter = jumlahVoter;
                    }

                    var title = snapshot.data!.docs[index].get("title");

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15.0),
                      padding: const EdgeInsets.all(15),
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
                      child: InkWell(
                        onTap: () {
                          PollModel pollModel = PollModel();
                          pollModel.id = snapshot.data!.docs[index].get("id");
                          pollModel.creator =
                              snapshot.data!.docs[index].get("creator");
                          pollModel.title = title;
                          pollModel.description =
                              snapshot.data!.docs[index].get("description");
                          pollModel.images =
                              snapshot.data!.docs[index].get("images");
                          pollModel.options = jumlahOpsi;
                          pollModel.anonim =
                              snapshot.data!.docs[index].get("anonim");
                          pollModel.multivote =
                              snapshot.data!.docs[index].get("multivote");
                          pollModel.show =
                              snapshot.data!.docs[index].get("show");
                          pollModel.end = aDate;

                          Navigation.intentWithData(
                              DetailVote.routeName, pollModel);
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 66.0,
                              height: 66.0,
                              color: getSoftColorByIndex(index),
                              child: Center(
                                child: Text(
                                  title[0].toString().toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 25.0,
                                      fontWeight: FontWeight.bold,
                                      color: getColorByIndex(index)),
                                ),
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 5.0),
                                    child: Text(
                                      title,
                                      style: textMedium,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        margin:
                                            const EdgeInsets.only(right: 5.0),
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
                                    margin: const EdgeInsets.only(top: 5.0),
                                    child: Text(
                                      'End $updatedDate',
                                      style: GoogleFonts.poppins(
                                          color: getColorByIndex(index),
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                )
              : const Center(child: Text("Belum Ada Voting Buatanmu"));
        });
  }
}
