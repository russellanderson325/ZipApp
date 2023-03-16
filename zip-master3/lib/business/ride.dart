import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:zip/business/currentUser.dart';
import 'package:zip/business/drivers.dart';
import 'package:zip/business/location.dart';
import 'package:zip/business/user.dart';
import 'package:zip/models/driver.dart';
import 'package:zip/models/request.dart';
import 'package:zip/models/rides.dart';
import 'package:zip/ui/screens/main_screen.dart';

class RideService {
  static final RideService _instance = RideService._internal();
  final bool showDebugPrints = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DocumentReference rideReference;
  DocumentReference currentRidesReference;
  bool isSearchingForRide;
  bool goToNextDriver;
  Stream<Ride> rideStream;
  StreamSubscription rideSubscription;
  Ride ride;
  GeoFirePoint destination;
  GeoFirePoint pickup;
  Function updateUI;
  bool removeRide;
  double pickupRadius; 

  // Services
  Geoflutterfire geo = Geoflutterfire();
  LocationService locationService = LocationService();
  DriverService driverService = DriverService();
  UserService userService = UserService();

  // Subscriptions
  Stream<List<DocumentSnapshot>> nearbyDrivers;

  factory RideService() {
    return _instance;
  }

  RideService._internal() {
    print("RideService Created");
    rideReference = _firestore.collection('rides').doc(userService.userID);
    currentRidesReference = _firestore.collection('CurrentRides').doc('currentRides');
  }

  /// This function will start the ride process between a customer
  /// and a driver. It gets the current location of the user and
  /// passes it into the pickupAddress field of the ride document
  /// it also gets the destination address and passes it into the
  /// destinationAddress field.
  void startRide(double lat, double long, Function callBackFunction,
      double paymentPrice) async {
    _retrievePickupRadius();
    updateUI = callBackFunction;
    updateUI(BottomSheetStatus.searching);
    await _initializeRideInFirestore(lat, long);
    rideStream = rideReference
        .snapshots()
        .map((snapshot) => Ride.fromDocument(snapshot))
        .asBroadcastStream();
    rideSubscription = rideStream.listen(
        _onRideUpdate); // Listen to changes in ride Document and update service
    int timesSearched = 0;
    // OG
    // replace hard coded radius with radius from firestore
    double radius = 1; 
    print('retrieved pickup radius from admin settings: $pickupRadius'); 
    isSearchingForRide = true;
    goToNextDriver = false;

    /// Main searching loop, get 10 closest drivers within the radius and in order of distance,
    /// send a request, wait for an answer or timeout the request after 70 seconds. Continue until
    /// a driver accepts or if there are no drivers or no driver accepted, waits 60 seconds for
    /// availability to change and restart with a new list of drivers up to 5 times.
    while (isSearchingForRide) {
      List<Driver> nearbyDrivers =
          await driverService.getNearbyDriversList(pickupRadius);
      if (showDebugPrints)
        print("There are ${nearbyDrivers.length} drivers nearby.");
      if (nearbyDrivers.length > 0 && timesSearched < 6) {
        for (int i = 0; i < nearbyDrivers.length; i++) {
          if (isSearchingForRide) {
            Driver driver = nearbyDrivers[i];
            await rideReference.update({'status': 'WAITING'});
            await _sendRequestToDriver(driver, paymentPrice);
            if (showDebugPrints) print("Moving to next driver");
          }
        }
        timesSearched += 1;
      } else {
        timesSearched += 1;
        if (radius < pickupRadius)
          radius += 1;
        if (showDebugPrints) {
          print("No Drivers Found after $timesSearched tries, setting radius to $radius");
          print("Pickup Radius = $pickupRadius");
        }
        if (timesSearched > 5) {
          isSearchingForRide = false;
        } else {
          await Future.delayed(const Duration(seconds: 60));
        }
      }
    }
    if (ride.status == "IN_PROGRESS") {
      print("Ride is in progress with user: ${ride.driverName}");
    } else {
      await rideReference
          .update({'lastActivity': DateTime.now(), 'status': "CANCELED"});
    }
  }

  void cancelRide() async {
    isSearchingForRide = false;
    goToNextDriver = true;
    updateUI(BottomSheetStatus.closed);
    if (rideSubscription != null) rideSubscription.cancel();
    DocumentSnapshot myRide = await rideReference.get();
    if (myRide.exists) {
      print("Canceling ride");
      removeCurrentRider();
      rideReference.update({
        'lastActivity': DateTime.now(),
        'status': "CANCELED",
      });
    }
  }

  void endRide() async {
    rideSubscription.cancel();
    rideReference.update({
      'lastActivity': DateTime.now(),
      'status': "ENDED",
    });
  }

