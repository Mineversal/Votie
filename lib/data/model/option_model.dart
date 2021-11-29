class OptionModel {
  int? id;
  String? images;
  String title;

  OptionModel({this.id, this.images, required this.title});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'images': images,
      'title': title,
      'voter': [],
    };
  }

  static List<Map> listToMap({required List<OptionModel> optionModels}) {
    List<Map> options = [];
    optionModels.forEach((element) {
      Map option = element.toMap();
      options.add(option);
    });
    return options;
  }
}
