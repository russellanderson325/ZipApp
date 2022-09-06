import 'dart:async';
import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';


class StripeScreen extends StatefulWidget {
  // final Payment payment;
  @override
  _StripeScreenState createState() => new _StripeScreenState();
}

class _StripeScreenState extends State<StripeScreen> {
  VoidCallback onBackPress;
  @override
  void initState() {
    onBackPress = () {
      Navigator.of(context).pop();
    };
    super.initState();
  }

  HttpsCallable onboardStripeFunction =
      CloudFunctions.instance.getHttpsCallable(
    functionName: 'createExpressAccount',
  );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPress,
      child: Scaffold(
        appBar: new AppBar(
        title: new Text(
          'Driver Payments',
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 5.0),
          child: 
              Stack(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "Set up Stripe Connect to recieve payouts. Place holder text. Place holder text.Place holder text.Place holder text.Place holder text.Place holder text."
                         + "Place holder text. Place holder text. Place holder text.Place holder text. Place holder text."
                         + "Place holder text.Place holder text.Place holder text.Place holder text.Place holder text.Place holder text."
                         + "Place holder text.Place holder text.Place holder text.Place holder text.Place holder text.Place holder text.",
                        softWrap: true,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          MaterialButton(
                            //color: Colors.cyan,
                            //padding: EdgeInsets.all(8.0),
                            elevation: 8.0,
                            child: Container(
                              width: 300,
                              height: 80,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage('assets/connectstripe_blurple_2x.png'),
                                    fit: BoxFit.scaleDown),
                              ),
                            ),
                            onPressed: () async {
                              print('Tapped');
                              HttpsCallableResult result = await onboardStripeFunction
                                  .call(<String, dynamic>{
                              });
                              print(result.toString());
                            },
                          ),

                        ]
                      ),

                    ]
                  )
                ]
            )
        )
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