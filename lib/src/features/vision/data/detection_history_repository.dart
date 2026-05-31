import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/db/detection_history_model.dart';

/// Provider that streams the DetectionHistory sub-collection as a list of models.
/// Path: /devices/HYDRO_001/DetectionHistory
final detectionHistoryProvider = StreamProvider<List<DetectionHistoryModel>>((
  ref,
) {
  final firestore = FirebaseFirestore.instance;

  return firestore
      .collection('devices')
      .doc('HYDRO_001')
      .collection('DetectionHistory')
      .snapshots()
      .map((snapshot) {
        final items = <DetectionHistoryModel>[];
        for (final doc in snapshot.docs) {
          try {
            items.add(DetectionHistoryModel.fromFirestore(doc));
          } catch (e) {
            debugPrint('[DetectionHistory] Error parsing doc ${doc.id}: $e');
          }
        }

        // Sort by timestamp descending (newest first)
        items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return items;
      });
});
