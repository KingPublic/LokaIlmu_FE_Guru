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

  BookModel({
    required this.title,
    required this.author,
    required this.category,
    required this.description,
    required this.imageUrl,
  });
}
