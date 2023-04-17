import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:zip/models/user.dart';
import 'package:zip/business/user.dart';
import 'package:zip/models/rides.dart';


class DriverHistoryScreen extends StatefulWidget {
  @override
  _DriverHistoryScreenState createState() => new _DriverHistoryScreenState();
}

class _DriverHistoryScreenState extends State<DriverHistoryScreen> { 
  VoidCallback onBackPress;
  final UserService userService = UserService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  List<dynamic> pastDrivesList;
  List<dynamic> pastDriveIDs;
  DocumentReference rideReference;
  Ride driverRide;

  @override
  void initState() {
    onBackPress = () {
      Navigator.of(context).pop();
    };
    super.initState();
  }

  Future _retrievePastRideIDs() async {
    DocumentReference userRef = _firestore.collection('users').doc(userService.userID);
    pastDriveIDs = (await userRef.get()).get('pastDrives');
    print('past ride ids: $pastDriveIDs');
    
    return pastDriveIDs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(
          'Past Trips',
        ),
      ),
      
      body: FutureBuilder<void>(
        future: _retrievePastRideIDs(),
        builder: (context, index) {
          return ListView.builder(
            itemCount: (pastDriveIDs != null) ? pastDriveIDs.length : 0,
            itemBuilder: (context, index) {
              print('id = ${pastDriveIDs[index]}');
              return Container(
                height: 50,
                color: Colors.yellow,
                child: Center(child: Text('past drive: ${pastDriveIDs[index]}')),
              );
            }
          );
        }
      ) 
    );
    
  } 
}
