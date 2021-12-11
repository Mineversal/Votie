import 'package:flutter/material.dart';
import 'package:votie/data/model/option_model.dart';
import 'package:votie/data/model/poll_model.dart';

class ResultVoteProvider extends ChangeNotifier {
  PollModel _pollModel = PollModel();

  int selectedOption = 0;
  List<OptionModel> _options = [];

  PollModel get getPollModel => _pollModel;
  List<OptionModel> get getOptions => _options;

  setPollModel(PollModel pollModel) {
    _pollModel = pollModel;
    notifyListeners();
  }

  setOptions(List<OptionModel> options) {
    _options = options;
    notifyListeners();
  }

  setSelectedOption(int index) {
    selectedOption = index;
  }
}
