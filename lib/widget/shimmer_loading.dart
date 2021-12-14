import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:votie/common/style.dart';

class ShimmerLoading extends StatelessWidget {
  final int count;

  const ShimmerLoading({Key? key, required this.count}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
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
                  offset: const Offset(2, 2), // changes position of shadow
                ),
              ],
            ),
            width: MediaQuery.of(context).size.width,
            child: TextButton(
              onPressed: null,
              child: Shimmer.fromColors(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        Container(
                          width: 60.0,
                          height: 60.0,
                          color: colorGray.withOpacity(0.5),
                        ),
                        Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                  left: 20.0, bottom: 10.0),
                              width: MediaQuery.of(context).size.width - 166,
                              height: 15.0,
                              color: colorGray.withOpacity(0.5),
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                  left: 20.0, right: 100.0),
                              width: MediaQuery.of(context).size.width - 266,
                              height: 15.0,
                              color: colorGray.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  baseColor: colorGray.withOpacity(0.5),
                  highlightColor: Colors.white),
            ),
          );
        },
        childCount: count,
      ),
    );
  }
}
