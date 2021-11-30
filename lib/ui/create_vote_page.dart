import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:votie/common/navigation.dart';
import 'package:votie/common/style.dart';
import 'package:votie/data/model/option_model.dart';
import 'package:votie/data/model/poll_model.dart';
import 'package:votie/data/model/user_model.dart';
import 'package:random_string/random_string.dart';
import 'package:votie/utils/date_time_helper.dart';

class CreateVote extends StatefulWidget {
  static const routeName = '/createVote';
  final UserModel userModel;

  const CreateVote({Key? key, required this.userModel}) : super(key: key);

  @override
  State<CreateVote> createState() => _CreateVoteState();
}

class _CreateVoteState extends State<CreateVote> {
  var _isMultivote = false;
  var _isAnonvote = false;
  var _isLoading = false;
  var _itemCount = 2;

  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  DateTime? _selectedDate;
  List<OptionModel> options = [];

  Color getColor(Set<MaterialState> states) {
    if (states.contains(MaterialState.selected)) {
      return colorGreen;
    }
    return colorGray;
  }

  saveOption(int index, String text) {
    OptionModel option =
        OptionModel(id: index, images: 'not-implemented-yet', title: text);
    if (options.length >= index + 1) {
      options[index] = option;
    } else {
      options.insert(index, option);
    }
  }

  validatePoll() {
    List<OptionModel> newOptions = [];
    var optionId = 1;
    var isDuplicate = false;
    for (var option in options) {
      if (option.title.isNotEmpty) {
        if (!newOptions.any((element) => element.title == option.title)) {
          newOptions.add(OptionModel(
              title: option.title, images: option.images, id: optionId));
          optionId++;
        } else {
          isDuplicate = true;
        }
      }
    }

    if (_titleController.text.isEmpty ||
        _descController.text.isEmpty ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill up all field')));
      return;
    }

    if (isDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Duplicate options exist')));
      return;
    }

    if (newOptions.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Poll must have minimum 2 options')));
      return;
    }

    addPoll(newOptions, optionId);
  }

  addPoll(List<OptionModel> options, int optionCount) async {
    _isLoading = true;

    var db = FirebaseFirestore.instance;
    CollectionReference polls = db.collection('polls');

    var id = randomAlphaNumeric(6);

    PollModel poll = PollModel(
        id: id,
        creator: widget.userModel.username,
        title: _titleController.text,
        description: _descController.text,
        images: "not-implemented-yet",
        options: optionCount - 1,
        show: true,
        end: _selectedDate);

    try {
      await polls.doc(id).set(poll.toMap()).then((value) {
        var optionsCollection = polls.doc(id).collection('options');
        var batch = db.batch();

        for (int i = 0; i < options.length; i++) {
          var ref = optionsCollection.doc('${i + 1}');
          batch.set(ref, options[i].toMap());
        }

        batch
            .commit()
            .then((value) => Navigation.back())
            .catchError((error) => throw Exception(error));
      }).catchError((error) => throw Exception(error));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                    onPressed: () => Navigation.back(),
                  ),
                  title: Text(
                    'Create New Voting',
                    style: titleMediumBlack,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.06),
                        spreadRadius: 5,
                        blurRadius: 20,
                        offset:
                            const Offset(2, 2), // changes position of shadow
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                  margin:
                      const EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0),
                  child: Column(
                    children: [
                      TextField(
                        autocorrect: false,
                        controller: _titleController,
                        style: textMedium,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Title',
                            hintStyle: textMedium.apply(color: colorGray)),
                      ),
                      const Divider(
                        height: 10.0,
                        thickness: 0.5,
                      ),
                      TextField(
                        autocorrect: false,
                        controller: _descController,
                        style: textMedium,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Description',
                            hintStyle: textMedium.apply(color: colorGray)),
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                      ),
                      const Divider(
                        height: 10.0,
                        thickness: 0.5,
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          child: Text(
                            _selectedDate == null
                                ? 'Ending Date'
                                : DateTimeHelper.formatDateTime(
                                    _selectedDate!, "EE, dd MMM yyy HH':'mm'"),
                            style: _selectedDate == null
                                ? textMedium.apply(color: colorGray)
                                : textMedium,
                          ),
                          onPressed: () {
                            DatePicker.showDateTimePicker(context,
                                showTitleActions: true,
                                minTime: DateTime.now(), onConfirm: (date) {
                              setState(() {
                                _selectedDate = date;
                              });
                            },
                                currentTime: DateTime.now(),
                                locale: LocaleType.en);
                          },
                        ),
                      ),
                      const Divider(
                        height: 10.0,
                        thickness: 0.5,
                      ),
                      InkWell(
                        onTap: () => setState(() {
                          _isMultivote = !_isMultivote;
                        }),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(0),
                          leading: Checkbox(
                            fillColor:
                                MaterialStateProperty.resolveWith(getColor),
                            activeColor: Colors.transparent,
                            value: _isMultivote,
                            shape: const CircleBorder(),
                            onChanged: (bool? value) {
                              setState(() {
                                _isMultivote = value!;
                              });
                            },
                          ),
                          title: Text(
                            'Multivote',
                            style: _isMultivote
                                ? textMedium
                                : textMedium.apply(color: colorGray),
                          ),
                        ),
                      ),
                      const Divider(
                        height: 10.0,
                        thickness: 0.5,
                      ),
                      InkWell(
                        onTap: () => setState(() {
                          _isAnonvote = !_isAnonvote;
                        }),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(0),
                          leading: Checkbox(
                            fillColor:
                                MaterialStateProperty.resolveWith(getColor),
                            activeColor: Colors.transparent,
                            value: _isAnonvote,
                            shape: const CircleBorder(),
                            onChanged: (bool? value) {
                              setState(() {
                                _isAnonvote = value!;
                              });
                            },
                          ),
                          title: Text(
                            'Anonymous Vote',
                            style: _isAnonvote
                                ? textMedium
                                : textMedium.apply(color: colorGray),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Flexible(
                    child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.06),
                        spreadRadius: 5,
                        blurRadius: 20,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                  margin:
                      const EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _itemCount,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          TextField(
                            autocorrect: false,
                            onChanged: (text) {
                              if (index == _itemCount - 1) {
                                setState(() {
                                  _itemCount++;
                                });
                              }
                              saveOption(index, text);
                            },
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '${index + 1}. Enter an Option',
                                hintStyle: textMedium.apply(color: colorGray)),
                          ),
                          index != _itemCount - 1
                              ? const Divider(
                                  height: 10.0,
                                  thickness: 0.5,
                                )
                              : Container(),
                        ],
                      );
                    },
                  ),
                )),
                Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 30.0, horizontal: 20.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints.tightFor(height: 50),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: colorGreen,
                      ),
                      onPressed: _isLoading ? null : () => {validatePoll()},
                      child: _isLoading
                          ? const SizedBox(
                              height: 25.0,
                              width: 25.0,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text('Create Vote'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }
}
