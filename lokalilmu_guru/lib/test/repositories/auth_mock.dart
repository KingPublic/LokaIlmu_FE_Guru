// import 'dart:convert';

// import 'package:flutter_test/flutter_test.dart';
// import 'package:http/http.dart' as http;
// import 'package:lokalilmu_guru/model/auth_response.dart';
// import 'package:lokalilmu_guru/repositories/auth_repository.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';

// import 'auth_mock.mocks.dart';

// @GenerateMocks([http.Client])
// void main() {
//   group('AuthRepository loginTeacher', () {
//     late AuthRepository authRepository;
//     late MockClient mockClient;

//     setUp(() {
//       mockClient = MockClient();
//       authRepository = AuthRepository(baseUrl: 'http://127.0.0.1:8000', client: mockClient);
//     });

//     test('returns AuthResponse with success on valid login', () async {
//       final mockResponseData = {
//         'message': 'Login berhasil',
//         'data': {
//           'user': {'id': 1, 'email': 'john.doe@example.com'},
//           'profil_guru': {
//             'namaLengkap': 'John Doe',
//             'email': 'john.doe@example.com',
//           },
//           'token': 'abc123token',
//         }
//       };

//       when(mockClient.post(
//         Uri.parse('http://127.0.0.1:8000/api/login-guru'),
//         headers: anyNamed('headers'),
//         body: anyNamed('body'),
//       )).thenAnswer((_) async => http.Response(jsonEncode(mockResponseData), 200));

//       final result = await authRepository.loginTeacher('john.doe@example.com', 'password123');

//       expect(result.success, true);
//       expect(result.message, 'Login berhasil');
//       expect(result.token, 'abc123token');
//       expect(result.teacher, isNotNull);
//       expect(result.teacher!.namaLengkap, 'John Doe');
//     });

//     test('returns AuthResponse with failure on invalid login', () async {
//       final mockErrorResponse = {
//         'message': 'Invalid credentials',
//         'errors': {'email_or_hp': ['Email atau password salah']}
//       };

//       when(mockClient.post(
//         Uri.parse('http://127.0.0.1:8000/api/login-guru'),
//         headers: anyNamed('headers'),
//         body: anyNamed('body'),
//       )).thenAnswer((_) async => http.Response(jsonEncode(mockErrorResponse), 401));

//       final result = await authRepository.loginTeacher('wrong@example.com', 'wrongpass');

//       expect(result.success, false);
//       expect(result.message, 'Invalid credentials');
//       expect(result.teacher, isNull);
//     });

//     test('returns AuthResponse with failure on exception', () async {
//       when(mockClient.post(
//         Uri.parse('http://127.0.0.1:8000/api/login-guru'),
//         headers: anyNamed('headers'),
//         body: anyNamed('body'),
//       )).thenThrow(Exception('Network error'));

//       final result = await authRepository.loginTeacher('email@example.com', 'pass');

//       expect(result.success, false);
//       expect(result.message, contains('Terjadi kesalahan'));
//     });
//   });
// }
