import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:lokalilmu_guru/repositories/auth_repository.dart';
import 'package:lokalilmu_guru/model/auth_response.dart';

@GenerateMocks([http.Client])
import 'auth_mock_test.mocks.dart';

class TestableAuthRepository extends AuthRepository {
  final http.Client httpClient;

  TestableAuthRepository({
    required String baseUrl,
    required this.httpClient,
  }) : super(baseUrl: baseUrl);

  // Helper method untuk convert string date ke DateTime
  Map<String, dynamic> _preprocessUserData(Map<String, dynamic> userData) {
    final processedData = Map<String, dynamic>.from(userData);
    
    // Convert string date ke DateTime object untuk RegisterModel
    if (processedData['tglLahir'] is String) {
      processedData['tglLahir'] = DateTime.parse(processedData['tglLahir']);
    }
    
    return processedData;
  }

  @override
  Future<AuthResponse> loginTeacher(String email, String password) async {
    try {
      final response = await httpClient.post(
        Uri.parse('http://127.0.0.1:8000/api/login-guru'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email_or_hp': email,
          'password': password,
        }),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
  
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = responseData['data'];
        
        // ✅ Preprocess user data untuk convert date string ke DateTime
        final processedUserData = _preprocessUserData(data['user']);
        
        return AuthResponse.fromJson({
          'success': true,
          'message': responseData['message'],
          'teacher': processedUserData, // Gunakan processed data
          'token': data['token'],
        });
      } else {
        return AuthResponse.fromJson({
          'success': false,
          'message': responseData['message'],
        });
      }
    } catch (e) {
      print("ERROR in loginTeacher: $e");
      return AuthResponse(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  @override
  Future<AuthResponse> registerTeacher(Map<String, dynamic> data) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:8000/api/register-guru'),
      );

      request.fields['nama_lengkap'] = data['nama_lengkap'] ?? '';
      request.fields['email'] = data['email'] ?? '';
      request.fields['no_hp'] = data['no_hp'] ?? '';
      request.fields['password'] = data['password'] ?? '';
      request.fields['NPSN'] = data['NPSN'] ?? '';
      request.fields['NUPTK'] = data['NUPTK'] ?? '';
      request.fields['tingkatPengajar'] = data['tingkatPengajar'] ?? '';
      request.fields['tgl_lahir'] = data['tgl_lahir'] ?? '';

      final streamedResponse = await httpClient.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        // ✅ Preprocess user data untuk convert date string ke DateTime
        final userData = responseData['data']?['user'];
        final processedUserData = userData != null ? _preprocessUserData(userData) : null;
        
        return AuthResponse.fromJson({
          'success': true,
          'message': responseData['message'],
          'teacher': processedUserData,
          'token': responseData['data']?['token'],
        });
      } else {
        return AuthResponse.fromJson({
          'success': false,
          'message': responseData['message'],
        });
      }
    } catch (e) {
      print("ERROR in registerTeacher: $e");
      return AuthResponse(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }
}

