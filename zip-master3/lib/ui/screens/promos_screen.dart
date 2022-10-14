import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:zip/CustomIcons/custom_icons_icons.dart';
import 'package:zip/business/user.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:zip/models/user.dart';
import 'package:zip/ui/widgets/custom_alert_dialog.dart';

class PromosScreen extends StatefulWidget {
  @override
  _PromosScreenState createState() => _PromosScreenState();
}

class _PromosScreenState extends State<PromosScreen> {
  VoidCallback onBackPress;
  UserService userService = UserService();
  bool _isInAsyncCall = false;

  final HttpsCallable applyPromoFunction =
      CloudFunctions.instance.getHttpsCallable(
    functionName: 'applyPromoCode',
  );

  final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
    functionName: 'repeat',
  );

  @override
  void initState() {
    super.initState();
    onBackPress = () {
      Navigator.of(context).pop();
    };
  }

/*
  Allows customers to apply promotion codes.
  Uses Firebase Cloud Function to do computation.
*/
  void _applyCode() async {
    setState(() {
      _isInAsyncCall = true;
    });
    try {
      HttpsCallableResult result = await applyPromoFunction
          .call(<String, dynamic>{
        'uid': userService.userID,
        'promo_code': _promoController.text
      });
      if (result.data['result'] == true) {
        _showAlert(
          title: "Success!",
          content: result.data['message'],
          onPressed: () {},
        );
      } else {
        _showAlert(
          title: "Error",
          content: result.data['message'],
          onPressed: () {},
        );
      }
    } catch (e) {
      print('An error has occured: $e');
    }
    setState(() {
      _isInAsyncCall = false;
    });
  }

/*
  Main build function.
  Displays Customer promotion credit information.
  If a user has entered a promotion, UI will show loading screen
  while waiting for result.
*/
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isInAsyncCall,
      progressIndicator: CircularProgressIndicator(),
      opacity: 0.5,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: ListView(
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: SafeArea(
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: onBackPress,
                ),
              ),
            ),
            Center(
              child: Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 10),
                  child: _promos),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 6,
                  right: MediaQuery.of(context).size.width / 4,
                  left: MediaQuery.of(context).size.width / 4),
              child: _fireIcon,
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: 45.0,
                  right: MediaQuery.of(context).size.width / 6,
                  left: MediaQuery.of(context).size.width / 6),
              child: Container(
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: BorderSide(color: Colors.white)),
                ),
                height: MediaQuery.of(context).size.height / 17,
                child: _enterPromo,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: 10.0,
                  right: MediaQuery.of(context).size.width / 4,
                  left: MediaQuery.of(context).size.width / 4),
              child: TextButton(
                onPressed: _applyCode,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                color: Colors.white,
                child: Text(
                  "Apply",
                  softWrap: true,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Bebas",
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                  padding: EdgeInsets.only(top: 100.0), child: _creditText),
            ),
            //progress bar attempt
            Padding(
                padding: EdgeInsets.only(
                    top: 10.0,
                    right: MediaQuery.of(context).size.width / 12,
                    left: MediaQuery.of(context).size.width / 12),
                child: buildProgressBar(context)),
          ],
        ),
      ),
    );
  }

  final Text _promos = Text(
    "Promos",
    softWrap: true,
    style: TextStyle(
      color: Color.fromRGBO(255, 242, 0, 1.0),
      fontSize: 42.0,
      fontWeight: FontWeight.w600,
      fontFamily: "Bebas",
    ),
  );

  final Icon _fireIcon = Icon(CustomIcons.fire,
      size: 110.0, color: Color.fromRGBO(255, 242, 0, 1.0));

  static final TextEditingController _promoController =
      new TextEditingController();
  final TextField _enterPromo = TextField(
    controller: _promoController,
    textAlign: TextAlign.center,
    style: TextStyle(
      color: Color.fromRGBO(255, 242, 0, 1.0),
      fontSize: 20.0,
      fontFamily: "Poppins",
      fontWeight: FontWeight.w300,
      decoration: TextDecoration.none,
    ),
    decoration: InputDecoration(
      hintStyle: TextStyle(
        color: Color.fromRGBO(255, 242, 0, 1.0),
        fontSize: 20.0,
        fontFamily: "Poppins",
        fontWeight: FontWeight.w300,
        decoration: TextDecoration.none,
      ),
      hintText: "Promo Code",
      border: InputBorder.none,
    ),
  );

  final Text _creditText = Text(
    "Credits",
    softWrap: true,
    style: TextStyle(
      color: Color.fromRGBO(255, 242, 0, 1.0),
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
      fontFamily: "Bebas",
    ),
  );

/*
  Builds Progress indicatior.
  Let's users know how many credits they currently have.
*/
  Widget buildProgressBar(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: Firestore.instance
            .collection('users')
            .document(userService.userID)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            User user = User.fromDocument(snapshot.data);
            return LinearPercentIndicator(
              width: MediaQuery.of(context).size.width / 1.2,
              animation: false,
              lineHeight: 20.0,
              percent: (user.credits / 200),
              progressColor: Color.fromRGBO(255, 242, 0, 1.0),
              backgroundColor: Colors.white,
              center: Text(user.credits.toInt().toString() + '/' + '200'),
            );
          } else {
            return DrawerHeader(child: Column());
          }
        });
  }

  void _showAlert({String title, String content, VoidCallback onPressed}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return CustomAlertDialog(
          content: content,
          title: title,
          onPressed: onPressed,
        );
      },
    );
  }
}
