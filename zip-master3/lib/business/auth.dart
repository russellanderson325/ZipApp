import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zip/models/user.dart';
import 'package:flutter/services.dart';
import 'package:zip/ui/screens/sms_pin_screen.dart';

enum authProblems { UserNotFound, PasswordNotValid, NetworkError, UnknownError }

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _isLoading;
  bool get isLoading => _isLoading;

  String _uid;
  String get uid => _uid;

  // FirebaseFirestore firestore = FirebaseFirestore.instance;
  //final Fires
  Stream<auth.User> get user => _auth.authStateChanges();

  Future<auth.User> googleSignIn() async {
    try {
      GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth =
          await googleSignInAccount.authentication;

      final auth.GoogleAuthCredential credential =
          auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      auth.User user = (await _auth.signInWithCredential(credential)).user;
      updateUserData(user);
      return user;
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<auth.User> facebookSignIn() async {
    try {
      FacebookLoginResult facebookLoginResult = await _handleFBSignIn();
      final accessToken = facebookLoginResult.accessToken.token;
      if (facebookLoginResult.status == FacebookLoginStatus.loggedIn) {
        final auth.FacebookAuthCredential facebookAuthCred =
            auth.FacebookAuthProvider.credential(accessToken);
        final user = (await _auth.signInWithCredential(facebookAuthCred)).user;
        updateUserData(user);
        return user;
      } else {
        return null;
      }
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<FacebookLoginResult> _handleFBSignIn() async {
    FacebookLogin facebookLogin = FacebookLogin();
    FacebookLoginResult facebookLoginResult =
        await facebookLogin.logIn(['email']);
    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.cancelledByUser:
        print("Cancelled");
        break;
      case FacebookLoginStatus.error:
        print("error");
        break;
      case FacebookLoginStatus.loggedIn:
        print("Logged In");
        break;
    }
    return facebookLoginResult;
  }

  Future<void> phoneAuthentication(
      String number, BuildContext context, bool newUser) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: number,

      //Android Only!
      verificationCompleted: (auth.PhoneAuthCredential credential) async {
        await _auth.currentUser.linkWithCredential(credential);
      },
      verificationFailed: (auth.FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          print("Invalid phone number provided");
        }
      },
      codeSent: (String verificationId, int resendToken) async {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => new SmsPinScreen(
                      verificationId: verificationId,
                      isNewUser: newUser,
                    )));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("Did not auto retrieve sms code within 30 seconds");
      },
    );
  }

  //Only called when the otp is not automatically verified by the phone,
  //which only occurs on some Android devices.
  void verifyOtpForAddingPhoneAuth({
    BuildContext context,
    String verificationId,
    String otp,
    Function onSuccess,
  }) async {
    try {
      auth.PhoneAuthCredential credential = auth.PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: otp);

      await _auth.currentUser.linkWithCredential(credential);
      onSuccess();
    } on auth.FirebaseAuthException catch (e) {
      print(e.message.toString());
    }
  }

  void verifyOtpForLogin({
    BuildContext context,
    String verificationId,
    String otp,
    Function onSuccess,
  }) async {
    try {
      auth.PhoneAuthCredential credential = auth.PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: otp);

      final user = (await _auth.signInWithCredential(credential)).user;
      updateUserData(user);
      onSuccess();
    } on auth.FirebaseAuthException catch (e) {
      print(e.message.toString());
    }
  }

  Future<String> signIn(String email, String password) async {
    auth.UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    updateUserData(result.user);
    return result.user.uid;
  }

  Future<String> signUp(String email, String password) async {
    auth.UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return result.user.uid;
  }

  Future<auth.User> getCurrentUser() async {
    auth.User user = await _auth.currentUser;
    return user;
  }

  Future<void> signOut() async {
    return _auth.signOut();
  }

  void addUser(User user) async {
    DocumentSnapshot doc = await _db.collection('users').doc(user.uid).get();
    if (doc.exists) {
      print("user ${user.firstName} ${user.email} already exists");
    } else {
      print("user ${user.firstName} ${user.email} added");
      FirebaseFirestore.instance.doc("users/${user.uid}").set(user.toJson());
    }
  }

  Future<void> updateUserData(auth.User fuser) async {
    DocumentReference userRef = _db.collection('users').doc(fuser.uid);
    DocumentSnapshot doc = await userRef.get();

    if (!doc.exists) {
      User user = User.fromFirebaseUser(fuser);
      return userRef.set(user.toJson(), SetOptions(merge: true));
    } else {
      User user = User.fromDocument(doc);
      user.updateActivity();
      return userRef.set(user.toJson(), SetOptions(merge: true));
    }
  }

  Future<void> sendResetPassword(String email) async {
    return _auth.sendPasswordResetEmail(email: email);
  }

  String getExceptionText(Exception e) {
    if (e is PlatformException) {
      switch (e.message) {
        case 'There is no user record corresponding to this identifier. The user may have been deleted.':
          return 'User with this e-mail not found.';
          break;
        case 'The password is invalid or the user does not have a password.':
          return 'Invalid password.';
          break;
        case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
          return 'No internet connection.';
          break;
        case 'The email address is already in use by another account.':
          return 'Email address is already taken.';
          break;
        default:
          return 'Unknown error occured.';
      }
    } else {
      return 'Unknown error occured.';
    }
  }

  Future<bool> userExists() async {
    DocumentSnapshot snapshot = await _db.collection("users").doc(_uid).get();

    if (snapshot.exists) {
      print("User exists!");
      return true;
    } else {
      print("User does not exist");
      return false;
    }
  }

  Future<bool> phoneNumberExists(String phoneNumber) async {
    Query queryPhoneNumber =
        _db.collection("users").where("phone", isEqualTo: phoneNumber);

    QuerySnapshot snapshot = await queryPhoneNumber.get();
    if (snapshot.docs.isNotEmpty) {
      return true;
    }
    return false;
  }
}
