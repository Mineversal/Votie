import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:votie/common/navigation.dart';
import 'package:votie/common/style.dart';
import 'package:votie/data/model/poll_model.dart';
import 'package:votie/data/model/user_model.dart';
import 'package:votie/provider/detail_vote_provider.dart';
import 'package:votie/utils/date_time_helper.dart';
import 'package:votie/utils/dynamic_link_helper.dart';
import 'package:votie/widget/list_options.dart';

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
        child: Stack(
          children: [
            CustomScrollView(
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
                            Navigation.back();
                            Provider.of<DetailVoteProvider>(context,
                                    listen: false)
                                .clear();
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            left: 20.0, right: 20.0, top: 10.0),
                        child: Text(
                          'End on ' +
                              DateTimeHelper.formatDateTime(
                                  widget.pollModel.end!,
                                  "EE, dd MMM yyy HH':'mm'"),
                          style: textRegular.apply(
                              color: getColorByIndex(
                                  widget.pollModel.title!.codeUnitAt(0))),
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
                            Flexible(
                              child: Text(
                                widget.pollModel.creator ?? '',
                                style: textRegular.apply(color: Colors.black),
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                              ),
                            ),
                          ],
                        ),
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
                                widget.pollModel.id.toString(),
                                style: textRegular.apply(color: Colors.black),
                              )
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            String url = await DynamicLinkHelper()
                                .buildDynamicLink(
                                    widget.pollModel.id.toString());
                            Share.share("Click Here to Give Your Vote: \n$url",

                                ///"Download Votie now on\n\nGoogle Play Store:\nhttps://play.google.com/store/apps/details?id=com.mineversal.votie\n\nAmazon Appstore:\nhttps://www.amazon.com/gp/product/B09NMXLJHM\n\nOr vote from our Web App:\nhttps://votie.mineversal.com\n\nUse this code to give your vote:\n${widget.pollModel.id.toString()}",
                                subject:
                                    "Download Votie now & use ${widget.pollModel.id.toString()} to give your vote");
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
                        if (widget.pollModel.multivote!)
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
                                  Icons.splitscreen,
                                  color: colorGray,
                                ),
                              ),
                              Text(
                                'Multivote',
                                style: textRegular.apply(color: Colors.black),
                              )
                            ],
                          ),
                        if (widget.pollModel.multivote!)
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
                                  Icons.supervisor_account_rounded,
                                  color: colorGray,
                                ),
                              ),
                              Text(
                                'Anonymous',
                                style: textRegular.apply(color: Colors.black),
                              )
                            ],
                          ),
                      ],
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300.0,
                      crossAxisSpacing: 49.0,
                      childAspectRatio: 2.0,
                    ),
                  ),
                ),
                ListOptions(
                  pollModel: widget.pollModel,
                  userModel: widget.userModel,
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Container(
                        height: 80.0,
                      )
                    ],
                  ),
                )
              ],
            ),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Consumer<DetailVoteProvider>(
                builder: (context, state, _) {
                  return !state.getOptions.any((option) => option.voter!
                              .contains(widget.userModel.username)) &&
                          widget.pollModel.show == true
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: state.getOptionStatus
                                    .any((option) => option != false)
                                ? getColorByIndex(
                                    widget.pollModel.title!.codeUnitAt(0),
                                  )
                                : colorGray,
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
                          onPressed: state.getOptionStatus
                                  .any((option) => option != false)
                              ? () {
                                  confirm(context, state);
                                }
                              : () {},
                        )
                      : Container();
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> confirm(BuildContext context, DetailVoteProvider state) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Are you sure?',
          style: Theme.of(context).textTheme.headline6,
        ),
        content: Text(
          'Do you want choose this?',
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
              primary: colorRed,
              backgroundColor: Colors.transparent,
              textStyle: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          const SizedBox(width: 1),
          ElevatedButton(
            child: const Text("CONFIRM"),
            onPressed: () {
              try {
                state.voteOption(
                    widget.pollModel.id!, widget.userModel.username!);
                const snackbar = SnackBar(content: Text("Successfully vote"));
                ScaffoldMessenger.of(context).showSnackBar(snackbar);
                Navigator.of(context).pop(false);
                state.clear();
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(e.toString())));
                Navigator.of(context).pop(false);
              }
            },
            style: TextButton.styleFrom(
              primary: Colors.white,
              backgroundColor: colorGreen,
              textStyle: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
