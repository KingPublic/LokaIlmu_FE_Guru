import 'package:flutter_test/flutter_test.dart';
import 'package:lokalilmu_guru/model/book_model.dart';

void main() {
  group('BookModel Tests', () {
    late BookModel bookModel;

    setUp(() {
      bookModel = BookModel(
        title: 'Flutter Development',
        author: 'John Doe',
        category: 'Programming',
        description: 'A comprehensive guide to Flutter development',
        imageUrl: 'https://example.com/image.jpg',
        filePath: '/path/to/book.pdf',
        isSaved: false,
      );
    });

    test('should create BookModel with all required fields', () {
      expect(bookModel.title, equals('Flutter Development'));
      expect(bookModel.author, equals('John Doe'));
      expect(bookModel.category, equals('Programming'));
      expect(bookModel.description, equals('A comprehensive guide to Flutter development'));
      expect(bookModel.imageUrl, equals('https://example.com/image.jpg'));
      expect(bookModel.filePath, equals('/path/to/book.pdf'));
      expect(bookModel.isSaved, equals(false));
    });

    test('should create BookModel with default values', () {
      final defaultBook = BookModel(
        title: 'Test Book',
        author: 'Test Author',
        category: 'Test Category',
        description: 'Test Description',
        imageUrl: 'test_image.jpg',
      );

      expect(defaultBook.filePath, isNull);
      expect(defaultBook.isSaved, equals(false));
    });

    test('should copy BookModel with new values', () {
      final copiedBook = bookModel.copyWith(
        title: 'Updated Title',
        isSaved: true,
      );

      expect(copiedBook.title, equals('Updated Title'));
      expect(copiedBook.author, equals('John Doe')); // unchanged
      expect(copiedBook.category, equals('Programming')); // unchanged
      expect(copiedBook.description, equals('A comprehensive guide to Flutter development')); // unchanged
      expect(copiedBook.imageUrl, equals('https://example.com/image.jpg')); // unchanged
      expect(copiedBook.filePath, equals('/path/to/book.pdf')); // unchanged
      expect(copiedBook.isSaved, equals(true)); // changed
    });

    test('should copy BookModel with null values', () {
      final copiedBook = bookModel.copyWith(
        filePath: null,
      );

      expect(copiedBook.filePath, isNull);
      expect(copiedBook.title, equals('Flutter Development')); // unchanged
    });

    test('should copy BookModel without changes when no parameters provided', () {
      final copiedBook = bookModel.copyWith();

      expect(copiedBook.title, equals(bookModel.title));
      expect(copiedBook.author, equals(bookModel.author));
      expect(copiedBook.category, equals(bookModel.category));
      expect(copiedBook.description, equals(bookModel.description));
      expect(copiedBook.imageUrl, equals(bookModel.imageUrl));
      expect(copiedBook.filePath, equals(bookModel.filePath));
      expect(copiedBook.isSaved, equals(bookModel.isSaved));
    });

    test('should handle empty strings', () {
      final emptyBook = BookModel(
        title: '',
        author: '',
        category: '',
        description: '',
        imageUrl: '',
      );

      expect(emptyBook.title, equals(''));
      expect(emptyBook.author, equals(''));
      expect(emptyBook.category, equals(''));
      expect(emptyBook.description, equals(''));
      expect(emptyBook.imageUrl, equals(''));
    });
  });
}