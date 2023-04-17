import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../utils.dart';

class User {
  final String uid;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String profilePictureURL;
  final double credits;
  final String homeAddress;
  DateTime lastActivity;
  final bool isDriver;
  final double defaultTip;
  bool acceptedtc;
  bool acceptedPrivPolicy;

  var pastRides;
  var pastDrives;


  User(
      {this.uid,
        this.firstName,
        this.lastName,
        this.phone,
        this.email,
        this.credits,
        this.homeAddress,
        this.lastActivity,
        this.profilePictureURL,
        this.isDriver,
        this.defaultTip,
        this.acceptedtc,
        this.acceptedPrivPolicy,
        this.pastRides,
        this.pastDrives});

  Map<String, Object> toJson() {
    return {
      'uid': uid,
      'firstName': firstName == null ? '' : firstName,
      'lastName': lastName == null ? '' : lastName,
      'phone': phone == null ? '' : phone,
      'lastActivity': lastActivity,
      'email': email == null ? '' : email,
      'credits': credits == null ? 0.0 : credits,
      'homeAddress': homeAddress == null ? '' : homeAddress,
      'profilePictureURL': profilePictureURL == null ? '' : profilePictureURL,
      'isDriver': isDriver == null ? false : isDriver,
      'defaultTip': defaultTip == null ? 0 : defaultTip,
      'acceptedtc': acceptedtc == null ? false : acceptedtc,
      'acceptedPrivPolicy': acceptedPrivPolicy == null ? false : acceptedPrivPolicy,
      'pastRides': pastRides == null ? [] : pastRides,
      'pastDrives': pastDrives == null ? [] : pastDrives
    };
  }

  factory User.fromJson(Map<String, Object> doc) {
    num creds = doc['credits'] == null ? 0.0 : doc['credits'];
    num defTip = doc['defaultTip'] == null ? 0.0 : doc['defaultTip'];

    User user = new User(
        uid: doc['uid'],
        firstName: doc['firstName'] == null ? '' : doc['firstName'],
        lastName: doc['lastName'] == null ? '' : doc['lastName'],
        lastActivity: convertStamp(doc['lastActivity']),
        phone: doc['phone'] == null ? '' : doc['phone'],
        email: doc['email'] == null ? '' : doc['email'],
        credits: creds.toDouble(),
        homeAddress: doc['homeAddress'] == null ? '' : doc['homeAddress'],
        profilePictureURL:
        doc['profilePictureURL'] == null ? '' : doc['profilePictureURL'],
        isDriver: doc['isDriver'] == null ? false : doc['isDriver'],
        acceptedtc: doc['acceptedtc'] == null ? false : doc['acceptedtc'],
        acceptedPrivPolicy: doc['acceptedPrivPolicy'] == null ? false : doc['acceptedPrivPolicy'],
        pastRides: doc['pastRides'] == null ? [] : doc['pastRides'],
        pastDrives: doc['pastDrives'] == null ? [] : doc['pastDrives'], 
        defaultTip: defTip.toDouble());
    return user;
  }

  factory User.fromFirebaseUser(auth.User fuser) {
    User user = new User(
        uid: fuser.uid,
        firstName: (fuser.displayName.contains(" "))
            ? fuser.displayName.substring(0, fuser.displayName.indexOf(' '))
            : fuser.displayName,
        lastName: (fuser.displayName.contains(" "))
            ? fuser.displayName.substring(
            fuser.displayName.indexOf(' ') + 1, fuser.displayName.length)
            : '',
        lastActivity: DateTime.now(),
        phone: fuser.phoneNumber,
        email: fuser.email,
        credits: 0,
        homeAddress: '',
        profilePictureURL: fuser.photoUrl,
        isDriver: false,
        acceptedtc: false,
        acceptedPrivPolicy: false,
        pastRides: [],
        pastDrives: [],
        defaultTip: 0.0);
    return user;
  }

  factory User.fromDocument(DocumentSnapshot doc) {
    return User.fromJson(doc.data());
  }

  void updateActivity() {
    this.lastActivity = DateTime.now();
  }
}
