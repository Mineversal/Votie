import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:votie/common/navigation.dart';
import 'package:votie/common/style.dart';
import 'package:votie/data/model/poll_model.dart';

class ResultVote extends StatelessWidget {
  static const routeName = '/resultVote';
  final PollModel pollModel;

  const ResultVote({Key? key, required this.pollModel}) : super(key: key);

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
                    onPressed: () => (Navigation.back()),
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
                  child: Text(
                    pollModel.title ?? '',
                    style: textSemiBold,
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.only(left: 20.0, right: 20.0, top: 18.0),
                  child: Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse commodo vitae ',
                    style: textRegular,
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.only(left: 20.0, right: 25.0, top: 28.0),
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
                            pollModel.creator ?? '',
                            style: textRegular.apply(color: Colors.black),
                          )
                        ],
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
                              Icons.how_to_vote,
                              color: colorGray,
                            ),
                          ),
                          Text(
                            '80 Votes',
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
                        pollModel.id.toString(),
                        style: textRegular.apply(color: Colors.black),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListOptions(
            pollModel: pollModel,
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Container(
                  margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: SvgPicture.asset(
                          getOptionBg(pollModel.title.toString().codeUnitAt(0)),
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
                                'End in',
                                style: textRegular.apply(color: colorDarkBlue),
                              ),
                              Text(
                                '01 : 07 : 56 : 32',
                                style: GoogleFonts.poppins(
                                    fontSize: 35.0,
                                    fontWeight: FontWeight.w600,
                                    color: colorDarkBlue),
                              ),
                              Text(
                                '   days          Hours          Minutes        Second',
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: colorDarkBlue),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return Container(
          margin: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 15.0),
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
                width: _width * ((Random().nextInt(80) + 20) / 100),
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
                        offset:
                            const Offset(2, 4), // changes position of shadow
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
                        margin: const EdgeInsets.only(left: 10.0, right: 15.0),
                        padding: const EdgeInsets.all(15.0),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${index + 1}',
                          style: textBoldBlack.apply(color: colorDarkBlue),
                        ),
                      ),
                      Text(
                        'Option',
                        style: textBoldBlack.apply(color: colorDarkBlue),
                      )
                    ],
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: 55,
                    margin: const EdgeInsets.only(left: 10.0, right: 15.0),
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      '10 Votes',
                      style: textBoldBlack.apply(color: colorDarkBlue),
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      }, childCount: 4),
    );
  }
}
