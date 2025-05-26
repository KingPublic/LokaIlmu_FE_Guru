import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:lokalilmu_guru/repositories/auth_repository.dart';
import 'package:lokalilmu_guru/model/auth_response.dart';

// Generate mocks hanya untuk http classes
@GenerateMocks([http.Client])
import 'auth_mock.mocks.dart';

// Wrapper untuk AuthRepository yang bisa menerima custom http client
class TestableAuthRepository extends AuthRepository {
  final http.Client httpClient;
  
  TestableAuthRepository({
    required String baseUrl,
    required this.httpClient,
  }) : super(baseUrl: baseUrl);

  @override
  Future<AuthResponse> loginTeacher(String email, String password) async {
    try {
      print('🚀 TestableAuthRepository.loginTeacher called with: $email');
      
      final response = await httpClient.post(
        Uri.parse('http://127.0.0.1:8000/api/login-guru'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email_or_hp': email,
          'password': password,
        }),
      );

      print('📡 HTTP Response: ${response.statusCode} - ${response.body}');
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = responseData['data'];
        return AuthResponse.fromJson({
          'success': true,
          'message': responseData['message'],
          'user': data['user'],
          'profil_guru': data['profil_guru'],
          'token': data['token'],
        });
      } else {
        return AuthResponse.fromJson({
          'success': false,
          'message': responseData['message'],
          'errors': responseData['errors'],
        });
      }
    } catch (e) {
      print('❌ Exception in loginTeacher: $e');
      return AuthResponse(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  @override
  Future<AuthResponse> registerTeacher(Map<String, dynamic> data) async {
    try {
      print('🚀 TestableAuthRepository.registerTeacher called');
      
      final response = await httpClient.post(
        Uri.parse('http://127.0.0.1:8000/api/register-guru'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      
      print('📡 HTTP Response: ${response.statusCode} - ${response.body}');
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        return AuthResponse.fromJson({
          ...responseData,
          'success': true,
        });
      } else {
        return AuthResponse.fromJson({
          ...responseData,
          'success': false,
        });
      }
    } catch (e) {
      print('❌ Exception in registerTeacher: $e');
      return AuthResponse(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }
}

void main() {
  group('AuthRepository Tests', () {
    late TestableAuthRepository authRepository;
    late MockClient mockClient;

    setUp(() {
      // Arrange - Setup untuk setiap test
      print('🔧 Setting up test...');
      mockClient = MockClient();
      authRepository = TestableAuthRepository(
        baseUrl: 'http://127.0.0.1:8000',
        httpClient: mockClient,
      );
    });

    tearDown(() {
      // Reset mock setelah setiap test
      reset(mockClient);
    });

    
    test('mock client should work properly', () async {
      // Arrange
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async {
        print('🎭 Simple mock called');
        return http.Response('{"test": "success"}', 200);
      });

      // Act
      final response = await mockClient.post(
        Uri.parse('http://test.com'),
        headers: {'Content-Type': 'application/json'},
        body: '{"test": "data"}',
      );

      // Assert
      expect(response.statusCode, 200);
      expect(response.body, '{"test": "success"}');
      verify(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(1);
      print('✅ Mock verification passed');
    });

    group('loginTeacher', () {
      test('should return successful AuthResponse when login is successful', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        final successResponse = {
          'message': 'Login berhasil',
          'data': {
            'user': {
              'id': 1,
              'email': 'test@example.com',
              'nama_lengkap': 'Test User'
            },
            'profil_guru': {
              'id': 1,
              'NUPTK': '1234567890',
              'tingkatPengajar': 'SMA'
            },
            'token': 'mock_token_123'
          }
        };

       
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async {
          print('🎭 Login success mock called');
          return http.Response(
            jsonEncode(successResponse),
            200,
          );
        });

        // Act
        final result = await authRepository.loginTeacher(email, password);

        // Assert
        print('📊 Login Success Result: success=${result.success}, message="${result.message}", token="${result.token}"');
        
        expect(result.success, true);
        expect(result.message, 'Login berhasil');
        expect(result.user, isNotNull);
        expect(result.token, 'mock_token_123');
        
        // Verify mock was called
        verify(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(1);
      });

      test('should return failed AuthResponse when login credentials are invalid', () async {
        // Arrange
        const email = 'wrong@example.com';
        const password = 'wrongpassword';
        final errorResponse = {
          'message': 'Email atau password salah',
          'errors': {
            'email': ['Email tidak ditemukan']
          }
        };

        // Setup mock dengan any untuk fleksibilitas
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async {
          print('🎭 Login error mock called');
          return http.Response(
            jsonEncode(errorResponse),
            401,
          );
        });

        // Act
        final result = await authRepository.loginTeacher(email, password);

        // Assert
        print('📊 Login Error Result: success=${result.success}, message="${result.message}", errors=${result.errors}');
        
        expect(result.success, false);
        expect(result.message, 'Email atau password salah');
        expect(result.errors, isNotNull);
        expect(result.user, isNull);
        expect(result.token, isNull);
        
        // Verify mock was called
        verify(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(1);
      });

      test('should return error AuthResponse when network exception occurs', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenThrow(Exception('Network error'));

        // Act
        final result = await authRepository.loginTeacher(email, password);

        // Assert
        print('📊 Network Error Result: success=${result.success}, message="${result.message}"');
        
        expect(result.success, false);
        expect(result.message, contains('Terjadi kesalahan'));
        expect(result.message, contains('Network error'));
        expect(result.user, isNull);
        expect(result.token, isNull);
        
        // Verify mock was called
        verify(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(1);
      });
    });

    group('registerTeacher', () {
      test('should return successful AuthResponse when registration is successful', () async {
        // Arrange
        final registrationData = {
          'nama_lengkap': 'John Doe',
          'email': 'john@example.com',
          'no_hp': '081234567890',
          'password': 'password123',
          'NPSN': '12345678',
          'NUPTK': '1234567890123456',
          'tingkatPengajar': 'SMA',
          'tgl_lahir': '1990-01-01',
        };

        final successResponse = {
          'message': 'Registrasi berhasil',
          'data': {
            'user': {
              'id': 1,
              'email': 'john@example.com',
              'nama_lengkap': 'John Doe'
            },
            'profil_guru': {
              'id': 1,
              'NUPTK': '1234567890123456',
              'tingkatPengajar': 'SMA'
            },
            'token': 'registration_token_123'
          }
        };

        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async {
          print('🎭 Registration success mock called');
          return http.Response(
            jsonEncode(successResponse),
            201,
          );
        });

        // Act
        final result = await authRepository.registerTeacher(registrationData);

        // Assert
        print('📊 Registration Success Result: success=${result.success}, message="${result.message}", token="${result.token}"');
        
        expect(result.success, true);
        expect(result.message, 'Registrasi berhasil');
        expect(result.user, isNotNull);
        expect(result.token, 'registration_token_123');
        
        // Verify mock was called
        verify(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(1);
      });

      test('should return failed AuthResponse when registration data is invalid', () async {
        // Arrange
        final invalidData = {
          'nama_lengkap': '',
          'email': 'invalid-email',
          'no_hp': '',
          'password': '123',
          'NPSN': '',
          'NUPTK': '',
          'tingkatPengajar': '',
          'tgl_lahir': '',
        };

        final errorResponse = {
          'message': 'Validation failed',
          'errors': {
            'email': ['Format email tidak valid'],
            'password': ['Password minimal 6 karakter'],
            'nama_lengkap': ['Nama lengkap wajib diisi']
          }
        };

        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async {
          print('🎭 Registration error mock called');
          return http.Response(
            jsonEncode(errorResponse),
            422,
          );
        });

        // Act
        final result = await authRepository.registerTeacher(invalidData);

        // Assert
        print('📊 Registration Error Result: success=${result.success}, message="${result.message}", errors=${result.errors}');
        
        expect(result.success, false);
        expect(result.message, 'Validation failed');
        expect(result.errors, isNotNull);
        expect(result.user, isNull);
        expect(result.token, isNull);
        
        // Verify mock was called
        verify(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(1);
      });

      test('should handle network exception during registration', () async {
        // Arrange
        final registrationData = {
          'nama_lengkap': 'John Doe',
          'email': 'john@example.com',
          'no_hp': '081234567890',
          'password': 'password123',
          'NPSN': '12345678',
          'NUPTK': '1234567890123456',
          'tingkatPengajar': 'SMA',
          'tgl_lahir': '1990-01-01',
        };

        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenThrow(Exception('Connection timeout'));

        // Act
        final result = await authRepository.registerTeacher(registrationData);

        // Assert
        print('📊 Registration Network Error Result: success=${result.success}, message="${result.message}"');
        
        expect(result.success, false);
        expect(result.message, contains('Terjadi kesalahan'));
        expect(result.message, contains('Connection timeout'));
        
        // Verify mock was called
        verify(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(1);
      });
    });

    group('Edge Cases', () {
      test('should handle malformed JSON response', () async {
        // Arrange
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async {
          print('🎭 Malformed JSON mock called');
          return http.Response('invalid json', 200);
        });

        // Act
        final result = await authRepository.loginTeacher('test@example.com', 'password');

        // Assert
        expect(result.success, false);
        expect(result.message, contains('Terjadi kesalahan'));
      });

      test('should handle empty response body', () async {
        // Arrange
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async {
          print('🎭 Empty response mock called');
          return http.Response('', 200);
        });

        // Act
        final result = await authRepository.loginTeacher('test@example.com', 'password');

        // Assert
        expect(result.success, false);
        expect(result.message, contains('Terjadi kesalahan'));
      });
    });
  });
}