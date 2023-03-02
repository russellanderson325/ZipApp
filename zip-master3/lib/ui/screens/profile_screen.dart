import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zip/business/auth.dart';
import 'package:zip/business/user.dart';
import 'package:zip/business/validator.dart';
import 'package:zip/models/user.dart';
import 'dart:core';
import 'package:flutter/services.dart';
import 'package:zip/ui/widgets/custom_alert_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zip/ui/widgets/custom_flat_button.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  VoidCallback onBackPress;
  final AuthService auth = AuthService();
  final UserService userService = UserService();
  final TextEditingController _firstname = new TextEditingController();
  final TextEditingController _lastname = new TextEditingController();
  final TextEditingController _number = new TextEditingController();
  final TextEditingController _email = new TextEditingController();
  final TextEditingController _homeAddress = new TextEditingController();
  bool _blackVisible = false;
  bool _isEditing = false;
  StorageUploadTask _uploadTask;
  User user;

  @override
  void initState() {
    super.initState();

    onBackPress = () {
      Navigator.of(context).pop();
    };
  }

/*
  Looks for Storage task created when uploading photo to
  Firestorage.
*/
  @override
  Widget build(BuildContext context) {
    if (_uploadTask != null) {
      return StreamBuilder<StorageTaskEvent>(
          stream: _uploadTask.events,
          builder: (_, snapshot) {
            var event = snapshot?.data?.snapshot;
            double progress = (event != null)
                ? event.bytesTransferred / event.totalByteCount
                : 0;
            return AlertDialog(
                title: _uploadTask.isInProgress
                    ? Text("Loading")
                    : Align(
                        alignment: Alignment.center, child: Text("Finished")),
                content: Container(
                  height: 150,
                  child: Column(children: <Widget>[
                    if (_uploadTask.isInProgress)
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.green,
                      ),
                    if (_uploadTask.isComplete)
                      Icon(Icons.thumb_up, size: 50.0),
                    _uploadTask.isComplete
                        ? Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 20.0, horizontal: 10.0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _uploadTask = null;
                                });
                              },
                              style: ElevatedButton.styleFrom(primary: Color.fromRGBO(76,86,96,1.0)),
                              child: Text(
                                "Continue",
                                softWrap: true,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Bebas",
                                    fontWeight: FontWeight.w300,
                                    fontSize: 24.0,
                                    decoration: TextDecoration.none),
                              ),
                            ),
                          )
                        : new Container(),
                  ]),
                ));
          });
    } else {
      //Stream of Customer information.
      return StreamBuilder<DocumentSnapshot>(
          stream: Firestore.instance
              .collection('users')
              .document(userService.userID)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              User user = User.fromDocument(snapshot.data);
              if (!_isEditing) {
                _firstname.text = user.firstName;
                _lastname.text = user.lastName;
                _number.text = user.phone;
                _email.text = user.email;
                _homeAddress.text = user.homeAddress;
              }
              return Scaffold(
                body: Stack(
                  children: <Widget>[
                    Stack(
                      alignment: Alignment.topLeft,
                      children: <Widget>[
                        ListView(
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height / 3.6,
                              color: Colors.black,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      _isEditing
                                          ? new Container()
                                          : getEditButton(context),
                                    ],
                                  ),

                                  //Use image_cropper for cropping
                                  //Need to build popup to choose
                                  TextButton(
                                    style: TextButton.styleFrom(onSurface: Colors.black),
                                    onPressed: () {
                                      _takePicOrGalleryPopup();
                                    },
                                    child: CircleAvatar(
                                      radius: 75.0,
                                      child: ClipOval(
                                        child: SizedBox(
                                          width: 180.0,
                                          height: 180.0,
                                          child: user.profilePictureURL == ''
                                              ? Image.asset(
                                                  'assets/profile_default.png')
                                              : Image.network(
                                                  user.profilePictureURL,
                                                  fit: BoxFit.fill,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 6.0, horizontal: 10.0),
                                child: buildCards(
                                    context,
                                    Icon(Icons.person,
                                        color:
                                            Color.fromRGBO(255, 242, 0, 1.0)),
                                    _firstname)),
                            Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 10.0),
                                child: buildCards(
                                    context,
                                    Icon(Icons.person,
                                        color:
                                            Color.fromRGBO(255, 242, 0, 1.0)),
                                    _lastname)),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 10.0),
                              child: buildCards(
                                  context,
                                  Icon(Icons.email,
                                      color: Color.fromRGBO(255, 242, 0, 1.0)),
                                  _email),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 10.0),
                              child: buildCards(
                                  context,
                                  Icon(Icons.phone,
                                      color: Color.fromRGBO(255, 242, 0, 1.0)),
                                  _number),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 6.0, horizontal: 10.0),
                              child: buildCards(
                                  context,
                                  Icon(Icons.home,
                                      color: Color.fromRGBO(255, 242, 0, 1.0)),
                                  _homeAddress),
                            ),
                            _isEditing
                                ? getSaveAndCancel(context)
                                : new Container(),
                            _isEditing
                                ? Padding(
                                    padding: EdgeInsets.only(
                                        top: 10.0,
                                        bottom: 10.0,
                                        right:
                                            MediaQuery.of(context).size.width /
                                                6,
                                        left:
                                            MediaQuery.of(context).size.width /
                                                6),
                                    child: TextButton(
                                        onPressed: () async {
                                          try {
                                            await auth
                                                .sendResetPassword(user.email);
                                            _showPasswordChangePopup(
                                              title: "Change Password",
                                              content:
                                                  "We have sent an password reset email to ${user.email}",
                                              onPressed: _changeBlackVisible,
                                            );
                                          } catch (e) {
                                            _showErrorAlert(
                                              title: "Change Password Error",
                                              content:
                                                  "An error occurred while sending a reset password email. " +
                                                      "Error: ${e.toString()}",
                                              onPressed: _changeBlackVisible,
                                            );
                                          }
                                          _changeBlackVisible();
                                          setState(() {
                                            _isEditing = false;
                                          });
                                        },
                                        style: TextButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            side:
                                                BorderSide(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(12.0)),
                                        ),
                                        child: Text("Change Password",
                                            softWrap: true,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Color.fromRGBO(
                                                  76, 86, 96, 1.0),
                                              fontSize: 24.0,
                                              fontFamily: "Bebas",
                                              fontWeight: FontWeight.w300,
                                            ))))
                                : new Container(),
                          ],
                        ),
                        SafeArea(
                          child: IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: onBackPress,
                          ),
                        ),
                      ],
                    ),
                    Offstage(
                      offstage: !_blackVisible,
                      child: GestureDetector(
                        onTap: () {},
                        child: AnimatedOpacity(
                          opacity: _blackVisible ? 1.0 : 0.0,
                          duration: Duration(milliseconds: 400),
                          curve: Curves.ease,
                          child: Container(
                            height: MediaQuery.of(context).size.height,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Container(
                color: Colors.black,
              );
            }
          });
    }
  }

  void _changeBlackVisible() {
    setState(() {
      _blackVisible = !_blackVisible;
    });
  }

  Widget getEditButton(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.edit, color: Color.fromRGBO(255, 242, 0, 1.0)),
        onPressed: () {
          setState(() {
            _isEditing = true;
          });
        });
  }

  //Builds action buttons for users when editing profile.
  Widget getSaveAndCancel(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: ElevatedButton(
            onPressed: () async {
              await _editInfo(
                  firstname: _firstname.text,
                  lastname: _lastname.text,
                  email: _email.text,
                  phone: _number.text,
                  home: _homeAddress.text);

              setState(() {
                _isEditing = false;
              });
            },
            style: ElevatedButton.styleFrom(primary: Colors.black),
            child: Text(
              "Save",
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color.fromRGBO(255, 242, 0, 1.0),
                  fontFamily: "Bebas",
                  fontWeight: FontWeight.w300,
                  fontSize: 24.0,
                  decoration: TextDecoration.none),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                //reset all textEditing Controllers.
                //_updateTextEditingControllers();
                _isEditing = false;
              });
            },
            style: ElevatedButton.styleFrom(primary: Colors.black),
            child: Text(
              "Cancel",
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color.fromRGBO(255, 242, 0, 1.0),
                  fontFamily: "Bebas",
                  fontWeight: FontWeight.w300,
                  fontSize: 24.0,
                  decoration: TextDecoration.none),
            ),
          ),
        ),
      ],
    );
  }

