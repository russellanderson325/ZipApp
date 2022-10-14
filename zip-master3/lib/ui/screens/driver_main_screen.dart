import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:zip/business/auth.dart';
import 'package:zip/business/drivers.dart';
import 'package:zip/business/user.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zip/models/driver.dart';
import 'package:zip/models/request.dart';
import 'package:zip/models/rides.dart';
import 'package:zip/ui/screens/Previous_Driver_Trips.dart';
import 'dart:io';
import 'package:zip/ui/screens/main_screen.dart';
import 'package:zip/ui/widgets/ride_bottom_sheet.dart';
import '../../models/user.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:unicorndial/unicorndial.dart';
import 'package:zip/CustomIcons/my_flutter_app_icons.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:zip/ui/screens/stripe_connect_screen.dart';
import 'driver_settings_screen.dart';
import 'earnings_screen.dart';
import 'main_screen.dart';

enum DriverBottomSheetStatus { closed, confirmation, searching, rideDetails }

class DriverMainScreen extends StatefulWidget {
  DriverMainScreen();
  _DriverMainScreenState createState() => _DriverMainScreenState();
}

class _DriverMainScreenState extends State<DriverMainScreen> {
  final UserService userService = UserService();
  final DriverService driverService = DriverService();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _blackVisible = false;
  bool _isRequest = false;
  static bool _isDriver = true;
  double screenHeight, screenWidth;
  static Text driverText = Text("Driver",
      softWrap: true,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.0,
        fontFamily: "Bebas",
        fontWeight: FontWeight.w600,
      )); // Audit
  DriverBottomSheetStatus driverBottomSheetStatus;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () => _introAlert(context));
    driverBottomSheetStatus = DriverBottomSheetStatus.closed;
  }

  // user defined function
  void _introAlert(BuildContext context) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(
            "Hello, ${userService.user.firstName}!",
            style: TextStyle(color: Color.fromRGBO(255, 242, 0, 1.0)),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "Driving with Zip is simple:\n\n1. Press drive to start.\n2. We'll connect you with a rider.\n3. Payment will be made by the hour.\n4. Tips will be added to your pay.",
                  style: TextStyle(
                    color: Color.fromRGBO(255, 242, 0, 1.0),
                    decoration: TextDecoration.none,
                    fontSize: 18.0,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w600,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new TextButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          backgroundColor: Colors.black,
        );
      },
    );
  }

  void _overrideAlert(BuildContext context, String displayText) {
    String result;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(
            "Driver Notification",
            style: TextStyle(color: Color.fromRGBO(255, 242, 0, 1.0)),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  displayText,
                  style: TextStyle(
                    color: Color.fromRGBO(255, 242, 0, 1.0),
                    decoration: TextDecoration.none,
                    fontSize: 18.0,
                    fontFamily: "Bebas",
                    fontWeight: FontWeight.w600,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog

            new TextButton(
                child: new Text("OVERRIDE",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 22.0,
                        fontWeight: FontWeight.w700)),
                onPressed: () async =>
                    {Navigator.of(context).pop(), _overrideDriver()}),
            new TextButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
          backgroundColor: Colors.black,
        );
      },
    );
  }

  void _driverAlert(BuildContext context, String displayText, bool override) {
    String result;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(
            "Driver Notification",
            style: TextStyle(color: Color.fromRGBO(255, 242, 0, 1.0)),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  displayText,
                  style: TextStyle(
                    color: Color.fromRGBO(255, 242, 0, 1.0),
                    decoration: TextDecoration.none,
                    fontSize: 18.0,
                    fontFamily: "OpenSans",
                    fontWeight: FontWeight.w600,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog

            new TextButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          backgroundColor: Colors.black,
        );
      },
    );
  }

  void _showVehicle(BuildContext context) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(
            'What kind of vehicle are you driving?',
            style: TextStyle(color: Color.fromRGBO(255, 242, 0, 1.0)),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new TextButton(
              child: new Text("ZipX"),
              onPressed: () async {
                Navigator.of(context).pop();
                await driverService.startDriving(updateUI);
              },
            ),
            new TextButton(
              child: new Text("ZipXL"),
              onPressed: () async {
                Navigator.of(context).pop();
                await driverService.startDriving(updateUI);
              },
            ),
          ],
          backgroundColor: Colors.black,
        );
      },
    );
  }

