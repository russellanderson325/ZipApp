import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:zip/business/location.dart';
import 'package:zip/business/user.dart';
import 'package:zip/models/driver.dart';
import 'package:zip/models/request.dart';
import 'package:zip/models/rides.dart';
import 'package:zip/models/user.dart';
import 'package:zip/ui/screens/driver_main_screen.dart';
import 'package:intl/intl.dart';

class DriverService {
  static final DriverService _instance = DriverService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final bool showDebugPrints = true;
  Geoflutterfire geo = Geoflutterfire();
  LocationService locationService = LocationService();
  StreamSubscription<Position> locationSub;
  CollectionReference driversCollection;
  DocumentReference driverReference;
  CollectionReference shiftCollection;
  DocumentReference shiftReference;
  UserService userService = UserService();
  List<Driver> nearbyDriversList;
  Stream<List<Driver>> nearbyDriversListStream;
  GeoFirePoint myLocation;
  Driver driver;
  CurrentShift currentShift;
  StreamSubscription<Driver> driverSub;
  // Request specific variables
  CollectionReference requestCollection;
  StreamSubscription<Request> requestSub;
  Stream<Request> requestStream;
  Request currentRequest;
  // Ride specific varaibles
  Stream<Ride> rideStream;
  StreamSubscription<Ride> rideSub;
  Ride currentRide;
  //Shift specific variables
  String shiftuid;

  Function uiCallbackFunction;

  HttpsCallable driverClockInFunction =
      CloudFunctions.instance.getHttpsCallable(
    functionName: 'driverClockIn',
  );

  HttpsCallable driverClockOutFunction =
      CloudFunctions.instance.getHttpsCallable(
    functionName: 'driverClockOut',
  );

  HttpsCallable driverStartBreakFunction =
      CloudFunctions.instance.getHttpsCallable(
    functionName: 'driverStartBreak',
  );

  HttpsCallable driverEndBreakFunction =
      CloudFunctions.instance.getHttpsCallable(
    functionName: 'driverEndBreak',
  );

  HttpsCallable overrideClockInFunction =
      CloudFunctions.instance.getHttpsCallable(
    functionName: 'overrideClockIn',
  );

  factory DriverService() {
    return _instance;
  }

  // TODO: Update to use user.isDriver before initializing since only driver users will need the service.

  DriverService._internal() {
    print("DriverService Created");
    driversCollection = _firestore.collection('drivers');
    driverReference = driversCollection.doc(userService.userID);
    requestCollection = driverReference.collection('requests');
    shiftCollection = driverReference.collection('shifts');
    shiftuid = DateFormat('MMddyyyy').format(DateTime.now());
  }

  Future<bool> setupService() async {
    await _updateDriverRecord();
    this.driverSub = driverReference
        .snapshots(includeMetadataChanges: true)
        .map((DocumentSnapshot snapshot) {
      return Driver.fromDocument(snapshot);
    }).listen((driver) {
      this.driver = driver;
    });
    if (locationSub != null) locationSub.cancel();
    locationSub = locationService.positionStream.listen(_updatePosition);
    print("DriverService setup");
    return true;
  }

  void _updatePosition(Position pos) {
    if (driver != null) {
      if (driver.isWorking) {
        this.myLocation =
            geo.point(latitude: pos.latitude, longitude: pos.longitude);
        print("Updating geoFirePoint to: ${myLocation.toString()}");
        // TODO: Check for splitting driver and position into seperate documents in firebase as an optimization
        driverReference.update(
            {'lastActivity': DateTime.now(), 'geoFirePoint': myLocation.data});
      }
    }
  }

  Future<void> startDriving(Function callback) async {
    uiCallbackFunction = callback;
    uiCallbackFunction(DriverBottomSheetStatus.searching);
    requestStream = requestCollection
        .snapshots()
        .map((event) => event.docs
            .map((e) => Request.fromDocument(e))
            .toList()
            .elementAt(0))
        .asBroadcastStream();
    driverReference.update({
      'lastActivity': DateTime.now(),
      'geoFirePoint': locationService.getCurrentGeoFirePoint().data,
      'isAvailable': true,
      //'isWorking': true
    });
    requestSub = requestStream.listen((request) {
      if (request.name != null) _onRequestRecieved(request);
    });
    await Future.delayed(const Duration(milliseconds: 500));
  }

  _onRequestRecieved(Request req) {
    print(
        "Request recieved from ${req.name} recieved, timeout at ${req.timeout}");
    currentRequest = req;
    var seconds = (req.timeout.seconds - Timestamp.now().seconds);
    Future.delayed(Duration(seconds: seconds)).then((value) {
      print("Request recieved from ${req.name} timed out");
      declineRequest(req.id);
    });
    uiCallbackFunction(DriverBottomSheetStatus.confirmation);
  }

