import "package:flutter/material.dart";
import 'package:flutter/rendering.dart';
import 'package:stripe_payment/stripe_payment.dart';
import "package:zip/business/auth.dart";
import "package:zip/business/user.dart";
import "package:zip/business/payment.dart";
import 'package:zip/models/driver.dart';
import 'package:zip/ui/screens/driver_settings_screen.dart';
import 'package:zip/business/drivers.dart';


// class EarningsScreen extends StatefulWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "Earnings Screen",
//       home: MyStatelessWidget(),
//     );
//   }
// }

class EarningsScreen extends StatefulWidget {
  _EarningsScreenState createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  VoidCallback onBackPress;
  final AuthService auth = AuthService();
  final UserService userService = UserService();
  final paymentService = Payment();
  PaymentMethod _paymentMethod;
  String _error;
  Payment pay;
  double screenHeight, screenWidth;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    onBackPress = () {
      Navigator.of(context).pop();
    };
    super.initState();

    paymentService.getPaymentMethods();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget> [
          Container(
            height: screenHeight * 0.25,
            width: screenWidth * 0.25,
            child: FloatingActionButton(
              onPressed: () {
                //do this action of cash out call that function
                // and change tip value back to 0
              },
              backgroundColor: Color.fromRGBO(255, 242, 0, 1.0),
              child: Text(
                "Cash Out",
                style: TextStyle(color: Colors.black, fontSize: 22.0),
                textAlign: TextAlign.center,
              )
            ),
          ),
          Container(
            height: screenHeight,
            width: screenWidth,
            child: Center(
              child: Text(
                  "Cash Amount", style: TextStyle(color: Colors.yellow, fontSize: 22.0), textAlign: TextAlign.center,)
            )
          ),
        ],
    ));
  }
}
