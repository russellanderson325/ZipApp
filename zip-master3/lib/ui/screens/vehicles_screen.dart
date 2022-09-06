import "package:flutter/material.dart";
import 'package:zip/ui/screens/driver_settings_screen.dart';

class VehiclesScreen extends StatefulWidget {
  _VehiclesScreenState createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  VoidCallback onBackPress;
  @override
  void initState() {
    onBackPress = () {
      Navigator.of(context).pop();
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPress,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: const EdgeInsets.only(
            top: 23.0,
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
          ),
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.black,
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back,
                            color: Color.fromRGBO(255, 242, 0, 1.0)),
                        onPressed: onBackPress,
                      ),
                    ),
                    Text("   Vehicle Type",
                        style: TextStyle(
                            color: Color.fromRGBO(255, 242, 0, 1.0),
                            fontSize: 36.0,
                            fontWeight: FontWeight.w300,
                            fontFamily: "Bebas"))
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0),
              ),
              Text(
                  "  Please select vehicle type below. \nRates will vary by type",
                  style: TextStyle(
                      color: Color.fromRGBO(255, 242, 0, 1.0),
                      fontSize: 24.0,
                      fontWeight: FontWeight.w300,
                      fontFamily: "Poppins")),
            ],
          ),
        ),
      ),
    );
  }
}

class TopRectangle extends StatelessWidget {
  final color;
  final height;
  final width;
  final child;
  final posi;
  TopRectangle(
      {this.posi,
      this.child,
      this.color,
      this.height = 100.0,
      this.width = 500.0});

  build(context) {
    return Container(
      width: width,
      height: height,
      color: Color.fromRGBO(76, 86, 96, 1.0),
      child: child,
    );
  }
}
