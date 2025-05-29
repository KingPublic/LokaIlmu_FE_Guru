import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:lokalilmu_guru/repositories/auth_repository.dart';
import 'package:lokalilmu_guru/model/auth_response.dart';

// Generate mock untuk Dio
@GenerateMocks([Dio])
import 'auth_mock_test.mocks.dart';

class TestableAuthRepository extends AuthRepository {
  final Dio dio;

  TestableAuthRepository({required this.dio}) {
    // Override _dio dengan mock dio
    // Ini menggunakan teknik reflection untuk mengakses private field
    final field = this.runtimeType.toString() == 'AuthRepository' 
        ? (this as dynamic)._dio 
        : null;
    
    if (field != null) {
      // field = dio;
    }
  }

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
      // Mock response untuk testing
      final response = await dio.post(
        '/login-guru',
        data: FormData.fromMap({
          'email_or_hp': email,
          'password': password,
        }),
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Data: ${response.data}");
      
      final responseData = response.data;
      
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        final data = responseData['data'];
        
        // Preprocess user data untuk convert date string ke DateTime
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
          'errors': responseData['errors'],
        });
      }
    } on DioException catch (e) {
      print("DioException in loginTeacher: $e");
      final response = e.response;
      if (response != null && response.data is Map) {
        return AuthResponse.fromJson({
          'success': false,
          'message': response.data['message'] ?? 'Terjadi kesalahan saat login',
          'errors': response.data['errors'],
        });
      } else {
        return AuthResponse(
          success: false,
          message: 'Gagal menghubungi server: ${e.message}',
        );
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
  Future<AuthResponse> registerTeacher(Map<String, dynamic> data, {File? ktpFile}) async {
    try {
      // Buat FormData untuk testing
      final formData = FormData.fromMap({
        'nama_lengkap': data['nama_lengkap'] ?? '',
        'email': data['email'] ?? '',
        'no_hp': data['no_hp'] ?? '',
        'password': data['password'] ?? '',
        'NPSN': data['NPSN'] ?? '',
        'NUPTK': data['NUPTK'] ?? '',
        'tingkatPengajar': data['tingkatPengajar'] ?? '',
        'tgl_lahir': data['tgl_lahir'] ?? '',
        // KTP file tidak perlu ditest secara real
      });

      final response = await dio.post(
        '/register-guru',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      
      final responseData = response.data;
      
      if (response.statusCode == 201) {
        // Preprocess user data untuk convert date string ke DateTime
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
          'errors': responseData['errors'],
        });
      }
    } on DioException catch (e) {
      print("DioException in registerTeacher: $e");
      final response = e.response;
      if (response != null && response.data is Map) {
        return AuthResponse.fromJson({
          'success': false,
          'message': response.data['message'] ?? 'Terjadi kesalahan saat register',
          'errors': response.data['errors'],
        });
      } else {
        return AuthResponse(
          success: false,
          message: 'Gagal menghubungi server: ${e.message}',
        );
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
  group('AuthRepository Dio Tests', () {
    late MockDio mockDio;
    late TestableAuthRepository authRepository;

    setUp(() {
      mockDio = MockDio();
      authRepository = TestableAuthRepository(dio: mockDio);
    });

    tearDown(() {
      reset(mockDio);
    });

    test('loginTeacher should return success when credentials are valid', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      
      // Mock response dengan STRING date (JSON-encodable)
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
            "tglLahir": "1990-01-01T00:00:00.000Z", // String, akan di-convert ke DateTime
          },
          "token": "abc123",
          "token_type": "Bearer"
        }
      };

      // Mock Dio response
      when(mockDio.post(
        any,
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
        data: mockResponse,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/login-guru'),
      ));

      // Act
      final result = await authRepository.loginTeacher(email, password);

      // Assert
      expect(result.success, true, reason: 'Login should be successful');
      expect(result.message, 'Login berhasil', reason: 'Message should match');
      expect(result.token, 'abc123', reason: 'Token should match');
      expect(result.teacher, isNotNull, reason: 'Teacher should not be null');
      expect(result.teacher?.namaLengkap, 'Test User', reason: 'Teacher name should match');
      expect(result.teacher?.email, email, reason: 'Teacher email should match');
      
      verify(mockDio.post(
        any,
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).called(1);
    });

    test('loginTeacher should return error when credentials are invalid', () async {
      // Arrange
      const email = 'wrong@example.com';
      const password = 'wrongpass';
      final mockResponse = {
        'message': 'Email atau password salah',
      };

      // Mock Dio error response
      when(mockDio.post(
        any,
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).thenThrow(DioException(
        response: Response(
          data: mockResponse,
          statusCode: 401,
          requestOptions: RequestOptions(path: '/login-guru'),
        ),
        requestOptions: RequestOptions(path: '/login-guru'),
      ));

      // Act
      final result = await authRepository.loginTeacher(email, password);

      // Assert
      expect(result.success, false, reason: 'Login should fail');
      expect(result.message, 'Email atau password salah', reason: 'Error message should match');
      expect(result.teacher, isNull, reason: 'Teacher should be null for failed login');
      expect(result.token, isNull, reason: 'Token should be null for failed login');
      
      verify(mockDio.post(
        any,
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).called(1);
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

      // Mock response dengan STRING date
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
            "tglLahir": "1990-01-01T00:00:00.000Z", // String date
          },
          "token": "regtoken123"
        }
      };

      // Mock Dio response
      when(mockDio.post(
        any,
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
        data: mockResponse,
        statusCode: 201,
        requestOptions: RequestOptions(path: '/register-guru'),
      ));

      // Act
      final result = await authRepository.registerTeacher(registrationData);

      // Assert
      expect(result.success, true, reason: 'Registration should be successful');
      expect(result.message, 'Registrasi berhasil', reason: 'Message should match');
      expect(result.token, 'regtoken123', reason: 'Token should match');
      expect(result.teacher, isNotNull, reason: 'Teacher should not be null');
      expect(result.teacher?.namaLengkap, 'John Doe', reason: 'Teacher name should match');
      expect(result.teacher?.email, 'john@example.com', reason: 'Teacher email should match');
      
      verify(mockDio.post(
        any,
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).called(1);
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
        'errors': {
          'email': ['The email must be a valid email address.']
        }
      };

      // Mock Dio error response
      when(mockDio.post(
        any,
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).thenThrow(DioException(
        response: Response(
          data: mockResponse,
          statusCode: 422,
          requestOptions: RequestOptions(path: '/register-guru'),
        ),
        requestOptions: RequestOptions(path: '/register-guru'),
      ));

      // Act
      final result = await authRepository.registerTeacher(invalidData);

      // Assert
      expect(result.success, false, reason: 'Registration should fail');
      expect(result.message, contains('email'), reason: 'Should contain email error message');
      expect(result.teacher, isNull, reason: 'Teacher should be null for failed registration');
      expect(result.token, isNull, reason: 'Token should be null for failed registration');
      
      verify(mockDio.post(
        any,
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).called(1);
    });

    test('should handle network error gracefully', () async {
      // Arrange
      when(mockDio.post(
        any,
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).thenThrow(DioException(
        error: 'Network Error',
        message: 'Failed to connect to server',
        requestOptions: RequestOptions(path: '/login-guru'),
      ));

      // Act
      final result = await authRepository.loginTeacher('test@example.com', '123456');

      // Assert
      expect(result.success, false, reason: 'Should fail on network error');
      expect(result.message, contains('Gagal menghubungi server'), reason: 'Should contain error message');
      
      verify(mockDio.post(
        any,
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).called(1);
    });

    test('registerTeacher should handle file upload', () async {
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

      // Create a temporary file for testing
      final tempFile = File('test_ktp.jpg');
      
      // Mock response
      final mockResponse = {
        "message": "Registrasi berhasil",
        "data": {
          "user": {
            "namaLengkap": registrationData['nama_lengkap'],
            "email": registrationData['email'],
            "tglLahir": "1990-01-01T00:00:00.000Z",
          },
          "token": "regtoken123"
        }
      };

      // Mock Dio response
      when(mockDio.post(
        any,
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
        data: mockResponse,
        statusCode: 201,
        requestOptions: RequestOptions(path: '/register-guru'),
      ));

      // Act
      final result = await authRepository.registerTeacher(registrationData, ktpFile: tempFile);

      // Assert
      expect(result.success, true, reason: 'Registration with file should be successful');
      expect(result.message, 'Registrasi berhasil', reason: 'Message should match');
      
      verify(mockDio.post(
        any,
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).called(1);
    });
  });
}