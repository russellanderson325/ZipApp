import "package:flutter/material.dart";
//import 'package:zip/ui/screens/profile_screen.dart';
//import 'package:zip/ui/screens/defaultTip_screen.dart';
import 'package:zip/ui/screens/profile_screen.dart';
import 'package:zip/ui/screens/legalInfo_screen.dart';
import 'package:zip/ui/screens/vehicles_screen.dart';
import 'package:zip/ui/screens/documents_screen.dart';
//import 'package:zip/services/payment_screen.dart';
import 'package:zip/business/auth.dart';
import 'package:flutter/material.dart';

class DriverSettingsScreen extends StatefulWidget {
  _DriverSettingsScreenState createState() => _DriverSettingsScreenState();
}

class _DriverSettingsScreenState extends State<DriverSettingsScreen> {
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
              //TopRectangle(
              Container(
                color: Colors.black,
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
                            backgroundColor: Colors.black,
                            color: Color.fromRGBO(255, 242, 0, 1.0),
                            fontSize: 36.0,
                            fontWeight: FontWeight.w300,
                            fontFamily: "Bebas"))
                  ],
                ),
              ),
              //),

              SettingRec(
                child: ListTile(
                    leading: Icon(Icons.assignment,
                        size: 28.0, color: Color.fromRGBO(255, 242, 0, 1.0)),
                    title: const Text("Terms and Conditions",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.white,
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
                    leading: Icon(Icons.monetization_on,
                        size: 28.0, color: Color.fromRGBO(255, 242, 0, 1.0)),
                    title: const Text("Payment",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                            fontWeight: FontWeight.w300,
                            fontFamily: "Bebas")),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VehiclesScreen()));
                      //builder: (context) => PaymentScreen()));
                    }),
              ),
              SettingRec(
                child: ListTile(
                    leading: Icon(Icons.account_box,
                        size: 28.0, color: Color.fromRGBO(255, 242, 0, 1.0)),
                    title: const Text("Edit Account",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                            fontWeight: FontWeight.w300,
                            fontFamily: "Bebas")),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileScreen()));
                    }),
              ),
              SettingRec(
                child: ListTile(
                    leading: Icon(Icons.lock,
                        size: 28.0, color: Color.fromRGBO(255, 242, 0, 1.0)),
                    title: const Text("Privacy Policy",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.white,
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
                    leading: Icon(Icons.not_interested,
                        size: 28.0, color: Color.fromRGBO(255, 242, 0, 1.0)),
                    title: const Text("Log Out",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.white,
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

void _logOut() async {
  AuthService().signOut();
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
      color: Colors.white,
      child: child,
    );
  }
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
