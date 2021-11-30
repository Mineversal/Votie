class PollModel {
  String? id;
  String? creator;
  String? title;
  String? description;
  String? images;
  int? options;
  bool? show;
  DateTime? end;

  PollModel(
      {this.id,
      this.creator,
      this.title,
      this.description,
      this.images,
      this.options,
      this.show,
      this.end});

  factory PollModel.fromMap(map) {
    return PollModel(
      id: map['id'],
      creator: map['creator'],
      title: map['title'],
      description: map['description'],
      images: map['images'],
      options: map['options'],
      show: map['show'],
      end: map['end'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creator': creator,
      'title': title,
      'description': description,
      'images': images,
      'options': options,
      'show': show ?? true,
      'end': end,
      'users': [],
    };
  }
}
