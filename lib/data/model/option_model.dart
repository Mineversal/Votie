class OptionModel {
  int? id;
  String? images;
  String title;
  List<dynamic>? voter;

  OptionModel({this.id, this.images, required this.title, this.voter});

  factory OptionModel.fromMap(map) {
    return OptionModel(
      id: map['id'],
      title: map['title'],
      images: map['images'],
      voter: map['voter'],
    );
  }

  factory OptionModel.fromDoc(doc) {
    return OptionModel(
      id: doc.get('id'),
      title: doc.get('title'),
      images: doc.get('images'),
      voter: doc.get('voter'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'images': images,
      'title': title,
      'voter': voter ?? [],
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
