import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? displayName;

  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    this.email,
    this.displayName,

    this.createdAt,
  });

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data was null');
    }
    return UserModel(
      uid: doc.id,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,

      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  factory UserModel.fromMap(Map<dynamic, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,

      createdAt: data['createdAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'displayName': displayName,

      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  Map<String, dynamic> toRealtimeMap() {
    return {
      'email': email,
      'displayName': displayName,

      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  UserModel copyWith({
    String? email,
    String? displayName,

    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,

      createdAt: createdAt ?? this.createdAt,
    );
  }
}
