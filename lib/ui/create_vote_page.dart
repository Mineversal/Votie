import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:votie/common/navigation.dart';
import 'package:votie/common/style.dart';
import 'package:votie/data/model/option_model.dart';
import 'package:votie/data/model/poll_model.dart';
import 'package:votie/data/model/user_model.dart';
import 'package:random_string/random_string.dart';
import 'package:votie/utils/date_time_helper.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

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
  final List<OptionModel> _options = [];
  final Map<int, XFile?> _optionsImage = {};
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  Color getColor(Set<MaterialState> states) {
    if (states.contains(MaterialState.selected)) {
      return colorGreen;
    }
    return colorGray;
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

  Future<String?> uploadImage(File file, String fileName) async {
    try {
      await storage.ref(fileName).putFile(file);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
      return null;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
    return storage.ref(fileName).getDownloadURL();
  }

  saveOption(int index, String text) {
    OptionModel option = OptionModel(id: index, images: '', title: text);
    if (_options.length >= index + 1) {
      _options[index] = option;
    } else {
      _options.insert(index, option);
    }
  }

  validatePoll() {
    List<OptionModel> newOptions = [];
    final Map<int, XFile?> newOptionsImage = {};
    var optionId = 1;
    var isDuplicate = false;
    for (var option in _options) {
      if (option.title.isNotEmpty) {
        if (!newOptions.any((element) => element.title == option.title)) {
          newOptions.add(OptionModel(
              title: option.title, images: option.images, id: optionId));
          newOptionsImage[optionId] = _optionsImage[option.id];
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

    addPoll(newOptions, newOptionsImage, optionId);
  }

  addPoll(List<OptionModel> options, Map<int, XFile?> optionsImage,
      int optionCount) async {
    setState(() {
      _isLoading = true;
    });

    var db = FirebaseFirestore.instance;
    CollectionReference polls = db.collection('polls');

    var id = randomAlphaNumeric(6);

    for (int i = 0; i < options.length; i++) {
      var option = options[i];
      if (optionsImage[option.id] != null) {
        var image = File(optionsImage[option.id]!.path);
        String basename = image.path.split('/').last;
        var fileName = 'images/polls/$id/$i-$basename';
        var imageUrl = await uploadImage(image, fileName);

        if (imageUrl != null) {
          option.images = imageUrl;
        } else {
          return;
        }
      }
    }

    PollModel poll = PollModel(
      id: id,
      creator: widget.userModel.username,
      title: _titleController.text,
      description: _descController.text,
      anonim: _isAnonvote,
      multivote: _isMultivote,
      images: "not-implemented-yet",
      options: optionCount - 1,
      show: true,
      end: _selectedDate,
      users: [widget.userModel.username],
    );

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
      setState(() {
        _isLoading = false;
      });
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
                          ListTile(
                            title: TextField(
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
                                  hintStyle:
                                      textMedium.apply(color: colorGray)),
                            ),
                            trailing: IconButton(
                              icon: _optionsImage[index] != null
                                  ? Image.file(
                                      File(_optionsImage[index]!.path),
                                      fit: BoxFit.fitHeight,
                                    )
                                  : Image.asset('assets/images/add_image.png'),
                              onPressed: () {
                                pickImage(index);
                              },
                              iconSize: 35.0,
                            ),
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
