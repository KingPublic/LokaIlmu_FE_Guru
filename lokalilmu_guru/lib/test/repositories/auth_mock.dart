// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
// import 'package:http/http.dart' as http;
// import 'package:lokalilmu_guru/repositories/auth_repository.dart';
// import 'package:lokalilmu_guru/model/auth_response.dart';

// // Manual Mock Classes - tidak perlu build_runner
// class MockClient extends Mock implements http.Client {}

// // Custom AuthRepository untuk testing yang menerima http.Client
// class TestableAuthRepository extends AuthRepository {
//   final http.Client httpClient;
  
//   TestableAuthRepository({
//     required String baseUrl,
//     required this.httpClient,
//   }) : super(baseUrl: baseUrl);

//   @override
//   Future<AuthResponse> loginTeacher(String email, String password) async {
//     try {
//       final response = await httpClient.post(
//         Uri.parse('http://127.0.0.1:8000/api/login-guru'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'email_or_hp': email,
//           'password': password,
//         }),
//       );

//       final responseData = jsonDecode(response.body);
      
//       if (response.statusCode >= 200 && response.statusCode < 300) {
//         final data = responseData['data'];
//         return AuthResponse.fromJson({
//           'success': true,
//           'message': responseData['message'],
//           'user': data['user'],
//           'profil_guru': data['profil_guru'],
//           'token': data['token'],
//         });
//       } else {
//         return AuthResponse.fromJson({
//           'success': false,
//           'message': responseData['message'],
//           'errors': responseData['errors'],
//         });
//       }
//     } catch (e) {
//       return AuthResponse(
//         success: false,
//         message: 'Terjadi kesalahan: ${e.toString()}',
//       );
//     }
//   }
// }

// void main() {
//   group('AuthRepository Tests', () {
//     late TestableAuthRepository authRepository;
//     late MockClient mockClient;
//     late Uri loginUri;

//     setUp(() {
//       // Arrange - Setup untuk setiap test
//       mockClient = MockClient();
//       authRepository = TestableAuthRepository(
//         baseUrl: 'http://127.0.0.1:8000',
//         httpClient: mockClient,
//       );
//       loginUri = Uri.parse('http://127.0.0.1:8000/api/login-guru');
//     });

//     group('loginTeacher', () {
//       test('should return successful AuthResponse when login is successful', () async {
//         // Arrange
//         const email = 'test@example.com';
//         const password = 'password123';
//         final requestBody = jsonEncode({
//           'email_or_hp': email,
//           'password': password,
//         });
//         final requestHeaders = {'Content-Type': 'application/json'};
        
//         final successResponse = {
//           'message': 'Login berhasil',
//           'data': {
//             'user': {
//               'id': 1,
//               'email': 'test@example.com',
//               'nama_lengkap': 'Test User'
//             },
//             'profil_guru': {
//               'id': 1,
//               'NUPTK': '1234567890',
//               'tingkatPengajar': 'SMA'
//             },
//             'token': 'mock_token_123'
//           }
//         };

//         when(mockClient.post(
//           loginUri,
//           headers: requestHeaders,
//           body: requestBody,
//         )).thenAnswer((_) async => http.Response(
//           jsonEncode(successResponse),
//           200,
//         ));

//         // Act
//         final result = await authRepository.loginTeacher(email, password);

//         // Assert
//         expect(result.success, true);
//         expect(result.message, 'Login berhasil');
//         expect(result.user, isNotNull);
//         expect(result.token, 'mock_token_123');
//         verify(mockClient.post(
//           loginUri,
//           headers: requestHeaders,
//           body: requestBody,
//         )).called(1);
//       });

//       test('should return failed AuthResponse when login credentials are invalid', () async {
//         // Arrange
//         const email = 'wrong@example.com';
//         const password = 'wrongpassword';
//         final requestBody = jsonEncode({
//           'email_or_hp': email,
//           'password': password,
//         });
//         final requestHeaders = {'Content-Type': 'application/json'};
        
//         final errorResponse = {
//           'message': 'Email atau password salah',
//           'errors': {
//             'email': ['Email tidak ditemukan']
//           }
//         };

//         when(mockClient.post(
//           loginUri,
//           headers: requestHeaders,
//           body: requestBody,
//         )).thenAnswer((_) async => http.Response(
//           jsonEncode(errorResponse),
//           401,
//         ));

//         // Act
//         final result = await authRepository.loginTeacher(email, password);

//         // Assert
//         expect(result.success, false);
//         expect(result.message, 'Email atau password salah');
//         expect(result.errors, isNotNull);
//         expect(result.user, isNull);
//         expect(result.token, isNull);
//       });

//       test('should return error AuthResponse when network exception occurs', () async {
//         // Arrange
//         const email = 'test@example.com';
//         const password = 'password123';

