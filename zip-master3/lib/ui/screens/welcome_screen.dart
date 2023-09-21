import 'package:flutter/material.dart';
import 'package:zip/ui/widgets/custom_flat_button.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:zip/business/auth.dart';
import 'package:zip/ui/widgets/custom_gplus_fb_btn.dart';
import 'package:firebase_auth/firebase_auth.dart';

//class WelcomeScreen extends StatelessWidget {

class WelcomeScreen extends StatefulWidget {
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void authLogin(Future<FirebaseUser> userFuture, BuildContext context) {
    userFuture.then((user) {
      if (user != null) {
        Navigator.of(context).pushNamed("/main");
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Login Failed"),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      body: new ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 35.0, right: 15.0, left: 15.0),
            child:
                Image.asset('assets/Zip Yellow B.png', height: 200, width: 200),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height / 10,
                left: MediaQuery.of(context).size.width / 10,
                right: MediaQuery.of(context).size.width / 10),
            child: CustomTextButton(
                title: "Log In",
                fontSize: 22,
                fontWeight: FontWeight.w700,
                textColor: Colors.black,
                onPressed: () {
                  Navigator.of(context).pushNamed("/signin");
                },
                splashColor: Colors.black12,
                borderColor: Color.fromRGBO(76, 86, 96, 1.0),
                borderWidth: 0,
                //color: Color.fromRGBO(76, 86, 96, 1.0),
                color: Color.fromRGBO(255, 242, 0, 1.0)),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 40.0),
            child: CustomTextButton(
              title: "Sign Up",
              fontSize: 22,
              fontWeight: FontWeight.w700,
              textColor: Color.fromRGBO(255, 242, 0, 1.0),
              onPressed: () {
                Navigator.of(context).pushNamed("/signup");
              },
              splashColor: Colors.black12,
              borderColor: Colors.black12,
              borderWidth: 2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 25.0, right: 5.0),
            child: Center(
              child: GoogleButton(
                onPressed: () {
                  authLogin(AuthService().googleSignIn(), context);
                  Navigator.of(context).pushNamed("/main");
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Center(
              //child: FacebookSignInButton(
              //onPressed: () {
              //AuthService().facebookSignIn();
              child: FacebookSignInButton(
                onPressed: () {
                  authLogin(AuthService().facebookSignIn(), context);
                  Navigator.of(context).pushNamed("/main");
                },
                //},
                borderRadius: 12.0,
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Center(
                  child: CustomTextButton(
                title: "Sign in With Phone and Code",
                fontSize: 17,
                fontWeight: FontWeight.w600,
                textColor: Colors.black,
                color: Color.fromRGBO(252, 242, 0, 1.0),
                onPressed: () {
                  Navigator.of(context).pushNamed("/phonesignin");
                },
                splashColor: Colors.black12,
                borderColor: Colors.black12,
                borderWidth: 12.0,
              ))),
        ],
      ),
    );
  }
}
