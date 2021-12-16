import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:votie/common/navigation.dart';
import 'package:votie/common/style.dart';
import 'package:votie/data/model/option_model.dart';
import 'package:votie/data/model/poll_model.dart';
import 'package:votie/provider/result_vote_provider.dart';

import 'detail_option.dart';

class ListOptionsResult extends StatefulWidget {
  const ListOptionsResult({Key? key, required this.pollModel})
      : super(key: key);

  final PollModel pollModel;

  @override
  State<ListOptionsResult> createState() => _ListOptionsResultState();
}

class _ListOptionsResultState extends State<ListOptionsResult> {
  void showDialog() {
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (_, __, ___) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
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
                const Expanded(
                  child: DetailOption(),
                ),
              ],
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
  Widget build(BuildContext context) {
    var _width = MediaQuery.of(context).size.width - 40;
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('polls')
            .doc(widget.pollModel.id)
            .collection('options')
            .snapshots(),
        builder: (context, snapshot) {
          var docs = snapshot.data != null ? snapshot.data!.docs : [];
          var options = docs.map((doc) => OptionModel.fromDoc(doc)).toList();
          Future.delayed(
            Duration.zero,
            () async {
              Provider.of<ResultVoteProvider>(context, listen: false)
                  .setOptions(options);
            },
          );
          double totalVote = 0;
          for (var option in options) {
            totalVote += option.voter!.length;
          }
          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              var option = options[index];
              return InkWell(
                onTap: () {
                  Provider.of<ResultVoteProvider>(context, listen: false)
                      .setSelectedOption(index);
                  showDialog();
                },
                child: Container(
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
                        width: totalVote == 0
                            ? 55.0
                            : ((option.voter!.length / totalVote) *
                                    (_width - 55)) +
                                55,
                        height: 55,
                        decoration: BoxDecoration(
                            color: getOptionColor(widget.pollModel.title
                                .toString()
                                .codeUnitAt(0)),
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
                              Container(
                                constraints:
                                    BoxConstraints(maxWidth: _width - 170),
                                child: Text(
                                  option.title,
                                  style:
                                      textBoldBlack.apply(color: colorDarkBlue),
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
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
                ),
              );
            }, childCount: options.length),
          );
        });
  }
}
