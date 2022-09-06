import 'dart:collection';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import '../utils.dart';

class Driver {
  final String uid;
  final String firstName;
  final String lastName;
  final String profilePictureURL;
  final DateTime lastActivity;
  final String fcm_Token; // Firebase Cloud Messaging Token
  final bool isWorking;
  final bool isAvailable;
  final GeoFirePoint geoFirePoint;
  final String currentRideID;
  final daysOfWeek;
  final bool isOnBreak;


  Driver(
      {this.uid,
      this.firstName,
      this.lastName,
      this.lastActivity,
      this.profilePictureURL,
      this.geoFirePoint,
      this.fcm_Token,
      this.isWorking,
      this.isAvailable,
      this.currentRideID,
      this.daysOfWeek,
      this.isOnBreak
      });

  Map<String, Object> toJson() {
    return {
      'uid': uid,
      'firstName': firstName == null ? '' : firstName,
      'lastName': lastName == null ? '' : lastName,
      'lastActivity': lastActivity,
      'profilePictureURL': profilePictureURL == null ? '' : profilePictureURL,
      'geoFirePoint': geoFirePoint,
      'fcm_token': fcm_Token == null ? '' : fcm_Token,
      'isWorking': isWorking == null ? false : isWorking,
      'isAvailable': isAvailable == null ? false : isAvailable,
      'currentRideID': currentRideID == null ? '' : currentRideID,
      'daysOfWeek': daysOfWeek == null ? [''] : daysOfWeek,
      'isOnBreak': isOnBreak == null ? false : isOnBreak
    };
  }

  
  factory Driver.fromJson(Map<String, Object> doc) {
    Driver driver = new Driver(
        uid: doc['uid'],
        firstName: doc['firstName'],
        lastName: doc['lastName'],
        lastActivity: convertStamp(doc['lastActivity']),
        profilePictureURL: doc['profilePictureURL'],
        geoFirePoint: extractGeoFirePoint(doc['geoFirePoint']),
        fcm_Token: doc['fcm_token'],
        isWorking: doc['isWorking'],
        isAvailable: doc['isAvailable'],
        currentRideID: doc['currentRideID'],
        daysOfWeek: doc['daysOfWeek'], //daysOfWeekConvert(doc['daysOfWeek']),
        isOnBreak: doc['isOnBreak']);
        //totalHoursWorked: doc['totalHoursWorked']);
    return driver;
  }

  factory Driver.fromDocument(DocumentSnapshot doc) {
    return Driver.fromJson(doc.data());
  }

  static GeoFirePoint extractGeoFirePoint(Map<String, dynamic> pointMap) {
    GeoPoint point = pointMap['geopoint'];
    return GeoFirePoint(point.latitude, point.longitude);
  }

  // static List<int> daysOfWeekConvert(List workDays)  {
  //   Map dayConvert = new Map<String, int>();
  //   dayConvert['sunday'] = 0;
  //   dayConvert['monday'] = 1;
  //   dayConvert['tuesday'] = 2;
  //   dayConvert['wednesday'] = 3;
  //   dayConvert['thursday'] = 4;
  //   dayConvert['friday'] = 5;
  //   dayConvert['saturday'] = 6;
  
  //   for(var i=0;i<workDays.length;i++){
  //       String temp = workDays[i].toLowerCase();
  //       workDays[i] = dayConvert[temp];
  //   }
  //   return workDays;
  // }
}

class CurrentShift {
  final DateTime shiftStart;
  final DateTime shiftEnd;
  final DateTime startTime;
  final DateTime endTime;
  final int totalBreakTime;
  final int totalShiftTime;
  final DateTime breakStart;
  final DateTime breakEnd;

  CurrentShift(
    {
      this.shiftStart,
      this.shiftEnd,
      this.startTime,
      this.endTime,
      this.totalBreakTime,
      this.totalShiftTime,
      this.breakStart,
      this.breakEnd
    });
  

  Map<String, Object> toJson()  {
    return {
      'shiftStart': shiftStart == null ? '' : shiftStart,
      'shiftEnd' : shiftEnd == null ? '': shiftEnd,
      'startTime' : startTime == null ? '' : startTime,
      'endTime' : endTime == null ? '' : endTime,
      'totalBreakTime' : totalBreakTime == null ? '' : totalBreakTime,
      'totalShiftTime' : totalShiftTime == null ? '' : totalShiftTime,
      'breakStart': breakStart == null ? '' : breakStart,
      'breakEnd' : breakEnd == null ? '': breakEnd,
      
    };
  }

  factory CurrentShift.fromJson(Map<String, Object> doc)  {
    CurrentShift shift = new CurrentShift(
      shiftStart: convertStamp(doc['shiftStart']),
      shiftEnd: convertStamp(doc['shiftEnd']),
      startTime: convertStamp(doc['startTime']),
      endTime: convertStamp(doc['endTime']),
      totalBreakTime: doc['totalBreakTime'],
      totalShiftTime: doc['totalShiftTime'],
      breakStart: convertStamp(doc['breakStart']),
      breakEnd: convertStamp(doc['breakEnd']));
    return shift;
  }

  factory CurrentShift.fromDocument(DocumentSnapshot doc) {
      return CurrentShift.fromJson(doc.data());
  }
  

}