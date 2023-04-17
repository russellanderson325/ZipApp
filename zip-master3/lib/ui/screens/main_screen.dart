import 'dart:io' show Platform;
import 'dart:async';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
//import 'package:location/location.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:zip/CustomIcons/my_flutter_app_icons.dart';
import 'package:zip/business/auth.dart';
import 'package:zip/business/drivers.dart';
import 'package:zip/business/ride.dart';
import 'package:zip/business/location.dart';
import 'package:zip/business/notifications.dart';
import 'package:zip/business/user.dart';
import 'package:zip/models/user.dart';
import 'package:zip/models/driver.dart';
import 'package:zip/models/rides.dart';
import 'package:zip/models/request.dart';
import 'package:zip/services/payment.dart';
import 'package:zip/ui/screens/settings_screen.dart';
import 'package:zip/ui/screens/previous_trips_screen.dart';
import 'package:zip/ui/screens/promos_screen.dart';
import 'package:zip/ui/screens/welcome_screen.dart';
import 'package:zip/ui/screens/driver_main_screen.dart';
import 'package:zip/ui/widgets/ride_bottom_sheet.dart';
import 'package:zip/ui/screens/driver_verification_screen.dart';
import 'package:zip/ui/screens/payment_history_screen.dart';
import 'package:zip/ui/screens/payment_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:zip/ui/screens/sign_in_screen.dart';
import 'package:zip/business/payment.dart' as paymentDetails;
import 'package:geolocator/geolocator.dart';
//import 'package:firebase_auth/firebase_auth.dart';

enum BottomSheetStatus {
  closed,
  welcome,
  setPin,
  size,
  confirmation,
  searching,
  rideDetails
}

class MainScreen extends StatefulWidget {
  /*final GlobalKey<MapScreen> mapScaffoldKey;
  MainScreen(this.mapScaffoldKey);*/
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  //this is the global key used for the scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey<MapScreen> mapScaffoldKey;
  double screenHeight, screenWidth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  VoidCallback onBackPress;

  ///these are the services that this screen uses.
  ///you can call these services anywhere in this class.
  final UserService userService = UserService();
  final LocationService locationService = LocationService();
  final RideService rideService = RideService();
  final NotificationService notificationService = NotificationService();
  final fireBaseUser = auth.FirebaseAuth.instance.currentUser;

  ///these are used to manipulate the textfield
  ///so that you can make sure the text is in sync
  ///with the prediction.
  final search_controller = TextEditingController();
  final FocusNode search_node = FocusNode();
  String address = '';
  LatLng pinDestination;
  final paymentService = paymentDetails.Payment();
  bool zipxl;
  double price;

  bool checkBoxValue = false;
  bool _checked = false;
  bool taccepted = true;
  bool paccepted = true;

  bool pinDropDestination = false;
  //bool _menuVisible;
  //bool termsSelect;

  ///maps api key used for the prediction
  final String map_key = "AIzaSyDsPh6P9PDFmOqxBiLXpzJ1sW4kx-2LN5g";

