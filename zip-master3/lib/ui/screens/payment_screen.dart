import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:zip/business/payment.dart';
import 'dart:io';

import 'package:zip/ui/screens/payment_history_screen.dart';

class PaymentScreen extends StatefulWidget {
  final paymentService;
  PaymentScreen({Key key, @required this.paymentService}) : super(key: key);
  @override
  _PaymentScreenState createState() => new _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _paymentMethod;
  String _error;
  PaymentIntentResult _paymentIntent;

  ScrollController _controller = ScrollController();
  var customerData = new Map();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  //var paymentMethodList;
  @override
  initState() {
    super.initState();

    StripePayment.setOptions(StripeOptions(
        publishableKey: "pk_test_Cn8XIP0a25tKPaf80s04Lo1m00dQhI8R0u"));
    //   paymentMethodList = [];
    widget.paymentService.getPaymentMethods();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[800],
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(
          'Payment Methods',
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _paymentIntent = null;
                _paymentMethod = null;
              });
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: ListView(
        controller: _controller,
        padding: EdgeInsets.zero,
        children: <Widget>[
          //Gets Payment Methods
          Card(
            child: ExpansionTile(
              leading: Icon(Icons.view_headline),
              title: Text("Payment Methods"),
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: widget.paymentService.getPaymentMethods(),
                  builder: (context, snapshot) {
                    /* Timer(Duration(seconds: 2), () {
                      print("Yeah, this line is printed after 2 seconds");
                    });*/
                    try {
                      if (snapshot.hasData) {
                        debugPrint("build widget: ${snapshot.data}");
                        List<QueryDocumentSnapshot> paymentList =
                            snapshot.data.docs;

                        return DataTable(
                          columnSpacing: 50,
                          columns: const <DataColumn>[
                            DataColumn(
                              label: Text(
                                'Brand',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Last4',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Ending',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                            //Column for trash icon
                            DataColumn(
                              label: Text(""),
                            ),
                          ],
                          rows: List<DataRow>.generate(
                            paymentList.length,
                            (index) => DataRow(cells: [
                              DataCell(
                                  Text(paymentList[index]["card"]["brand"]),
                                  onTap: () async {
                                //amount = 15.00;
                                // String currency = "US";
                                widget.paymentService.paymentMethod =
                                    paymentList[index]["id"];
                                _showOrderConfirmation(
                                    paymentList[index]["card"]["last4"]);
                                /* await paymentService
                                    .triggerCloudFunctionPaymentIntent(amount,
                                        currency, paymentList[index]['id']);*/
                              }),
                              DataCell(
                                  Text(paymentList[index]["card"]["last4"]),
                                  onTap: () {
                                widget.paymentService.paymentMethod =
                                    paymentList[index]["id"];
                                _showOrderConfirmation(
                                    paymentList[index]["card"]["last4"]);
                                //ONLY FOR PAYMNET ONLY! MUST DELETE THIS******************
                              }),
                              DataCell(
                                  //(var number = 5);
                                  Text(
                                      '${paymentList[index]["card"]["exp_month"]}/${paymentList[index]["card"]["exp_year"]}'),
                                  onTap: () {
                                widget.paymentService.paymentMethod =
                                    paymentList[index]["id"];
                                _showOrderConfirmation(
                                    paymentList[index]["card"]["last4"]);
                              }),
                              DataCell(
                                Icon(Icons.delete_outline),
                                onTap: () async {
                                  print("TEST: ${paymentList[index].id}");
                                  await _showDeleteAlertDialog(
                                      paymentList[index].id);
                                },
                              )
                            ]),
                          ),
                        );
                      } else {
                        // We can show the loading view until the data comes back.
                        debugPrint('build loading widget');
                        return CircularProgressIndicator();
                      }
                    } catch (error) {
                      return CircularProgressIndicator();
                    }
                  },
                ),
              ],
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.add_circle_outline),
              title: Text("Add new credit/debit card"),
              onTap: () async {
                await StripePayment.paymentRequestWithCardForm(
                        CardFormPaymentRequest())
                    .then((paymentMethod) async {
                  /*_scaffoldKey.currentState.showSnackBar(
                      SnackBar(content: Text('Received ${paymentMethod.id}')));*/
                  setState(() {
                    //_getCustomer();
                    _paymentMethod = paymentMethod;
                  });
                  await widget.paymentService
                      .setPaymentMethodID(_paymentMethod);
                  // print("TEST: DID I GETSDDSAD?");
                  buildShowDialog(context);
                  await _checkPayment();
                  //await _addPaymentMethodDialog(_paymentMethod.id);
                }).catchError(setError);
                //_addPaymentMethodDialog();
              },
            ),
          ),
        ],
      ),
    );
  }

  void setError(dynamic error) {
    //_scaffoldKey.currentState
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(error.toString())));
    setState(() {
      _error = error.toString();
    });
  }

  //Dialog that makes sure that User wants to Delete this payment method
  //if User clicks yes, then this method calls the _deletePaymentMethod() method
  Future<void> _showDeleteAlertDialog(paymentListID) async {
    return showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Delete?"),
          content: Text("Are you sure?"),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text("Yes"),
              onPressed: () async {
                try {
                  Navigator.of(context).pop();
                  buildShowDialog(context);
                  await widget.paymentService
                      .deletePaymentMethod(paymentListID);
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: Text('Succesfully Deleted'),
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

//Dialog if the Payment Method was added succesfully
  _addPaymentMethodDialog() async {
    Future.delayed(Duration(microseconds: 1));
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Payment Added Successfully!"),
          actions: <Widget>[
            CupertinoDialogAction(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ],
        );
      },
    );
  }

  _validatePaymentDialog() async {
    Future.delayed(Duration(microseconds: 1));
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Success!"),
          actions: <Widget>[
            CupertinoDialogAction(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ],
        );
      },
    );
  }

  _showError(error) async {
    await Future.delayed(Duration(microseconds: 1));
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("ERROR"),
          content: Text("There was a problem with your card!"),
          actions: <Widget>[
            CupertinoDialogAction(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
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

  Future<void> _checkPayment() async {
    print("TEST: was this called?");
    DocumentSnapshot snapshot = await widget.paymentService.checkPaymentAdded();
    print("TEST: Snapshot: ${snapshot.data()}");
    if (snapshot.data()['error'] == null) {
      print("TEST: DID I REACH HERE?");
      Navigator.of(context).pop();
      _addPaymentMethodDialog();
    } else {
      //print("TEST: payment list idL $paymentMethodListID");
      widget.paymentService
          .deletePaymentMethod(widget.paymentService.cardDocumentID.id);
      Navigator.of(context).pop();
      _showError(snapshot.get('error'));
    }
  }

  Future<void> _checkPaymentValidation(docID) async {
    print("TEST: was this called?");
    DocumentSnapshot snapshot =
        await widget.paymentService.validatePayment(docID);
    print("TEST: Snapshot: ${snapshot.data()}");
    if (snapshot.data()['error'] == null) {
      print("TEST: DID I REACH HERE?");
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      _validatePaymentDialog();
    } else {
      //print("TEST: payment list idL $paymentMethodListID");
      //widget.paymentService.deletePaymentMethod(paymentService.cardDocumentID.id);
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      _showError(snapshot.get('error'));
    }
  }

  //*****************THIS WILL NEED TO CHANGE ACCORDINGLY WITH REQUIREMENTS FROM SPONSORS*******************************************************************
  void _showOrderConfirmation(card) {
    print("Test: amount : ${widget.paymentService.amount}");
    var ok = widget.paymentService.amount / 100;
    print("TEST: okamoung: $ok");
    String amount = (widget.paymentService.amount / 100).toStringAsFixed(2);
    DocumentReference doc;
    //double tax = (paymentService.amount) * .10;
    var promotionCredits = 0;
    //double currentTotal = (paymentService.amount) - promotionCredits;
    showModalBottomSheet(
        context: context,
        isDismissible: false,
        builder: (context) {
          return Center(
            child: Column(
              children: <Widget>[
                Card(
                  child: ListTile(
                    leading: Image.asset('assets/Zip Yellow B.png',
                        height: 60, width: 60),
                    title: Text(
                      "Order Confirmation ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    trailing: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ),
                ),
                ListTile(
                    leading: Icon(Icons.attach_money),
                    title: Text("Estimated Amount: \$${amount}"),
                    trailing: Icon(Icons.help)),
                ListTile(
                  leading: Icon(Icons.credit_card),
                  title: Text("Card: *********$card"),
                ),
                //TODO: ADD FUNCTIONALITY TO APPLY PROMOS CREDITS OR NOT TO APPLY THEM
                ListTile(
                  leading: Icon(Icons.card_giftcard),
                  title: Text("Promo Credits Available: $promotionCredits"),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextButton(
                        child: Text('Request Ride'),
                        color: Colors.black,
                        onPressed: () async {
                          //buildShowDialog(context);
                          doc = await widget.paymentService
                              .triggerCloudFunctionPaymentIntent(
                                  widget.paymentService, card);
                          print("TEST: docID: ${doc.id}");
                          buildShowDialog(context);
                          await _checkPaymentValidation(doc.id);
                          print("TEST DOCID: ${doc.id}");

                          await widget.paymentService.collectPayment(doc.id);

                          print("TEST: update");
                          //Navigator.pop(context);
                          // Navigator.pop(context);
                          // Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        child: Text('Cancel'),
                        color: Colors.black,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Text(
                      "*You agree to pay the upfront price shown at booking. The upfront price is calculated using the base rate, plus the per-minute rate and/or per-mile rate. It may be adjusted due to marketplace factors, promotions, and/or other discounts, and includes applicable taxes, fees, surcharges and estimated tolls. Additional charges, such as a wait-time fee, may be added to your upfront price. If the length or route of your trip changes, your upfront price may change based on the rates above and other applicable taxes, tolls, fees, and surcharges. Rates shown are rounded to 2 decimal points, ",
                      style: TextStyle(fontSize: 10)),
                ),
              ],
            ),
          );
        });
  }
}
