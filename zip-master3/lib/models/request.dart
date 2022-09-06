import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class Request {
  final String id;
  final GeoFirePoint destinationAddress;
  final GeoFirePoint pickupAddress;
  final String price;
  final String name;
  final String photoURL;
  final Timestamp timeout;

  Request(
      {this.id,
      this.destinationAddress,
      this.pickupAddress,
      this.price,
      this.name,
      this.photoURL,
      this.timeout});

  Map<String, Object> toJson() {
    return {
      'id': id,
      'destinationAddress': destinationAddress.data,
      'pickupAddress': pickupAddress.data,
      'price': price,
      'name': name,
      'photoURL': photoURL,
      'timeout': timeout
    };
  }

  factory Request.fromJson(Map<String, Object> doc) {
    Request ride = new Request(
        id: doc['id'],
        destinationAddress: extractGeoFirePoint(doc['destinationAddress']),
        pickupAddress: extractGeoFirePoint(doc['pickupAddress']),
        price: doc['price'],
        name: doc['name'],
        photoURL: doc['photoURL'],
        timeout: doc['timeout']);
    return ride;
  }

  factory Request.fromDocument(DocumentSnapshot doc) {
    return Request.fromJson(doc.data());
  }

  static GeoFirePoint extractGeoFirePoint(Map<String, dynamic> pointMap) {
    GeoPoint point = pointMap['geopoint'];
    return GeoFirePoint(point.latitude, point.longitude);
  }
}
