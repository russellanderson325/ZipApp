import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

DateTime convertStamp(Timestamp _stamp) {

  if (_stamp != null) {

    if (Platform.isIOS) {
      return _stamp.toDate();
    } else {
      return Timestamp(_stamp.seconds, _stamp.nanoseconds).toDate();
    }

  } else {
    return null;
  }
}