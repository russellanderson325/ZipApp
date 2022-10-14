import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:zip/business/payment.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:strings/strings.dart';

class HistoryScreen extends StatefulWidget {
  // final Payment payment;
  @override
  _HistoryScreenState createState() => new _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  PaymentMethod _paymentMethod;
  String _error;
  PaymentIntentResult _paymentIntent;

  ScrollController _controller = ScrollController();
  var customerData = new Map();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final paymentService = Payment();
  final firebaseUser = auth.FirebaseAuth.instance.currentUser;
  //var paymentMethodList;
  @override
  initState() {
    super.initState();

    StripePayment.setOptions(StripeOptions(
        publishableKey: "pk_test_Cn8XIP0a25tKPaf80s04Lo1m00dQhI8R0u"));
    //   paymentMethodList = [];
    paymentService.getPaymentMethods();
  }

  @override
  Widget build(BuildContext context) {
    bool refundStatus = false;
    List<bool> refundStatusList = new List();
    return Scaffold(
      // backgroundColor: Colors.grey[800],
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(
          'History',
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
      body: StreamBuilder<QuerySnapshot>(
        stream: paymentService.getPaymentHistory(),
        builder: (context, snapshot) {
          /* Timer(Duration(seconds: 2), () {
                  print("Yeah, this line is printed after 2 seconds");
                });*/
          try {
            if (snapshot.hasData) {
              debugPrint("build widget: ${snapshot.data}");
              List<QueryDocumentSnapshot> paymentList = snapshot.data.docs;
              List<QueryDocumentSnapshot> successfulPaymentsList = new List();
              print("TEST: test; $paymentList");
              print("TEST: TSTET: ${paymentList[1].id}");
              paymentList.forEach((element) {
                if (element["status"] == "succeeded") {
                  print("TESTtestetste: ${element.data()}");
                  successfulPaymentsList.add(element);
                  print("OK2: ${successfulPaymentsList.length}");
                  print("OK3: ${paymentList.length}");
                  //print("TEST: TSTET: TEST ${element["refund"]}");
                }
              });
              print("OK: ${successfulPaymentsList.length}");
              return ListView.builder(
                  itemCount: successfulPaymentsList.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.place),
                            title: Text("LOCATION"),
                            subtitle: Text(capitalize(
                                    successfulPaymentsList[index]["charges"]
                                                ["data"][0]
                                            ["payment_method_details"]["card"]
                                        ["brand"]) +
                                " ****${successfulPaymentsList[index]["charges"]["data"][0]["payment_method_details"]["card"]["last4"]}"),
                            trailing: Text(
                                "Amount: \$${(successfulPaymentsList[index]["amount_received"] / 100).toStringAsFixed(2)} "),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              TextButton(
                                textColor: Colors.blue,
                                child: Text('REQUEST REFUND'),
                                //color: Colors.blue,
                                onPressed: () async {
                                  bool checkRefundStatus =
                                      await paymentService.getRefundStatus(
                                          successfulPaymentsList[index].id);
                                  if (checkRefundStatus) {
                                    _showRefundAlreadyInProgress();
                                  } else {
                                    await _showRefundAlertDialog(
                                        successfulPaymentsList[index].id);
                                  }
                                  // Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  });
            } else {
              // We can show the loading view until the data comes back.
              debugPrint('TEST: TEROERERbuild loading widget');
              //print("No previous trips ");
              return CircularProgressIndicator();
            }
          } catch (error) {
            //print("ERROR: afsdfas $error");
            //return ("No previous trips Found");
            return text(context);
          }
        },
      ),
    );
  }

  Widget text(BuildContext context) {
    //print ("No previous trips found");
    return Center(child: Text("No previous trips found"));
  }

  _showRefundAlreadyInProgress() async {
    return showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(
                "Your Refund Request has already been received! An email will be sent to ${firebaseUser.email} once approved!"),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Future<void> _showRefundAlertDialog(docID) async {
    return showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Request Refund?"),
          content: Text("Are you sure?"),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text("Yes"),
              onPressed: () async {
                try {
                  Navigator.of(context).pop();
                  //buildShowDialog(context);
                  await paymentService.sendRefundRequest(docID);
                  //Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: Text('Your refund request has been received'),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: Text('Ok'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              //Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                } catch (error) {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: Text('Error Occured'),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: Text('Ok'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
            CupertinoDialogAction(
              child: Text("No",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    //backgroundColor: Colors.black,
                  )),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  buildShowDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