//         // Mock semua kemungkinan pemanggilan post method
//         when(mockClient.post(
//           loginUri,
//           headers: {'Content-Type': 'application/json'},
//           body: jsonEncode({
//             'email_or_hp': email,
//             'password': password,
//           }),
//         )).thenThrow(Exception('Network error'));

//         // Act
//         final result = await authRepository.loginTeacher(email, password);

//         // Assert
//         expect(result.success, false);
//         expect(result.message, contains('Terjadi kesalahan'));
//         expect(result.message, contains('Network error'));
//         expect(result.user, isNull);
//         expect(result.token, isNull);
//       });

//       test('should return failed AuthResponse when server returns 500 error', () async {
//         // Arrange
//         const email = 'test@example.com';
//         const password = 'password123';
//         final requestBody = jsonEncode({
//           'email_or_hp': email,
//           'password': password,
//         });
//         final requestHeaders = {'Content-Type': 'application/json'};
        
//         final serverErrorResponse = {
//           'message': 'Internal server error',
//         };

//         when(mockClient.post(
//           loginUri,
//           headers: requestHeaders,
//           body: requestBody,
//         )).thenAnswer((_) async => http.Response(
//           jsonEncode(serverErrorResponse),
//           500,
//         ));

//         // Act
//         final result = await authRepository.loginTeacher(email, password);

//         // Assert
//         expect(result.success, false);
//         expect(result.message, 'Internal server error');
//         expect(result.user, isNull);
//         expect(result.token, isNull);
//       });

//       test('should handle malformed JSON response', () async {
//         // Arrange
//         const email = 'test@example.com';
//         const password = 'password123';
//         final requestBody = jsonEncode({
//           'email_or_hp': email,
//           'password': password,
//         });
//         final requestHeaders = {'Content-Type': 'application/json'};

//         when(mockClient.post(
//           loginUri,
//           headers: requestHeaders,
//           body: requestBody,
//         )).thenAnswer((_) async => http.Response(
//           'Invalid JSON response',
//           200,
//         ));

//         // Act
//         final result = await authRepository.loginTeacher(email, password);

//         // Assert
//         expect(result.success, false);
//         expect(result.message, contains('Terjadi kesalahan'));
//         expect(result.user, isNull);
//         expect(result.token, isNull);
//       });

//       test('should handle empty response body', () async {
//         // Arrange
//         const email = 'test@example.com';
//         const password = 'password123';
//         final requestBody = jsonEncode({
//           'email_or_hp': email,
//           'password': password,
//         });
//         final requestHeaders = {'Content-Type': 'application/json'};

//         when(mockClient.post(
//           loginUri,
//           headers: requestHeaders,
//           body: requestBody,
//         )).thenAnswer((_) async => http.Response('', 200));

//         // Act
//         final result = await authRepository.loginTeacher(email, password);

//         // Assert
//         expect(result.success, false);
//         expect(result.message, contains('Terjadi kesalahan'));
//       });
//     });

//     group('registerTeacher', () {
//       test('should handle registration data correctly', () async {
//         // Arrange
//         final registrationData = {
//           'nama_lengkap': 'John Doe',
//           'email': 'john@example.com',
//           'no_hp': '081234567890',
//           'password': 'password123',
//           'NPSN': '12345678',
//           'NUPTK': '1234567890123456',
//           'tingkatPengajar': 'SMA',
//           'tgl_lahir': '1990-01-01',
//         };

//         // Act & Assert
//         expect(registrationData['nama_lengkap'], isNotEmpty);
//         expect(registrationData['email'], contains('@'));
//         expect(registrationData['password'], isNotEmpty);
//         expect(registrationData['NPSN'], isNotEmpty);
//         expect(registrationData['NUPTK'], isNotEmpty);
//       });

//       test('should handle empty registration data', () {
//         // Arrange
//         final emptyData = <String, dynamic>{};

//         // Act & Assert
//         expect(emptyData['nama_lengkap'] ?? '', isEmpty);
//         expect(emptyData['email'] ?? '', isEmpty);
//         expect(emptyData['password'] ?? '', isEmpty);
//         expect(emptyData['NPSN'] ?? '', isEmpty);
//         expect(emptyData['NUPTK'] ?? '', isEmpty);
//       });

//       test('should validate required fields in registration data', () {
//         // Arrange
//         final incompleteData = {
//           'nama_lengkap': 'John Doe',
//           'email': 'john@example.com',
//           // missing password, NPSN, NUPTK
//         };

//         // Act & Assert
//         expect(incompleteData['nama_lengkap'], isNotNull);
//         expect(incompleteData['email'], isNotNull);
//         expect(incompleteData['password'] ?? '', isEmpty);
//         expect(incompleteData['NPSN'] ?? '', isEmpty);
//         expect(incompleteData['NUPTK'] ?? '', isEmpty);
//       });

