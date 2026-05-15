import 'package:cloud_firestore/cloud_firestore.dart';

class AppUserModel {
  final String userId;
  final String name;
  final String email;
  final DateTime createdAt;

  AppUserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  factory AppUserModel.fromJson(Map<String, dynamic> json, String documentId) {
    return AppUserModel(
      userId: documentId,
      name: json['user_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      createdAt: _timestampToDateTime(json['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_name': name,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static DateTime? _timestampToDateTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.tryParse(timestamp);
    }
    return null;
  }
}
