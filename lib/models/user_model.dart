import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String phone;
  final String userType;
  final bool isProfileVerified;
  final Timestamp createdAt;

  // Tour Guide specific fields
  final String? yearsOfExperience;
  final String? specialization;
  final List<String>? languagesSpoken;

  // Tourist specific fields
  final String? age;
  final String? countryOfResidence;
  final String? tripType;
  final String? travelBudget;
  final String? travelPace;
  final List<String>? interests;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.userType,
    required this.isProfileVerified,
    required this.createdAt,
    this.yearsOfExperience,
    this.specialization,
    this.languagesSpoken,
    this.age,
    this.countryOfResidence,
    this.tripType,
    this.travelBudget,
    this.travelPace,
    this.interests,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'],
      email: data['email'],
      fullName: data['fullName'],
      phone: data['phone'],
      userType: data['userType'],
      isProfileVerified: data['isProfileVerified'],
      createdAt: data['createdAt'],
      yearsOfExperience: data['yearsOfExperience'],
      specialization: data['specialization'],
      languagesSpoken: data['languagesSpoken'] != null
          ? List<String>.from(data['languagesSpoken'])
          : null,
      age: data['age'],
      countryOfResidence: data['countryOfResidence'],
      tripType: data['tripType'],
      travelBudget: data['travelBudget'],
      travelPace: data['travelPace'],
      interests: data['interests'] != null
          ? List<String>.from(data['interests'])
          : null,
    );
  }
}
