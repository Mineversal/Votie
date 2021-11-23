class UserModel {
  String? uid;
  String? email;
  String? username;
  String? name;

  UserModel({this.uid, this.email, this.username, this.name});

  ///Menerima Data Dari Firestore
  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      username: map['username'],
      name: map['name'],
    );
  }

  ///Mengirim Data ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'name': name,
    };
  }
}
