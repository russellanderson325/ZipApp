import "package:flutter/material.dart";
import 'package:zip/ui/screens/documents_screen.dart';
import 'package:zip/ui/screens/profile_screen.dart';
import 'package:zip/ui/screens/defaultTip_screen.dart';
import 'package:zip/ui/screens/legalInfo_screen.dart';
import 'package:zip/ui/screens/safety_features_screen.dart';
import 'package:zip/ui/screens/welcome_screen.dart';
import 'package:zip/ui/screens/main_screen.dart';
import 'package:zip/business/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:mailto/mailto.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  VoidCallback onBackPress;
  @override
  void initState() {
    onBackPress = () {
      Navigator.of(context).pop();
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPress,
      child: Scaffold(
        //backgroundColor: Colors.grey[70],
        backgroundColor: Colors.black,
        body: Padding(
          padding: const EdgeInsets.only(
            top: 23.0,
            bottom: 20.0,
            left: 0.0,
            right: 0.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TopRectangle(
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back,
                            color: Color.fromRGBO(255, 242, 0, 1.0)),
                        onPressed: onBackPress,
                      ),
                    ),
                    Text("Settings",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(255, 242, 0, 1.0),
                            fontSize: 36.0,
                            fontWeight: FontWeight.w300,
                            fontFamily: "Bebas"))
                  ],
                ),
              ),
              SettingRec(
                child: ListTile(
                    leading: Icon(Icons.account_box,
                        size: 28.0, color: Color.fromRGBO(255, 242, 0, 1.0)),
                    title: const Text("Rules & Safety",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Color.fromRGBO(255, 242, 0, 1.0),
                            fontSize: 24.0,
                            fontWeight: FontWeight.w300,
                            fontFamily: "Bebas")),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SafetyFeaturesScreen()));
                    }

                    //child: Icon(Icons.account_box, size: 28.0, color: Colors.white),

                    ),
              ),
              SettingRec(
                child: ListTile(
                    leading: Icon(Icons.monetization_on,
                        size: 28.0, color: Color.fromRGBO(255, 242, 0, 1.0)),
                    title: const Text("Default Tip",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Color.fromRGBO(255, 242, 0, 1.0),
                            fontSize: 24.0,
                            fontWeight: FontWeight.w300,
                            fontFamily: "Bebas")),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DefaultTipScreen()));
                    }),
              ),
              SettingRec(
                child: ListTile(
                    leading: Icon(Icons.drive_eta,
                        size: 28.0, color: Color.fromRGBO(255, 242, 0, 1.0)),
                    title: const Text("Drive with Zip",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Color.fromRGBO(255, 242, 0, 1.0),
                            fontSize: 24.0,
                            fontWeight: FontWeight.w300,
                            fontFamily: "Bebas")),
                    onTap: () {
                      funcOpenMailComposer();
                    }),
              ),
              SettingRec(
                child: ListTile(
                    leading: Icon(Icons.assignment,
                        size: 28.0, color: Color.fromRGBO(255, 242, 0, 1.0)),
                    title: const Text("Terms and Conditions",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Color.fromRGBO(255, 242, 0, 1.0),
                            fontSize: 24.0,
                            fontWeight: FontWeight.w300,
                            fontFamily: "Bebas")),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DocumentsScreen()));
                    }),
              ),
              SettingRec(
                child: ListTile(
                    leading: Icon(Icons.lock,
                        size: 28.0, color: Color.fromRGBO(255, 242, 0, 1.0)),
                    title: const Text("Privacy Policy",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Color.fromRGBO(255, 242, 0, 1.0),
                            fontSize: 24.0,
                            fontWeight: FontWeight.w300,
                            fontFamily: "Bebas")),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LegalInformationScreen()));
                    }),
              ),
              SettingRec(
                child: ListTile(
                    leading: Icon(Icons.lock,
                        size: 28.0, color: Color.fromRGBO(255, 242, 0, 1.0)),
                    title: const Text("Sign Out",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Color.fromRGBO(255, 242, 0, 1.0),
                            fontSize: 24.0,
                            fontWeight: FontWeight.w300,
                            fontFamily: "Bebas")),
                    onTap: () {
                      _logOut();

                      Navigator.of(context).pushNamed("/root");
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TopRectangle extends StatelessWidget {
  final color;
  final height;
  final width;
  final child;

  TopRectangle(
      {this.child, this.color, this.height = 100.0, this.width = 500.0});

  build(context) {
    return Container(
      width: width,
      height: height,
      color: Colors.black,
      child: child,
    );
  }
}

void _logOut() async {
  AuthService().signOut();
}

class SettingRec extends StatelessWidget {
  final color;
  final decoration;
  final width;
  final height;
  // final borderWidth;
  final child;
  SettingRec(
      {this.child,
      this.color,
      this.width = 500.0,
      this.decoration,
      this.height = 55.0});

  build(context) {
    return Container(
      width: width,
      height: height,
      color: Color.fromRGBO(76, 86, 96, 1.0),
      child: child,
    );
  }
}

void funcOpenMailComposer() async {
  final mailtoLink = Mailto(
    to: ['info@zipgameday.com'],
    subject: 'New Driver',
    body: '',
  );
  await launch('$mailtoLink');
}