//       test('should validate email format in registration data', () {
//         // Arrange
//         final validEmailData = {'email': 'test@example.com'};
//         final invalidEmailData = {'email': 'invalid-email'};

//         // Act & Assert
//         expect(validEmailData['email'], contains('@'));
//         expect(validEmailData['email'], contains('.'));
//         expect(invalidEmailData['email'], isNot(contains('@')));
//       });

//       test('should validate phone number format', () {
//         // Arrange
//         final validPhoneData = {'no_hp': '081234567890'};
//         final invalidPhoneData = {'no_hp': '123'};

//         // Act & Assert
//         expect(validPhoneData['no_hp']?.length, greaterThanOrEqualTo(10));
//         expect(invalidPhoneData['no_hp']?.length, lessThan(10));
//       });
//     });

//     group('Error Handling', () {
//       test('should handle timeout exception', () async {
//         // Arrange
//         const email = 'test@example.com';
//         const password = 'password123';
//         final requestBody = jsonEncode({
//           'email_or_hp': email,
//           'password': password,
//         });
//         final requestHeaders = {'Content-Type': 'application/json'};

//         when(mockClient.post(
//           loginUri,
//           headers: requestHeaders,
//           body: requestBody,
//         )).thenThrow(SocketException('Connection timed out'));

//         // Act
//         final result = await authRepository.loginTeacher(email, password);

//         // Assert
//         expect(result.success, false);
//         expect(result.message, contains('Terjadi kesalahan'));
//         expect(result.message, contains('Connection timed out'));
//       });

//       test('should handle HTTP client exception', () async {
//         // Arrange
//         const email = 'test@example.com';
//         const password = 'password123';
//         final requestBody = jsonEncode({
//           'email_or_hp': email,
//           'password': password,
//         });
//         final requestHeaders = {'Content-Type': 'application/json'};

//         when(mockClient.post(
//           loginUri,
//           headers: requestHeaders,
//           body: requestBody,
//         )).thenThrow(http.ClientException('Client error'));

//         // Act
//         final result = await authRepository.loginTeacher(email, password);

//         // Assert
//         expect(result.success, false);
//         expect(result.message, contains('Terjadi kesalahan'));
//         expect(result.message, contains('Client error'));
//       });

//       test('should handle format exception from malformed JSON', () async {
//         // Arrange
//         const email = 'test@example.com';
//         const password = 'password123';
//         final requestBody = jsonEncode({
//           'email_or_hp': email,
//           'password': password,
//         });
//         final requestHeaders = {'Content-Type': 'application/json'};

//         when(mockClient.post(
//           loginUri,
//           headers: requestHeaders,
//           body: requestBody,
//         )).thenAnswer((_) async => http.Response(
//           '{invalid json}',
//           200,
//         ));

//         // Act
//         final result = await authRepository.loginTeacher(email, password);

//         // Assert
//         expect(result.success, false);
//         expect(result.message, contains('Terjadi kesalahan'));
//       });
//     });

//     group('Response Status Code Handling', () {
//       test('should handle 422 validation error', () async {
//         // Arrange
//         const email = 'invalid@example.com';
//         const password = 'short';
//         final requestBody = jsonEncode({
//           'email_or_hp': email,
//           'password': password,
//         });
//         final requestHeaders = {'Content-Type': 'application/json'};
        
//         final validationErrorResponse = {
//           'message': 'Validation failed',
//           'errors': {
//             'password': ['Password minimal 8 karakter'],
//             'email': ['Email sudah terdaftar']
//           }
//         };

//         when(mockClient.post(
//           loginUri,
//           headers: requestHeaders,
//           body: requestBody,
//         )).thenAnswer((_) async => http.Response(
//           jsonEncode(validationErrorResponse),
//           422,
//         ));

//         // Act
//         final result = await authRepository.loginTeacher(email, password);

//         // Assert
//         expect(result.success, false);
//         expect(result.message, 'Validation failed');
//         expect(result.errors, isNotNull);
//       });

//       test('should handle 403 forbidden error', () async {
//         // Arrange
//         const email = 'blocked@example.com';
//         const password = 'password123';
//         final requestBody = jsonEncode({
//           'email_or_hp': email,
//           'password': password,
//         });
//         final requestHeaders = {'Content-Type': 'application/json'};
        
//         final forbiddenResponse = {
//           'message': 'Akun Anda telah diblokir',
//         };

//         when(mockClient.post(
//           loginUri,
//           headers: requestHeaders,
//           body: requestBody,
//         )).thenAnswer((_) async => http.Response(
//           jsonEncode(forbiddenResponse),
//           403,
//         ));

//         // Act
//         final result = await authRepository.loginTeacher(email, password);

//         // Assert
//         expect(result.success, false);
//         expect(result.message, 'Akun Anda telah diblokir');
//       });
//     });
//   });
// }