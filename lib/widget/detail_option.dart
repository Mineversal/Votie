import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:votie/common/style.dart';
import 'package:votie/provider/result_vote_provider.dart';

class DetailOption extends StatelessWidget {
  const DetailOption({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ResultVoteProvider>(
      builder: (context, state, _) {
        var poll = state.getPollModel;
        var options = state.getOptions;
        var option = options[state.selectedOption];
        double totalVote = 0;
        for (var option in options) {
          totalVote += option.voter!.length;
        }
        return Container(
          margin: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 130.0,
                    height: 130.0,
                    margin: const EdgeInsets.only(right: 20),
                    color: getSoftColorByIndex(poll.title!.codeUnitAt(0)),
                    child: option.images!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(5.0),
                            child: Image.network(
                              option.images!,
                              fit: BoxFit.cover,
                              height: 130.0,
                              width: 130.0,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return SizedBox(
                                    height: 130.0,
                                    width: 130.0,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: getColorByIndex(
                                            poll.title!.codeUnitAt(0)),
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
                        : Center(
                            child: Text(
                              option.title[0].toString().toUpperCase(),
                              style: TextStyle(
                                fontSize: 40.0,
                                fontWeight: FontWeight.bold,
                                color: getColorByIndex(
                                  poll.title!.codeUnitAt(0),
                                ),
                              ),
                            ),
                          ),
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.title,
                          style: textMedium,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10.0),
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
                                  Icons.how_to_vote,
                                  color: colorGray,
                                ),
                              ),
                              Text(
                                '${option.voter != null ? option.voter!.length : '0'} Voter',
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
                                Icons.bar_chart,
                                color: colorGray,
                              ),
                            ),
                            Text(
                              '${option.voter!.isNotEmpty ? ((option.voter!.length / totalVote) * 100).round() : '0'}%',
                              style: textRegular.apply(color: Colors.black),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(
                  top: 20.0,
                  bottom: 10,
                ),
                child: Text(
                  'Voters',
                  style: textMedium,
                ),
              ),
              option.voter!.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                    top: 15.0, right: 20.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50.0),
                                  child: Container(
                                    width: 55,
                                    height: 55,
                                    color: colorSoftGray,
                                    child: const Icon(
                                      Icons.person,
                                      color: colorGray,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                poll.anonim!
                                    ? 'Anonymous'
                                    : option.voter![index],
                                style: textRegular.apply(color: Colors.black),
                              ),
                            ],
                          );
                        },
                        itemCount: option.voter!.length,
                      ),
                    )
                  : Center(
                      child: Text(
                        'No Voter',
                        style: textRegular,
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}