  ///these are for translating place details into coordinates
  ///used for creating a ride in the database
  final GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: 'AIzaSyDsPh6P9PDFmOqxBiLXpzJ1sW4kx-2LN5g');
  PlacesDetailsResponse details;

  ///these are used for controlling the bottomsheet
  ///and other things to do with creating a ride.
  BottomSheetStatus bottomSheetStatus;

  ///this is used for toggle visibility for Drop A Pin icon
  bool showDropPin;

  ///these are for the toggle in the top left part of the
  ///screen.
  static bool _isCustomer = true;
  static Text customerText = Text("Customer",
      softWrap: true,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.0,
        fontFamily: "Bebas",
        fontWeight: FontWeight.w600,
      ));

  ///these are for the toggle in the bottom left part of the
  ///screen.
  static bool _isLight = true;
  static Text MapStyleText = Text("Light Mode",
      softWrap: false,
      style: TextStyle(
        color: Colors.black,
        fontSize: 16.0,
        fontFamily: "Bebas",
        fontWeight: FontWeight.w600,
      ));

  ///this is text for the sidebar
  static Text viewProfileText = Text("View Profile",
      softWrap: true,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.0,
        fontFamily: "Bebas",
        fontWeight: FontWeight.w600,
      ));
  @override
  Future<void> initState() {
    super.initState();
    mapScaffoldKey = GlobalKey();
    bottomSheetStatus = BottomSheetStatus.welcome;
    showDropPin = false;
    onBackPress = () {
      Navigator.of(context).maybePop();
    };
    _checkLegal();
  }

  //This method checks to see if the user in firebase has accepted the TC and Privacy Policy
  void _checkLegal() async {
    //Calls the reference documents for all users
    DocumentReference termsandConditionsReference =
        _firestore.collection('users').doc(userService.user.uid);
    bool acceptedTerms =
        //calls the specifcic document of the users
        (await termsandConditionsReference.get()).get('acceptedtc');

    //If the terms and conditions is not accepted show the alert dialog
    if (acceptedTerms == false) {
      _termsAlert(context);
    } else {
      _showAlert(context);
    }
  }

  // user defined function
  void _privacyAlert(BuildContext context) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(
            " Privacy Policy for Mobile",
            style: TextStyle(color: Color.fromRGBO(255, 242, 0, 1.0)),
          ),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Column(
                //Row
                children: <Widget>[
                  Text(
                    "Article 1 - DEFINITIONS:\n\na) APPLICABLE MOBILE APPLICATION: This Privacy Policy will refer to and be applicable to the Mobile App listed above, which shall hereinafter be referred to as \"Mobile App.\"\n\nb) EFFECTIVE DATE: \"Effective Date\" means the date this Privacy Policy comes into force and effect.\n\nc) PARTIES: The parties to this privacy policy are the following data controller: Russell Anderson (\"Data Controller\") and you, as the user of this Mobile App. Hereinafter, the parties will individually be referred to as \"Party\" and collectively as \"Parties.\"\n\nd) DATA CONTROLLER: Data Controller is the publisher, owner, and operator of the Mobile App and is the Party responsible for the collection of information described herein. Data Controller shall be referred to either by Data Controller's name or \"Data Controller,\" as listed above. If Data Controller or Data Controller's property shall be referred to through first-person pronouns, it shall be through the use of the following: us, we, our, ours, etc\n\ne) YOU: Should you agree to this Privacy Policy and continue your use of the Mobile App, you will be referred to herein as either you, the user, or if any second-person pronouns are required and applicable, such pronouns as \“your\", \"yours\", etc.\n\nf) SERVICES: \"Services\" means any services that we make available for sale on the Mobile App.\n\ng) PERSONAL DATA: \"Personal DATA\" means personal data and information that we obtain from you in connection with your use of the Mobile App that is capable of identifying you in any manner.\n\n" +
                        "Article 2 - GENERAL INFORMATION:\n\nThis privacy policy (hereinafter \"Privacy Policy\") describes how we collect and use the Personal Data that we receive about you, as well as your rights in relation to that Personal Data, when you visit our Mobile App or use our Services.\n\nThis Privacy Policy does not cover any information that we may receive about you through sources other than the use of our Mobile App. The Mobile App may link out to other websites or mobile applications, but this Privacy Policy does not and will not apply to any of those linked websites or applications.\n\nWe are committed to the protection of your privacy while you use our Mobile App.\n\nBy continuing to use our Mobile App, you acknowledge that you have had the chance to review and consider this Privacy Policy, and you acknowledge that you agree to it. This means that you also consent to the use of your information and the method of disclosure as described in this Privacy Policy. If you do not understand the Privacy Policy or do not agree to it, then you agree to immediately cease your use of our Mobile App.\n\n" +
                        "Article 3 -CONTACT AND DATA PROTECTION OFFICER:\n\nThe Party responsible for the processing of your personal data is as follows: Russell Anderson. The Data Controller may be contacted as follows:\n\ninfo@zipgameday.com\n\nThe Data Controller and operator of the Mobile App are one and the same.\n\nThe Data Protection Officer is as follows: Paxton DeLamar. The Data Protection Officer may be contacted as follows:\n\npaxton.delamar@zipgameday.com\n\n" +
                        "Article 4 - LOCATION:\n\nPlease be advised the data processing activities take place in the United States, outside the European Economic Area. Data may also be transferred to companies within the United States, but will only be done so in a manner that complies with the EU's General Data Protection Regulation or GDPR. The location where the data processing activities take place is as follows:\n\n300 E South Street\n\nUnit 3005\n\nOrlando, FL 32801\n\nArticle 5 - MODIFICATIONS AND REVISIONS:\n\nWe reserve the right to modify, revise, or otherwise amend this Privacy Policy at any time and in any manner. If we do so, however, we will notify you and obtain your consent to the change in processing. Unless we specifically obtain your consent, any changes to the Privacy Policy will only impact the information collected on or after the date of the change. It is also your responsibility to periodically check this page for any such modification, revision or amendment.\n\n" +
                        "Article 6 - THE PERSONAL DATA WE RECEIVE FROM YOU:\n\nDepending on how you use our Mobile App, you will be subject to different types of Personal Data collected and different manners of collection:\n\na) Registered users: You, as a user of the Mobile App, may be asked to register in order to use the Mobile App or to purchase the Services available for sale.\n\nDuring the process of your registration, we will collect some of the following Personal Data from you through your voluntary disclosure:\n\nFirst Name\n\nLast Name\n\nMailing Address\n\nEmail Address\n\nPhone Number\n\nEmployer\n\nJob Title\n\nAge\n\nRace\n\nGender\n\nReligion\n\nPolitical Affiliation\n\nHousehold Income\n\nPersonal Data may be asked for in relation to:\n\nI) Interaction with our representatives in any way\n\nII) making purchases\n\nIII) receiving notifications by text message or email about marketing\n\nIV) receiving general emails from us\n\nBy undergoing the registration process, you consent to us collecting your Personal Data, including the Personal Data described in this clause, as well as storing, using or disclosing your Personal Data in accordance with this Privacy Policy.\n\n" +
                        "b) Unregistered users: If you are a passive user of the Mobile App and do not register for any purchases or other service, you may still be subject to certain passive data collection (\"Passive Data Collection\"). Such Passive Data Collection may include through cookies, as described below, IP address information, location information, and certain browser data, such as history and/or session information.\n\nc) All users: The Passive Data Collection that applies to Unregistered users shall also apply to all other users and/or visitors of our Mobile App.\n\nd) Sales & Billing Information: In order to purchase any of the services on the Mobile App, you will be asked to provide certain credit information, billing address information, and possibly additional specific information so that you may be properly charged for your purchases. This payment and billing information may be stored for the following period: 1 Year. If so, it will be used exclusively to assist you with making future purchases with us.\n\ne) Related Entities: We may share your Personal Data, including Personal Data that identifies you personally, with any of our parent companies, subsidiary companies, affiliates or other trusted related entities.\n\nHowever, we only share your Personal Data with a trusted related entity if that entity agrees to our privacy standards as set out in this Privacy Policy and to treat your Personal Data in the same manner that we do.\n\nf) Email Marketing: You may be asked to provide certain Personal Data, such as your name and email address, for " +
                        "the purpose of receiving email marketing communications. This information will only be obtained through your voluntary disclosure and you will be asked to affirmatively opt-in to email marketing communications.\n\ng) User Experience: From time to time we may request information from you to assist us in improving our Mobile App, and the Services we sell, such as demographic information or your particular preferences.\n\nh) Combined or Aggregated Information: We may combine or aggregate some of your Personal Data in order to better serve you and to better enhance and update our Mobile App for your and other consumers' use.\n\nWe may also share such aggregated information with others, but only if that aggregated information does not contain any Personal Data.\n\n" +
                        "Article 7 - THE PERSONAL DATA WE RECEIVE AUTOMATICALLY:\n\nCookies: We may collect information from you through automatic tracking systems (such as information about your browsing preferences) as well as through information that you volunteer to us (such as information that you provide during a registration process or at other times while using the Mobile App, as described above).\n\nFor example, we use cookies to make your browsing experience easier and more intuitive: cookies are small strings of text used to store some information that may concern the user, his or her preferences or the device they are using to access the internet (such as a computer, tablet, or mobile phone). Cookies are mainly used to adapt the operation of the site to your expectations, offering a more personalized browsing experience and memorizing the choices you made previously.\nA cookie consists of a reduced set of data transferred to your browser from a web server and it can only be read by the server that made the transfer. This is not executable code and does not transmit viruses.\n\nCookies do not record or store any Personal Data. If you want, you can prevent the use of cookies, but then you may not be able to use our Mobile App as we intend. To proceed without changing the options related to cookies, simply continue to use our Mobile " +
                        "App.\n\nTechnical cookies: Technical cookies, which can also sometimes be called HTML cookies, are used for navigation and to facilitate your access to and use of the site. They are necessary for the transmission of communications on the network or to supply services requested by you. The use of technical cookies allows the safe and efficient use of the site.\n\nYou can manage or request the general deactivation or cancelation of cookies through your browser. If you do this though, please be advised this action might slow down or prevent access to some parts of the site.\n\nCookies may also be retransmitted by an analytics or statistics provider to collect aggregated information on the number of users and how they visit the Mobile App. These are also considered technical cookies when they operate as described.\n\nTemporary session cookies are deleted automatically at the end of the browsing session - these are mostly used to identify you and ensure that you don't have to log in each time - whereas permanent cookies remain active longer than just one particular session.\n\nThird-party cookies: We may also utilize third-party cookies, which are cookies sent by a third-party " +
                        "to your computer. Permanent cookies are often third-party cookies. The majority of third-party cookies consist of tracking cookies used to identify online behavior, understand interests and then customize advertising for users.\n\nThird-party analytical cookies may also be installed. They are sent from the domains of the aforementioned third parties external to the site. Third-party analytical cookies are used to detect information on user behavior on our Mobile App. This place anonymously, in order to monitor the performance and improve the usability of the site. Third-party profiling cookies are used to create profiles relating to users, in order to propose advertising in line with the choices expressed by the users themselves.\n\nProfiling cookies: We may also use profiling cookies, which are those that create profiles related to the user and are used in order to send advertising to the user's browser.\n\nWhen these types of cookies are used, we will receive your explicit consent.\n\nSupport in configuring your browser: You can manage cookies through the settings of your browser on your device. However, deleting cookies " +
                        "from your browser may remove the preferences you have set for this Mobile App.\n\nFor further information and support, you can also visit the specific help page of the web browser you are using:\n\n- Internet Explorer: http://windows.microsoft.com/en-us/windows-vista/block-or-allow-cookies\n\n- Firefox: https://support.mozilla.org/en-us/kb/enable-and-disable-cookies-website-preferences\n\n- Safari: http://www.apple.com/legal/privacy/\n\n- Chrome: https://support.google.com/accounts/answer/61416?hl=en\n\n- Opera: http://www.opera.com/help/tutorials/security/cookies/\n\nLog Data: Like all websites and mobile applications, this Mobile App also makes use of log files that store automatic information collected during user visits. The different types of log data could be as follows:\n\n- internet protocol (IP) address;\n\n- type of browser and device parameters used to connect to the Mobile App;\n\n- name of the Internet Service Provider (ISP);\n\n- date and time of visit;\n\n- web page of origin of the user (referral) and exit;\n\n- possibly the number of clicks.\n\nThe aforementioned information is processed in an automated " +
                        "form and collected in an exclusively aggregated manner in order to verify the correct functioning of the site, and for security reasons. This information will be processed according to the legitimate interests of the Data Controller.\n\nFor security purposes (spam filters, firewalls, virus detection), the automatically recorded data may also possibly include Personal Data such as IP address, which could be used, in accordance with applicable laws, in order to block attempts at damage to the Mobile App or damage to other users, or in the case of harmful activities or crime. Such data are never used for the identification or profiling of the user, but only for the protection of the Mobile App and our users. Such information will be treated according to the legitimate interests of the Data Controller.\n\nArticle 8 - THIRD PARTIES:\n\nWe may utilize third-party service providers (\"Third-Party Service Providers\"), from time to time or all the time, to help us with our Mobile App, and to help serve you.\n\nWe may use Third-Party Service Providers " +
                        "to assist with information storage (such as cloud storage).\n\nWe may provide some of your Personal Data to Third-Party Service Providers in order to help us track usage data, such as referral websites, dates and times of page requests, etc. We use this information to understand patterns of usage of, and to improve, the Mobile App.\n\nWe may use Third-Party Service Providers to host the Mobile App. In this instance, the Third-Party Service Provider will have access to your Personal Data.\n\nWe may use Third-Party Service Providers to fulfill orders in relation to the Mobile App.\n\nWe may allow third parties to advertise on the Mobile App. These third parties may use cookies in connection with their advertisements (see the \"Cookies\" clause in this Privacy Policy).\nWe only share your Personal Data with a Third-Party Service Provider if that provider agrees to our privacy standards as set out in this Privacy Policy.\n\nYour Personal Data will not be sold or otherwise transferred to other third parties without your approval.\n\nNotwithstanding the other provisions of this Privacy Policy, we may provide your Personal Data to a third party or to third parties in order to protect the rights, property or safety, of us, our customers or third parties, or as otherwise required by law." +
                        "\n\nWe will not knowingly share your Personal Data with any third parties other than in accordance with this Privacy Policy.\n\nIf your Personal Data might be provided to a third party in a manner that is other than as explained in this Privacy Policy, you will be notified. You will also have the opportunity to request that we not share that information.\nIn general, you may request that we do not share your Personal Data with third parties. Please contact us via email, if so. Please be advised that you may lose access to certain services that we rely on third-party providers for.\n\nArticle 9 - HOW PERSONAL DATA IS STORED:\n\nWe use secure physical and digital systems to store your Personal Data when appropriate. We ensure that your Personal Data is protected against unauthorized access, disclosure, or destruction.\n\nPlease note, however, that no system involving the transmission of information via the internet, or the electronic storage of data, is completely secure. However, we take the protection and storage of your Personal Data very seriously. We take all reasonable steps to protect your Personal Data.\n\nPersonal Data is stored throughout your relationship with us. We delete your Personal Data upon request for cancelation of your account or other general " +
                        "request for the deletion of data.\n\nIn the event of a breach of your Personal Data, you will be notified in a reasonable time frame, but in no event later than two weeks, and we will follow all applicable laws regarding such breach.\n\nArticle 10 - PURPOSES OF PROCESSING OF PERSONAL DATA:\n\nWe primarily use your Personal Data to help us provide a better experience for you on our Mobile App and to provide you the services and/or information you may have requested, such as use of our Mobile App.\n\nInformation that does not identify you personally, but that may assist in providing us broad overviews of our customer base, will be used for market research or marketing efforts. Such information may include, but is not limited to, interests based on your cookies.\n\nPersonal Data that may be considering identifying may be used for the following:\n\na) Improving your personal user experience\n\nb) Communicating with you about your user account with us\n\nc) Marketing and advertising to you, including via email\n\nd) Fulfilling your purchases\ne) Providing customer service to you\n\nf) Advising " +
                        "you about updates to the Mobile App or related Items\n\nArticle 11 - DISCLOSURE OF PERSONAL DATA:\n\nAlthough our policy is to maintain the privacy of your Personal Data as described herein, we may disclose your Personal Data if we believe that it is reasonable to do so in certain cases, in our sole and exclusive discretion. Such cases may include, but are not limited to:\na) To satisfy any local, state, or Federal laws or regulations\n\nb) To respond to requests, such discovery, criminal, civil, or administrative process, subpoenas, court orders, or writs from law enforcement or other governmental or legal bodies\n\nc) To bring legal action against a user who has violated the law or violated the terms of use of our Mobile App\n\nd) As may be necessary for the operation of our Mobile App\n\ne) To generally cooperate with any lawful investigation about our users\n\nf) If we suspect any fraudulent activity on our Mobile App or if we have noticed any activity which may violate our terms or other applicable rules\n\n" +
                        "Article 12 - PUBLIC INFORMATION:\n\nWe may allow users to post their own content or information publicly on our Mobile App. Such content or information may include, but is not limited to, photographs, status updates, blogs, articles, or other personal snippets. Please be aware that any such information or content that you may post should be considered entirely public and that we do not purport to maintain the privacy of such public information.\n\nArticle 13 - OPTING OUT OF TRANSMITTALS FROM US:\n\nFrom time to time, we may send you informational or marketing communications related to our Mobile App such as announcements or other information. If you wish to opt-out of such communications, you may contact the following email: info@zipgameday.com. You may also click the opt-out link which will be provided at the bottom of any and all such communications.\n\nPlease be advised that even though you may opt-out of such communications, you may still receive information from us that is specifically about your use of our Mobile App or about your account with us.\n\nBy providing any Personal Data to us, or by using our Mobile App in any manner, you have created a commercial relationship with us. As such, you agree that any email sent from us or third-party affiliates, even unsolicited email, shall specifically not be considered SPAM, as that term is legally defined.\n\nA" +
                        "Article 14 - MODIFYING, DELETING, AND ACCESSING YOUR INFORMATION:\n\nIf you wish to modify or delete any information we may have about you, or you wish to simply access any information we have about you, you may do so from your account settings page.\n\nArticle 15 - ACCEPTANCE OF RISK:\n\nBy continuing to our Mobile App in any manner, use the Product, you manifest your continuing asset to this Privacy Policy. You further acknowledge, agree and accept that no transmission of information or data via the internet is not always completely secure, no matter what steps are taken. You acknowledge, agree and accept that we do not guarantee or warrant the security of any information that you provide to us, and that you transmit such information at your own risk.\n\nArticle 16 - YOUR RIGHTS:\n\nYou have many rights in relation to your Personal Data. Specifically, your rights are as follows:\n\n- the right to be informed about the processing of your Personal Data\n\n- the right to have access to your Personal Data\n\n- the right to update and/or correct your Personal Data\n\n- the right to portability of your Personal Data\n\n- the right to oppose or limit the processing of your Personal Data\n\n- the " +
                        "right to request that we stop processing and delete your Personal Data\n\n- the right to block any Personal Data processing in violation of any applicable law\n\n- the right to launch a complaint with the Federal Trade Commission (FTC) in the United States or applicable data protection authority in another jurisdiction\nSuch rights can all be exercised by contacting us at the relevant contact information listed in this Privacy Policy.\n\nArticle 17 - CONTACT INFORMATION:\n\nIf you have any questions about this Privacy Policy or the way we collect information from you, or if you would like to launch a complaint about anything related to this Privacy Policy, you may contact us at the following email address: info@zipgameday.com.",
                    style: TextStyle(
                      color: Color.fromRGBO(255, 242, 0, 1.0),
                      decoration: TextDecoration.none,
                      fontSize: 18.0,
                      fontFamily: "Bebas",
                      fontWeight: FontWeight.w600,
                    ),
                    softWrap: true,
                  ),
                  //check box right here
                  CheckboxListTile(
                    title: Text("Click here to accept these Privacy Policies",
                        softWrap: true,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontFamily: "Bebas",
                          fontWeight: FontWeight.w600,
                        )),
                    controlAffinity: ListTileControlAffinity.platform,
                    value: checkBoxValue,
                    onChanged: (bool value) {
                      setState(() {
                        checkBoxValue = true;
                        DocumentReference policyReference = _firestore
                            .collection('users')
                            .doc(userService.user.uid);
                        policyReference
                            .update({'acceptedPrivPolicy': paccepted});
                      });
                    },
                    activeColor: Colors.white,
                    checkColor: Colors.red,
                  )
                ],
              ),
            );
          }),
          actions: <Widget>[
            new TextButton(
              child: new Text(
                "Next",
              ),
              onPressed: () async {
                DocumentReference termsandConditionsReference =
                    _firestore.collection('users').doc(userService.user.uid);
                bool acceptedPolicy = (await termsandConditionsReference.get())
                    .get('acceptedPrivPolicy');
                ;
                if (acceptedPolicy == true) {
                  Navigator.of(context).pop();
                  _showAlert(context);
                } else {
                  null;
                }
                ;
              },
            ),
          ],
          backgroundColor: Colors.black,
        );
      },
      barrierDismissible: false,
    );
  }

  // user defined function
  void _termsAlert(BuildContext context) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(
            " Zip Terms & Conditions",
            style: TextStyle(color: Color.fromRGBO(255, 242, 0, 1.0)),
          ),
          //This allows the state to be able to change in the alert dialog box
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            //Makes it so the text can be scrollable
            return SingleChildScrollView(
              child: Column(
                //Row
                children: <Widget>[
                  Text(
                    "These Terms of Use (\“Terms\”) describe the Zip service, how you will be using it as a Rider, and important legal rights and responsibilities that you have in connection with it. These Terms are effective as to the “Last Updated” date above. \n\nPLEASE READ THESE TERMS CAREFULLY BEFORE USING ZIP." +
                        "1. Your relationship with Zip\n\nBy using the Zip website (www.zipgameday.com) or the Zip mobile application (\“App\”), by telephoning Zip, or by entering a vehicle used by a Zip Driver, you agree to be bound by these Terms.\n\nThese Terms create a contractual relationship between you and Zip. These Terms do not create any commercial or legal relationship of any type between you and any Zip Driver, Rider, or Passenger.\n\nZip (\“we,\” \“our,\” \“us\”) may update these Terms from time to time. Any such amendments will take effect as soon as Zip posts them on its Website or App. By continuing to use Zip after an update, you agree to be bound by the updated Terms." +
                        "\n\n2. How you use the Service\n\nZip is an app-based event transportation service. It allows people at events who want a short ride by golf cart or pedicab from one location to another (\“Riders\”) to find people who are interested in driving them (\“Drivers\”). As a Rider, you can contact Zip to request a ride, and Zip will try to match you with a Driver who can pick you up and take you where you need to go. Right now, you can contact Zip through the App. These Terms refer to this service as the “\Service.\”" +
                        "\n\nHere's how the Service works. You contact Zip and request to be picked up at the location that you provide, and to be dropped off at another location not far away. Zip is for short drives, not road trips, so make it a trip less than five miles. Zip will dispatch one of its on-call Drivers to pick you up and drop you off. Zip will choose a Driver for you based on availability, and there may not be a Driver available quickly (or at all). Zip and Zip Drivers have the right to refuse the Service to you or to any Passengers for any reason at any time. If you don’t want to enter the Driver’s vehicle for any reason, you don’t have to. If you do, then just hop in and enjoy the ride. When you reach your destination, it’s nice to tip the Driver, but you don’t have to tip, and there’s no minimum amount if you do tip." +
                        "\n\nYou may bring one or more friends into the vehicle with you (\“Passengers\”), if your Driver agrees to take them. If you request to bring a Passenger and your Driver agrees, then you agree to be personally responsible and financially liable for the Passenger’s conduct and to make sure the Passenger complies with these Terms to the same extent that you agree to." +
                        "\n\nIf a Driver or another Rider or Passenger ever does anything that you don’t like in connection with the Service, please tell Zip immediately. We want this to be a great Service that people enjoy using. If anybody sexually harasses you, tell us. If anybody’s a jerk, tell us. If a Driver pressures you for a tip, which they have agreed with us not to do, tell us." +
                        "\n\nTo use the Service, you must satisfy any eligibility criteria that Zip may adopt at any time. Any other use of this Service is unauthorized. If you use the Service in any unauthorized manner, then you agree to compensate Zip for its attorneys’ fees and any legal costs that may result from Zip’s initiation of any related legal action against you." +
                        "\n\n3. Your authorizations to Zip\n\nIn order to match Riders with Drivers, Zip may collect some information about you. This may include your name, your phone number, and other information that Zip may request through the website, by phone, or through the App. You agree that Zip may collect this information and share it with Drivers for the limited purpose of helping them identify you at pickup locations or communicate with you about your ride, and may share it with third-party services.\n\nZip values your privacy. Please review our Rider Privacy Policy to learn how we collect and use information about you via the Service. By using the Service, you consent to Zip’s collection and use of information about you as set forth in that policy, and as it may be updated from time to time." +
                        "\n\n4. The Rider’s Pledge\n\nPlease be courteous to your Driver and act responsibly. Here’s what we mean. When you’re in a Driver’s vehicle, you agree:\n\nDon’t harass a Driver or another Rider or Passenger. Don’t harass them verbally, physically, sexually, or otherwise.\n\nAlways wear your seat belt. If your seat belt doesn’t work, tell your Driver before the vehicle begins moving. If there is not a working seat belt, don’t ride.\n\nIf you receive a Driver’s phone number or other contact information in the course of using the Service, don’t use it for any reason except in connection with the Service. In particular, don’t use it to call them and ask for a date or to hang out, and don’t give the contact information to anybody else.\n\nDon’t do anything illegal.\n\nDon’t bring any illegal drugs or other illegal substances into the vehicle. Don’t bring any alcohol into the vehicle, whether it is an open or closed container.\n\Don’t do anything that might cause an accident. For example, don’t distract the Driver.\n\nIf you are in contact with law enforcement officials or emergency medical personnel, follow their directions." +
                        "\n\nDon’t use any type of tobacco product in the vehicle, and don’t smoke within twenty feet of it.\n\nFeel free to suggest the quickest route from your pickup location to the dropoff location if you know it, but if your Driver has a preferred route, let the Driver choose the route.\n\nThe Driver is the boss of his or her vehicle. If they ask you to do something, you agree to do so, whether that is to keep the noise level down, not to smoke, or otherwise, so long as they’re not asking you to do anything illegal or that would conflict with these Terms. The Driver also has the right to ask you to leave the vehicle at any time and for any reason.If they ask you to leave the vehicle, you agree to do so.\n\nIf you cause any damage to your Driver’s vehicle or cause the vehicle to require professional cleaning or detailing, you’ll pay the Driver’s reasonable costs of repair or cleaning.\n\nDon’t ask anybody else to violate any of these rules. If you bring any Passengers on the ride with you, make sure they follow them too." +
                        "\n\n5. Termination\n\nEither you or Zip may immediately terminate these Terms at any time and for any reason, ending your use of the Service.\n\n6. Disclaimers, waiver of liability, and indemnity DISCLAIMER\n\nZIP OFFERS THE SERVICE \“AS IS.\” ZIP DISCLAIMS ALL REPRESENTATIONS AND WARRANTIES, EXPRESS, IMPLIED, OR STATUTORY, EXCEPT THOSE EXPRESSLY CONTAINED IN THESE TERMS, INCLUDING IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT. ZIP MAKES NO REPRESENTATION, WARRANTY, OR GUARANTEE CONCERNING THE RELIABILITY, TIMELINESS, QUALITY, OR AVAILABILITY OF THE SERVICE.\n\nYOU AGREE THAT YOU ALONE BEAR THE ENTIRE RISK OF USING THE SERVICE, TO THE EXTENT PERMITTED UNDER THE LAW." +
                        "\n\nWAIVER OF LIABILITY\n\nNEITHER COMPANY NOR ITS DIRECTORS, OFFICERS, SHAREHOLDERS, PARTNERS OR EMPLOYEES (COLLECTIVELY, “REPRESENTATIVES”) IS AN INSURER; THAT YOU CURRENTLY HAVE AND SHALL ALWAYS MAINTAIN INSURANCE COVERING YOU, AND OTHERS WHO MAY BE ON THE PREMISES OR CARTS FOR MEDICAL, DISABILITY, LIFE, AND PROPERTY; THAT RECOVERY FOR ALL SUCH LOSS, DAMAGE AND EXPENSE SHALL BE LIMITED TO ANY SUCH INSURANCE COVERAGE ONLY: AND THAT COMPANY AND REPRESENTATIVES ARE RELEASED FROM ALL LIABILITY DUE TO ACTIVE OR PASSIVE SOLE, JOINT OR SEVERE NEGLIGENCE OF ANY KIND OR DEGREE, THE IMPROPER OPERATION OR NON-OPERATION OF THE CARTS OR APPS, BREACH OF CONTRACT, EXPRESS OR IMPLIED, BREACH OF WARRANTY, EXPRESS OR IMPLIED, OR BY LOSS OR DAMAGE TO OR MALFUNCTION OF APP, CARTS, FACILITIES, OR OPERATORS." +
                        "THAT SHOULD THERE ARISE ANY LIABILITY ON THE PART OF COMPANY OR REPRESENTATIVES FOR ANY LOSS, DAMAGE OR EXPENSE DUE TO ACTIVE OR PASSIVE SOLE, JOINT OR SEVERE NEGLIGENCE OF ANY KIND OR DEGREE WHICH OCCURS BEFORE OR AFTER THE SIGNING OF THIS AGREEMENT, PRODUCT OR STRICT LIABILITY, BREACH OF WARRANTY, EXPRESS OR IMPLIED, BREACH OF CONTRACT, EXPRESS OR IMPLIED, OR FOR SUBROGATION, CONTRIBUTION OR INDEMNIFICATION, SUCH LIABILITY SHALL BE LIMITED TO THE MAXIMUM SUM OF \$1,000.00 FOR COMPANY AND REPRESENTATIVES.  ANY ACTION AGAINST THE COMPANY MUST BE COMMENCED WITHIN ONE YEAR OF THE ACCRUAL OF THE CAUSE OF ACTION OR SHALL BE BARRED." +
                        "THE COMPANY NOR ITS REPRESENTATIVES WILL BE LIABLE UNDER ANY CIRCUMSTANCES TO YOU OR TO ANY OTHER PERSON FOR DAMAGES OF ANY TYPE (INCLUDING DIRECT, INDIRECT, LOST PROFIT, ECONOMIC, CONSEQUENTIAL, INCIDENTAL, SPECIAL, EXEMPLARY, OR PUNITIVE DAMAGES), PERSONAL INJURY, PROPERTY DAMAGE, OR FOR ANY CLAIM OR DEMAND AGAINST THE COMPANY BY ANY OTHER PERSON RELATED TO ANY USE OF THE SERVICE."
                            "\n\nIndemnification & Exculpatory Clause\n\nYou will indemnify and hold Zip and its officers, directors, employees, independent contractors (including Zip Drivers) and agents, and other Zip Riders and/or Passengers, harmless from any claims or expenses (including attorneys’ fees) arising in connection with the Service.  Customer agrees that Company is not an insurer and no insurance coverage is oﬀered herein.  Company is not assuming liability, and, therefore, shall not be liable to Customer for any loss or inability to retrieve data, personal injury or property damage sustained as a result of cart failure, equipment failure, theft, wreck, or any other cause, regardless of whether or not such loss or damage was caused by or contributed to by Company’s negligent performance to any degree in furtherance of this Agreement, any extra contractual or legal duty, strict products liability, or negligent failure to perform any obligation pursuant to this Agreement.  Customer agrees to indemnify the Company and to hold the Company harmless from and against any claims or demands which may be asserted against the Company.\n\n7. Miscellaneous\n\nNo transfer or assignment\n\nThe Service is for you alone. You agree not to assign or transfer your rights under these Terms to any other person, for financial gain or otherwise.\n\nEntire Agreement\n\nThese Terms are the final, complete, and exclusive understanding between the parties. They replace and supersede all previous oral or written communications or agreements between the parties with respect to the subject matter of these Terms. These Terms may not be modified or amended except in writing signed by an authorized representative of Zip or by an updated Terms of Service posted on the Zip website or App." +
                        "\n\nGoverning Law and Jurisdiction\n\nThese terms will be governed by and construed in accordance with the laws of the state of Alabama. The federal and state courts in Alabama will have jurisdiction over any claim brought under these Terms or in connection with the Service, and the parties hereby consent to the personal jurisdiction of such courts." +
                        "\n\nSeverability\n\nIf any provision of these Terms is held to be invalid, unenforceable, or illegal, that provision will be severed from the Terms, without effect to any other provisions of the Terms.\n\nResolving disputes\n\nIf you have any dispute with Zip, you agree to contact us in writing before filing a lawsuit and try in good faith to resolve the dispute. If you are not satisfied with that process, then the parties will arbitrate the dispute before an arbitrator that you and Zip agree to in writing in the State of Alabama. If the parties cannot agree on the choice of arbitrator, each party will appoint one individual representative and the two party representatives will, between themselves, choose an arbitrator." +
                        "\n\nWaiver\n\nThe failure of either party to enforce any provisions of these Terms is not a waiver of the provisions or of the right of that party to subsequently enforce that, or any other, provision of these Terms.\n\n",
                    style: TextStyle(
                      color: Color.fromRGBO(255, 242, 0, 1.0),
                      decoration: TextDecoration.none,
                      fontSize: 18.0,
                      fontFamily: "Bebas",
                      fontWeight: FontWeight.w600,
                    ),
                    softWrap: true,
                  ),
                  //The start of the checkbox
                  CheckboxListTile(
                    title:
                        Text("Click here to accept these Terms and Conditions?",
                            softWrap: true,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontFamily: "Bebas",
                              fontWeight: FontWeight.w600,
                            )),
                    controlAffinity: ListTileControlAffinity.platform,
                    value: _checked,
                    // Changes the value when checked and set state updates the value on screen
                    onChanged: (bool value) {
                      setState(() {
                        _checked = true;
                        DocumentReference termsandConditionsReference =
                            _firestore
                                .collection('users')
                                .doc(userService.user.uid);
                        termsandConditionsReference
                            .update({'acceptedtc': taccepted});
                      });
                    },
                    activeColor: Colors.white,
                    checkColor: Colors.red,
                  ),
                ],
              ),
            );
          }),
          actions: <Widget>[
            new TextButton(
              child: new Text(
                "Next",
              ),
              onPressed: () async {
                DocumentReference termsandConditionsReference =
                    _firestore.collection('users').doc(userService.user.uid);
                bool acceptedTerms =
                    (await termsandConditionsReference.get()).get('acceptedtc');
                ;
                if (acceptedTerms == true) {
                  Navigator.of(context).pop();
                  _privacyAlert(context);
                } else {
                  null;
                }
                ;
              },
            ),
          ],
          backgroundColor: Colors.black,
        );
      },
      barrierDismissible: false,
    );
  }

