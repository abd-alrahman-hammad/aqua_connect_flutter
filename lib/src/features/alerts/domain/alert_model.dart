enum AlertType { critical, warning, optimal, info }

class AlertModel {
  final String id;
  final AlertType type;
  final String icon;
  final String title;
  final DateTime timestamp;
  final String message;
  final bool isDismissible;

  const AlertModel({
    required this.id,
    required this.type,
    required this.icon,
    required this.title,
    required this.timestamp,
    required this.message,
    this.isDismissible = true,
  });

  AlertModel copyWith({
    String? id,
    AlertType? type,
    String? icon,
    String? title,
    DateTime? timestamp,
    String? message,
    bool? isDismissible,
  }) {
    return AlertModel(
      id: id ?? this.id,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      title: title ?? this.title,
      timestamp: timestamp ?? this.timestamp,
      message: message ?? this.message,
      isDismissible: isDismissible ?? this.isDismissible,
    );
  }
}
