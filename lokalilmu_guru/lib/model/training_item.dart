class TrainingItem {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final int totalSessions;
  final int completedSessions;

  TrainingItem({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.totalSessions,
    required this.completedSessions,
  });

  factory TrainingItem.fromJson(Map<String, dynamic> json) {
    return TrainingItem(
      id: json['id'],
      title: json['title'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalSessions: json['totalSessions'],
      completedSessions: json['completedSessions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalSessions': totalSessions,
      'completedSessions': completedSessions,
    };
  }

  double get progressPercentage {
    return completedSessions / totalSessions;
  }
}