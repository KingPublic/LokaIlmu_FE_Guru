import 'package:hive/hive.dart';

part 'book_model.g.dart';

@HiveType(typeId: 0)
class BookModel extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String author;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String imageUrl;
  
  @HiveField(5)
  final String? filePath;
  
  @HiveField(6)
  final bool isSaved;

  BookModel({
    required this.title,
    required this.author,
    required this.category,
    required this.description,
    required this.imageUrl,
    this.filePath,
    this.isSaved = false,
  });
  
  BookModel copyWith({
    String? title,
    String? author,
    String? category,
    String? description,
    String? imageUrl,
    String? filePath,
    bool? isSaved,
  }) {
    return BookModel(
      title: title ?? this.title,
      author: author ?? this.author,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      filePath: filePath ?? this.filePath,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}