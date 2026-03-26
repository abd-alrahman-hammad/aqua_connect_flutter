import 'package:cloud_firestore/cloud_firestore.dart';
import 'live_monitoring_model.dart';

class DetectionHistoryModel {
  final String id;
  final String imageUrl;
  final String confidence; // Keeping as String since UI expects e.g., '91%' but can parse from double
  final DateTime timestamp;
  final String status;
  final String title;
  final String subtitle;
  final String description;
  final String rootCause;
  final String recommendedTreatment;
  final List<SpotDetailModel> spotsDetails;
  final int totalSpots;

  DetectionHistoryModel({
    required this.id,
    required this.imageUrl,
    required this.confidence,
    required this.timestamp,
    required this.status,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.rootCause,
    required this.recommendedTreatment,
    required this.spotsDetails,
    required this.totalSpots,
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
    
    // Safely parse spotsMap
    Map<dynamic, dynamic> spotsMap = {};
    final rawSpots = data['spots_details'];
    if (rawSpots is Map) {
      spotsMap = rawSpots;
    } else if (rawSpots is List) {
      for (int i = 0; i < rawSpots.length; i++) {
        spotsMap['spot_${i + 1}'] = rawSpots[i];
      }
    }
    
    if (data['status'] == null && spotsMap.isNotEmpty) {
      bool hasCritical = false;
      bool hasWarning = false;
      for (var spot in spotsMap.values) {
        if (spot is Map) {
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

    // Parse spots strictly as SpotDetailModels for UI processing
    final parsedSpots = <SpotDetailModel>[];
    if (spotsMap.isNotEmpty) {
      final sortedKeys = spotsMap.keys.toList()..sort((a, b) => a.compareTo(b));
      for (final key in sortedKeys) {
        final spotData = spotsMap[key];
        if (spotData is Map) {
          parsedSpots.add(SpotDetailModel.fromJson(
            Map<dynamic, dynamic>.from(spotData),
            key.toString(),
          ));
        }
      }
    }

    // Default titles if not provided
    final String deviceId = data['device_id']?.toString().replaceAll('_', ' ') ?? 'Plant Device';
    final int totalSpotsCount = spotsMap.length;

    return DetectionHistoryModel(
      id: doc.id,
      imageUrl: data['imageUrl'] ?? data['image_url'] ?? '',
      confidence: parsedConfidence,
      timestamp: parsedTimestamp,
      status: derivedStatus,
      title: data['title'] ?? deviceId,
      subtitle: data['subtitle'] ?? (totalSpotsCount > 0 ? '$totalSpotsCount Spots Detected' : 'No issues found'),
      description: data['description'] ?? (derivedStatus == 'Healthy' ? 'Optimal growth' : 'Action requires attention'),
      rootCause: data['root_cause'] ?? 'Unknown',
      recommendedTreatment: data['recommended_treatment'] ?? 'Consult an agronomist',
      spotsDetails: parsedSpots,
      totalSpots: totalSpotsCount,
    );
  }
}
