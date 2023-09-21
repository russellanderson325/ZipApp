import 'package:flutter/material.dart';
import 'package:zip/business/drivers.dart';
import 'package:zip/business/location.dart';
import 'package:zip/business/ride.dart';
import 'package:zip/business/user.dart';
import 'package:zip/ui/screens/welcome_screen.dart';
import 'package:zip/ui/screens/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class RootScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _RootScreenState();
}

enum LoadingState {
  none,
  loading,
  done,
}

/**
 * This class sets up all of the services that
 * the app will use while running.
 */
class _RootScreenState extends State<RootScreen> {
  LoadingState loading = LoadingState.none;

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<auth.User>(
      stream: auth.FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return new Container(
            // TODO: create a splashscreen / loading screen
            color: Colors.white,
          );
        } else {
          if (snapshot.hasData) {
            switch (loading) {
              case LoadingState.none:
                _initializeServices(snapshot.data.uid).whenComplete(() {
                  setState(() {
                    loading = LoadingState.done;
                  });
                });
                loading = LoadingState.loading;
                return _buildWaitingScreen();
                break;
              case LoadingState.loading:
                return _buildWaitingScreen();
                break;
              case LoadingState.done:
                //If this is MainScreen(), basically automatically logs in the user if they logged in before
                return MainScreen();
                break;
              default:
                print("Error: Unknown loading state");
            }
          } else {
            return WelcomeScreen();
          }
        }
      },
    );
  }

  Future<bool> _initializeServices(String uid) async {
    UserService userService = UserService();
    userService.setupService(uid);
    LocationService locationService = LocationService();
    await locationService.setupService();
    DriverService driverService = DriverService();
    await driverService.setupService();
    RideService rideService = RideService();
    return true;
  }
}
