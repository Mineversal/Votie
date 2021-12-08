import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:votie/common/navigation.dart';
import 'package:votie/common/style.dart';
import 'package:votie/data/model/option_model.dart';
import 'package:votie/data/model/poll_model.dart';
import 'package:votie/data/model/user_model.dart';
import 'package:votie/provider/detail_vote_provider.dart';

class DetailVote extends StatefulWidget {
  static const routeName = '/detailVote';
  final PollModel pollModel;
  final UserModel userModel;

  const DetailVote({Key? key, required this.pollModel, required this.userModel})
      : super(key: key);

  @override
  _DetailVoteState createState() => _DetailVoteState();
}

class _DetailVoteState extends State<DetailVote> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
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
                      onPressed: () {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        Navigation.back();
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                        left: 20.0, right: 20.0, top: 10.0),
                    child: Text(
                      widget.pollModel.title ?? '',
                      style: textSemiBold,
                    ),
                  ),
                  widget.pollModel.description != null
                      ? Container(
                          margin: const EdgeInsets.only(
                              left: 20.0, right: 20.0, top: 18.0),
                          child: Text(
                            widget.pollModel.description!,
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
                        TextButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                    text: widget.pollModel.id.toString()))
                                .then((_) {
                              const snackbar = SnackBar(
                                  content:
                                      Text("Voting code copied successfully"));
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
                                widget.pollModel.id.toString(),
                                style: textRegular.apply(color: Colors.black),
                              )
                            ],
                          ),
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
                                Icons.person,
                                color: colorGray,
                              ),
                            ),
                            Text(
                              widget.pollModel.creator ?? '',
                              style: textRegular.apply(color: Colors.black),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                        left: 20.0, right: 25.0, top: 18.0, bottom: 28.0),
                    child: TextButton(
                      onPressed: () {
                        Share.share(
                            "Download Votie now\nhttps://play.google.com/store/apps/details?id=com.mineversal.votie\n\nUse this code to give your vote\n${widget.pollModel.id.toString()}",
                            subject:
                                "Download Votie now & use ${widget.pollModel.id.toString()} to give your vote");
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
                            "Share",
                            style: textRegular.apply(color: Colors.black),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListOptions(
              pollModel: widget.pollModel,
              userModel: widget.userModel,
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.pollModel.voters!.any(
              (voter) => voter.toString().contains(widget.userModel.username!))
          ? null
          : Consumer<DetailVoteProvider>(
              builder: (context, state, _) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: state.getOption.any((option) => option != false)
                        ? getColorByIndex(
                            widget.pollModel.title!.codeUnitAt(0),
                          )
                        : colorSoftGray,
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
                  onPressed: state.getOption.any((option) => option != false)
                      ? () {
                          try {
                            state.voteOption(widget.pollModel.id!,
                                widget.userModel.username!);
                          } catch (e) {
                            print(e);
                          }
                        }
                      : null,
                );
              },
            ),
    );
  }
}

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
          return Consumer<DetailVoteProvider>(
            builder: (context, state, _) {
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  var option = options[index];
                  if (state.getOption.length < index + 1) {
                    state.getOption.insert(index, false);
                  }
                  return InkWell(
                    onTap: widget.pollModel.voters!.any((voter) => voter
                            .toString()
                            .contains(widget.userModel.username!))
                        ? null
                        : () {
                            var isSelected = !state.getOption[index];
                            if (!widget.pollModel.multivote!) {
                              for (int i = 0; i < state.getOption.length; i++) {
                                state.getOption[i] = false;
                              }
                            }
                            state.setOption(isSelected, index);
                          },
                    splashFactory: NoSplash.splashFactory,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      margin: const EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 15.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(
                            color: state.getOption[index]
                                ? getColorByIndex(
                                    widget.pollModel.title!.codeUnitAt(0))
                                : const Color(0xFFECECEC),
                            width: 2.0,
                            style: BorderStyle.solid),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(0),
                        leading: Checkbox(
                          fillColor:
                              MaterialStateProperty.resolveWith(getColor),
                          activeColor: Colors.transparent,
                          value: state.getOption[index],
                          shape: const CircleBorder(),
                          onChanged: widget.pollModel.voters!.any((voter) =>
                                  voter
                                      .toString()
                                      .contains(widget.userModel.username!))
                              ? null
                              : (bool? value) {
                                  state.setOption(value!, index);
                                },
                        ),
                        title: Text(
                          option.title,
                          style: state.getOption[index]
                              ? textMedium.apply(
                                  color: getColorByIndex(
                                      widget.pollModel.title!.codeUnitAt(0)))
                              : textMedium,
                        ),
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
