import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:zip/models/user.dart';
import 'package:zip/business/user.dart';

class PreviousTripsScreen extends StatefulWidget {
  _PreviousTripsScreenState createState() => _PreviousTripsScreenState();
}

class _PreviousTripsScreenState extends State<PreviousTripsScreen> {
  VoidCallback onBackPress;
  final UserService userService = UserService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  List<QueryDocumentSnapshot> pastRidesList;
  List<dynamic> pastRideIDs;
  DocumentReference rideReference;
  

  @override
  void initState() {
    onBackPress = () {
      Navigator.of(context).pop();
    };
    super.initState();
  }

  Future _retrievePastRideIDs() async {
    DocumentReference userRef = _firestore.collection('users').doc(userService.userID);
    pastRideIDs = (await userRef.get()).get('pastRides');
    print('past ride ids: $pastRideIDs');
    return pastRideIDs;
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
            itemCount: (pastRideIDs != null) ? pastRideIDs.length : 0,
            itemBuilder: (context, index) {
              return Container(
                height: 50,
                color: Colors.yellow,
                child: Center(child: Text('past ride: ${pastRideIDs[index]}')),
              );
            }
          );
        }
      ) 
    );
    
  } 
}