  /// Sends a request to the specified driver using the service's current pickup and destination GeoFirePoints.
  /// Sets a 60 second timeout on the request for the driver to answer by, and waits for 70 seconds to get a responce
  /// before timing out locally.
  Future<void> _sendRequestToDriver(Driver driver, double paymentPrice) async {
    String pAmount = paymentPrice.toString();
    if (showDebugPrints) print("Sending request to ${driver.uid}");
    _firestore
        .collection('drivers')
        .doc(driver.uid)
        .collection('requests')
        .doc(userService.userID)
        .set(Request(
                id: userService.userID,
                name: "${userService.user.firstName}",
                destinationAddress: destination,
                pickupAddress: pickup,
                price: "\$" + pAmount,
                photoURL: userService.user.profilePictureURL,
                timeout: Timestamp.fromMillisecondsSinceEpoch(
                    Timestamp.now().millisecondsSinceEpoch + 60000))
            .toJson());
    int iterations = 0;
    // Timeout loop for current request
    while (!goToNextDriver) {
      if (showDebugPrints)
        print("Request to ${driver.uid} sent $iterations seconds ago.");
      await Future.delayed(const Duration(seconds: 1));
      iterations += 1;
      if (iterations >= 70) goToNextDriver = true;
    }
    goToNextDriver = false;
  }

  void _retrievePickupRadius() async { 
    DocumentReference adminSettingsRef = _firestore.collection('config_settings').doc('admin_settings'); 
    pickupRadius = (await adminSettingsRef.get()).get('PickupRadius').toDouble(); 
  }  

  // This method is attached to the ride stream and run every time the ride document in firestore changes.
  // Use it to keep the UI state in sync and the local Ride object updated.
  void _onRideUpdate(Ride updatedRide) {
    if (updatedRide.status != null) {
      bool wasRideAlreadyCanceled = false;
      if (ride != null && ride.status != null) {
        if (updatedRide.status == "CANCELED" && ride.status == "CANCELED")
          wasRideAlreadyCanceled = true;
      }
      ride = updatedRide;
      switch (updatedRide.status) {
        case 'CANCELED':
          removeRide = true;
          isSearchingForRide = false;
          updateUI(BottomSheetStatus.closed);
          if (!wasRideAlreadyCanceled) cancelRide();
          print("Ride is canceled");
          break;
        case 'IN_PROGRESS':
          isSearchingForRide = false;
          goToNextDriver = true;
          updateUI(BottomSheetStatus.rideDetails);
          print("Ride is now IN_PROGRESS");
          break;
        case 'INITIALIZING':
          updateUI(BottomSheetStatus.searching);
          print("Ride is initializing");
          break;
        case 'SEARCHING':
          goToNextDriver = true;
          updateUI(BottomSheetStatus.searching);
          print("Moving to next driver and setting ride back to searching.");
          break;
        case 'WAITING':
          print("Waiting on response from driver.");
          break;
        case 'ENDED':
          removeRide = true;
          isSearchingForRide = false;
          goToNextDriver = false;
          updateUI(BottomSheetStatus.closed);
          print("Ride has ended.");
          removeCurrentRider();
          break;
        default:
      }
      if (showDebugPrints)
        print(
            "Updated ride status from ${ride.status} to ${updatedRide.status}");
    }
  }

  Future<void> _initializeRideInFirestore(double lat, double long) async {
    destination = geo.point(latitude: lat, longitude: long);
    pickup = locationService.getCurrentGeoFirePoint();
    DocumentSnapshot myRide = await rideReference.get();
    addCurrentRider();
    if (!myRide.exists) {
      // Create new ride document for the user
      await rideReference.set({
        'uid': userService.userID,
        'userName': userService.user.firstName,
        'userPhotoURL': userService.user.profilePictureURL,
        'drid': '',
        'lastActivity': DateTime.now(),
        'pickupAddress': pickup.data,
        'destinationAddress': destination.data,
        'status': "INITIALIZING",
      });
      addCurrentRider();
    } else {
      // Update user's ride document
      await rideReference.update({
        'uid': userService.userID,
        'userName': userService.user.firstName,
        'userPhotoURL': userService.user.profilePictureURL,
        'drid': '',
        'lastActivity': DateTime.now(),
        'pickupAddress': pickup.data,
        'destinationAddress': destination.data,
        'status': "INITIALIZING"
      });
    }
  }

  Future<void> addCurrentRider() async {
    // current Number of rides in "CurrentRides" collection
    int currentNumberOfRides =
        (await currentRidesReference.get()).get('ridesGoingNow');
    await currentRidesReference
        .set({'ridesGoingNow': currentNumberOfRides + 1});
  }

  Future<void> removeCurrentRider() async {
    // current Number of rides in "CurrentRides" collection
    int currentNumberOfRides =
        (await currentRidesReference.get()).get('ridesGoingNow');
    await currentRidesReference
        .set({'ridesGoingNow': currentNumberOfRides - 1});
  }

  Stream<Ride> getRideStream() {
    return rideReference.snapshots().map((snapshot) {
      return Ride.fromDocument(snapshot);
    });
  }
}
