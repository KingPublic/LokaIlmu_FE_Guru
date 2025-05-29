import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:lokalilmu_guru/model/book_model.dart';

@GenerateMocks([http.Client])
import 'book_repository_test.mocks.dart';

// Testable BookRepository yang simulate API calls
class TestableBookRepository {
  final http.Client httpClient;
  final String baseUrl;

  TestableBookRepository({
    required this.httpClient,
    required this.baseUrl,
  });

  // Simulate API call untuk get all books
  Future<List<BookModel>> getAllBooks() async {
    try {
      final response = await httpClient.get(
        Uri.parse('$baseUrl/api/books'),
        headers: {'Content-Type': 'application/json'},
      );

      print("GET Books - Status Code: ${response.statusCode}");
      print("GET Books - Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> booksJson = responseData['data'];
        
        return booksJson.map((json) => BookModel(
          title: json['title'],
          author: json['author'],
          category: json['category'],
          description: json['description'],
          imageUrl: json['imageUrl'],
          filePath: json['filePath'],
          isSaved: json['isSaved'] ?? false,
        )).toList();
      } else {
        throw Exception('Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      print("ERROR in getAllBooks: $e");
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Simulate API call untuk search books
  Future<List<BookModel>> searchBooks(String keyword, String category) async {
    try {
      final queryParams = {
        'keyword': keyword,
        'category': category,
      };
      
      final uri = Uri.parse('$baseUrl/api/books/search').replace(
        queryParameters: queryParams,
      );

      final response = await httpClient.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      print("Search Books - Status Code: ${response.statusCode}");
      print("Search Books - Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> booksJson = responseData['data'];
        
        return booksJson.map((json) => BookModel(
          title: json['title'],
          author: json['author'],
          category: json['category'],
          description: json['description'],
          imageUrl: json['imageUrl'],
          filePath: json['filePath'],
          isSaved: json['isSaved'] ?? false,
        )).toList();
      } else {
        throw Exception('Failed to search books: ${response.statusCode}');
      }
    } catch (e) {
      print("ERROR in searchBooks: $e");
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Simulate API call untuk save book
  Future<bool> saveBook(BookModel book) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$baseUrl/api/books/save'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': book.title,
          'author': book.author,
          'category': book.category,
        }),
      );

      print("Save Book - Status Code: ${response.statusCode}");
      print("Save Book - Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      print("ERROR in saveBook: $e");
      return false;
    }
  }

  // Simulate API call untuk unsave book
  Future<bool> unsaveBook(BookModel book) async {
    try {
      final response = await httpClient.delete(
        Uri.parse('$baseUrl/api/books/save'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': book.title,
        }),
      );

      print("Unsave Book - Status Code: ${response.statusCode}");
      print("Unsave Book - Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      print("ERROR in unsaveBook: $e");
      return false;
    }
  }

  // Simulate API call untuk get saved books
  Future<List<BookModel>> getSavedBooks() async {
    try {
      final response = await httpClient.get(
        Uri.parse('$baseUrl/api/books/saved'),
        headers: {'Content-Type': 'application/json'},
      );

      print("Get Saved Books - Status Code: ${response.statusCode}");
      print("Get Saved Books - Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> booksJson = responseData['data'];
        
        return booksJson.map((json) => BookModel(
          title: json['title'],
          author: json['author'],
          category: json['category'],
          description: json['description'],
          imageUrl: json['imageUrl'],
          filePath: json['filePath'],
          isSaved: true, // Saved books always have isSaved = true
        )).toList();
      } else {
        throw Exception('Failed to load saved books: ${response.statusCode}');
      }
    } catch (e) {
      print("ERROR in getSavedBooks: $e");
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Simulate API call untuk get books by category
  Future<List<BookModel>> getBooksByCategory(String category) async {
    try {
      final response = await httpClient.get(
        Uri.parse('$baseUrl/api/books/category/$category'),
        headers: {'Content-Type': 'application/json'},
      );

      print("Get Books by Category - Status Code: ${response.statusCode}");
      print("Get Books by Category - Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> booksJson = responseData['data'];
        
        return booksJson.map((json) => BookModel(
          title: json['title'],
          author: json['author'],
          category: json['category'],
          description: json['description'],
          imageUrl: json['imageUrl'],
          filePath: json['filePath'],
          isSaved: json['isSaved'] ?? false,
        )).toList();
      } else {
        throw Exception('Failed to load books by category: ${response.statusCode}');
      }
    } catch (e) {
      print("ERROR in getBooksByCategory: $e");
      throw Exception('Network error: ${e.toString()}');
    }
  }
}

void main() {
  group('BookRepository API Tests', () {
    late MockClient mockClient;
    late TestableBookRepository bookRepository;

    setUp(() {
      mockClient = MockClient();
      bookRepository = TestableBookRepository(
        httpClient: mockClient,
        baseUrl: 'http://127.0.0.1:8000',
      );
    });

    tearDown(() {
      reset(mockClient);
    });

    test('getAllBooks should return list of books when API call succeeds', () async {
      // Arrange
      final mockResponse = {
        "success": true,
        "message": "Books retrieved successfully",
        "data": [
          {
            "title": "Dasar-Dasar Pemrograman",
            "author": "Shinta Esabella, Miftahul Haq",
            "category": "Informatika",
            "description": "Buku tentang dasar pemrograman",
            "imageUrl": "asset/images/dasar_program.jpeg",
            "filePath": "asset/file/dasar_program.pdf",
            "isSaved": false,
          },
          {
            "title": "Fisika SMA",
            "author": "Marianna Magdalena Radjawane",
            "category": "Sains",
            "description": "Buku fisika untuk SMA",
            "imageUrl": "asset/images/fisika-bs.png",
            "filePath": "asset/file/fisika-bs.pdf",
            "isSaved": true,
          }
        ]
      };

      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      // Act
      final result = await bookRepository.getAllBooks();

      // Assert
      expect(result, isA<List<BookModel>>());
      expect(result.length, 2);
      expect(result[0].title, 'Dasar-Dasar Pemrograman');
      expect(result[0].category, 'Informatika');
      expect(result[0].isSaved, false);
      expect(result[1].title, 'Fisika SMA');
      expect(result[1].isSaved, true);
      
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('getAllBooks should throw exception when API call fails', () async {
      // Arrange
      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('Server Error', 500));

      // Act & Assert
      expect(
        () async => await bookRepository.getAllBooks(),
        throwsA(isA<Exception>()),
      );
      
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('searchBooks should return filtered books when search succeeds', () async {
      // Arrange
      const keyword = 'Fisika';
      const category = 'Sains';
      
      final mockResponse = {
        "success": true,
        "message": "Search completed successfully",
        "data": [
          {
            "title": "Fisika SMA",
            "author": "Marianna Magdalena Radjawane",
            "category": "Sains",
            "description": "Buku fisika untuk SMA",
            "imageUrl": "asset/images/fisika-bs.png",
            "filePath": "asset/file/fisika-bs.pdf",
            "isSaved": false,
          }
        ]
      };

      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      // Act
      final result = await bookRepository.searchBooks(keyword, category);

      // Assert
      expect(result, isA<List<BookModel>>());
      expect(result.length, 1);
      expect(result[0].title, 'Fisika SMA');
      expect(result[0].category, 'Sains');
      
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('saveBook should return true when book is saved successfully', () async {
      // Arrange
      final book = BookModel(
        title: 'Test Book',
        author: 'Test Author',
        category: 'Test Category',
        description: 'Test Description',
        imageUrl: 'test_image.jpg',
      );

      final mockResponse = {
        "success": true,
        "message": "Book saved successfully",
      };

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      // Act
      final result = await bookRepository.saveBook(book);

      // Assert
      expect(result, true);
      
      verify(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).called(1);
    });

    test('saveBook should return false when save fails', () async {
      // Arrange
      final book = BookModel(
        title: 'Test Book',
        author: 'Test Author',
        category: 'Test Category',
        description: 'Test Description',
        imageUrl: 'test_image.jpg',
      );

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Bad Request', 400));

      // Act
      final result = await bookRepository.saveBook(book);

      // Assert
      expect(result, false);
      
      verify(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).called(1);
    });

    test('unsaveBook should return true when book is unsaved successfully', () async {
      // Arrange
      final book = BookModel(
        title: 'Test Book',
        author: 'Test Author',
        category: 'Test Category',
        description: 'Test Description',
        imageUrl: 'test_image.jpg',
        isSaved: true,
      );

      final mockResponse = {
        "success": true,
        "message": "Book unsaved successfully",
      };

      when(mockClient.delete(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      // Act
      final result = await bookRepository.unsaveBook(book);

      // Assert
      expect(result, true);
      
      verify(mockClient.delete(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).called(1);
    });

    test('getSavedBooks should return list of saved books', () async {
      // Arrange
      final mockResponse = {
        "success": true,
        "message": "Saved books retrieved successfully",
        "data": [
          {
            "title": "Saved Book 1",
            "author": "Author 1",
            "category": "Category 1",
            "description": "Description 1",
            "imageUrl": "image1.jpg",
            "filePath": "file1.pdf",
          },
          {
            "title": "Saved Book 2",
            "author": "Author 2",
            "category": "Category 2",
            "description": "Description 2",
            "imageUrl": "image2.jpg",
            "filePath": "file2.pdf",
          }
        ]
      };

      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      // Act
      final result = await bookRepository.getSavedBooks();

      // Assert
      expect(result, isA<List<BookModel>>());
      expect(result.length, 2);
      expect(result[0].title, 'Saved Book 1');
      expect(result[0].isSaved, true); // All saved books should have isSaved = true
      expect(result[1].title, 'Saved Book 2');
      expect(result[1].isSaved, true);
      
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('getBooksByCategory should return books filtered by category', () async {
      // Arrange
      const category = 'Informatika';
      
      final mockResponse = {
        "success": true,
        "message": "Books by category retrieved successfully",
        "data": [
          {
            "title": "Dasar-Dasar Pemrograman",
            "author": "Shinta Esabella",
            "category": "Informatika",
            "description": "Buku pemrograman",
            "imageUrl": "programming.jpg",
            "filePath": "programming.pdf",
            "isSaved": false,
          }
        ]
      };

      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      // Act
      final result = await bookRepository.getBooksByCategory(category);

      // Assert
      expect(result, isA<List<BookModel>>());
      expect(result.length, 1);
      expect(result[0].title, 'Dasar-Dasar Pemrograman');
      expect(result[0].category, 'Informatika');
      
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('should handle network error gracefully', () async {
      // Arrange
      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenThrow(Exception('Network Error'));

      // Act & Assert
      expect(
        () async => await bookRepository.getAllBooks(),
        throwsA(isA<Exception>()),
      );
      
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });
  });
}