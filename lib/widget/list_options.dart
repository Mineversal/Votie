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
          var isGrid = options.any((option) => option.images!.isNotEmpty);
          return isGrid
              ? SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  sliver: OptionTypeGrid(
                      options: options,
                      pollModel: widget.pollModel,
                      userModel: widget.userModel),
                )
              : OptionTypeList(
                  options: options,
                  pollModel: widget.pollModel,
                  userModel: widget.userModel);
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

class OptionTypeList extends StatelessWidget {
  final PollModel pollModel;
  final UserModel userModel;
  final List<OptionModel> options;

  const OptionTypeList(
      {Key? key,
      required this.pollModel,
      required this.userModel,
      required this.options})
      : super(key: key);

  Color getColor(Set<MaterialState> states) {
    if (states.contains(MaterialState.selected)) {
      return getColorByIndex(pollModel.title!.codeUnitAt(0));
    }
    return colorGray;
  }

  @override
  Widget build(BuildContext context) {
    var _width = MediaQuery.of(context).size.width - 80;
    var isVoted =
        options.any((element) => element.voter!.contains(userModel.username!));
    var isShow = pollModel.show!;
    double totalVote = 0;
    for (var option in options) {
      totalVote += option.voter!.length;
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
            var isChecked = option.voter!.contains(userModel.username);
            if (state.getOptionStatus.length < index + 1) {
              state.getOptionStatus.insert(index, false);
            }
            return InkWell(
              onTap: isVoted || isShow == false
                  ? null
                  : () {
                      var isSelected = !state.getOptionStatus[index];
                      if (!pollModel.multivote!) {
                        for (int i = 0; i < state.getOptionStatus.length; i++) {
                          state.getOptionStatus[i] = false;
                        }
                      }
                      state.setOptionStatus(isSelected, index);
                    },
              splashFactory: NoSplash.splashFactory,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                margin:
                    const EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                      color:
                          (isVoted ? isChecked : state.getOptionStatus[index])
                              ? getColorByIndex(pollModel.title!.codeUnitAt(0))
                              : const Color(0xFFECECEC),
                      width: 2.0,
                      style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      leading: Checkbox(
                        fillColor: MaterialStateProperty.resolveWith(getColor),
                        activeColor: Colors.transparent,
                        value:
                            isVoted ? isChecked : state.getOptionStatus[index],
                        shape: const CircleBorder(),
                        onChanged: isVoted || isShow == false
                            ? null
                            : (bool? value) {
                                state.setOptionStatus(value!, index);
                              },
                      ),
                      title: Text(
                        option.title,
                        style:
                            (isVoted ? isChecked : state.getOptionStatus[index])
                                ? textMedium.apply(
                                    color: getColorByIndex(
                                      pollModel.title!.codeUnitAt(0),
                                    ),
                                  )
                                : textMedium,
                      ),
                      trailing: isVoted || isShow == false
                          ? Container(
                              margin: const EdgeInsets.only(right: 20.0),
                              child: Text(
                                '${((option.voter!.length / totalVote) * 100).round()}%',
                                style: (isVoted
                                        ? isChecked
                                        : state.getOptionStatus[index])
                                    ? textMedium.apply(
                                        color: getColorByIndex(
                                          pollModel.title!.codeUnitAt(0),
                                        ),
                                      )
                                    : textRegular.apply(color: Colors.black),
                              ),
                            )
                          : const Text(''),
                    ),
                    isVoted || isShow == false
                        ? Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 10.0),
                                width: _width,
                                height: 13.0,
                                decoration: BoxDecoration(
                                  color: colorSoftGray,
                                  borderRadius: BorderRadius.circular(50.0),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(bottom: 10.0),
                                width: ((option.voter!.length / totalVote) *
                                    _width),
                                height: 13.0,
                                decoration: BoxDecoration(
                                  color: (isVoted
                                          ? isChecked
                                          : state.getOptionStatus[index])
                                      ? getColorByIndex(
                                          pollModel.title!.codeUnitAt(0))
                                      : colorGray,
                                  borderRadius: BorderRadius.circular(50.0),
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
  }
}

class OptionTypeGrid extends StatelessWidget {
  final PollModel pollModel;
  final UserModel userModel;
  final List<OptionModel> options;

  const OptionTypeGrid(
      {Key? key,
      required this.pollModel,
      required this.userModel,
      required this.options})
      : super(key: key);

  Color getColor(Set<MaterialState> states) {
    if (states.contains(MaterialState.selected)) {
      return getColorByIndex(pollModel.title!.codeUnitAt(0));
    }
    return colorGray;
  }

  @override
  Widget build(BuildContext context) {
    var isVoted =
        options.any((element) => element.voter!.contains(userModel.username!));
    var isShow = pollModel.show!;
    double totalVote = 0;
    for (var option in options) {
      totalVote += option.voter!.length;
    }
    Future.delayed(Duration.zero, () async {
      Provider.of<DetailVoteProvider>(context, listen: false)
          .setOptions(options);
    });
    return Consumer<DetailVoteProvider>(
      builder: (context, state, _) {
        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200.0,
            mainAxisSpacing: 20.0,
            crossAxisSpacing: 20.0,
            childAspectRatio: 0.75,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            var option = options[index];
            var isChecked = option.voter!.contains(userModel.username);
            if (state.getOptionStatus.length < index + 1) {
              state.getOptionStatus.insert(index, false);
            }
            return InkWell(
              onTap: isVoted || isShow == false
                  ? null
                  : () {
                      var isSelected = !state.getOptionStatus[index];
                      if (!pollModel.multivote!) {
                        for (int i = 0; i < state.getOptionStatus.length; i++) {
                          state.getOptionStatus[i] = false;
                        }
                      }
                      state.setOptionStatus(isSelected, index);
                    },
              splashFactory: NoSplash.splashFactory,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                      color:
                          (isVoted ? isChecked : state.getOptionStatus[index])
                              ? getColorByIndex(pollModel.title!.codeUnitAt(0))
                              : const Color(0xFFECECEC),
                      width: 2.0,
                      style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                          top: 12.0, left: 12.0, right: 12.0),
                      child: Stack(
                        children: [
                          option.images!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(5.0),
                                  child: Image.network(
                                    option.images!,
                                    fit: BoxFit.cover,
                                    height: 140.0,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return SizedBox(
                                          height: 140.0,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: getColorByIndex(pollModel
                                                  .title!
                                                  .codeUnitAt(0)),
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          ));
                                    },
                                  ),
                                )
                              : Container(
                                  height: 140.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: colorSoftGray,
                                  ),
                                  child: Center(
                                    child: Text(
                                      option.title[0].toString().toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 25.0,
                                        fontWeight: FontWeight.bold,
                                        color: colorGray,
                                      ),
                                    ),
                                  ),
                                ),
                          isVoted || isShow == false
                              ? Container(
                                  height: 140,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: Colors.black.withOpacity(0.4),
                                  ),
                                )
                              : Container(),
                          isVoted || isShow == false
                              ? SizedBox(
                                  height: 140,
                                  child: Column(
                                    children: [
                                      Container(
                                        margin:
                                            const EdgeInsets.only(top: 10.0),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${((option.voter!.length / totalVote) * 100).round()}%',
                                          style: textMedium.apply(
                                              color: Colors.white),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: 108.0 -
                                                (option.voter!.length /
                                                        totalVote) *
                                                    108.0),
                                        height:
                                            (option.voter!.length / totalVote) *
                                                108.0,
                                        width: 20,
                                        color: (isVoted
                                                ? isChecked
                                                : state.getOptionStatus[index])
                                            ? getColorByIndex(
                                                pollModel.title!.codeUnitAt(0))
                                            : colorGray,
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      leading: Checkbox(
                        fillColor: MaterialStateProperty.resolveWith(getColor),
                        activeColor: Colors.transparent,
                        value:
                            isVoted ? isChecked : state.getOptionStatus[index],
                        shape: const CircleBorder(),
                        onChanged: isVoted || isShow == false
                            ? null
                            : (bool? value) {
                                state.setOptionStatus(value!, index);
                              },
                      ),
                      title: Text(
                        option.title,
                        style:
                            (isVoted ? isChecked : state.getOptionStatus[index])
                                ? textMedium.apply(
                                    color: getColorByIndex(
                                      pollModel.title!.codeUnitAt(0),
                                    ),
                                  )
                                : textMedium,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }, childCount: options.length),
        );
      },
    );
  }
}
