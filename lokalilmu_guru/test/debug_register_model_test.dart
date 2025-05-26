// import 'package:flutter_test/flutter_test.dart';
// import 'package:lokalilmu_guru/model/loginregis_model.dart';

// void main() {
//   group('RegisterModel Debug Tests', () {
//     test('should debug RegisterModel.fromJson parsing', () {
//       // Test data yang sama dengan mock
//       final userData = {
//         "idUser": "USR171900118",
//         "namaLengkap": "Test User",
//         "email": "test@example.com",
//         "noHP": "081234567890",
//       };

//       print('🔍 Testing RegisterModel.fromJson with: $userData');
      
//       try {
//         final registerModel = RegisterModel.fromJson(userData);
//         print('✅ RegisterModel created successfully:');
//         print('  - idUser: ${registerModel.idUser}');
//         print('  - namaLengkap: ${registerModel.namaLengkap}');
//         print('  - email: ${registerModel.email}');
//         print('  - noHP: ${registerModel.noHP}');
//       } catch (e) {
//         print('❌ RegisterModel.fromJson failed: $e');
//         print('❌ Stack trace: ${StackTrace.current}');
//       // }
//     });

//     test('should test different field variations', () {
//       final variations = [
//         {
//           "id": "USR171900118",
//           "nama_lengkap": "Test User",
//           "email": "test@example.com",
//           "no_hp": "081234567890",
//         },
//         {
//           "user_id": "USR171900118",
//           "name": "Test User",
//           "email": "test@example.com",
//           "phone": "081234567890",
//         }
//       ];

//       for (int i = 0; i < variations.length; i++) {
//         print('🧪 Testing variation $i: ${variations[i]}');
//         try {
//           final result = RegisterModel.fromJson(variations[i]);
//           print('  ✅ Success: $result');
//         } catch (e) {
//           print('  ❌ Failed: $e');
//         }
//       }
//     });
//   });
// }