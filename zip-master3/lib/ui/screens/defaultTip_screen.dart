import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:zip/business/user.dart';

class DefaultTipScreen extends StatefulWidget {
  _DefaultTipScreenState createState() => _DefaultTipScreenState();
}

double tipAmount;

class _DefaultTipScreenState extends State<DefaultTipScreen> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserService userService = UserService();
  VoidCallback onBackPress;
  @override
  void initState() {
    onBackPress = () {
      Navigator.of(context).pop();
    };
    tipAmount = userService.user.defaultTip;
    super.initState();
  }

  void updateDefaultTip(String newTip) {
    tipAmount = double.parse(newTip);
    print("Updating default tip to: $tipAmount");
    _firestore
        .collection('users')
        .document(userService.userID)
        .updateData({'defaultTip': tipAmount});
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPress,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: const EdgeInsets.only(
            top: 23.0,
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  color: Colors.black,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back,
                              color: Color.fromRGBO(255, 242, 0, 1.0)),
                          onPressed: onBackPress,
                        ),
                      ),
                      Text("   Default Tip",
                          style: TextStyle(
                              //backgroundColor: Colors.black,
                              color: Color.fromRGBO(255, 242, 0, 1.0),
                              fontSize: 36.0,
                              fontWeight: FontWeight.w300,
                              fontFamily: "Bebas"))
                    ],
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Text("Choose Default:",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(255, 242, 0, 1.0),
                            fontSize: 30.0,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Bebas"))),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 30.0, right: 15.0, left: 15.0),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FlatButton(
                        onPressed: () {
                          updateDefaultTip("15");
                        },
                        child: CircularButton(
                            child: Center(
                          child: Text('15%',
                              style: TextStyle(
                                  color: Colors.black, fontSize: 24.0)),
                        )),
                      ),
                      FlatButton(
                        onPressed: () {
                          updateDefaultTip("20");
                        },
                        child: CircularButton(
                          child: Center(
                            child: Text('20%',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 24.0)),
                          ),
                        ),
                      ),
                      FlatButton(
                        onPressed: () {
                          updateDefaultTip("25");
                        },
                        child: CircularButton(
                          child: Center(
                            child: Text('25%',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 24.0)),
                          ),
                        ),
                      ),
                    ]),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Text("Create Custom Default:",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color.fromRGBO(255, 242, 0, 1.0),
                          fontSize: 30.0,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Bebas")),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 30.0, left: 100.0, right: 100.0),
                  child: TextFormField(
                    decoration: new InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color.fromRGBO(255, 242, 0, 1.0))),
                    ),
                    style: TextStyle(color: Colors.white),
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    onChanged: (v) => this.updateDefaultTip(v),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a numerical percentage';
                      }
                      return null;
                    },
                  ),
                ),
                DisplayTip(tipAmount),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DisplayTip extends StatelessWidget {
  DisplayTip(tipAmount);
  build(context) {
    return Container(
        child: Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Text("Default Tip: " + tipAmount.toString() + '%',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color.fromRGBO(255, 242, 0, 1.0),
                    fontSize: 30.0,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Bebas"))));
  }
}

class TopRectangle extends StatelessWidget {
  final color;
  final height;
  final width;
  final child;
  final posi;
  TopRectangle(
      {this.posi,
      this.child,
      this.color,
      this.height = 100.0,
      this.width = 500.0});

  build(context) {
    return Container(
      width: width,
      height: height,
      color: Color.fromRGBO(76, 86, 96, 1.0),
      child: child,
    );
  }
}

class CircularButton extends StatelessWidget {
  final child;
  CircularButton({this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ClipOval(
        child: Container(
          color: Color.fromRGBO(255, 242, 0, 1.0),
          height: 105.0, // height of the button
          width: 105.0, // width of the button
          child: child,
        ),
      ),
    );
  }
}
