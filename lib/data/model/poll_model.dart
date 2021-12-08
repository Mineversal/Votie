import 'package:votie/utils/date_time_helper.dart';

class PollModel {
  String? id;
  String? creator;
  String? title;
  String? description;
  String? images;
  int? options;
  bool? anonim;
  bool? multivote;
  bool? show;
  DateTime? end;
  List<dynamic>? users;
  List<dynamic>? voters;

  PollModel(
      {this.id,
      this.creator,
      this.title,
      this.description,
      this.images,
      this.options,
      this.anonim,
      this.multivote,
      this.show,
      this.end,
      this.users,
      this.voters});

  factory PollModel.fromMap(map) {
    return PollModel(
      id: map['id'],
      creator: map['creator'],
      title: map['title'],
      description: map['description'],
      images: map['images'],
      options: map['options'],
      anonim: map['anonim'],
      multivote: map['multivote'],
      show: map['show'],
      end: map['end'],
      users: map['users'],
      voters: map['voters'],
    );
  }

  factory PollModel.fromDoc(doc) {
    return PollModel(
      id: doc.get('id'),
      creator: doc.get('creator'),
      title: doc.get('title'),
      description: doc.get('description'),
      images: doc.get('images'),
      options: doc.get('options'),
      anonim: doc.get('anonim'),
      multivote: doc.get('multivote'),
      show: doc.get('show'),
      end: DateTimeHelper.timeStampToDateTime(doc.get('end')),
      users: doc.get('users'),
      voters: doc.get('voters'),
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
      'anonim': anonim,
      'multivote': multivote,
      'show': show ?? true,
      'end': end,
      'users': users ?? [],
      'voters': voters ?? [],
    };
  }
}
