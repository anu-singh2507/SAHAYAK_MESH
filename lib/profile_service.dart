import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserProfile {
  // Personal Info
  String name;
  String imagePath; // Path to local image file
  String dob; // Date of Birth
  String gender;
  String phone;
  String iceName; // Emergency Contact Name
  String icePhone; // Emergency Contact Phone
  String address;
  String languages;

  // Medical Info
  String bloodGroup;
  String allergies;
  String conditions;
  String medications;
  String implants;
  String mobilityStatus;
  String pregnancyStatus; // "Yes", "No", or "Week X"

  UserProfile({
    this.name = '',
    this.imagePath = '',
    this.dob = '',
    this.gender = '',
    this.phone = '',
    this.iceName = '',
    this.icePhone = '',
    this.address = '',
    this.languages = '',
    this.bloodGroup = '',
    this.allergies = '',
    this.conditions = '',
    this.medications = '',
    this.implants = '',
    this.mobilityStatus = '',
    this.pregnancyStatus = 'No',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'imagePath': imagePath,
        'dob': dob,
        'gender': gender,
        'phone': phone,
        'iceName': iceName,
        'icePhone': icePhone,
        'address': address,
        'languages': languages,
        'bloodGroup': bloodGroup,
        'allergies': allergies,
        'conditions': conditions,
        'medications': medications,
        'implants': implants,
        'mobilityStatus': mobilityStatus,
        'pregnancyStatus': pregnancyStatus,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] ?? '',
        imagePath: json['imagePath'] ?? '',
        dob: json['dob'] ?? '',
        gender: json['gender'] ?? '',
        phone: json['phone'] ?? '',
        iceName: json['iceName'] ?? '',
        icePhone: json['icePhone'] ?? '',
        address: json['address'] ?? '',
        languages: json['languages'] ?? '',
        bloodGroup: json['bloodGroup'] ?? '',
        allergies: json['allergies'] ?? '',
        conditions: json['conditions'] ?? '',
        medications: json['medications'] ?? '',
        implants: json['implants'] ?? '',
        mobilityStatus: json['mobilityStatus'] ?? '',
        pregnancyStatus: json['pregnancyStatus'] ?? 'No',
      );
}

class ProfileService {
  static const String _key = 'user_profile_full';

  static Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(profile.toJson());
    await prefs.setString(_key, jsonString);
  }

  static Future<UserProfile> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(_key);
    if (jsonString == null) return UserProfile(); // Return empty if new
    return UserProfile.fromJson(jsonDecode(jsonString));
  }
}