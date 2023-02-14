// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:zip/models/adminSettings.dart';

// class AdminSettingsService {
//   static final AdminSettingsService _instance = AdminSettingsService._internal();
//   final bool showDebugPrints = true;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   DocumentReference adminSettingsReference;

//   Stream<AdminSettings> adminSettingsStream;
//   AdminSettings adminSettings;

//   String termsOfService;
//   double pickupRadius;
//   double priceMultiplier;

//   factory AdminSettingsService() {
//     return _instance;
//   }

//   AdminSettingsService._internal() {
//     print('AdminSettingsService created');
//     adminSettingsReference = _firestore.collection('admin_settings').doc('settings');
//   }

//   void _onSettingsUpdate(AdminSettings updateAdminSettings) {
    
//   }
  
//   Stream<AdminSettings> getAdminSettingsStream() {
//     return adminSettingsReference.snapshots().map((snapshot) {
//       return AdminSettings.fromDocument(snapshot);
//     });
//   }
// }
