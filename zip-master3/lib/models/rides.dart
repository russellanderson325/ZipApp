import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class Ride {
  final String uid;
  final String userPictureURL;
  final String userName;
  final String drid;
  final String driverPictureURL;
  final String driverName;
  final GeoFirePoint destinationAddress;
  final GeoFirePoint pickupAddress;
  final String status;

  Ride(
      {
      this.uid,
      this.userName,
      this.userPictureURL,
      this.drid,
      this.driverName,
      this.driverPictureURL,
      this.destinationAddress,
      this.pickupAddress,
      this.status});

  Map<String, Object> toJson() {
    return {
      'uid': uid,
      'userName': userName,
      'userPictureURL': userPictureURL == null ? '' : userPictureURL,
      'drid': drid == null ? '' : drid,
      'driverName': driverName == null ? '' : driverName,
      'driverPictureURL': driverPictureURL == null ? '' : driverPictureURL,
      'destinationAddress': destinationAddress,
      'pickupAddress': pickupAddress,
      'status': status
    };
  }

  factory Ride.fromJson(Map<String, Object> doc) {
    print('doc = ');
    print(doc);
    Ride ride = new Ride(
        uid: doc['uid'],
        userName: doc['userName'],
        userPictureURL: doc['userPictureURL'],
        drid: doc['drid'],
        driverName: doc['driverName'],
        driverPictureURL: doc['driverPictureURL'],
        destinationAddress: extractGeoFirePoint(doc['destinationAddress']),
        pickupAddress: extractGeoFirePoint(doc['pickupAddress']),
        status: doc['status']);
    return ride;
  }

  factory Ride.fromDocument(DocumentSnapshot doc) {
    return Ride.fromJson(doc.data());
  }

  static GeoFirePoint extractGeoFirePoint(Map<String, dynamic> pointMap) {
    GeoPoint point = pointMap['geopoint'];
    return GeoFirePoint(point.latitude, point.longitude);
  }
}
