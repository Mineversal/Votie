import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:votie/data/model/option_model.dart';

class DetailVoteProvider extends ChangeNotifier {
  final FirebaseFirestore firestore;

  DetailVoteProvider({required this.firestore});

  final List<bool> _isOptionSelected = [];

  List<OptionModel> _options = [];

  List<bool> get getOptionStatus => _isOptionSelected;

  List<OptionModel> get getOptions => _options;

  setOptions(List<OptionModel> options) {
    _options = options;
    notifyListeners();
  }

  setOptionStatus(bool option, int index) {
    _isOptionSelected[index] = option;
    notifyListeners();
  }

  Future<void> voteOption(String pollId, String username) async {
    for (int i = 0; i < _isOptionSelected.length; i++) {
      if (_isOptionSelected[i]) {
        firestore
            .collection("polls")
            .doc(pollId)
            .collection('options')
            .doc((i + 1).toString())
            .update({
          'voter': FieldValue.arrayUnion([username])
        });
        firestore.collection("polls").doc(pollId).update({
          'voters': FieldValue.arrayUnion([username])
        });
      }
    }
  }
}