/*
  Main build function for Driver Page.
*/
  @override
  Widget build(BuildContext context) {
    //MediaQuery used for constant UI on different sized screens.
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    //Subscribed to Driver with certain ID
    //This is how we get constant updates from the database.
    //Needed to change UI based off events happening on Client Side
    return StreamBuilder<Driver>(
      stream: driverService.getDriverStream(),
      builder: (BuildContext context, AsyncSnapshot<Driver> driverObject) {
        print(driverObject.toString());
        if (driverObject.hasData) {
          return Scaffold(
              key: _scaffoldKey,
              backgroundColor: Colors.black,
              body: Stack(
                children: <Widget>[
                  //Uses Enum to determine which view to build.
                  driverBottomSheetStatus ==
                          DriverBottomSheetStatus.confirmation
                      ? _buildMapView()
                      : TheMap(),
                  Align(
                    alignment: Alignment.topLeft,
                    child: SafeArea(
                        child: Stack(children: <Widget>[
                      Card(
                          color: Colors.transparent,
                          elevation: 100,
                          child: IconButton(
                              iconSize: 44,
                              color: Color.fromRGBO(255, 242, 0, 1.0),
                              icon: Icon(Icons.menu),
                              onPressed: () =>
                                  _scaffoldKey.currentState.openDrawer()))
                    ])),
                  ),
                ],
              ),
              drawer: _buildDrawer(context),
              bottomSheet: _buildBottomSheet(),
              //If bottomsheet is closed -> display Drive button

              //comenting out this sets it in center but do we still want this without drive button
              // floatingActionButtonLocation:
              //     driverBottomSheetStatus != DriverBottomSheetStatus.closed
              //         ? null
              //         : FloatingActionButtonLocation.centerDocked,
              floatingActionButton: driverBottomSheetStatus !=
                      DriverBottomSheetStatus.closed
                  ? null
                  :
                  // Container(
                  //    alignment: Alignment.bottomRight,
                  //    height: screenHeight * 0.25,
                  //    width: screenWidth * 0.25,
                  //    padding: EdgeInsets.only(bottom: 20.0),
                  //    color: Colors.transparent,
                  //    child:
                  SafeArea(
                      child: SpeedDial(
                        marginEnd: 18,
                        marginBottom: 20,
                        icon: MyFlutterApp.golfCart,
                        activeIcon: Icons.close,
                        buttonSize: 60.0,
                        visible: true,
                        iconTheme: IconThemeData(color: Colors.black, size: 25),

                        /// If true user is forced to close dial manually
                        /// by tapping main button and overlay is not rendered.
                        closeManually: false,

                        /// If true overlay will render no matter what.
                        renderOverlay: false,
                        useRotationAnimation: false,
                        tooltip: 'Speed Dial',
                        heroTag: 'speed-dial-hero-tag',
                        backgroundColor: Color.fromRGBO(255, 242, 0, 1.0),
                        foregroundColor: Colors.transparent,
                        elevation: 8.0,
                        overlayOpacity: 0,
                        //overlayColor: Colors.transparent,
                        shape: CircleBorder(),
                        // orientation: SpeedDialOrientation.Up,
                        // childMarginBottom: 2,
                        // childMarginTop: 2,
                        children: [
                          SpeedDialChild(
                            child:
                                new Icon(MdiIcons.clockIn, color: Colors.black),
                            backgroundColor: Colors.grey[300],
                            label: 'Clock In',
                            labelStyle: TextStyle(fontSize: 17.0),
                            onTap: () async {
                              List result = await driverService.clockIn();
                              //[message, override]
                              if (result[1]) {
                                _overrideAlert(context, result[0]);
                              } else {
                                _driverAlert(context, result[0], result[1]);
                                await driverService.startDriving(updateUI);
                              }
                            },
                          ),
                          SpeedDialChild(
                            child: new Icon(MdiIcons.clockOut,
                                color: Colors.black),
                            backgroundColor: Colors.grey[300],
                            label: 'Clock Out',
                            labelStyle: TextStyle(fontSize: 17.0),
                            onTap: () async {
                              String message = await driverService.clockOut();
                              _driverAlert(context, message, false);
                            },
                          ),
                          SpeedDialChild(
                            child: new Icon(MdiIcons.play, color: Colors.black),
                            backgroundColor: Colors.grey[300],
                            label: 'Start Break',
                            labelStyle: TextStyle(fontSize: 17.0),
                            onTap: () async {
                              String message = await driverService.startBreak();
                              _driverAlert(context, message, false);
                            },
                          ),
                          SpeedDialChild(
                            child:
                                new Icon(MdiIcons.pause, color: Colors.black),
                            backgroundColor: Colors.grey[300],
                            label: 'End Break',
                            labelStyle: TextStyle(fontSize: 17.0),
                            onTap: () async {
                              String message = await driverService.endBreak();
                              _driverAlert(context, message, false);
                            },
                          ),
                        ],
                      ),
                    ));
        } else {
          print("no driver data :((( ");
          return Scaffold(
            body: Container(child: Center(child: CircularProgressIndicator())),
          );
        }
      },
    );
  }

  /*
    Updated based on bottomSheet enum.
    Builds basic bottomSheet to alert Driver that system is looking for rider.
  */
  Widget _buildLookingForRider(BuildContext context) {
    return Container(
        color: Colors.black,
        height: screenHeight * 0.20,
        width: screenWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
              ),
            ),
            Text("Looking for rider",
                softWrap: true,
                style: TextStyle(
                    backgroundColor: Colors.black,
                    color: Color.fromRGBO(255, 242, 0, 1.0),
                    fontWeight: FontWeight.w400,
                    fontSize: 22.0,
                    fontFamily: "Bebas")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              )),
              onPressed: () {
                driverService.stopDriving();
              },
              child: Text("Cancel"),
            ),
          ],
        ));
  }

