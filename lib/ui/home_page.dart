import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:votie/common/style.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

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
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(
                            bottom: 20.0, top: 60.0, right: 20.0, left: 20.0),
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
                                style: textRegularGray,
                              ),
                            ),
                            Container(
                              color: colorSoftGray,
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
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Ex: 234RGGN',
                                          hintStyle: textRegularGray),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {},
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
                  child: ListRecentVote(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ListRecentVote extends StatelessWidget {
  final List<String> _dummyData = [
    'Tujuan liburan akhir tahun',
    'Pemilihan ketua kelas',
    'Vote makan siang',
    'Pilih band favorit',
  ];

  ListRecentVote({Key? key}) : super(key: key);

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
                  width: 60.0,
                  height: 60.0,
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
                      Text(
                        'End 22 Dec 2021',
                        style: textRegularGray,
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
