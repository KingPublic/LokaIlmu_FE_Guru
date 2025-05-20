import 'package:hive/hive.dart';

part 'mentor_model.g.dart';

@HiveType(typeId: 2) // Pastikan typeId unik (tidak bentrok dengan model lain)
class MentorModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String institution;

  @HiveField(3)
  final String imageUrl;

  @HiveField(4)
  final double rating;

  @HiveField(5)
  final int reviewCount;

  @HiveField(6)
  final String description;

  @HiveField(7)
  final List<String> categories;

  @HiveField(8)
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
      institution: json['institution'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      description: json['description'] ?? '',
      categories: List<String>.from(json['categories'] ?? []),
      pricePerSession: json['reviewCount'] ?? 0
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
      'pricePerSession': pricePerSession,
    };
  }
}