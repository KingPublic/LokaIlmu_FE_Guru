import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:lokalilmu_guru/model/mentor_model.dart';

@GenerateMocks([http.Client])
import 'mentor_repository_test.mocks.dart';

// Testable MentorRepository yang simulate API calls
class TestableMentorRepository {
  final http.Client httpClient;
  final String baseUrl;

  TestableMentorRepository({
    required this.httpClient,
    required this.baseUrl,
  });

  Future<List<MentorModel>> getAllMentors() async {
    try {
      final response = await httpClient.get(
        Uri.parse('$baseUrl/api/mentors'),
        headers: {'Content-Type': 'application/json'},
      );

      print("GET Mentors - Status Code: ${response.statusCode}");
      print("GET Mentors - Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> mentorsJson = responseData['data'];
        
        return mentorsJson.map((json) => MentorModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load mentors: ${response.statusCode}');
      }
    } catch (e) {
      print("ERROR in getAllMentors: $e");
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<List<MentorModel>> searchMentors(String query, String? category) async {
    try {
      final queryParams = <String, String>{
        'query': query,
      };
      
      if (category != null && category != 'Semua Subjek') {
        queryParams['category'] = category;
      }
      
      final uri = Uri.parse('$baseUrl/api/mentors/search').replace(
        queryParameters: queryParams,
      );

      final response = await httpClient.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      print("Search Mentors - Status Code: ${response.statusCode}");
      print("Search Mentors - Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> mentorsJson = responseData['data'];
        
        return mentorsJson.map((json) => MentorModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search mentors: ${response.statusCode}');
      }
    } catch (e) {
      print("ERROR in searchMentors: $e");
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<List<String>> getAllCategories() async {
    try {
      final response = await httpClient.get(
        Uri.parse('$baseUrl/api/mentors/categories'),
        headers: {'Content-Type': 'application/json'},
      );

      print("GET Categories - Status Code: ${response.statusCode}");
      print("GET Categories - Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> categoriesJson = responseData['data'];
        
        return categoriesJson.cast<String>();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print("ERROR in getAllCategories: $e");
      throw Exception('Network error: ${e.toString()}');
    }
  }
}

void main() {
  group('MentorRepository API Tests', () {
    late MockClient mockClient;
    late TestableMentorRepository mentorRepository;

    setUp(() {
      mockClient = MockClient();
      mentorRepository = TestableMentorRepository(
        httpClient: mockClient,
        baseUrl: 'http://127.0.0.1:8000',
      );
    });

    tearDown(() {
      reset(mockClient);
    });

    test('getAllMentors should return list of mentors when API call succeeds', () async {
      // Arrange
      final mockResponse = {
        "success": true,
        "message": "Mentors retrieved successfully",
        "data": [
          {
            "id": "1",
            "name": "Dr. Budi Santoso",
            "expertise": "Matematika",
            "imageUrl": "https://randomuser.me/api/portraits/men/1.jpg",
            "rating": 4.8,
            "reviewCount": 120,
            "description": "Dosen matematika dengan pengalaman mengajar 15 tahun",
            "categories": ["Matematika", "Aljabar", "Kalkulus"],
            "pricePerSession": 100000,
          },
          {
            "id": "2",
            "name": "Siti Rahayu, M.Pd",
            "expertise": "Bahasa Inggris",
            "imageUrl": "https://randomuser.me/api/portraits/women/2.jpg",
            "rating": 4.6,
            "reviewCount": 98,
            "description": "Guru bahasa Inggris berpengalaman",
            "categories": ["Bahasa Inggris", "Grammar", "Speaking"],
            "pricePerSession": 100000,
          }
        ]
      };

      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      // Act
      final result = await mentorRepository.getAllMentors();

      // Assert
      expect(result, isA<List<MentorModel>>());
      expect(result.length, 2);
      expect(result[0].name, 'Dr. Budi Santoso');
      expect(result[0].institution, 'Matematika');
      expect(result[0].rating, 4.8);
      expect(result[1].name, 'Siti Rahayu, M.Pd');
      expect(result[1].categories, contains('Bahasa Inggris'));
      
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('getAllMentors should throw exception when API call fails', () async {
      // Arrange
      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('Server Error', 500));

      // Act & Assert
      expect(
        () async => await mentorRepository.getAllMentors(),
        throwsA(isA<Exception>()),
      );
      
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('searchMentors should return filtered mentors when search succeeds', () async {
      // Arrange
      const query = 'Budi';
      const category = 'Matematika';
      
      final mockResponse = {
        "success": true,
        "message": "Search completed successfully",
        "data": [
          {
            "id": "1",
            "name": "Dr. Budi Santoso",
            "expertise": "Matematika",
            "imageUrl": "https://randomuser.me/api/portraits/men/1.jpg",
            "rating": 4.8,
            "reviewCount": 120,
            "description": "Dosen matematika dengan pengalaman mengajar 15 tahun",
            "categories": ["Matematika", "Aljabar", "Kalkulus"],
            "pricePerSession": 100000,
          }
        ]
      };

      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      // Act
      final result = await mentorRepository.searchMentors(query, category);

      // Assert
      expect(result, isA<List<MentorModel>>());
      expect(result.length, 1);
      expect(result[0].name, 'Dr. Budi Santoso');
      expect(result[0].institution, 'Matematika');
      
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('searchMentors should handle empty query', () async {
      // Arrange
      const query = '';
      const category = null;
      
      final mockResponse = {
        "success": true,
        "message": "All mentors retrieved",
        "data": [
          {
            "id": "1",
            "name": "Dr. Budi Santoso",
            "expertise": "Matematika",
            "imageUrl": "https://randomuser.me/api/portraits/men/1.jpg",
            "rating": 4.8,
            "reviewCount": 120,
            "description": "Dosen matematika",
            "categories": ["Matematika"],
            "pricePerSession": 100000,
          }
        ]
      };

      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      // Act
      final result = await mentorRepository.searchMentors(query, category);

      // Assert
      expect(result, isA<List<MentorModel>>());
      expect(result.length, 1);
      
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('getAllCategories should return list of categories', () async {
      // Arrange
      final mockResponse = {
        "success": true,
        "message": "Categories retrieved successfully",
        "data": [
          "Semua Subjek",
          "Matematika",
          "Bahasa Inggris",
          "Fisika",
          "Pemrograman",
          "Kimia"
        ]
      };

      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      // Act
      final result = await mentorRepository.getAllCategories();

      // Assert
      expect(result, isA<List<String>>());
      expect(result.length, 6);
      expect(result, contains('Semua Subjek'));
      expect(result, contains('Matematika'));
      expect(result, contains('Bahasa Inggris'));
      
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
        () async => await mentorRepository.getAllMentors(),
        throwsA(isA<Exception>()),
      );
      
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });
  });
}