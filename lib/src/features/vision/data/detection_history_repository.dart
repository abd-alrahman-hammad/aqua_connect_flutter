import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/db/detection_history_model.dart';

/// Provider for mapping the 'detectionHistory' collection into a Stream of List<DetectionHistoryModel>
final detectionHistoryProvider = StreamProvider<List<DetectionHistoryModel>>((
  ref,
) {
  final firestore = FirebaseFirestore.instance;

  return firestore
      .collection('DetectionHistory')
      .orderBy('server_time', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => DetectionHistoryModel.fromFirestore(doc))
            .toList();
      });
});
