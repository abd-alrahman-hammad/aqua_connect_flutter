import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceModel {
  final String deviceId;
  final String userId;
  final String name;
  final DateTime createdAt;

  DeviceModel({
    required this.deviceId,
    required this.userId,
    required this.name,
    required this.createdAt,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json, String documentId) {
    return DeviceModel(
      deviceId: documentId,
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      createdAt: _timestampToDateTime(json['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
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
