import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:votie/common/navigation.dart';
import 'package:votie/common/style.dart';

class CreateVote extends StatefulWidget {
  static const routeName = '/createVote';

  const CreateVote({Key? key}) : super(key: key);

  @override
  State<CreateVote> createState() => _CreateVoteState();
}

class _CreateVoteState extends State<CreateVote> {
  var _isMultivote = false;
  var _isAnonvote = false;
  var _isLoading = false;
  String _selectedDate = 'Ending Date';

  Color getColor(Set<MaterialState> states) {
    if (states.contains(MaterialState.selected)) {
      return colorGreen;
    }
    return colorGray;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 1.225,
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
                            _selectedDate,
                            style: textMedium.apply(color: colorGray),
                          ),
                          onPressed: () {
                            DatePicker.showDatePicker(context,
                                showTitleActions: true,
                                minTime: DateTime.now(), onConfirm: (date) {
                              setState(() {
                                _selectedDate = date.toString();
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
                            style: textMedium.apply(color: colorGray),
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
                            style: textMedium.apply(color: colorGray),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const Flexible(child: OptionList()),
                Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 30.0, horizontal: 20.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints.tightFor(height: 50),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: colorGreen,
                      ),
                      onPressed: _isLoading ? null : () => {},
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
}

class OptionList extends StatefulWidget {
  const OptionList({Key? key}) : super(key: key);

  @override
  State<OptionList> createState() => _OptionListState();
}

class _OptionListState extends State<OptionList> {
  var _itemCount = 2;
  Map<int, String> options = {};

  void saveOption(int index, String text) {
    if (text.isNotEmpty) {
      options[index] = text;
    } else {
      options.remove(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
      margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
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
    );
  }
}
