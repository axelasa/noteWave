import 'package:cloud_firestore/cloud_firestore.dart';

// class MyContact {}

class UserData {
  final String? uid;
  final String? email;
  final String? name;
  final String? profileImage;

  UserData({
    this.uid,
    this.email,
    this.name,
    this.profileImage
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'name': name,
    'profileImage': profileImage
  };

  static UserData? userdataFromSnapShot(DocumentSnapshot snap) {
    if (snap.exists) {
      var snapshot = snap.data() as Map<String, dynamic>;

      return UserData(
        uid: snapshot['uid'] ?? '',
        email: snapshot['email'] ?? '',
        name: snapshot['name'] ?? '',
        profileImage: snapshot['profileImage'] ?? '',
      );
    } else {
      return null;
    }
  }
}

