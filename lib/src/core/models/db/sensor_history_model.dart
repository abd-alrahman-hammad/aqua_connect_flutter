import 'package:cloud_firestore/cloud_firestore.dart';

class SensorHistoryModel {
  final String id;
  final num temperature;
  final num phValue;
  final num ecValue;
  final DateTime timestamp;

  SensorHistoryModel({
    required this.id,
    required this.temperature,
    required this.phValue,
    required this.ecValue,
    required this.timestamp,
  });

  factory SensorHistoryModel.fromJson(
    Map<String, dynamic> json,
    String documentId,
  ) {
    return SensorHistoryModel(
      id: documentId,
      temperature: json['temperature'] as num? ?? 0.0,
      phValue: json['ph_value'] as num? ?? 0.0,
      ecValue: json['ec_value'] as num? ?? 0.0,
      timestamp: _timestampToDateTime(json['timestamp']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'temperature': temperature,
      'ph_value': phValue,
      'ec_value': ecValue,
      'timestamp': Timestamp.fromDate(timestamp),
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