// user defined function
  void _showAlert(BuildContext context) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(
            "Welcome, ${userService.user.firstName}!",
            style: TextStyle(color: Color.fromRGBO(255, 242, 0, 1.0)),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "Ordering a Zip is simple:\n1. Enter your destination.\n2. Choose cart size.\n3. Enter your pickup location.\n\nA Zip cart will pick you up!",
                  style: TextStyle(
                    color: Color.fromRGBO(255, 242, 0, 1.0),
                    decoration: TextDecoration.none,
                    fontSize: 18.0,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w600,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new TextButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          backgroundColor: Colors.black,
        );
      },
    );
  }

  ///this returns a scaffold that contains the entire mainscreen.
  ///here you'll find that we call the map (bottom of this file),
  ///drawer(see buildDrawer function), and create the bottomsheet
  ///and the button for moving to your location. The textfield with
  ///the autocomplete functionality is also here.

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    notificationService.registerContext(context);
    return Scaffold(
        key: _scaffoldKey,
        body: Stack(children: <Widget>[
          TheMap(
            key: mapScaffoldKey,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SafeArea(
                child: Stack(children: <Widget>[
              // Visibility(
              // visible: _menuVisible,
              // child:
              Card(
                  color: Colors.transparent,
                  elevation: 100,
                  child: IconButton(
                      iconSize: 44,
                      color: Color.fromRGBO(255, 242, 0, 1.0),
                      icon: Icon(Icons.menu),
                      onPressed: () => _scaffoldKey.currentState.openDrawer()))
            ])),
          ),
          Visibility(
              visible: showDropPin,
              child: Stack(children: <Widget>[
                // Align(
                //   alignment: Alignment.topLeft,
                //   child: SafeArea(
                //     child: IconButton(
                //       icon: Icon(Icons.arrow_back, color: Colors.white),
                //       onPressed: onBackPress
                //     ),
                //   ),
                // ),
                Center(
                    //alignment: Alignment.center,
                    child: Icon(
                  Icons.push_pin,
                  color: Colors.white,
                  size: 55,
                ))
              ]))
        ]),
        drawer: buildDrawer(context),
        bottomSheet: _buildBottomSheet());
  }