void main() {
  group('AuthRepository Final Tests', () {
    late MockClient mockClient;
    late TestableAuthRepository authRepository;

    setUp(() {
      mockClient = MockClient();
      authRepository = TestableAuthRepository(
        baseUrl: 'http://127.0.0.1:8000',
        httpClient: mockClient,
      );
    });

    tearDown(() {
      reset(mockClient);
    });

    test('loginTeacher should return success when credentials are valid', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      
      // ✅ Mock response dengan STRING date (JSON-encodable)
      final mockResponse = {
        "status": "success",
        "message": "Login berhasil",
        "data": {
          "user": {
            "namaLengkap": "Test User",
            "email": email,
            "password": "dummy_password",
            "confirmPassword": "dummy_password",
            "nip": "123456789",
            "namaSekolah": "SMA Test",
            "npsn": "12345678",
            "tingkatPengajar": "SMA",
            "spesialisasi": "Matematika",
            "ktpPath": "/path/to/ktp.jpg",
            "tglLahir": "1990-01-01T00:00:00.000Z", // ✅ String, akan di-convert ke DateTime
          },
          "token": "abc123",
          "token_type": "Bearer"
        }
      };

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      // Act
      final result = await authRepository.loginTeacher(email, password);

      // Assert
      expect(result.success, true, reason: 'Login should be successful');
      expect(result.message, 'Login berhasil', reason: 'Message should match');
      expect(result.token, 'abc123', reason: 'Token should match');
      expect(result.teacher, isNotNull, reason: 'Teacher should not be null');
      expect(result.teacher?.namaLengkap, 'Test User', reason: 'Teacher name should match');
      expect(result.teacher?.email, email, reason: 'Teacher email should match');
      
      verify(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(1);
    });

    test('loginTeacher should return error when credentials are invalid', () async {
      // Arrange
      const email = 'wrong@example.com';
      const password = 'wrongpass';
      final mockResponse = {
        'message': 'Email atau password salah',
      };

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 401));

      // Act
      final result = await authRepository.loginTeacher(email, password);

      // Assert
      expect(result.success, false, reason: 'Login should fail');
      expect(result.message, 'Email atau password salah', reason: 'Error message should match');
      expect(result.teacher, isNull, reason: 'Teacher should be null for failed login');
      expect(result.token, isNull, reason: 'Token should be null for failed login');
      
      verify(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(1);
    });

    test('registerTeacher should return success when registration data is valid', () async {
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

      // ✅ Mock response dengan STRING date
      final mockResponse = {
        "message": "Registrasi berhasil",
        "data": {
          "user": {
            "namaLengkap": registrationData['nama_lengkap'],
            "email": registrationData['email'],
            "password": registrationData['password'],
            "confirmPassword": registrationData['password'],
            "nip": registrationData['NUPTK'],
            "namaSekolah": "SMA Test",
            "npsn": registrationData['NPSN'],
            "tingkatPengajar": registrationData['tingkatPengajar'],
            "spesialisasi": "Umum",
            "ktpPath": "/path/to/ktp.jpg",
            "tglLahir": "1990-01-01T00:00:00.000Z", // ✅ String date
          },
          "token": "regtoken123"
        }
      };

      final mockStreamedResponse = http.StreamedResponse(
        Stream.fromIterable([utf8.encode(jsonEncode(mockResponse))]),
        201,
      );

      when(mockClient.send(any)).thenAnswer((_) async => mockStreamedResponse);

      // Act
      final result = await authRepository.registerTeacher(registrationData);

      // Assert
      expect(result.success, true, reason: 'Registration should be successful');
      expect(result.message, 'Registrasi berhasil', reason: 'Message should match');
      expect(result.token, 'regtoken123', reason: 'Token should match');
      expect(result.teacher, isNotNull, reason: 'Teacher should not be null');
      expect(result.teacher?.namaLengkap, 'John Doe', reason: 'Teacher name should match');
      expect(result.teacher?.email, 'john@example.com', reason: 'Teacher email should match');
      
      verify(mockClient.send(any)).called(1);
    });

    test('registerTeacher should return error when validation fails', () async {
      // Arrange
      final invalidData = {
        'nama_lengkap': '',
        'email': 'invalid-email',
        'password': '123',
      };

      final mockResponse = {
        'message': 'The email must be a valid email address.',
      };

      final mockStreamedResponse = http.StreamedResponse(
        Stream.fromIterable([utf8.encode(jsonEncode(mockResponse))]),
        422,
      );

      when(mockClient.send(any)).thenAnswer((_) async => mockStreamedResponse);

      // Act
      final result = await authRepository.registerTeacher(invalidData);

      // Assert
      expect(result.success, false, reason: 'Registration should fail');
      expect(result.message, contains('email'), reason: 'Should contain email error message');
      expect(result.teacher, isNull, reason: 'Teacher should be null for failed registration');
      expect(result.token, isNull, reason: 'Token should be null for failed registration');
      
      verify(mockClient.send(any)).called(1);
    });

    test('should handle network error gracefully', () async {
      // Arrange
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenThrow(Exception('Network Error'));

      // Act
      final result = await authRepository.loginTeacher('test@example.com', '123456');

      // Assert
      expect(result.success, false, reason: 'Should fail on network error');
      expect(result.message, contains('Terjadi kesalahan'), reason: 'Should contain error message');
      expect(result.message, contains('Network Error'), reason: 'Should contain specific error');
      
      verify(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(1);
    });
  });
}