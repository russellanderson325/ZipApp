import "package:flutter/material.dart";
import 'package:flutter/rendering.dart';
import 'package:stripe_payment/stripe_payment.dart';
import "package:zip/business/auth.dart";
import "package:zip/business/user.dart";
import "package:zip/business/payment.dart";
import 'package:zip/models/driver.dart';
import 'package:zip/ui/screens/driver_settings_screen.dart';
import 'package:zip/business/drivers.dart';
import 'package:zip/ui/widgets/custom_flat_button.dart';

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
    return WillPopScope(
      onWillPop: onBackPress,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: <Widget>[
            Stack(
              alignment: Alignment.topLeft,
              children: <Widget>[
                ListView(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 70.0, bottom: 10.0, left: 10.0, right: 10.0),
                      child: Text(
                        "Driver Earnings",
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromRGBO(255, 242, 0, 1.0),
                          decoration: TextDecoration.none,
                          fontSize: 32.0,
                          fontWeight: FontWeight.w700,
                          fontFamily: "Bebas",
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 10.0, bottom: 20.0, left: 15.0, right: 15.0),
                      child: Text("Cash Amount", style: TextStyle(color: Colors.yellow, fontSize: 22.0), textAlign: TextAlign.center,)
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 40.0),
                      child: CustomTextButton(
                        title: "Cash Out",
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        textColor: Colors.black,
                        onPressed: () {
                          print('driver earnings - cash out button clicked');
                        },
                        color: Color.fromRGBO(255, 242, 0, 1.0),
                        splashColor: Colors.black12,
                        borderColor: Color.fromRGBO(212, 20, 15, 1.0),
                        borderWidth: 0,
                        
                      ),
                    ),
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
          ],
        ),
      ),
    );
  }

}
  