/*
  Returns a card template.
*/
  Widget buildCards(
      BuildContext context, Icon prefIcon, TextEditingController controller) {
    return Card(
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Colors.black,
          width: 0.5,
        ),
      ),
      color: Colors.white,
      child: TextField(
        enabled: _isEditing,
        controller: controller,
        onChanged: (text) {},
        style: TextStyle(
            color: Color.fromRGBO(76, 86, 96, 1.0),
            fontFamily: "Poppins",
            fontWeight: FontWeight.w300,
            decoration: TextDecoration.none),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(),
            child: prefIcon,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

/*
  Allows customer to edit information.
*/
  Future<void> _editInfo(
      {String firstname,
      String lastname,
      String phone,
      String email,
      String home,
      BuildContext context}) async {
    _changeBlackVisible();
    if (Validator.validateName(firstname) &&
        Validator.validateName(lastname) &&
        Validator.validateEmail(email) &&
        Validator.validateNumber(phone)) {
      try {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        //Updating information from user
        await Firestore.instance
            .collection('users')
            .document(userService.userID)
            .updateData({
          'firstName': firstname,
          'lastName': lastname,
          'phone': phone,
          'email': email,
          'homeAddress': home
        }).then((blah) {
          _changeBlackVisible();
        });
      } catch (e) {
        print("Error when editing profile information: $e");
        String exception = auth.getExceptionText(e);
        _showErrorAlert(
          title: "Edit profile failed",
          content: exception,
          onPressed: _changeBlackVisible,
        );
        _changeBlackVisible();
      }
    }
  }

  void _showErrorAlert({String title, String content, VoidCallback onPressed}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return CustomAlertDialog(
          content: content,
          title: title,
          onPressed: onPressed,
        );
      },
    );
  }

  void _showPasswordChangePopup(
      {String title, String content, VoidCallback onPressed}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return CustomAlertDialog(
          content: content,
          title: title,
          onPressed: onPressed,
        );
      },
    );
  }