/* 
  If bottomSheet has found a ride -> show preview of route inside application. 
*/
  Widget _buildMapView() {
    return Container(
      height: screenHeight * 0.75,
      width: screenWidth,
      child: WebView(
        initialUrl:
            "https://www.google.com/maps/dir/?api=1&origin=${driverService.locationService.position.latitude},${driverService.locationService.position.longitude}&destination=${driverService.currentRequest.pickupAddress.latitude},${driverService.currentRequest.pickupAddress.longitude}",
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }

/* 
  Controls the state of the bottomSheet.
  Constantly listens to a request stream to check for changes.
*/
  Widget _buildBottomSheet() {
    switch (driverBottomSheetStatus) {
      //_selectVehicle(context);
      case DriverBottomSheetStatus.closed:
        return Container(width: 0, height: 0);
        break;
      case DriverBottomSheetStatus.searching:
        return _buildLookingForRider(context);
        //return _selectVehicle(context);
        break;
      case DriverBottomSheetStatus.confirmation:
        return _buildAcceptOrDeclineRider(context, _changeBlackVisible);
        break;
      case DriverBottomSheetStatus.rideDetails:
        return _buildRideDetails(context);
        break;
      default:
    }
  }

  Widget _selectVehicle() {
    Container(
      color: Colors.black,
      width: screenWidth,
      height: screenHeight * 0.25,
      padding: EdgeInsets.only(
        left: screenWidth * 0.1,
        right: screenWidth * 0.1,
        top: screenHeight * 0.01,
        bottom: screenHeight * 0.01,
      ),
      child: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //Image.asset('assets/golf_cart.png'),
                  Text(
                    'Choose a Golf Cart size:',
                    style: TextStyle(
                      color: Color.fromRGBO(255, 242, 0, 1.0),
                      decoration: TextDecoration.none,
                      fontSize: 22.0,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600,
                    ),
                    softWrap: true,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FloatingActionButton.extended(
                    backgroundColor: Color.fromRGBO(255, 242, 0, 1.0),
                    onPressed: () async {
                      return _buildLookingForRider(context);
                    },
                    label: Text('ZipX'),
                  ),
                  FloatingActionButton.extended(
                    backgroundColor: Color.fromRGBO(255, 242, 0, 1.0),
                    onPressed: () async {
                      return _buildLookingForRider(context);
                    },
                    label: Text('ZipXL'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //Image.asset('assets/golf_cart.png'),
                  Text(
                    '3 riders        5 riders',
                    style: TextStyle(
                      color: Color.fromRGBO(255, 242, 0, 1.0),
                      decoration: TextDecoration.none,
                      fontSize: 22.0,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600,
                    ),
                    softWrap: true,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRideDetails(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    Request currentRequest = driverService.currentRequest;
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      child: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                      radius: 50,
                      child: Image.asset('assets/profile_default.png')),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceAround,
              ),
              Row(
                children: <Widget>[
                  Text(currentRequest.name),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceAround,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  FloatingActionButton.extended(
                    backgroundColor: Colors.yellow,
                    onPressed: () {
                      _openRoute(currentRequest.destinationAddress.latitude,
                          currentRequest.destinationAddress.longitude);
                    },
                    label: Text('Arrived'),
                    icon: Icon(Icons.pin_drop),
                  ),
                  FloatingActionButton.extended(
                    backgroundColor: Color.fromRGBO(255, 242, 0, 1.0),
                    onPressed: () {
                      driverService.cancelRide();
                    },
                    label: Text('Cancel'),
                    icon: Icon(Icons.cancel),
                  ),
                  FloatingActionButton.extended(
                    backgroundColor: Color.fromRGBO(255, 242, 0, 1.0),
                    onPressed: () {
                      driverService.completeRide();
                    },
                    label: Text('Complete'),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

/*
  Build bottomSheet that shows if a rider should be Accepted or Declined.
*/
  Widget _buildAcceptOrDeclineRider(
      BuildContext context, VoidCallback onPressed) {
    Request currentRequest = driverService.currentRequest;
    return Container(
        color: Colors.white,
        height: screenHeight * 0.25,
        width: screenWidth,
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 30.0,
                child: ClipOval(
                  child: SizedBox(
                      width: 30.0,
                      height: 30.0,
                      child: Image.asset('assets/golf_cart.png',
                          fit: BoxFit.fill)),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.001),
              child: Text("${currentRequest.name}",
                  style: TextStyle(fontSize: 16.0)),
            ),
            ListBody(
              mainAxis: Axis.vertical,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Price: ", style: TextStyle(fontSize: 16.0)),
                    Text("${currentRequest.price}",
                        style: TextStyle(fontSize: 16.0)),
                  ],
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.001),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton.icon(
                    icon: Icon(Icons.check, color: Colors.white),
                    elevation: 1.0,
                    color: Color.fromRGBO(76, 86, 96, 1.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                    label: Text(
                      "Accept",
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                    onPressed: () async {
                      await _openRoute(currentRequest.pickupAddress.latitude,
                          currentRequest.pickupAddress.longitude);
                      await driverService.acceptRequest(currentRequest.id);
                    },
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.cancel),
                    elevation: 1.0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.black38),
                        borderRadius: BorderRadius.circular(12.0)),
                    label: Text(
                      "Decline",
                      style: TextStyle(
                          color: Color.fromRGBO(76, 86, 96, 1.0),
                          fontSize: 16.0),
                    ),
                    onPressed: () async {
                      await driverService.declineRequest(currentRequest.id);
                    },
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  void _overrideDriver() async {
    String result = await driverService.overrideClockIn();
    _driverAlert(context, result, false);
    await driverService.startDriving(updateUI);
  }

/*
  Changes the background of the screen.
*/
  void _changeBlackVisible() {
    setState(() {
      _blackVisible = !_blackVisible;
    });
  }

/*
  Set the status of the bottomSheet.
*/
  void updateUI(DriverBottomSheetStatus status) {
    setState(() {
      driverBottomSheetStatus = status;
    });
  }

/*
  Builds a drawer that is subscribed to user stream.
  Drivers and Customers have the same UID.
  We can use information from Customer snapshot instead of 
  duplicating data.
*/
  Widget _buildDrawer(BuildContext context) {
    _buildHeader() {
      return StreamBuilder<DocumentSnapshot>(
          stream: Firestore.instance
              .collection('users')
              .document(userService.userID)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              User user = User.fromDocument(snapshot.data);
              return Container(
                  height: MediaQuery.of(context).size.height / 2.8,
                  child: DrawerHeader(
                    padding: EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 2.0),
                    decoration: BoxDecoration(color: Colors.black),
                    child: Column(children: [
                      _buildTopRowOfDriverDrawer(context),
                      CircleAvatar(
                        radius: 60.0,
                        child: ClipOval(
                          child: SizedBox(
                            width: 130.0,
                            height: 130.0,
                            child: user.profilePictureURL == ''
                                ? Image.asset('assets/profile_default.png')
                                : Image.network(
                                    user.profilePictureURL,
                                    fit: BoxFit.fill,
                                  ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(top: 10.0),
                              child: Text(
                                '${user.firstName} ${user.lastName}',
                                style: TextStyle(
                                  color: Color.fromRGBO(255, 242, 0, 1.0),
                                  fontSize: 16.0,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w400,
                                ),
                              )),
                        ],
                      )
                    ]),
                  ));
            } else {
              return DrawerHeader(child: Column());
            }
          });
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _buildHeader(),
          ListTile(
            title: Text('Edit Profile'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            title: Text('Earnings'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => EarningsScreen()));
            },
          ),
          ListTile(
            title: Text('Driver History Screen'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DriverHistoryScreen()));
            },
          ),
          ListTile(
            title: Text('Account Settings'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DriverSettingsScreen()));
            },
          ),
          ListTile(
            title: Text('Payment Settings'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => StripeScreen()));
            },
          ),
          ListTile(
            title: Text('Log Out'),
            onTap: () {
              _logOut();
              _scaffoldKey.currentState.openEndDrawer();
              Navigator.of(context).pushNamed("/root");
            },
          ),
        ],
      ),
    );
  }

  ///this will logout the user.
  void _logOut() async {
    AuthService().signOut();
  }

