import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:lokalilmu_guru/model/schedule_item.dart';
import 'package:lokalilmu_guru/model/training_item.dart';

@GenerateMocks([http.Client])
import 'course_repository_test.mocks.dart';

// Testable CourseRepository yang simulate API calls
class TestableCourseRepository {
  final http.Client httpClient;
  final String baseUrl;

  TestableCourseRepository({
    required this.httpClient,
    required this.baseUrl,
  });

  Future<List<ScheduleItem>> getUpcomingSchedules() async {
    try {
      final response = await httpClient.get(
        Uri.parse('$baseUrl/api/schedules/upcoming'),
        headers: {'Content-Type': 'application/json'},
      );

      print("GET Schedules - Status Code: ${response.statusCode}");
      print("GET Schedules - Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> schedulesJson = responseData['data'];
        
        return schedulesJson.map((json) => ScheduleItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load schedules: ${response.statusCode}');
      }
    } catch (e) {
      print("ERROR in getUpcomingSchedules: $e");
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<TrainingItem?> getCurrentTraining() async {
    try {
      final response = await httpClient.get(
        Uri.parse('$baseUrl/api/training/current'),
        headers: {'Content-Type': 'application/json'},
      );

      print("GET Current Training - Status Code: ${response.statusCode}");
      print("GET Current Training - Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['data'] != null) {
          return TrainingItem.fromJson(responseData['data']);
        } else {
          return null; // No current training
        }
      } else if (response.statusCode == 404) {
        return null; // No current training found
      } else {
        throw Exception('Failed to load current training: ${response.statusCode}');
      }
    } catch (e) {
      print("ERROR in getCurrentTraining: $e");
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<bool> hasJoinedCourses() async {
    try {
      final response = await httpClient.get(
        Uri.parse('$baseUrl/api/courses/status'),
        headers: {'Content-Type': 'application/json'},
      );

      print("GET Course Status - Status Code: ${response.statusCode}");
      print("GET Course Status - Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['hasJoinedCourses'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      print("ERROR in hasJoinedCourses: $e");
      return false;
    }
  }

  Future<bool> toggleCourseState(bool newState) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$baseUrl/api/courses/toggle'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'hasJoinedCourses': newState,
        }),
      );

      print("Toggle Course State - Status Code: ${response.statusCode}");
      print("Toggle Course State - Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      print("ERROR in toggleCourseState: $e");
      return false;
    }
  }
}

void main() {
  group('CourseRepository API Tests', () {
    late MockClient mockClient;
    late TestableCourseRepository courseRepository;

    setUp(() {
      mockClient = MockClient();
      courseRepository = TestableCourseRepository(
        httpClient: mockClient,
        baseUrl: 'http://127.0.0.1:8000',
      );
    });

    tearDown(() {
      reset(mockClient);
    });

    test('getUpcomingSchedules should return list of schedules when API call succeeds', () async {
      // Arrange
      final mockResponse = {
        "success": true,
        "message": "Schedules retrieved successfully",
        "data": [
          {
            "id": "1",
            "title": "Sesi 1: Mengenal Microsoft Excel & Navigasi",
            "startDate": "2023-04-21T12:00:00.000Z",
            "endDate": "2023-04-21T15:00:00.000Z",
          },
          {
            "id": "2",
            "title": "Sesi 2: Format Data & Pengolahan Dasar",
            "startDate": "2023-04-25T10:00:00.000Z",
            "endDate": "2023-04-25T13:00:00.000Z",
          }
        ]
      };

      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      // Act
      final result = await courseRepository.getUpcomingSchedules();

      // Assert
      expect(result, isA<List<ScheduleItem>>());
      expect(result.length, 2);
      expect(result[0].title, 'Sesi 1: Mengenal Microsoft Excel & Navigasi');
      expect(result[0].id, '1');
      expect(result[1].title, 'Sesi 2: Format Data & Pengolahan Dasar');
      expect(result[1].id, '2');
      
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('getUpcomingSchedules should throw exception when API call fails', () async {
      // Arrange
      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('Server Error', 500));

      // Act & Assert
      expect(
        () async => await courseRepository.getUpcomingSchedules(),
        throwsA(isA<Exception>()),
      );
      
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('getCurrentTraining should return training item when available', () async {
      // Arrange
      final mockResponse = {
        "success": true,
        "message": "Current training retrieved successfully",
        "data": {
          "id": "1",
          "title": "Pengenalan & Dasar-Dasar Excel",
          "startDate": "2023-04-19T00:00:00.000Z",
          "endDate": "2023-05-03T00:00:00.000Z",
          "totalSessions": 10,
          "completedSessions": 1,
        }
      };

      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      // Act
      final result = await courseRepository.getCurrentTraining();

      // Assert
      expect(result, isA<TrainingItem>());
      expect(result!.title, 'Pengenalan & Dasar-Dasar Excel');
      expect(result.id, '1');
      expect(result.totalSessions, 10);
      expect(result.completedSessions, 1);
      expect(result.progressPercentage, 0.1); // 1/10 = 0.1
      
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('getCurrentTraining should return null when no training available', () async {
      // Arrange
      final mockResponse = {
        "success": true,
        "message": "No current training found",
        "data": null,
      };

      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      // Act
      final result = await courseRepository.getCurrentTraining();

      // Assert
      expect(result, isNull);
      
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('getCurrentTraining should return null when API returns 404', () async {
      // Arrange
      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('Not Found', 404));

      // Act
      final result = await courseRepository.getCurrentTraining();

      // Assert
      expect(result, isNull);
      
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('hasJoinedCourses should return true when user has joined courses', () async {
      // Arrange
      final mockResponse = {
        "success": true,
        "hasJoinedCourses": true,
        "message": "User has joined courses",
      };

      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      // Act
      final result = await courseRepository.hasJoinedCourses();

      // Assert
      expect(result, true);
      
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('hasJoinedCourses should return false when user has not joined courses', () async {
      // Arrange
      final mockResponse = {
        "success": true,
        "hasJoinedCourses": false,
        "message": "User has not joined any courses",
      };

      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      // Act
      final result = await courseRepository.hasJoinedCourses();

      // Assert
      expect(result, false);
      
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('hasJoinedCourses should return false when API call fails', () async {
      // Arrange
      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('Server Error', 500));

      // Act
      final result = await courseRepository.hasJoinedCourses();

      // Assert
      expect(result, false);
      
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('toggleCourseState should return true when toggle succeeds', () async {
      // Arrange
      const newState = true;
      final mockResponse = {
        "success": true,
        "message": "Course state updated successfully",
      };

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      // Act
      final result = await courseRepository.toggleCourseState(newState);

      // Assert
      expect(result, true);
      
      verify(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).called(1);
    });

    test('toggleCourseState should return false when toggle fails', () async {
      // Arrange
      const newState = false;

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Bad Request', 400));

      // Act
      final result = await courseRepository.toggleCourseState(newState);

      // Assert
      expect(result, false);
      
      verify(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).called(1);
    });

    test('should handle network error gracefully', () async {
      // Arrange
      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenThrow(Exception('Network Error'));

      // Act & Assert
      expect(
        () async => await courseRepository.getUpcomingSchedules(),
        throwsA(isA<Exception>()),
      );
      
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });
  });
}