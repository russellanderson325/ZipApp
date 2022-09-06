import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:zip/business/payment.dart';

class PaymentMethodsScreen extends StatefulWidget {
  @override
  _PaymentMethodsScreenState createState() => new _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  PaymentMethod _paymentMethod;
  String _error;
  PaymentIntentResult _paymentIntent;

  ScrollController _controller = ScrollController();
  var customerData = new Map();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final paymentService = Payment();
  //var paymentMethodList;
  @override
  initState() {
    super.initState();

    StripePayment.setOptions(StripeOptions(
        publishableKey: "pk_test_Cn8XIP0a25tKPaf80s04Lo1m00dQhI8R0u"));
    //   paymentMethodList = [];
    paymentService.getPaymentMethods();
  }

  void setError(dynamic error) {
    _scaffoldKey.currentState
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
                  buildShowDialog(context);
                  await paymentService.deletePaymentMethod(paymentListID);
                  Navigator.of(context).pop();
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

  _showError(error) async {
    await Future.delayed(Duration(microseconds: 1));
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("ERROR"),
          content: Text("There was a problem while authorizing your card!"),
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
    DocumentSnapshot snapshot = await paymentService.checkPaymentAdded();
    print("TEST: Snapshot: ${snapshot.data()}");
    if (snapshot.data()['error'] == null) {
      Navigator.of(context).pop();
      _addPaymentMethodDialog();
    } else {
      //print("TEST: payment list idL $paymentMethodListID");
      paymentService.deletePaymentMethod(paymentService.cardDocumentID.id);
      Navigator.of(context).pop();
      _showError(snapshot.get('error'));
    }
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
                  stream: paymentService.getPaymentMethods(),
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
                              ),
                              DataCell(
                                Text(paymentList[index]["card"]["last4"]),
                              ),
                              DataCell(
                                //(var number = 5);
                                Text(
                                    '${paymentList[index]["card"]["exp_month"]}/${paymentList[index]["card"]["exp_year"]}'),
                              ),
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
                  setState(() {
                    _paymentMethod = paymentMethod;
                  });
                  await paymentService.setPaymentMethodID(_paymentMethod);
                  buildShowDialog(context);
                  await _checkPayment();
                }).catchError(setError);
              },
            ),
          ),
        ],
      ),
    );
  }
}