// Positioned(
//                   top: 70,
//                   bottom: 100,
//                   left: 100,
//                   right: 100,
//                   //alignment: Alignment.center,
//                   child: Icon(
//                     Icons.push_pin,
//                     color: Colors.white,
//                     size: 55,
//                   ))
  Widget _buildBottomSheet() {
    switch (bottomSheetStatus) {
      case BottomSheetStatus.closed:
        return Container(
          height: 0,
          width: 0,
        );
        break;
      case BottomSheetStatus.welcome:
        showDropPin = false;
        return Container(
          color: Colors.black,
          width: screenWidth,
          height: screenHeight * 0.35,
          padding: EdgeInsets.only(
            left: screenWidth * 0.1,
            right: screenWidth * 0.1,
            top: screenHeight * 0.01,
            bottom: screenHeight * 0.01,
          ),
          child: Stack(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Hello, ${userService.user.firstName}!",
                        style: TextStyle(
                          color: Color.fromRGBO(255, 242, 0, 1.0),
                          decoration: TextDecoration.none,
                          fontSize: 20.0,
                          fontFamily: "Bebas",
                          fontWeight: FontWeight.w400,
                        ),
                        softWrap: true,
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Where are you headed?",
                        style: TextStyle(
                          color: Color.fromRGBO(255, 242, 0, 1.0),
                          decoration: TextDecoration.none,
                          fontSize: 22.0,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w600,
                        ),
                        softWrap: true,
                      ),
                    ],
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.white,
                            ),
                            height: screenHeight * 0.07,
                            width: screenWidth * 0.8,
                            child: TextField(
                                onTap: () async {
                                  setState(() {
                                    bottomSheetStatus =
                                        BottomSheetStatus.closed;
                                  });
                                  Prediction p = await PlacesAutocomplete.show(
                                          context: context,
                                          hint: 'Search Destination',
                                          startText:
                                              search_controller.text == ''
                                                  ? ''
                                                  : search_controller.text,
                                          apiKey: this.map_key,
                                          language: "en",
                                          components: [
                                            Component(Component.country, "us")
                                          ],
                                          mode: Mode.overlay)
                                      .then((v) async {
                                    if (v != null) {
                                      this.address = v.description;
                                      search_controller.text = this.address;
                                      this.details = await _places
                                          .getDetailsByPlaceId(v.placeId);
                                    } else {
                                      search_controller.text = '';
                                      this.address = '';
                                      setState(() {
                                        bottomSheetStatus =
                                            BottomSheetStatus.welcome;
                                      });
                                    }
                                    search_node.unfocus();
                                    _pickSize();
                                    return null;
                                  });
                                },
                                controller: search_controller,
                                focusNode: search_node,
                                textInputAction: TextInputAction.go,
                                onSubmitted: (s) {
                                  _pickSize();
                                },
                                decoration: InputDecoration(
                                  icon: Container(
                                    margin: EdgeInsets.only(left: 20, top: 5),
                                    width: 10,
                                    height: 10,
                                    child: Icon(
                                      MyFlutterApp.golfCart,
                                      color: Colors.black,
                                    ),
                                  ),
                                  hintText: "Search Destination",
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.only(left: 15.0, top: 16.0),
                                ))),
                      ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton.extended(
                        heroTag: 'setPin',
                        backgroundColor: Colors.transparent,
                        onPressed: () {
                          _setPinOnMap();
                          mapScaffoldKey.currentState._setUserDefinedPin();
                        },
                        label: Text(
                          'Or Set On Map',
                          style: TextStyle(
                            color: Color.fromRGBO(255, 242, 0, 1.0),
                            decoration: TextDecoration.none,
                            fontSize: 15.0,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        icon: Icon(Icons.pin_drop, color: Colors.white),
                      )
                    ],
                  ),

                  //insert previous destinations if user has any
                ],
              ),
            ],
          ),
        );
        break;
      case BottomSheetStatus.setPin:
        return Container(
          color: Colors.black,
          width: screenWidth,
          height: screenHeight * 0.25,
          padding: EdgeInsets.only(
            left: screenWidth * 0.1,
            right: screenWidth * 0.1,
            top: screenHeight * 0.03,
            bottom: screenHeight * 0.01,
          ),
          child: Stack(
            children: <Widget>[
              Column(
                children: [
                  Row(
                    children: [
                      Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.white,
                          ),
                          height: screenHeight * 0.07,
                          width: screenWidth * 0.8,
                          child: TextField(
                              onTap: () async {
                                setState(() {
                                  bottomSheetStatus = BottomSheetStatus.closed;
                                });
                                Prediction p = await PlacesAutocomplete.show(
                                        context: context,
                                        hint: 'Search Destination',
                                        startText: search_controller.text == ''
                                            ? ''
                                            : search_controller.text,
                                        apiKey: this.map_key,
                                        language: "en",
                                        components: [
                                          Component(Component.country, "us")
                                        ],
                                        mode: Mode.overlay)
                                    .then((v) async {
                                  if (v != null) {
                                    print("v description " + v.description);
                                    this.address = v.description;
                                    search_controller.text = this.address;
                                    this.details = await _places
                                        .getDetailsByPlaceId(v.placeId);
                                    print("details " + this.details.toString());
                                  } else {
                                    search_controller.text = '';
                                    this.address = '';
                                    setState(() {
                                      bottomSheetStatus =
                                          BottomSheetStatus.welcome;
                                    });
                                  }
                                  search_node.unfocus();
                                  this.pinDropDestination = false;
                                  _pickSize();
                                  return null;
                                });
                              },
                              controller: search_controller,
                              focusNode: search_node,
                              textInputAction: TextInputAction.go,
                              onSubmitted: (s) {
                                _pickSize();
                              },
                              decoration: InputDecoration(
                                icon: Container(
                                  margin: EdgeInsets.only(left: 20, top: 5),
                                  width: 10,
                                  height: 10,
                                  child: Icon(
                                    MyFlutterApp.golfCart,
                                    color: Colors.black,
                                  ),
                                ),
                                hintText: 'Pin Destination',
                                /*listenForPin(),*/
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.only(left: 15.0, top: 16.0),
                              ))),
                    ],
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          child: Text('Set Destination'),
                          style: ElevatedButton.styleFrom(
                              primary: Color.fromRGBO(255, 242, 0, 1.0),
                              onPrimary: Colors.black,
                              minimumSize: Size(84, 40)),
                          onPressed: () async {
                            pinDropDestination = true;
                            this.pinDestination =
                                mapScaffoldKey.currentState._getPinDrop();
                            print(pinDestination);
                            _pickSize();
                          })
                    ],
                  ),
                ],
              )
            ],
          ),
        );
        break;
      case BottomSheetStatus.size:
        showDropPin = false;
        return Container(
          color: Colors.black,
          width: screenWidth,
          height: screenHeight * 0.25,
          padding: EdgeInsets.only(
            left: screenWidth * 0.1,
            right: screenWidth * 0.1,
            top: screenHeight * 0.01,
            bottom: screenHeight * 0.01,
          ),
          child: Stack(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      //Image.asset('assets/golf_cart.png'),
                      Text(
                        'Choose a Golf Cart size:',
                        style: TextStyle(
                          color: Color.fromRGBO(255, 242, 0, 1.0),
                          decoration: TextDecoration.none,
                          fontSize: 22.0,
                          fontFamily: "Bebas",
                          fontWeight: FontWeight.w600,
                        ),
                        softWrap: true,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FloatingActionButton.extended(
                        backgroundColor: Color.fromRGBO(255, 242, 0, 1.0),
                        onPressed: () {
                          zipxl = false;
                          _checkPrice();
                        },
                        label: Text('ZipX'),
                      ),
                      FloatingActionButton.extended(
                        backgroundColor: Color.fromRGBO(255, 242, 0, 1.0),
                        onPressed: () {
                          zipxl = true;
                          _checkPrice();
                        },
                        label: Text('ZipXL'),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      //Image.asset('assets/golf_cart.png'),
                      Text(
                        '3 riders            5 riders',
                        style: TextStyle(
                          color: Color.fromRGBO(255, 242, 0, 1.0),
                          decoration: TextDecoration.none,
                          fontSize: 22.0,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w600,
                        ),
                        softWrap: true,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
        break;
      case BottomSheetStatus.confirmation:
        showDropPin = false;
        return Container(
          color: Colors.black,
          width: screenWidth,
          height: screenHeight * 0.35,
          padding: EdgeInsets.only(
            left: screenWidth * 0.1,
            right: screenWidth * 0.1,
            top: screenHeight * 0.01,
            bottom: screenHeight * 0.01,
          ),
          child: Stack(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Price: ",
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Color.fromRGBO(255, 242, 0, 1.0))),
                      Text("\$" + price.toString(),
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Color.fromRGBO(255, 242, 0, 1.0))),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FloatingActionButton.extended(
                          heroTag: "confirmRide",
                          backgroundColor: Color.fromRGBO(255, 242, 0, 1.0),
                          onPressed: () async {
                            var paymentMethodID =
                                await _navigateAndDisplaySelection(context);
                            print("TESTING PAYMENT ID: $paymentMethodID");
                            _lookForRide();
                          },
                          label: Text('Confirm'),
                          icon: Icon(Icons.check)),
                      FloatingActionButton.extended(
                        heroTag: 'cancelRide',
                        backgroundColor: Color.fromRGBO(255, 242, 0, 1.0),
                        onPressed: () {
                          _cancelRide();
                        },
                        label: Text('Cancel'),
                        icon: Icon(Icons.cancel),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
        break;
      case BottomSheetStatus.searching:
        showDropPin = false;
        return Container(
            color: Colors.black,
            height: screenHeight * 0.25,
            width: screenWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                  ),
                ),
                Text("Looking for driver",
                    softWrap: true,
                    style: TextStyle(
                        color: Color.fromRGBO(255, 242, 0, 1.0),
                        fontWeight: FontWeight.w400,
                        fontSize: 22.0,
                        fontFamily: "Bebas")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      //backgroundColor: Color.fromRGBO(255, 242, 0, 1.0),
                      primary: Color.fromRGBO(255, 242, 0, 1.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      )),
                  onPressed: () {
                    _cancelRide();
                  },
                  child: Text("Cancel"),
                ),
              ],
            ));
        break;
      case BottomSheetStatus.rideDetails:
        showDropPin = false;
        return RideDetails(
          driver: false,
          ride: rideService.ride,
        );
        break;
      default:
    }
  }

  ///this will logout the user.
  void _logOut() async {
    AuthService().signOut();
  }

  ///this will pull up setPin bottomsheet and display pin icon
  void _setPinOnMap() async {
    setState(() {
      bottomSheetStatus = BottomSheetStatus.setPin;
      showDropPin = true;
    });
  }

  ///this will pull up the bottomsheet and ask if the user what
  ///size cart they want
  void _pickSize() async {
    //TODO fix setPin check
    if ((search_controller.text == this.address &&
            search_controller.text.length > 0) ||
        pinDropDestination == true) {
      setState(() {
        bottomSheetStatus = BottomSheetStatus.size;
      });
    }
  }

  Future<double> _rideDistance(bool pinDropDestination) async {
    double length;
    if (pinDropDestination) {
      length = await Geolocator().distanceBetween(
          locationService.position.latitude,
          locationService.position.longitude,
          this.pinDestination.latitude,
          this.pinDestination.longitude);
    } else {
      length = await Geolocator().distanceBetween(
          locationService.position.latitude,
          locationService.position.longitude,
          this.details.result.geometry.location.lat,
          this.details.result.geometry.location.lng);
    }
    // convert meters to miles
    length = length * 0.000621371;
    print(length);
    return length;
  }

  ///this will pull up the bottomsheet and ask if the user wants
  ///to move forward with the ride process
  void _checkPrice() async {
    //get current count of currentRides Collection
    DocumentReference currentRidesReference =
        _firestore.collection('CurrentRides').doc('currentRides');
    int currentNumberOfRides =
        (await currentRidesReference.get()).get('ridesGoingNow');

    if (search_controller.text == this.address &&
            search_controller.text.length > 0 ||
        pinDropDestination == true) {
      double length = await this._rideDistance(pinDropDestination);
      price =
          await paymentService.getAmmount(zipxl, length, currentNumberOfRides);
      setState(() {
        bottomSheetStatus = BottomSheetStatus.confirmation;
      });
    }
  }

  ///once the rider clicks confirm it will create a ride and look
  ///for a driver
  void _lookForRide() async {
    print(rideService.ride);
    if (this.pinDropDestination) {
      rideService.startRide(this.pinDestination.latitude,
          this.pinDestination.longitude, this.onRideChange, price);
    } else if (this.details != null) {
      rideService.startRide(this.details.result.geometry.location.lat,
          this.details.result.geometry.location.lng, this.onRideChange, price);
    }
  }

  void _returnToWelcome() {
    setState(() {
      bottomSheetStatus = BottomSheetStatus.welcome;
    });
  }

  ///if the rider clicks the cancel button, it will dismiss
  ///the bottomsheet and cancel the ride.
  void _cancelRide() {
    setState(() {
      bottomSheetStatus = BottomSheetStatus.welcome;
    });
    rideService.cancelRide();
  }

  void onRideChange(BottomSheetStatus status) {
    setState(() {
      bottomSheetStatus = status;
    });
  }

  _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              PaymentScreen(paymentService: this.paymentService)),
    );
    return result;
  }

  ///this builds the sidebar also known as the drawer.
  Widget buildDrawer(BuildContext context) {
    _buildHeader() {
      return StreamBuilder<DocumentSnapshot>(
          stream: Firestore.instance
              .collection('users')
              .document(userService.userID)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              User user = User.fromDocument(snapshot.data);
              return Container(
                  height: screenHeight * 0.36,
                  child: DrawerHeader(
                    padding: EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 2.0),
                    decoration: BoxDecoration(color: Colors.black),
                    child: Column(children: [
                      buildTopRowOfDrawerHeader(context),
                      CircleAvatar(
                        radius: 60.0,
                        child: ClipOval(
                          child: SizedBox(
                            width: 130.0,
                            height: 130.0,
                            child: user.profilePictureURL == ''
                                ? Image.asset('assets/profile_default.png')
                                : Image.network(
                                    user.profilePictureURL,
                                    fit: BoxFit.fill,
                                  ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(top: 10.0),
                              child: Text(
                                '${user.firstName} ${user.lastName}',
                                style: TextStyle(
                                  color: Color.fromRGBO(255, 242, 0, 1.0),
                                  fontSize: 16.0,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w400,
                                ),
                              )),
                        ],
                      )
                    ]),
                  ));
            } else {
              return DrawerHeader(child: Column());
            }
          });
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _buildHeader(),
          ListTile(
            title: Text('Edit Profile'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            title: Text('Payment'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Payment()));
            },
          ),
          ListTile(
            title: Text('Previous Trips'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HistoryScreen()));
            },
          ),
          ListTile(
            title: Text('Promo Codes'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PromosScreen()));
            },
          ),
          ListTile(
            title: Text('Settings'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()));
            },
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Switch(
              value: _isLight,
              onChanged: (value) {
                setState(() {
                  _isLight = value;
                });
              },
              activeColor: Colors.blue[400],
              activeTrackColor: Colors.blue[100],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: MapStyleText,
          ),
        ],
      ),
    );
  }

  ///this displays user information above the drawer
  Widget buildTopRowOfDrawerHeader(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Switch(
            value: _isCustomer,
            onChanged: (value) {
              setState(() {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VerificationScreen()));
              });
            },
            activeColor: Colors.blue[400],
            activeTrackColor: Colors.blue[100],
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: customerText,
        ),
      ],
    );
  }
}

