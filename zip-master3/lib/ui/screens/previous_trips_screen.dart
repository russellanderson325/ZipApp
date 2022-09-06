import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:zip/models/user.dart';

class PreviousTripsScreen extends StatefulWidget {
  _PreviousTripsScreenState createState() => _PreviousTripsScreenState();
}

class _PreviousTripsScreenState extends State<PreviousTripsScreen> {
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
        body: Padding(
          padding: const EdgeInsets.only(
            top: 23.0,
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
          ),
          child: Column(
            children: <Widget>[
              TopRectangle(
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: onBackPress,
                      ),
                    ),
                    Text("   Previous Trips",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 36.0,
                            fontWeight: FontWeight.w300,
                            fontFamily: "Bebas"))
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0),
              ),
              Text("  Information heading",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 28.0,
                      fontWeight: FontWeight.w300,
                      fontFamily: "Bebas")),
              Padding(
                padding:
                    const EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0),
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
