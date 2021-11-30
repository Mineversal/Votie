class PollModel {
  String? id;
  String? creator;
  String? title;
  String? description;
  String? images;
  bool? show;
  DateTime? end;

  PollModel(
      {this.id,
      this.creator,
      this.title,
      this.description,
      this.images,
      this.show,
      this.end});

  factory PollModel.fromMap(map) {
    return PollModel(
      id: map['id'],
      creator: map['creator'],
      title: map['title'],
      description: map['description'],
      images: map['images'],
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
      'show': show ?? true,
      'end': end,
      'users': [],
    };
  }
}