///this is the map class for displaying the google map

class TheMap extends StatefulWidget {
  TheMap({Key key}) : super(key: key);
  @override
  State<TheMap> createState() => MapScreen();
}

class MapScreen extends State<TheMap> {
  ///variables and services needed to  initialize the map
  ///and location of the user.
  final DriverService driverService = DriverService();
  LocationService location = LocationService();
  static LatLng _initialPosition;
  // static LatLng _lastPosition;
  static LatLng _destinationPin;

  ///these three objects are used for the markers
  ///that display nearby drivers.
  final Set<Marker> _markers = {};
  BitmapDescriptor pinLocationIcon;
  Set<LatLng> driverPositions = {
    LatLng(32.62532, -85.46849),
    LatLng(32.62932, -85.46249)
  };
  List<Driver> driversList;

  ///this controller helps you manipulate the map
  ///from different places.
  Completer<GoogleMapController> _controller = Completer();
/*
  // for my drawn routes on the map
  // this will hold the generated polylines
  Set<Polyline> _polylines = Set<Polyline>();
  // this will hold each polyline coordinate as Lat and Lng pairs
  List<LatLng> polylineCoordinates = [];
// which generates every polyline between start and finish
  PolylinePoints polylinePoints;
*/
  BitmapDescriptor _sourceIcon;

