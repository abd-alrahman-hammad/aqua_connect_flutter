import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing live plant monitoring data from the vision system.
///
/// This model maps to the `devices/{deviceId}/liveMonitoring` subcollection
/// in Cloud Firestore. It contains disease detection results including
/// overall plant status, confidence scores, and individual spot details.
///
/// Schema:
/// - `confidence` (String, e.g. "91%") → String confidence
/// - `image_url` (String) → String imageUrl
/// - `last_update` (String, e.g. "2026-03-11 18:16:26") → DateTime? lastUpdate
/// - `spots_details` (Map of spot objects) → List<SpotDetailModel> spotsDetails
/// - `status_ar` (String) → String statusAr
/// - `status_en` (String) → String statusEn
/// - `total_spots` (int) → int totalSpots
class LiveMonitoringModel {
  /// Firestore document ID (used for pagination cursors)
  final String documentId;

  /// Overall disease detection confidence (e.g. "91%")
  final String confidence;

  /// URL of the captured plant image from Firebase Storage
  final String imageUrl;

  /// Timestamp of the last analysis update
  final DateTime? lastUpdate;

  /// Individual disease spot details detected on the plant
  final List<SpotDetailModel> spotsDetails;

  /// Overall plant status in Arabic (e.g. "حرج")
  final String statusAr;

  /// Overall plant status in English (e.g. "Critical")
  final String statusEn;

  /// Total number of disease spots detected
  final int totalSpots;

  /// Creates a new [LiveMonitoringModel] instance
  const LiveMonitoringModel({
    this.documentId = '',
    required this.confidence,
    required this.imageUrl,
    this.lastUpdate,
    required this.spotsDetails,
    required this.statusAr,
    required this.statusEn,
    required this.totalSpots,
  });

  /// Creates a [LiveMonitoringModel] with default empty values
  const LiveMonitoringModel.initial()
    : documentId = '',
      confidence = '0%',
      imageUrl = '',
      lastUpdate = null,
      spotsDetails = const [],
      statusAr = '',
      statusEn = '',
      totalSpots = 0;

  /// Creates a [LiveMonitoringModel] from a JSON map
  ///
  /// Example JSON from Firebase:
  /// ```json
  /// {
  ///   "confidence": "91%",
  ///   "image_url": "https://...",
  ///   "last_update": "2026-03-11 18:16:26",
  ///   "spots_details": {
  ///     "spot_1": { "confidence": "91%", ... },
  ///     "spot_2": { "confidence": "90%", ... }
  ///   },
  ///   "status_ar": "حرج",
  ///   "status_en": "Critical",
  ///   "total_spots": 6
  /// }
  /// ```
  factory LiveMonitoringModel.fromJson(
    Map<dynamic, dynamic> json, [
    String docId = '',
  ]) {
    // Parse spots_details map into a sorted list
    final spotsMap = json['spots_details'] as Map<dynamic, dynamic>? ?? {};
    final spots = <SpotDetailModel>[];

    // Sort by key (spot_1, spot_2, ...) to maintain consistent ordering
    final sortedKeys = spotsMap.keys.toList()
      ..sort((a, b) => a.toString().compareTo(b.toString()));

    for (final key in sortedKeys) {
      final spotData = spotsMap[key];
      if (spotData is Map) {
        spots.add(SpotDetailModel.fromJson(
          Map<dynamic, dynamic>.from(spotData),
          key.toString(),
        ));
      }
    }

    return LiveMonitoringModel(
      documentId: docId,
      confidence: (json['confidence'] ?? '0%').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
      lastUpdate: _parseDateTime(json['last_update']),
      spotsDetails: spots,
      statusAr: (json['status_ar'] ?? '').toString(),
      statusEn: (json['status_en'] ?? '').toString(),
      totalSpots: _parseInt(json['total_spots']),
    );
  }

  /// Converts the model to a JSON map for Firebase
  Map<String, dynamic> toJson() {
    final spotsMap = <String, dynamic>{};
    for (final spot in spotsDetails) {
      spotsMap[spot.spotId] = spot.toJson();
    }

    return {
      'confidence': confidence,
      'image_url': imageUrl,
      'last_update': lastUpdate?.toString(),
      'spots_details': spotsMap,
      'status_ar': statusAr,
      'status_en': statusEn,
      'total_spots': totalSpots,
    };
  }

  /// Creates a copy of this model with updated values
  LiveMonitoringModel copyWith({
    String? documentId,
    String? confidence,
    String? imageUrl,
    DateTime? lastUpdate,
    List<SpotDetailModel>? spotsDetails,
    String? statusAr,
    String? statusEn,
    int? totalSpots,
  }) {
    return LiveMonitoringModel(
      documentId: documentId ?? this.documentId,
      confidence: confidence ?? this.confidence,
      imageUrl: imageUrl ?? this.imageUrl,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      spotsDetails: spotsDetails ?? this.spotsDetails,
      statusAr: statusAr ?? this.statusAr,
      statusEn: statusEn ?? this.statusEn,
      totalSpots: totalSpots ?? this.totalSpots,
    );
  }

