import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class CurrentUser {
  final String uid;

  CurrentUser({this.uid});

  Map<String, Object> toJson() {
    return {'uid': uid};
  }

  factory CurrentUser.fromJson(Map<String, Object> doc) {
    CurrentUser user = new CurrentUser(uid: doc['uid']);
    return user;
  }

  factory CurrentUser.fromFirebaseUser(auth.User fuser) {
    CurrentUser user = new CurrentUser(uid: fuser.uid);
    return user;
  }

  factory CurrentUser.fromDocument(DocumentSnapshot doc) {
    return CurrentUser.fromJson(doc.data());
  }
}