  BitmapDescriptor _destinationIcon;

  LatLng pinDrop;

  // the user's initial location and current location
// as it moves
//  LocationData currentLocation;
// a reference to the destination location
  // LocationData destinationLocation;
// wrapper around the location API
  // Location location;

  ///this initalizes the map, user location, and drivers nearby.
  @override
  void initState() {
    super.initState();
    _setCustomMapPin();
    _getUserLocation();
    _getNearbyDrivers();
    pinDrop = LatLng(32.62532, -85.46849);

    // polylinePoints = PolylinePoints();
  }

  ///this initializes the cameraposition of the map.
  static final CameraPosition _currentPosition = CameraPosition(
    target: LatLng(_initialPosition.latitude, _initialPosition.longitude),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        //key: mapScaffoldKey,
        body: _initialPosition == null
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              )
            :
            //Listener  ( child:
            GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _currentPosition,
                onMapCreated: (GoogleMapController controller) {
                  _setStyle(controller);
                  _controller.complete(controller);
                  setMapPins();
                  _getUserLocation();
                  //setPolylines();
                },
                onCameraMoveStarted: () {
                  print("camera moving");
                },
                onCameraMove: (position) {
                  //_destinationPin = position.target;
                  pinDrop = position.target;
                  //print('${position.target}');
                },
                onCameraIdle: () async {},
                zoomGesturesEnabled: true,
                markers: _markers,
                //polylines: _polylines,
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
                mapToolbarEnabled: true,
              ),
        //),

        floatingActionButton: FloatingActionButton(
            onPressed: () => _goToMe(),
            child: Icon(Icons.my_location),
            backgroundColor: Color.fromRGBO(255, 242, 0, 1.0)));
    //return new Scaffold();
  }

  LatLng _getPinDrop() {
    return pinDrop;
  }

  void _setUserDefinedPin() {
    setState(() {
      print("hjhjjhj");

      /*_markers.add(Marker(
              markerId: MarkerId('pinDrop'),
              position: _initialPosition,
              icon: pinLocationIcon));*/
    });
  }

  ///this sets the icon for the markers
  void _setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 4), 'assets/golf_cart.png');
  }

  ///this sets style for dark mode
  void _setStyle(GoogleMapController controller) async {
    String value =
        await DefaultAssetBundle.of(context).loadString('assets/map_style.txt');
    controller.setMapStyle(value);
  }

  ///this gets the current users location
  void _getUserLocation() async {
    setState(() {
      _initialPosition =
          LatLng(location.position.latitude, location.position.longitude);
    });
    driverPositions.forEach((dr) => _markers.add(Marker(
          markerId: MarkerId('testing'),
          position: dr,
          icon: pinLocationIcon,
        )));
  }

  void setMapPins() {
    setState(() {
      // source pin
      _markers.add(Marker(
          markerId: MarkerId('source'),
          position: _initialPosition,
          icon: _sourceIcon));
      // destination pin
      /*  _markers.add(Marker(
          markerId: MarkerId('destination'),
          position: LatLng(37.430119406953, -122.0874490566),
          icon: _destinationIcon));*/
    });
  }

  /* void setPolylines() async {
    List<PointLatLng> result = await polylinePoints?.getRouteBetweenCoordinates(
        "AIzaSyDsPh6P9PDFmOqxBiLXpzJ1sW4kx-2LN5g",
        _initialPosition.latitude,
        _initialPosition.longitude,
        37.430119406953,
        -122.0874490566);
    result.forEach((PointLatLng point) {
      polylineCoordinates.add(LatLng(point.latitude, point.longitude));
    });

    setState(() {
      Polyline polyline = Polyline(
          polylineId: PolylineId("p"),
          color: Colors.blue,
          points: polylineCoordinates);
      _polylines.add(polyline);
    });
  }*/

  Future<void> _goToMe() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(location.position.latitude, location.position.longitude),
        zoom: 14.47)));
  }

  void _getNearbyDrivers() {}
}