  /// Returns the numeric confidence value (e.g. 91 from "91%")
  int get confidenceValue {
    final cleaned = confidence.replaceAll('%', '').trim();
    return int.tryParse(cleaned) ?? 0;
  }

  /// Whether the plant status is critical
  bool get isCritical =>
      statusEn.toLowerCase() == 'critical' || statusAr == 'حرج';

  /// Whether the plant status is warning
  bool get isWarning =>
      statusEn.toLowerCase() == 'warning' || statusAr == 'تحذير';

  /// Whether the plant is healthy
  bool get isHealthy =>
      statusEn.toLowerCase() == 'healthy' || statusAr == 'سليم';

  /// Whether any spots were detected
  bool get hasSpots => totalSpots > 0;

  /// Parses a date-time value from Firestore (Timestamp) or RTDB (String)
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Parses an integer value from Firebase
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  @override
  String toString() {
    return 'LiveMonitoringModel(status: $statusEn, confidence: $confidence, spots: $totalSpots)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LiveMonitoringModel &&
        other.confidence == confidence &&
        other.imageUrl == imageUrl &&
        other.lastUpdate == lastUpdate &&
        other.statusAr == statusAr &&
        other.statusEn == statusEn &&
        other.totalSpots == totalSpots;
  }

  @override
  int get hashCode => Object.hash(
        confidence,
        imageUrl,
        lastUpdate,
        statusAr,
        statusEn,
        totalSpots,
      );
}

// =============================================================================
// Spot Detail Model
// =============================================================================

/// Model representing a single disease spot detected on a plant.
///
/// Each spot has a confidence score, location description (bilingual),
/// and a status (bilingual).
///
/// Schema:
/// - `confidence` (String, e.g. "91%") → String confidence
/// - `location_ar` (String) → String locationAr
/// - `location_en` (String) → String locationEn
/// - `status_ar` (String) → String statusAr
/// - `status_en` (String) → String statusEn
class SpotDetailModel {
  /// Identifier for this spot (e.g. "spot_1", "spot_2")
  final String spotId;

  /// Detection confidence for this specific spot
  final String confidence;

  /// Spot location description in Arabic
  final String locationAr;

  /// Spot location description in English (e.g. "Bottom Left", "Top Right")
  final String locationEn;

  /// Spot status in Arabic (e.g. "مصاب")
  final String statusAr;

  /// Spot status in English (e.g. "Diseased")
  final String statusEn;

  /// Creates a new [SpotDetailModel] instance
  const SpotDetailModel({
    required this.spotId,
    required this.confidence,
    required this.locationAr,
    required this.locationEn,
    required this.statusAr,
    required this.statusEn,
  });

  /// Creates a [SpotDetailModel] from a JSON map
  ///
  /// [spotKey] is the Firebase key (e.g. "spot_1") used as the spot identifier.
  factory SpotDetailModel.fromJson(Map<dynamic, dynamic> json, String spotKey) {
    return SpotDetailModel(
      spotId: spotKey,
      confidence: (json['confidence'] ?? '0%').toString(),
      locationAr: (json['location_ar'] ?? '').toString(),
      locationEn: (json['location_en'] ?? '').toString(),
      statusAr: (json['status_ar'] ?? '').toString(),
      statusEn: (json['status_en'] ?? '').toString(),
    );
  }

  /// Converts the model to a JSON map for Firebase
  Map<String, dynamic> toJson() {
    return {
      'confidence': confidence,
      'location_ar': locationAr,
      'location_en': locationEn,
      'status_ar': statusAr,
      'status_en': statusEn,
    };
  }

  /// Returns the numeric confidence value (e.g. 91 from "91%")
  int get confidenceValue {
    final cleaned = confidence.replaceAll('%', '').trim();
    return int.tryParse(cleaned) ?? 0;
  }

  /// Whether this spot is marked as diseased
  bool get isDiseased =>
      statusEn.toLowerCase() == 'diseased' || statusAr == 'مصاب';

  @override
  String toString() {
    return 'SpotDetailModel($spotId: $statusEn at $locationEn, $confidence)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpotDetailModel &&
        other.spotId == spotId &&
        other.confidence == confidence &&
        other.locationAr == locationAr &&
        other.locationEn == locationEn &&
        other.statusAr == statusAr &&
        other.statusEn == statusEn;
  }

  @override
  int get hashCode =>
      Object.hash(spotId, confidence, locationAr, locationEn, statusAr, statusEn);
}
