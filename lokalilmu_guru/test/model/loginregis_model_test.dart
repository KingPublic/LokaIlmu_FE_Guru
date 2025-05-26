import 'package:flutter_test/flutter_test.dart';
import 'package:lokalilmu_guru/model/loginregis_model.dart';

void main() {
  group('RegisterModel Tests', () {
    late RegisterModel registerModel;
    late Map<String, dynamic> validJson;

    setUp(() {
      validJson = {
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
      };

      registerModel = RegisterModel(
        namaLengkap: 'John Doe',
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
    });

    test('should create RegisterModel with valid data', () {
      expect(registerModel.namaLengkap, equals('John Doe'));
      expect(registerModel.email, equals('john.doe@example.com'));
      expect(registerModel.password, equals('password123'));
      expect(registerModel.confirmPassword, equals('password123'));
      expect(registerModel.nip, equals('123456789'));
      expect(registerModel.namaSekolah, equals('SMA Negeri 1'));
      expect(registerModel.npsn, equals('987654321'));
      expect(registerModel.tingkatPengajar, equals('SMA'));
      expect(registerModel.spesialisasi, equals('Matematika'));
      expect(registerModel.ktpPath, equals('/path/to/ktp.jpg'));
      expect(registerModel.tglLahir, equals(DateTime(1990, 5, 15)));
    });

    test('should create RegisterModel from JSON', () {
      final model = RegisterModel.fromJson(validJson);

      expect(model.namaLengkap, equals('John Doe'));
      expect(model.email, equals('john.doe@example.com'));
      expect(model.password, equals('password123'));
      expect(model.confirmPassword, equals('password123'));
      expect(model.nip, equals('123456789'));
      expect(model.namaSekolah, equals('SMA Negeri 1'));
      expect(model.npsn, equals('987654321'));
      expect(model.tingkatPengajar, equals('SMA'));
      expect(model.spesialisasi, equals('Matematika'));
      expect(model.ktpPath, equals('/path/to/ktp.jpg'));
      expect(model.tglLahir, equals(DateTime(1990, 5, 15)));
    });

    test('should handle null values in JSON gracefully', () {
      final jsonWithNulls = <String, dynamic>{
        'namaLengkap': null,
        'email': null,
        'password': null,
        'confirmPassword': null,
        'nip': null,
        'namaSekolah': null,
        'npsn': null,
        'tingkatPengajar': null,
        'spesialisasi': null,
        'ktpPath': null,
        'tglLahir': null,
      };

      expect(() => RegisterModel.fromJson(jsonWithNulls), throwsA(isA<TypeError>()));
    });
  });

  group('LoginModel Tests', () {
    late LoginModel loginModel;
    late Map<String, dynamic> validJson;

    setUp(() {
      validJson = {
        'emailOrPhone': 'john.doe@example.com',
        'password': 'password123',
      };

      loginModel = LoginModel(
        emailOrPhone: 'john.doe@example.com',
        password: 'password123',
      );
    });

    test('should create LoginModel with valid data', () {
      expect(loginModel.emailOrPhone, equals('john.doe@example.com'));
      expect(loginModel.password, equals('password123'));
    });

    test('should create LoginModel from JSON', () {
      final model = LoginModel.fromJson(validJson);

      expect(model.emailOrPhone, equals('john.doe@example.com'));
      expect(model.password, equals('password123'));
    });

    test('should create LoginModel with phone number', () {
      final phoneLoginModel = LoginModel(
        emailOrPhone: '+6281234567890',
        password: 'password123',
      );

      expect(phoneLoginModel.emailOrPhone, equals('+6281234567890'));
      expect(phoneLoginModel.password, equals('password123'));
    });

    test('should handle null values in JSON gracefully', () {
      final jsonWithNulls = <String, dynamic>{
        'emailOrPhone': null,
        'password': null,
      };

      expect(() => LoginModel.fromJson(jsonWithNulls), throwsA(isA<TypeError>()));
    });
  });
}