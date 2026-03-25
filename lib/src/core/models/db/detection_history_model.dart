import 'package:cloud_firestore/cloud_firestore.dart';

class DetectionHistoryModel {
  final String id;
  final String imageUrl;
  final String confidence; // Keeping as String since UI expects e.g., '91%' but can parse from double
  final DateTime timestamp;
  final String status;
  final String title;
  final String subtitle;
  final String description;

  DetectionHistoryModel({
    required this.id,
    required this.imageUrl,
    required this.confidence,
    required this.timestamp,
    required this.status,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  factory DetectionHistoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    // Parse confidence - handle both String ('91%') and double (0.91 or 91)
    String parsedConfidence = 'N/A';
    if (data['confidence'] != null) {
      if (data['confidence'] is String) {
        parsedConfidence = data['confidence'];
      } else if (data['confidence'] is double || data['confidence'] is int) {
        final double val = (data['confidence'] as num).toDouble();
        if (val <= 1.0) {
          parsedConfidence = '${(val * 100).round()}%';
        } else {
          parsedConfidence = '${val.round()}%';
        }
      }
    }

    // Parse timestamp using server_time
    DateTime parsedTimestamp = DateTime.now();
    final timeVal = data['server_time'] ?? data['last_update'];
    if (timeVal != null) {
      if (timeVal is Timestamp) {
        parsedTimestamp = timeVal.toDate();
      } else if (timeVal is String) {
        parsedTimestamp = DateTime.tryParse(timeVal) ?? DateTime.now();
      } else if (timeVal is int) {
        parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(timeVal);
      }
    }
    
    // Derive status from spots_details
    String derivedStatus = data['status'] ?? 'Healthy';
    final spotsMap = data['spots_details'] as Map<String, dynamic>? ?? {};
    if (data['status'] == null && spotsMap.isNotEmpty) {
      bool hasCritical = false;
      bool hasWarning = false;
      for (var spot in spotsMap.values) {
        if (spot is Map<String, dynamic>) {
           final statusEn = (spot['status_en'] ?? '').toString().toLowerCase();
           final statusAr = (spot['status_ar'] ?? '').toString().toLowerCase();
           if (statusEn.contains('disease') || statusEn.contains('critical') || statusAr.contains('مصاب')) {
             hasCritical = true;
           }
           else if (statusEn.contains('warn') || statusAr.contains('تحذير')) {
             hasWarning = true;
           }
        }
      }
      if (hasCritical) derivedStatus = 'Critical';
      else if (hasWarning) derivedStatus = 'Warning';
    }

    // Default titles if not provided
    final String deviceId = data['device_id']?.toString().replaceAll('_', ' ') ?? 'Plant Device';
    final int totalSpots = spotsMap.length;

    return DetectionHistoryModel(
      id: doc.id,
      imageUrl: data['imageUrl'] ?? data['image_url'] ?? '',
      confidence: parsedConfidence,
      timestamp: parsedTimestamp,
      status: derivedStatus,
      title: data['title'] ?? deviceId,
      subtitle: data['subtitle'] ?? (totalSpots > 0 ? '$totalSpots Spots Detected' : 'No issues found'),
      description: data['description'] ?? (derivedStatus == 'Healthy' ? 'Optimal growth' : 'Action requires attention'),
    );
  }
}