  Future<void> declineRequest(String requestID) async {
    print("Declining request: $requestID");
    DocumentSnapshot requestRef = await requestCollection.doc(requestID).get();
    if (requestRef.exists) {
      print("Request $requestID exists and will be deleted.");
      await _firestore
          .collection('rides')
          .doc(requestID)
          .update({'status': "SEARCHING"});
      await requestCollection.doc(requestID).delete();
      uiCallbackFunction(DriverBottomSheetStatus.searching);
    }
    print("Request is already deleted"); // TODO: Delete
    _firestore.collection('rides').doc(requestID).get().then((value) => print(
        "Request status is ${value.data()['status']}, should be 'WAITING'"));
  }

  Future<void> acceptRequest(String requestID) async {
    print("Accepting request: $requestID");
    DocumentSnapshot requestRef =
        await _firestore.collection('rides').doc(requestID).get();
    rideStream = _firestore
        .collection('rides')
        .doc(requestID)
        .snapshots()
        .map((event) => Ride.fromDocument(event));
    rideSub = rideStream.listen(_onRideUpdate);
    if (requestRef.exists) {
      print("Request $requestID exists and will be deleted after acceptance.");
      await driverReference
          .update({'isAvailable': false, 'currentRideID': requestID});
      await _firestore.collection('rides').doc(requestID).update({
        'status': "IN_PROGRESS",
        'drid': userService.userID,
        'driverName': userService.user.firstName,
        'driverPhotoURL': userService.user.profilePictureURL
      });
      await requestCollection.doc(requestID).delete();
    }
  }

  void stopDriving() {
    driverReference.update({
      'lastActivity': DateTime.now(),
      // 'isAvailable': false,
      // 'isWorking': false,
      'currentRideID': ''
    });
    if (requestSub != null) requestSub.cancel();
    if (driverSub != null) driverSub.cancel();
    if (rideSub != null) rideSub.cancel();
    if (uiCallbackFunction != null)
      uiCallbackFunction(DriverBottomSheetStatus.closed);
  }

  void completeRide() async {
    if (currentRide.status != "ENDED") {
      String rideID = driver.currentRideID;
      _addRideToDriver(rideID);
      _addRideToRider(rideID);

      await _firestore.collection('rides').doc(driver.currentRideID).update({
        'lastActivity': DateTime.now(),
        'status': 'ENDED',
        'drid': this.driver.uid,
        'driverName': "${this.driver.firstName} ${this.driver.lastName}",
        'driverPhotoURL': this.driver.profilePictureURL
      });
    }
    print(this.driver.uid);
    stopDriving();
  }

  void _addRideToDriver(rideID) async {
    print('Adding ride $rideID to driver list of past drives');
    var rideObj = await _firestore.collection('rides').doc(rideID).get();
    var rideDriver = rideObj.get('drid');
    
    var driverPastDrives = (await _firestore.collection('users').doc(rideDriver).get()).get('pastDrives');
    driverPastDrives.add(driver.currentRideID);
    await _firestore.collection('users').doc(rideDriver).update({
      'pastDrives': driverPastDrives
    });
  }

  void _addRideToRider(rideID) async {
    print('Adding ride $rideID to rider list of past rides');
    var rideObj = await _firestore.collection('rides').doc(rideID).get();
    var rideRider = rideObj.get('uid');
    var riderPastRides = (await _firestore.collection('users').doc(rideRider).get()).get('pastRides');
    riderPastRides.add(rideID);
    await _firestore.collection('users').doc(rideRider).update({
      'pastRides': riderPastRides
    });
  }

  void cancelRide() async {
    if (currentRide.status != "CANCELED") {
      await _firestore.collection('rides').doc(driver.currentRideID).update({
        'lastActivity': DateTime.now(),
        'status': 'CANCELED',
        'drid': '',
        'driverName': '',
        'driverPhotoURL': ''
      });
    }
    stopDriving();
  }

  void _onRideUpdate(Ride updatedRide) {
    if (updatedRide != null) {
      if (showDebugPrints)
        print("Updated ride status to ${updatedRide.status}");
      currentRide = updatedRide;
      switch (updatedRide.status) {
        case 'CANCELED':
          uiCallbackFunction(DriverBottomSheetStatus.closed);
          cancelRide();
          if (showDebugPrints) print("Ride is canceled");
          break;
        case 'IN_PROGRESS':
          uiCallbackFunction(DriverBottomSheetStatus.rideDetails);
          if (showDebugPrints) print("Ride is now IN_PROGRESS");
          break;
        case 'ENDED':
          uiCallbackFunction(DriverBottomSheetStatus.closed);
          if (showDebugPrints) print("Ride has ended.");
          break;
        default:
      }
    }
  }

