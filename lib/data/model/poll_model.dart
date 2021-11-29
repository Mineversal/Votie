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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creator': creator,
      'title': title,
      'description': description,
      'images': images,
      'show': show ?? true,
      'end': end,
      'user': [],
    };
  }
}
