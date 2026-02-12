class AiInsightModel {
  final String analysis;
  final String actionRequired;
  final String dailyTip;

  const AiInsightModel({
    required this.analysis,
    required this.actionRequired,
    required this.dailyTip,
  });

  factory AiInsightModel.fromJson(Map<String, dynamic> json) => AiInsightModel(
    analysis: json['analysis'] as String,
    actionRequired: json['action_required'] as String,
    dailyTip: json['daily_tip'] as String,
  );
}
