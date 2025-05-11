class ScheduleItem {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;

  ScheduleItem({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      id: json['id'],
      title: json['title'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}