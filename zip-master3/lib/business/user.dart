import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zip/models/user.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String userID = '';
  Stream<User> userStream;
  StreamSubscription userSub;
  User user;

  factory UserService() {
    return _instance;
  }

  UserService._internal() {
    print("UserService Created with user: $userID");
  }

  void setupService(String id) {
    if (userID != id) {
      if (userSub != null) userSub.cancel();
      userID = id;
      userStream = _db
          .collection("users")
          .doc(userID)
          .snapshots()
          .map((DocumentSnapshot snapshot) {
        return User.fromDocument(snapshot);
      });
      userSub = userStream.listen((user) {
        this.user = user;
      });
      print("UserService setup with user: $userID");
    }
  }

  Stream<User> getUserStream() {
    return _db
        .collection("users")
        .doc(userID)
        .snapshots()
        .map((DocumentSnapshot snapshot) {
      return User.fromDocument(snapshot);
    });
  }
}
