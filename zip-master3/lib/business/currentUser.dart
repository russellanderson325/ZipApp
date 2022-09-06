import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zip/models/currentUserModel.dart';

class CurrentUserService {
  static final CurrentUserService _instance = CurrentUserService._internal();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String userID = '';
  Stream<CurrentUser> currentUserStream;
  StreamSubscription userSub;
  CurrentUser currentUser;

  factory CurrentUserService() {
    return _instance;
  }

  CurrentUserService._internal() {
    print("CurrentUserService Created with user: $userID");
  }

  void setupService(String id) {
    if (userID != id) {
      if (userSub != null) userSub.cancel();
      userID = id;
      currentUserStream = _db
          .collection("CurrentRides")
          .doc(userID)
          .snapshots()
          .map((DocumentSnapshot snapshot) {
        return CurrentUser.fromDocument(snapshot);
      });
      userSub = currentUserStream.listen((user) {
        this.currentUser = currentUser;
      });
      print("CurrentUserService setup with user: $userID");
    }
  }

  Stream<CurrentUser> getUserStream() {
    return _db
        .collection("CurrentRides")
        .doc(userID)
        .snapshots()
        .map((DocumentSnapshot snapshot) {
      return CurrentUser.fromDocument(snapshot);
    });
  }
}
