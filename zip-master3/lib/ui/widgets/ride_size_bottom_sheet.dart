import 'package:flutter/material.dart';
import 'package:zip/models/rides.dart';
import 'package:zip/business/drivers.dart';
import 'package:zip/business/user.dart';
import 'package:zip/business/ride.dart';

class RideDetails extends StatelessWidget {
  final bool driver;
  final Ride ride;
  final DriverService driverService = DriverService();
  final UserService userService = UserService();
  final RideService rideService = RideService();
  double screenHeight, screenWidth;

  RideDetails({
    @required this.driver,
    @required this.ride,
  });

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
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
                      child: Image.asset(
                          'assets/profile_default.png') //driver ? Image.network(ride.driverPictureURL) : Image.network(ride.userPictureURL),
                      ),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceAround,
              ),
              Row(
                children: <Widget>[
                  driver ? Text(ride.userName) : Text(ride.driverName),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceAround,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    FloatingActionButton.extended(
                      backgroundColor: Color.fromRGBO(255, 242, 0, 1.0),
                      onPressed: () {
                        _cancelRide();
                      },
                      label: Text("cancel ",
                          style:
                              TextStyle(fontSize: 16.0, color: Colors.black)),
                      icon: Icon(Icons.cancel),
                    )
                  ])
            ],
          ),
        ],
      ),
    );
  }

  void _cancelRide() {
    rideService.cancelRide();
  }
}
