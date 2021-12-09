import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:votie/common/style.dart';
import 'package:votie/data/model/option_model.dart';
import 'package:votie/data/model/poll_model.dart';
import 'package:votie/data/model/user_model.dart';
import 'package:votie/provider/detail_vote_provider.dart';

class ListOptions extends StatefulWidget {
  final PollModel pollModel;
  final UserModel userModel;

  const ListOptions({
    Key? key,
    required this.pollModel,
    required this.userModel,
  }) : super(key: key);

  @override
  State<ListOptions> createState() => _ListOptionsState();
}

class _ListOptionsState extends State<ListOptions> {
  Color getColor(Set<MaterialState> states) {
    if (states.contains(MaterialState.selected)) {
      return getColorByIndex(widget.pollModel.title!.codeUnitAt(0));
    }
    return colorGray;
  }

  @override
  Widget build(BuildContext context) {
    var _width = MediaQuery.of(context).size.width - 80;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("polls")
          .doc(widget.pollModel.id)
          .collection("options")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var docs = snapshot.data!.docs;
          var options = docs.map((doc) => OptionModel.fromDoc(doc)).toList();
          var isVoted = options.any(
              (element) => element.voter!.contains(widget.userModel.username!));
          double totalVote = 0;
          for (var element in options) {
            totalVote += element.voter!.length;
          }
          Future.delayed(Duration.zero, () async {
            Provider.of<DetailVoteProvider>(context, listen: false)
                .setOptions(options);
          });
          return Consumer<DetailVoteProvider>(
            builder: (context, state, _) {
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  var option = options[index];
                  var isChecked =
                      option.voter!.contains(widget.userModel.username);
                  inspect(isChecked);
                  if (state.getOptionStatus.length < index + 1) {
                    state.getOptionStatus.insert(index, false);
                  }
                  return InkWell(
                    onTap: isVoted
                        ? null
                        : () {
                            var isSelected = !state.getOptionStatus[index];
                            if (!widget.pollModel.multivote!) {
                              for (int i = 0;
                                  i < state.getOptionStatus.length;
                                  i++) {
                                state.getOptionStatus[i] = false;
                              }
                            }
                            state.setOptionStatus(isSelected, index);
                          },
                    splashFactory: NoSplash.splashFactory,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      margin: const EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 15.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(
                            color: (isVoted
                                    ? isChecked
                                    : state.getOptionStatus[index])
                                ? getColorByIndex(
                                    widget.pollModel.title!.codeUnitAt(0))
                                : const Color(0xFFECECEC),
                            width: 2.0,
                            style: BorderStyle.solid),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.all(0),
                            leading: Checkbox(
                              fillColor:
                                  MaterialStateProperty.resolveWith(getColor),
                              activeColor: Colors.transparent,
                              value: isVoted
                                  ? isChecked
                                  : state.getOptionStatus[index],
                              shape: const CircleBorder(),
                              onChanged: isVoted
                                  ? null
                                  : (bool? value) {
                                      state.setOptionStatus(value!, index);
                                    },
                            ),
                            title: Text(
                              option.title,
                              style: (isVoted
                                      ? isChecked
                                      : state.getOptionStatus[index])
                                  ? textMedium.apply(
                                      color: getColorByIndex(
                                        widget.pollModel.title!.codeUnitAt(0),
                                      ),
                                    )
                                  : textMedium,
                            ),
                            trailing: isVoted
                                ? Container(
                                    margin: EdgeInsets.only(right: 20.0),
                                    child: Text(
                                      '${((option.voter!.length / totalVote) * 100).round()}%',
                                      style: (isVoted
                                              ? isChecked
                                              : state.getOptionStatus[index])
                                          ? textMedium.apply(
                                              color: getColorByIndex(
                                                widget.pollModel.title!
                                                    .codeUnitAt(0),
                                              ),
                                            )
                                          : textRegular.apply(
                                              color: Colors.black),
                                    ),
                                  )
                                : const Text(''),
                          ),
                          isVoted
                              ? Stack(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(bottom: 10.0),
                                      width: _width,
                                      height: 13.0,
                                      decoration: BoxDecoration(
                                        color: colorSoftGray,
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(bottom: 10.0),
                                      width:
                                          ((option.voter!.length / totalVote) *
                                              _width),
                                      height: 13.0,
                                      decoration: BoxDecoration(
                                        color: (isVoted
                                                ? isChecked
                                                : state.getOptionStatus[index])
                                            ? getColorByIndex(widget
                                                .pollModel.title!
                                                .codeUnitAt(0))
                                            : colorGray,
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  );
                }, childCount: options.length),
              );
            },
          );
        } else {
          return SliverList(
            delegate: SliverChildListDelegate(
              [
                const Center(
                  child: Text("Opsi Tidak Ada"),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
