class OptionModel {
  int? id;
  String? images;
  String title;

  OptionModel({this.id, this.images, required this.title});

  factory OptionModel.fromMap(map) {
    return OptionModel(
      id: map['id'],
      title: map['title'],
      images: map['images'],
    );
  }

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
    for (var element in optionModels) {
      Map option = element.toMap();
      options.add(option);
    }
    return options;
  }
}
