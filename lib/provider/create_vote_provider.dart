import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:votie/data/model/option_model.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:votie/data/model/poll_model.dart';
import 'package:votie/data/model/user_model.dart';

class CreateVoteProvider extends ChangeNotifier {
  final FirebaseFirestore firestore;
  late firebase_storage.FirebaseStorage storage;

  CreateVoteProvider({required this.firestore}) {
    storage = firebase_storage.FirebaseStorage.instance;
  }

  UserModel userModel = UserModel();

  var isMultivote = false;
  var isAnonvote = false;
  var isLoading = false;
  var itemCount = 2;

  final List<OptionModel> options = [];

  notify() {
    notifyListeners();
  }

  clear() {
    itemCount = 2;
    isAnonvote = false;
    isMultivote = false;
    options.clear();
  }

  Future<String?> uploadImage(File file, String fileName) async {
    try {
      await storage.ref(fileName).putFile(file);
    } catch (e) {
      throw e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return storage.ref(fileName).getDownloadURL();
  }

  saveOption(int index, String text) {
    OptionModel option = OptionModel(id: index, images: '', title: text);
    if (options.length >= index + 1) {
      options[index] = option;
    } else {
      if (index == 1) {
        options.insert(0, OptionModel(id: 0, images: '', title: ''));
        options.insert(index, option);
      } else {
        options.insert(index, option);
      }
    }
  }

  Future<void> validatePoll(String title, String desc, DateTime? selectedDate,
      Map<int, XFile?> optionsImage) async {
    List<OptionModel> newOptions = [];
    final Map<int, XFile?> newOptionsImage = {};
    var optionId = 1;
    var isDuplicate = false;
    for (var option in options) {
      if (option.title.isNotEmpty) {
        if (!newOptions.any((element) => element.title == option.title)) {
          newOptions.add(OptionModel(
              title: option.title, images: option.images, id: optionId));
          newOptionsImage[optionId] = optionsImage[option.id];
          optionId++;
        } else {
          isDuplicate = true;
        }
      }
    }

    if (title.isEmpty || desc.isEmpty || selectedDate == null) {
      throw 'Please fill up all field';
    }

    if (isDuplicate) {
      throw 'Duplicate options exist';
    }

    if (newOptions.length < 2) {
      throw 'Poll must have minimum 2 options';
    }
    try {
      await addPoll(
          newOptions, newOptionsImage, optionId, title, desc, selectedDate);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addPoll(
      List<OptionModel> options,
      Map<int, XFile?> optionsImage,
      int optionCount,
      String title,
      String desc,
      DateTime? selectedDate) async {
    isLoading = true;
    notifyListeners();

    var db = FirebaseFirestore.instance;
    CollectionReference polls = db.collection('polls');

    var id = randomAlphaNumeric(6).toUpperCase();

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
      creator: userModel.username,
      title: title,
      description: desc,
      anonim: isAnonvote,
      multivote: isMultivote,
      images: "not-implemented-yet",
      options: optionCount - 1,
      show: true,
      end: selectedDate,
      users: [userModel.username],
      voters: [],
    );

    try {
      await polls.doc(id).set(poll.toMap()).then((value) {
        var optionsCollection = polls.doc(id).collection('options');
        var batch = db.batch();

        for (int i = 0; i < options.length; i++) {
          var ref = optionsCollection.doc('${i + 1}');
          batch.set(ref, options[i].toMap());
        }

        batch.commit();
      });
    } catch (e) {
      throw e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
