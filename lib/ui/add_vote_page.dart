import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:votie/common/style.dart';

class AddVote extends StatelessWidget {
  const AddVote({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
                      style: textMediumWhite,
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(
                        bottom: 2.0, right: 20.0, left: 20.0),
                    child: ElevatedButton(
                      onPressed: () {},
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
              child: ListYourVote(),
            ),
          ),
        ],
      ),
    );
  }
}

class ListYourVote extends StatelessWidget {
  final List<String> _dummyData = [
    'Tujuan liburan akhir tahun',
    'Pemilihan ketua kelas',
    'Vote makan siang',
    'Pilih band favorit',
  ];

  ListYourVote({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.only(top: 0),
        itemBuilder: (context, index) {
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
                  offset: const Offset(2, 2), // changes position of shadow
                ),
              ],
            ),
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: [
                Container(
                  width: 66.0,
                  height: 66.0,
                  color: getSoftColorByIndex(index),
                  child: Center(
                    child: Text(
                      _dummyData[index][0],
                      style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          color: getColorByIndex(index)),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 5.0),
                        child: Text(
                          _dummyData[index],
                          style: textMediumBlack,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 5.0),
                            child: const Icon(
                              Icons.person,
                              color: colorGray,
                              size: 18,
                            ),
                          ),
                          Text(
                            '29 Voter',
                            style: textRegularGray,
                          ),
                          Container(
                            margin:
                                const EdgeInsets.only(right: 5.0, left: 15.0),
                            child: const Icon(
                              Icons.style,
                              color: colorGray,
                              size: 18,
                            ),
                          ),
                          Text(
                            '3 Option',
                            style: textRegularGray,
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: Text(
                          'End 22 Dec 2021',
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
          );
        },
        itemCount: _dummyData.length);
  }
}
