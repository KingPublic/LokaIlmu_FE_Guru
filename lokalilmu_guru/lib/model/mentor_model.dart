class Mentor {
  final String id;
  final String name;
  final String institution;
  final String photoUrl;
  final double rating;
  final List<String> subjects;
  final String description;
  final double pricePerSession;

  Mentor({
    required this.id,
    required this.name,
    required this.institution,
    required this.photoUrl,
    required this.rating,
    required this.subjects,
    required this.description,
    required this.pricePerSession,
  });

  factory Mentor.fromJson(Map<String, dynamic> json) {
    return Mentor(
      id: json['id'],
      name: json['name'],
      institution: json['institution'],
      photoUrl: json['photoUrl'],
      rating: json['rating'].toDouble(),
      subjects: List<String>.from(json['subjects']),
      description: json['description'],
      pricePerSession: json['pricePerSession'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'institution': institution,
      'photoUrl': photoUrl,
      'rating': rating,
      'subjects': subjects,
      'description': description,
      'pricePerSession': pricePerSession,
    };
  }
}