import 'package:flutter_test/flutter_test.dart';
import 'package:lokalilmu_guru/model/auth_response.dart';
import 'package:lokalilmu_guru/model/loginregis_model.dart';

void main() {
  group('AuthResponse Tests', () {
    late Map<String, dynamic> validSuccessJson;
    late Map<String, dynamic> validFailureJson;
    late RegisterModel testTeacher;

    setUp(() {
      testTeacher = RegisterModel(
        namaLengkap: 'John Doe',
        noHP: '08123456789',
        email: 'john.doe@example.com',
        password: 'password123',
        confirmPassword: 'password123',
        nip: '123456789',
        namaSekolah: 'SMA Negeri 1',
        npsn: '987654321',
        tingkatPengajar: 'SMA',
        spesialisasi: 'Matematika',
        ktpPath: '/path/to/ktp.jpg',
        tglLahir: DateTime(1990, 5, 15),
      );

      validSuccessJson = {
        'success': true,
        'message': 'Login successful',
        'token': 'abc123token',
        'teacher': {
          'namaLengkap': 'John Doe',
          'email': 'john.doe@example.com',
          'password': 'password123',
          'confirmPassword': 'password123',
          'nip': '123456789',
          'namaSekolah': 'SMA Negeri 1',
          'npsn': '987654321',
          'tingkatPengajar': 'SMA',
          'spesialisasi': 'Matematika',
          'ktpPath': '/path/to/ktp.jpg',
          'tglLahir': DateTime(1990, 5, 15),
        }
      };

      validFailureJson = {
        'success': false,
        'message': 'Invalid credentials',
        'token': null,
        'teacher': null,
      };
    });

    test('should create successful AuthResponse with all fields', () {
      final authResponse = AuthResponse(
        success: true,
        message: 'Login successful',
        token: 'abc123token',
        user: testTeacher,
      );

      expect(authResponse.success, equals(true));
      expect(authResponse.message, equals('Login successful'));
      expect(authResponse.token, equals('abc123token'));
      expect(authResponse.user, equals(testTeacher));
    });

    test('should create failed AuthResponse', () {
      final authResponse = AuthResponse(
        success: false,
        message: 'Invalid credentials',
      );

      expect(authResponse.success, equals(false));
      expect(authResponse.message, equals('Invalid credentials'));
      expect(authResponse.token, isNull);
      expect(authResponse.user, isNull);
    });

    test('should create AuthResponse from successful JSON', () {
      final authResponse = AuthResponse.fromJson(validSuccessJson);

      expect(authResponse.success, equals(true));
      expect(authResponse.message, equals('Login successful'));
      expect(authResponse.token, equals('abc123token'));
      expect(authResponse.user, isNotNull);
      expect(authResponse.user!.namaLengkap, equals('John Doe'));
      expect(authResponse.user!.email, equals('john.doe@example.com'));
    });

    test('should create AuthResponse from failed JSON', () {
      final authResponse = AuthResponse.fromJson(validFailureJson);

      expect(authResponse.success, equals(false));
      expect(authResponse.message, equals('Invalid credentials'));
      expect(authResponse.token, isNull);
      expect(authResponse.user, isNull);
    });

    test('should handle JSON without optional fields', () {
      final minimalJson = {
        'success': true,
      };

      final authResponse = AuthResponse.fromJson(minimalJson);

      expect(authResponse.success, equals(true));
      expect(authResponse.message, isNull);
      expect(authResponse.token, isNull);
      expect(authResponse.user, isNull);
    });

    test('should return null for deprecated getters', () {
      final authResponse = AuthResponse(success: true);

      expect(authResponse.user, isNull);
      expect(authResponse.profilGuru, isNull);
      expect(authResponse.errors, isNull);
    });

    test('should handle malformed teacher JSON', () {
      final malformedJson = {
        'success': true,
        'teacher': {
          'namaLengkap': 'John Doe',
          // Missing required fields
        }
      };

      expect(() => AuthResponse.fromJson(malformedJson), throwsA(isA<TypeError>()));
    });
  });
}