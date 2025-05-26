// import 'package:flutter_test/flutter_test.dart';
// import 'package:lokalilmu_guru/model/auth_response.dart';

// void main() {
//   group('AuthResponse Debug Tests', () {
//     test('should debug AuthResponse.fromJson parsing', () {
//       // Test data yang sama persis dengan mock
//       final testData = {
//         'success': true,
//         'message': 'Login berhasil',
//         'user': {
//           'idUser': 'USR171900118',
//           'namaLengkap': 'Test User',
//           'email': 'test@example.com',
//           'noHP': '081234567890',
//         },
//         'profil_guru': {
//           'idUser': 'USR171900118',
//           'NUPTK': '123123122',
//           'tingkatPengajar': 'SMP',
//         },
//         'token': 'abc123',
//       };

//       print('🔍 Input data: $testData');
      
//       // Test fromJson
//       final authResponse = AuthResponse.fromJson(testData);
      
//       print('🔍 AuthResponse result:');
//       print('  - success: ${authResponse.success}');
//       print('  - message: ${authResponse.message}');
//       print('  - user: ${authResponse.user}');
//       print('  - user type: ${authResponse.user.runtimeType}');
//       print('  - token: ${authResponse.token}');
//       print('  - token type: ${authResponse.token.runtimeType}');
      
//       // Test manual constructor
//       final manualResponse = AuthResponse(
//         success: true,
//         message: 'Login berhasil',
//         // Coba berbagai kemungkinan parameter name
//         // user: testData['user'],
//         // token: testData['token'],
//       );
      
//       print('🔍 Manual constructor result:');
//       print('  - success: ${manualResponse.success}');
//       print('  - message: ${manualResponse.message}');
//       print('  - user: ${manualResponse.user}');
//       print('  - token: ${manualResponse.token}');
//     });

//     test('should test different field names', () {
//       // Test dengan field names yang mungkin berbeda
//       final testVariations = [
//         {
//           'success': true,
//           'message': 'Test',
//           'data': {
//             'user': {'id': 1},
//             'token': 'test123'
//           }
//         },
//         {
//           'success': true,
//           'message': 'Test',
//           'user_data': {'id': 1},
//           'access_token': 'test123'
//         },
//         {
//           'success': true,
//           'message': 'Test',
//           'userData': {'id': 1},
//           'authToken': 'test123'
//         }
//       ];

//       for (int i = 0; i < testVariations.length; i++) {
//         print('🧪 Testing variation $i: ${testVariations[i]}');
//         try {
//           final result = AuthResponse.fromJson(testVariations[i]);
//           print('  ✅ Success - user: ${result.user}, token: ${result.token}');
//         } catch (e) {
//           print('  ❌ Error: $e');
//         }
//       }
//     });
//   });
// }