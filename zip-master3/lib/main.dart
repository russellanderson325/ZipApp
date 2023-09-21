import 'package:flutter/material.dart';
import 'package:zip/ui/screens/phone_login_screen.dart';
import 'package:zip/ui/screens/profile_screen.dart';
import 'package:zip/ui/screens/root_screen.dart';
import 'package:zip/ui/screens/sign_in_screen.dart';
import 'package:zip/ui/screens/sign_up_screen.dart';
import 'package:zip/ui/screens/main_screen.dart';
import 'package:zip/ui/screens/sms_pin_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';

// May the torture begin
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences.getInstance().then((prefs) {
    runApp(MyApp(prefs: prefs));
  });
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  MyApp({this.prefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zip Gameday',
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        '/root': (BuildContext context) => RootScreen(),
        '/signin': (BuildContext context) => SignInScreen(),
        '/signup': (BuildContext context) => SignUpScreen(),
        '/main': (BuildContext context) => MainScreen(),
        '/profile': (BuildContext context) => ProfileScreen(),
        'smspinscreen': (BuildContext context) => SmsPinScreen(),
        '/phonesignin': (BuildContext context) => PhoneLoginScreen(),
      },
      theme: ThemeData(
        primaryColor: Colors.white,
        primarySwatch: Colors.grey,
      ),
      home: _handleCurrentScreen(),
    );
  }

  Widget _handleCurrentScreen() {
    return RootScreen();
  }
}
// Test
