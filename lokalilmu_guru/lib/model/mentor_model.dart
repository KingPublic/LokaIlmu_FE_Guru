class MentorModel {
  final String id;
  final String name;
  final String institution;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String description;
  final List<String> categories;
  final int pricePerSession;

  MentorModel({
    required this.id,
    required this.name,
    required this.institution,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.categories,
    required this.pricePerSession,
  });

  // Factory untuk membuat model dari JSON
  factory MentorModel.fromJson(Map<String, dynamic> json) {
    return MentorModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      institution: json['expertise'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      description: json['description'] ?? '',
      categories: List<String>.from(json['categories'] ?? []),
      pricePerSession: json['pricePerSession'] ?? 0,
    );
  }

  // Method untuk mengkonversi model ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'institution': institution,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'description': description,
      'categories': categories,
    };
  }
}