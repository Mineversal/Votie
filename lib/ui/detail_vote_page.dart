import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:votie/common/style.dart';
import 'package:votie/data/model/poll_model.dart';

class DetailVote extends StatefulWidget {
  static const routeName = '/detailVote';
  final PollModel pollModel;

  const DetailVote({Key? key, required this.pollModel}) : super(key: key);

  @override
  _DetailVoteState createState() => _DetailVoteState();
}

class _DetailVoteState extends State<DetailVote> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 1.125,
          child: Center(
            child: Column(
              children: [
                Text(widget.pollModel.title.toString()),
                Text(widget.pollModel.description.toString()),
                Text(widget.pollModel.id.toString()),
                Text(widget.pollModel.creator.toString()),
                Text(widget.pollModel.end.toString()),
                Container(
                  margin: const EdgeInsets.all(20.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pilih Sekarang',
                    style: titleMediumBlack,
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ListOptions(pollModel: widget.pollModel),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ListOptions extends StatelessWidget {
  final PollModel pollModel;

  const ListOptions({
    Key? key,
    required this.pollModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("polls")
            .doc(pollModel.id)
            .collection("options")
            .snapshots(),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: const EdgeInsets.only(top: 0),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    ///var id = snapshot.data!.docs[index].get("id");
                    var title = snapshot.data!.docs[index].get("title");
                    List voter = snapshot.data!.docs[index].get("voter");
                    var jumlahVoter = voter.length;

                    if (jumlahVoter.isNaN) {
                      jumlahVoter = 0;
                    } else {
                      jumlahVoter = jumlahVoter;
                    }

                    return InkWell(
                      onTap: () {},
                      child: Container(
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
                              offset: const Offset(
                                  2, 2), // changes position of shadow
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
                                  title[0].toString().toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 25.0,
                                      fontWeight: FontWeight.bold,
                                      color: getColorByIndex(index)),
                                ),
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Center(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 5.0),
                                  child: Text(
                                    title,
                                    style: textMedium,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                )
              : const Center(child: Text("Opsi Tidak Ada"));
        });
  }
}