//Will check if user has a image for original display
//If no picture, display default
//Else, grab photo from URL provided by FireStorage
  void _takePicOrGalleryPopup() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(5.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            title: Text(
              "Upload Photo",
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                decoration: TextDecoration.none,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: "Bebas",
              ),
            ),
            content: Container(
              height: 275,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0, bottom: 15.0),
                    child: CustomTextButton(
                      title: "Take a picture",
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                      textColor: Color.fromRGBO(76, 86, 96, 1.0),
                      onPressed: () {
                        _takePictureFromPhone();
                        Navigator.of(context).pop();
                      },
                      splashColor: Colors.black12,
                      borderColor: Colors.black12,
                      borderWidth: 2,
                    ),
                  ),
                  Text(
                    "Or",
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      decoration: TextDecoration.none,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: "Bebas",
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: CustomTextButton(
                      title: "Choose a picture from photos",
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                      textColor: Color.fromRGBO(76, 86, 96, 1.0),
                      onPressed: () {
                        _getPictureFromGallery();
                        Navigator.of(context).pop();
                      },
                      splashColor: Colors.black12,
                      borderColor: Colors.black12,
                      borderWidth: 2,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 15.0),
                    child: CustomTextButton(
                      title: "Cancel",
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      textColor: Colors.black,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      splashColor: Colors.black12,
                      borderColor: Colors.black12,
                      borderWidth: 2,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

/*
  Takes picture from CAMERA using image picture package.
*/
  Future<void> _takePictureFromPhone() async {
    var img = await ImagePicker.pickImage(source: ImageSource.camera);
    await _uploadPhoto(img);
  }

/*
  Takes picture from GALLERY using image picture package.
*/
  Future<void> _getPictureFromGallery() async {
    var img = await ImagePicker.pickImage(source: ImageSource.gallery);
    await _uploadPhoto(img);
  }

  Future<void> _uploadPhoto(File img) async {
    try {
      final StorageReference storageRef = FirebaseStorage.instance
          .ref()
          .child('FCMImages/user_profiles/${userService.userID}');
      setState(() {
        _uploadTask = storageRef.putFile(img);
      });
      _uploadTask.onComplete.then((asd) {
        storageRef.getDownloadURL().then((fileURL) async {
          await Firestore.instance
              .collection('users')
              .document(userService.userID)
              .updateData({'profilePictureURL': fileURL});
        });
      });
    } catch (e) {
      _showErrorAlert(
        title: "Upload photo failed",
        content: e,
        onPressed: _changeBlackVisible,
      );
    }
  }
}
