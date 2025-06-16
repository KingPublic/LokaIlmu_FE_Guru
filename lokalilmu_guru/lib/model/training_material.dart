class TrainingMaterial {
  final String id;
  final String trainingId;
  final String title;
  final String duration;
  final String participantCount;
  final List<TrainingSession> sessions;
  final List<String> teachingNotes;

  TrainingMaterial({
    required this.id,
    required this.trainingId,
    required this.title,
    required this.duration,
    required this.participantCount,
    required this.sessions,
    required this.teachingNotes,
  });

  factory TrainingMaterial.fromJson(Map<String, dynamic> json) {
    return TrainingMaterial(
      id: json['id'],
      trainingId: json['trainingId'],
      title: json['title'],
      duration: json['duration'],
      participantCount: json['participantCount'],
      sessions: (json['sessions'] as List)
          .map((session) => TrainingSession.fromJson(session))
          .toList(),
      teachingNotes: List<String>.from(json['teachingNotes']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trainingId': trainingId,
      'title': title,
      'duration': duration,
      'participantCount': participantCount,
      'sessions': sessions.map((session) => session.toJson()).toList(),
      'teachingNotes': teachingNotes,
    };
  }
}

class TrainingSession {
  final String id;
  final String title;
  final List<MaterialItem> materials;

  TrainingSession({
    required this.id,
    required this.title,
    required this.materials,
  });

  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    return TrainingSession(
      id: json['id'],
      title: json['title'],
      materials: (json['materials'] as List)
          .map((material) => MaterialItem.fromJson(material))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'materials': materials.map((material) => material.toJson()).toList(),
    };
  }
}

class MaterialItem {
  final String id;
  final String title;
  final String subtitle;
  final TrainingMaterialType type; // Ganti dari MaterialType ke TrainingMaterialType
  final String? description;

  MaterialItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    this.description,
  });

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      type: TrainingMaterialType.values.firstWhere(
        (type) => type.toString().split('.').last == json['type'],
      ),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'type': type.toString().split('.').last,
      'description': description,
    };
  }
}

// Ganti nama enum dari MaterialType ke TrainingMaterialType
enum TrainingMaterialType {
  slide,
  video,
  example,
  document,
}