import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:votie/common/navigation.dart';
import 'package:votie/common/style.dart';
import 'package:votie/data/model/user_model.dart';
import 'package:votie/provider/create_vote_provider.dart';
import 'package:votie/utils/date_time_helper.dart';

class CreateVote extends StatefulWidget {
  static const routeName = '/createVote';
  final UserModel userModel;

  const CreateVote({Key? key, required this.userModel}) : super(key: key);

  @override
  State<CreateVote> createState() => _CreateVoteState();
}

class _CreateVoteState extends State<CreateVote> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDate;

  final Map<int, XFile?> _optionsImage = {};

  @override
  void initState() {
    Provider.of<CreateVoteProvider>(context, listen: false).loadNTPTime();
    super.initState();
  }

  pickImage(int index) async {
    ImageSource? imageSource;
    var isRemove = false;
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(
              'Image Option',
              style: textMedium,
            ),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  imageSource = ImageSource.gallery;
                  Navigator.pop(context, true);
                },
                child: Text(
                  'Pick a picture from gallery',
                  style: textRegular.apply(color: Colors.black),
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  imageSource = ImageSource.camera;
                  Navigator.pop(context, true);
                },
                child: Text(
                  'Take a picture with camera',
                  style: textRegular.apply(color: Colors.black),
                ),
              ),
              _optionsImage[index] != null
                  ? SimpleDialogOption(
                      onPressed: () {
                        isRemove = true;
                        Navigator.pop(context, true);
                      },
                      child: Text(
                        'Remove image',
                        style: textRegular.apply(color: Colors.black),
                      ),
                    )
                  : Container()
            ],
          );
        });

    if (!isRemove) {
      if (imageSource != null) {
        _optionsImage[index] =
            await ImagePicker().pickImage(source: imageSource!);
      }
    } else {
      _optionsImage.remove(index);
    }
    setState(() {});
  }

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
        child: Consumer<CreateVoteProvider>(
          builder: (context, state, _) {
            state.userModel = widget.userModel;
            return CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      ListTile(
                        leading: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            Navigation.back(context);
                            state.clear();
                          },
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
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 8),
                        margin: const EdgeInsets.only(
                            left: 20.0, right: 20.0, top: 15.0),
                        child: Column(
                          children: [
                            TextField(
                              autocorrect: false,
                              controller: _titleController,
                              style: textMedium,
                              enabled: !state.isLoading,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Title',
                                  hintStyle:
                                      textMedium.apply(color: colorGray)),
                            ),
                            const Divider(
                              height: 10.0,
                              thickness: 0.5,
                            ),
                            TextField(
                              autocorrect: false,
                              controller: _descController,
                              style: textMedium,
                              enabled: !state.isLoading,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Description',
                                  hintStyle:
                                      textMedium.apply(color: colorGray)),
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
                                          _selectedDate!,
                                          "EE, dd MMM yyy HH':'mm'"),
                                  style: _selectedDate == null
                                      ? textMedium.apply(color: colorGray)
                                      : textMedium,
                                ),
                                onPressed: state.isLoading
                                    ? null
                                    : () {
                                        DatePicker.showDateTimePicker(context,
                                            showTitleActions: true,
                                            minTime: state.dateNow,
                                            onConfirm: (date) {
                                          setState(() {
                                            _selectedDate = date;
                                          });
                                        },
                                            currentTime: state.dateNow,
                                            locale: LocaleType.en);
                                      },
                              ),
                            ),
                            const Divider(
                              height: 10.0,
                              thickness: 0.5,
                            ),
                            InkWell(
                              onTap: state.isLoading
                                  ? null
                                  : () {
                                      state.isMultivote = !state.isMultivote;
                                      state.notify();
                                    },
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(0),
                                leading: Checkbox(
                                  fillColor: MaterialStateProperty.resolveWith(
                                      getColor),
                                  activeColor: Colors.transparent,
                                  value: state.isMultivote,
                                  shape: const CircleBorder(),
                                  onChanged: state.isLoading
                                      ? null
                                      : (bool? value) {
                                          state.isMultivote = value!;
                                          state.notify();
                                        },
                                ),
                                title: Text(
                                  'Multivote',
                                  style: state.isMultivote
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
                              onTap: state.isLoading
                                  ? null
                                  : () {
                                      state.isAnonvote = !state.isAnonvote;
                                      state.notify();
                                    },
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(0),
                                leading: Checkbox(
                                  fillColor: MaterialStateProperty.resolveWith(
                                      getColor),
                                  activeColor: Colors.transparent,
                                  value: state.isAnonvote,
                                  shape: const CircleBorder(),
                                  onChanged: state.isLoading
                                      ? null
                                      : (bool? value) {
                                          state.isAnonvote = value!;
                                          state.notify();
                                        },
                                ),
                                title: Text(
                                  'Anonymous Vote',
                                  style: state.isAnonvote
                                      ? textMedium
                                      : textMedium.apply(color: colorGray),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SliverStack(
                  children: [
                    SliverPositioned.fill(
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 8),
                        margin: const EdgeInsets.only(
                            left: 20.0, right: 20.0, top: 30.0),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.only(
                          left: 40, right: 40, top: 38, bottom: 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return Column(
                            children: [
                              ListTile(
                                title: TextField(
                                  autocorrect: false,
                                  enabled: !state.isLoading,
                                  onChanged: (text) {
                                    if (index == state.itemCount - 1) {
                                      state.itemCount++;
                                      state.notify();
                                    }
                                    state.saveOption(index, text);
                                  },
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '${index + 1}. Enter an Option',
                                      hintStyle:
                                          textMedium.apply(color: colorGray)),
                                ),
                                trailing: IconButton(
                                  icon: _optionsImage[index] != null
                                      ? Image.file(
                                          File(_optionsImage[index]!.path),
                                          fit: BoxFit.fitHeight,
                                        )
                                      : Image.asset(
                                          'assets/images/add_image.png'),
                                  onPressed: state.isLoading
                                      ? null
                                      : () {
                                          pickImage(index);
                                        },
                                  iconSize: 35.0,
                                ),
                              ),
                              index != state.itemCount - 1
                                  ? const Divider(
                                      height: 10.0,
                                      thickness: 0.5,
                                    )
                                  : Container(),
                            ],
                          );
                        }, childCount: state.itemCount),
                      ),
                    )
                  ],
                ),
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 30.0, horizontal: 20.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints.tightFor(height: 50),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: colorGreen,
                        ),
                        onPressed: state.isLoading
                            ? null
                            : () async {
                                try {
                                  await state.validatePoll(
                                      _titleController.text.toString(),
                                      _descController.text.toString(),
                                      _selectedDate,
                                      _optionsImage);
                                  Navigation.back(context);
                                  state.clear();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())));
                                }
                              },
                        child: state.isLoading
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
                )
              ],
            );
          },
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