  Stream<Driver> getDriverStream() {
    return driverReference
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      return Driver.fromDocument(snapshot);
    });
  }

  Stream<CurrentShift> getCurrentShift() {
    return shiftReference
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      return CurrentShift.fromDocument(snapshot);
    });
  }

  // TODO: Audit
  Stream<List<Driver>> getNearbyDriversStream() {
    if (nearbyDriversListStream == null) {
      nearbyDriversListStream = geo
          .collection(collectionRef: driversCollection)
          .within(center: myLocation, radius: 50, field: 'geoFirePoint')
          .map((snapshots) =>
              snapshots.map((e) => Driver.fromDocument(e)).take(10).toList());
    }
    return nearbyDriversListStream;
  }

  Future<List<Driver>> getNearbyDriversList(double radius) async {
    GeoFirePoint centerPoint = locationService.getCurrentGeoFirePoint();
    Query collectionReference =
        _firestore.collection('drivers').where('isAvailable', isEqualTo: true);

    Stream<List<Driver>> stream = geo
        .collection(collectionRef: collectionReference)
        .within(
            center: centerPoint,
            radius: radius,
            field: 'geoFirePoint',
            strictMode: false)
        .map((event) =>
            event.map((e) => Driver.fromDocument(e)).take(10).toList());

    List<Driver> nearbyDrivers = await stream.first;
    nearbyDrivers.forEach((driver) {
      print("${driver.firstName} is available and in range.");
    });
    return nearbyDrivers;
  }

  _updateDriverRecord() async {
    DocumentSnapshot myDriverRef = await driverReference.get();
    if (!myDriverRef.exists) {
      driversCollection.doc(userService.userID).set({
        'uid': userService.userID,
        'firstName': userService.user.firstName,
        'lastName': userService.user.lastName,
        'profilePictureURL': userService.user.profilePictureURL,
        'geoFirePoint': locationService.getCurrentGeoFirePoint().data,
        'lastActivity': DateTime.now(),
        'isAvailable': false,
        'isWorking': false,
        'isOnBreak': false,
        'daysOfWeek': [" "]
      });
    } else {
      // TODO: Get rid of once server is constantly checking for abandoned drivers
      stopDriving();
    }
  }

  Future<List> clockIn() async {
    String message;
    bool override;
    try {
      HttpsCallableResult result =
          await driverClockInFunction.call(<String, dynamic>{
        'daysOfWeek': this.driver.daysOfWeek,
        'isWorking': this.driver.isWorking,
        'driveruid': this.driver.uid,
        'shiftuid': shiftuid
      });

      //grab return values
      message = result.data['message'].toString();
      override = result.data['override'];

      try {
        driverReference.update({'isWorking': result.data['isWorking']});
      } catch (e) {
        print("Error setting is Working");
      }
    } catch (e) {
      print('Error clocking in');
    }
    return [message, override];
  }

  Future<String> clockOut() async {
    String message;
    print(this.shiftuid);
    try {
      HttpsCallableResult result = await driverClockOutFunction
          .call(<String, dynamic>{
        'driveruid': this.driver.uid,
        'shiftuid': this.shiftuid
      });

      message = (result.data['message']).toString();
    } catch (e) {
      print("Error clocking out");
    }
    return message;
  }

  Future<String> startBreak() async {
    String message;
    try {
      HttpsCallableResult result = await driverStartBreakFunction
          .call(<String, dynamic>{
        'driveruid': this.driver.uid,
        'shiftuid': this.shiftuid
      });

      message = (result.data['message']).toString();
    } catch (e) {
      print("Error starting break");
    }
    return message;
  }

  Future<String> endBreak() async {
    String message;
    try {
      HttpsCallableResult result = await driverEndBreakFunction
          .call(<String, dynamic>{
        'driveruid': this.driver.uid,
        'shiftuid': this.shiftuid
      });

      message = (result.data['message']).toString();
    } catch (e) {
      print("Error starting break");
    }
    return message;
  }

  Future<String> overrideClockIn() async {
    String message;
    try {
      HttpsCallableResult result = await overrideClockInFunction
          .call(<String, dynamic>{
        'driveruid': this.driver.uid,
        'shiftuid': shiftuid
      });

      message = (result.data['message']).toString();
    } catch (e) {
      print("Error overriding clock in");
    }
    return message;
  }
}
