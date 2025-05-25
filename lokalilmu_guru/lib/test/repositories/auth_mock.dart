// import 'dart:convert';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:http/http.dart' as http;
// import 'package:lokalilmu_guru/model/auth_response.dart';
// import 'package:lokalilmu_guru/repositories/auth_repository.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';

// import 'package:lokalilmu_guru/test/repositories/auth_mock.dart';

// @GenerateMocks([http.Client])
// void main() {
//   group('AuthRepository', () {
//     late MockClient mockClient;
//     late AuthRepository repository;

//     setUp(() {
//       mockClient = MockClient();
//       repository = AuthRepository(baseUrl: 'http://127.0.0.1:8000');
//     });

//     test('loginTeacher returns success AuthResponse when status code is 200', () async {
//       // Arrange
//       const email = 'guru@example.com';
//       const password = 'password123';
//       final mockResponse = {
//         'message': 'Login berhasil',
//         'data': {
//           'user': {'id': 1, 'name': 'Guru'},
//           'profil_guru': {'id': 10, 'nama_lengkap': 'Guru Hebat'},
//           'token': 'dummy_token'
//         }
//       };

//       when(mockClient.post(
//         Uri.parse('http://127.0.0.1:8000/api/login-guru'),
//         headers: anyNamed('headers'),
//         body: anyNamed('body'),
//       )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

//       // Act
//       final result = await repository.loginTeacher(email, password);

//       // Assert
//       expect(result.success, true);
//       expect(result.user?['name'], 'Guru');
//       expect(result.profilGuru?['nama_lengkap'], 'Guru Hebat');
//     });

//     test('registerTeacher returns failed AuthResponse when status code != 201', () async {
//       // Arrange
//       final mockData = {
//         'nama_lengkap': 'Guru Coba',
//         'email': 'guru@coba.com',
//         'no_hp': '08123456789',
//         'password': 'password',
//         'NPSN': '12345678',
//         'NUPTK': '87654321',
//         'tingkatPengajar': 'SMA',
//         'tgl_lahir': '1990-01-01',
//       };

//       final mockResponse = {
//         'message': 'Validasi gagal',
//         'errors': {'email': ['Email sudah digunakan']}
//       };

//       // NOTE: Multipart test tricky. This is a logic test, not integration test.
//       // So we call the real method and fake response handling if you want true coverage use integration testing.

//       // Act
//       final result = await repository.registerTeacher(mockData);

//       // Assert
//       expect(result.success, false);
//       expect(result.message, contains('Terjadi kesalahan'));
//     });
//   });
// }