/*
  Builds Switch to change pages.
*/
  Widget _buildTopRowOfDriverDrawer(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Switch(
            value: _isDriver,
            onChanged: (value) {
              setState(() {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MainScreen()));
              });
            },
            activeColor: Colors.green[400],
            activeTrackColor: Colors.green[100],
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: driverText,
        ),
      ],
    );
  }

/*
  Open directions to address on either Apple/Google Maps.
*/
  Future<void> _openRoute(double lat, double lng) async {
    try {
      if (Platform.isAndroid) {
        if (await canLaunch("google.navigation:q=$lat,$lng")) {
          launch("google.navigation:q=$lat,$lng");
        } else {
          throw "Could not";
        }
      } else {
        if (await canLaunch(
            "http://maps.apple.com/?daddr=$lat,$lng&dirflg=d")) {
          launch("http://maps.apple.com/?daddr=$lat,$lng&dirflg=d");
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }
}

/*
  Builds a Google Map centered on users location.
*/
class TheMap extends StatefulWidget {
  @override
  State<TheMap> createState() => MapScreen();
}

class MapScreen extends State<TheMap> {
  static LatLng _initialPosition;
  final Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Completer<GoogleMapController> _controller = Completer();
  BitmapDescriptor _sourceIcon;
  BitmapDescriptor _destinationIcon;

  @override
  void initState() {
    super.initState();
    setCustomMapPin();
    _getDriverLocation();
  }

  static final CameraPosition _currentPosition = CameraPosition(
    target: LatLng(_initialPosition.latitude, _initialPosition.longitude),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: _initialPosition == null
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              )
            : Stack(children: [
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _currentPosition,
                  onMapCreated: (GoogleMapController controller) {
                    _setStyle(controller);
                    _controller.complete(controller);
                  },
                  zoomControlsEnabled: false,
                  zoomGesturesEnabled: true,
                  markers: _markers,
                  polylines: _polylines,
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  mapToolbarEnabled: true,
                ),
              ]));
  }

  void setCustomMapPin() async {
    _sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 4.5), 'assets/golf_cart.png');
    _destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 4.5), 'assets/golf_cart.png');
  }

  void _getDriverLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });
  }

  void setMapPins() {
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId('source'),
          position: _initialPosition,
          icon: _sourceIcon));
      _markers.add(Marker(
          markerId: MarkerId('destination'),
          position: LatLng(37.430119406953, -122.0874490566),
          icon: _sourceIcon));
    });
  }

  void _setStyle(GoogleMapController controller) async {
    String value =
        await DefaultAssetBundle.of(context).loadString('assets/map_style.txt');
    controller.setMapStyle(value);
  }

  void setPolylines() async {
    List<PointLatLng> result = await polylinePoints?.getRouteBetweenCoordinates(
        "AIzaSyDsPh6P9PDFmOqxBiLXpzJ1sW4kx-2LN5g",
        _initialPosition.latitude,
        _initialPosition.longitude,
        37.430119406953,
        -122.0874490566);
    result.forEach((PointLatLng point) {
      polylineCoordinates.add(LatLng(point.latitude, point.longitude));
    });

    setState(() {
      Polyline polyline = Polyline(
          polylineId: PolylineId("p"),
          color: Colors.blue,
          points: polylineCoordinates);
      _polylines.add(polyline);
    });
  }
}
