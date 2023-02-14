import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSettings {
  final String termsOfService;
  final double pickupRadius;
  final double priceMultiplier;

  AdminSettings(
    {
      this.termsOfService,
      this.pickupRadius,
      this.priceMultiplier
    }
  );

  Map<String, Object> toJson() {
    return {
      'termsOfService': termsOfService,
      'pickupRadius': pickupRadius,
      'priceMultiplier': priceMultiplier
    };
  }

  factory AdminSettings.fromJson(Map<String, Object> doc) {
    AdminSettings adminSettings = new AdminSettings(
      termsOfService: doc['termsOfService'],
      pickupRadius: doc['pickupRadius'],
      priceMultiplier: doc['priceMultiplier']
    );
    return adminSettings;
  }

  factory AdminSettings.fromDocument(DocumentSnapshot doc) {
    return AdminSettings.fromJson(doc.data());
  }
}