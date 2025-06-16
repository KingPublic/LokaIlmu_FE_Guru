import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:lokalilmu_guru/model/auth_response.dart';
import 'package:path/path.dart' as p;

void debugFormData(FormData formData) {
  final Map<String, dynamic> jsonMap = {};

  // Tambahkan fields biasa
  for (final field in formData.fields) {
    jsonMap[field.key] = field.value;
  }

  // Tambahkan info file (tanpa isi file-nya, hanya nama dan key)
  for (final file in formData.files) {
    jsonMap[file.key] = {
      'filename': file.value.filename,
      'contentType': file.value.contentType.toString(),
    };
  }

  // Cetak hasil dalam bentuk JSON
  debugPrint(jsonEncode(jsonMap));
}


class AuthRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  Future<AuthResponse> loginTeacher(String email, String password) async {
    try {
      final formData = FormData.fromMap({
        'email_or_hp': email ?? '',
        'password': password ?? '',
      });

      final response = await _dio.post(
        '/login-guru',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      debugPrint("Status Code: ${response.statusCode}");

      // debugPrint("Response Body: ${response.body}");
      // final responseData = jsonDecode(response.body);
      debugPrint("Response Body: ${response.data}");
      final responseData = response.data;

    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        final data = responseData['data'];
        final userData = data['user'] ?? {};
        final profilGuruData = data['profil_guru'] ?? {};

        debugPrint('Raw API response: $responseData');
        debugPrint('User data: ${data['user']}');
        debugPrint('Profil guru data: ${data['profil_guru']}');
        debugPrint('Token: ${data['token']}');

        return AuthResponse.fromJson({
          'success': true,
          'message': responseData['message'],
          'user': userData,
          'profil_guru': profilGuruData,
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
      return AuthResponse(
        success: false,
        message: 'Terjadi kesalahan tidak diketahui: ${e.toString()}',
      );
    }
  }

  Future<AuthResponse> registerTeacher(Map<String, dynamic> data, {File? ktpFile}) async {//, File ktpFile) async {
    try {
      final spesialisasi = data['spesialisasi'];

      List<String> spesialisasiList;
      if (spesialisasi is List<String>) {
        spesialisasiList = spesialisasi;
      } else if (spesialisasi is String) {
        spesialisasiList = spesialisasi.split(',').map((e) => e.trim()).toList();
      } else {
        spesialisasiList = [];
      }

      // final dataPayload = {
      //   'nama_lengkap': data['nama_lengkap'] ?? '',
      //   'email': data['email'] ?? '',
      //   'no_hp': data['no_hp'] ?? '',
      //   'password': data['password'] ?? '',
      //   'NPSN': data['NPSN'] ?? '',
      //   'NUPTK': data['NUPTK'] ?? '',
      //   'tingkatPengajar': data['tingkatPengajar'] ?? '',
      //   'tgl_lahir': data['tgl_lahir'] ?? '',
      //   'spesialisasi': spesialisasiList,
      // };

      final formData = FormData.fromMap({
        'nama_lengkap': data['nama_lengkap'] ?? '',
        'email': data['email'] ?? '',
        'no_hp': data['no_hp'] ?? '',
        'password': data['password'] ?? '',
        'NPSN': data['NPSN'] ?? '',
        'NUPTK': data['NUPTK'] ?? '',
        'tingkatPengajar': data['tingkatPengajar'] ?? '',
        'spesialisasi': spesialisasiList,
        'tgl_lahir': data['tgl_lahir'] ?? '',
        if (ktpFile != null && ktpFile.path.isNotEmpty)
          'pathKTP': await MultipartFile.fromFile(
            ktpFile.path,
            filename: p.basename(ktpFile.path),
            contentType: MediaType('application', 'octet-stream'), // Atur sesuai mime-type yang lebih tepat jika diperlukan
          ),
      }, ListFormat.multiCompatible);

      // final formData = FormData();

      // formData.fields.add(MapEntry('nama_lengkap', data['nama_lengkap'] ?? ''));
      // formData.fields.add(MapEntry('email', data['email'] ?? ''));
      // formData.fields.add(MapEntry('no_hp', data['no_hp'] ?? ''));
      // formData.fields.add(MapEntry('password', data['password'] ?? ''));
      // formData.fields.add(MapEntry('NPSN', data['NPSN'] ?? ''));
      // formData.fields.add(MapEntry('NUPTK', data['NUPTK'] ?? ''));
      // formData.fields.add(MapEntry('tingkatPengajar', data['tingkatPengajar'] ?? ''));
      // // ... add other single fields similarly

      // // Add spesialisasi array as multiple entries with key 'spesialisasi[]'
      // for (final spec in spesialisasiList) {
      //   formData.fields.add(MapEntry('spesialisasi[]', spec));
      // }

      // // Add file if present
      // if (ktpFile != null && ktpFile.path.isNotEmpty) {
      //   formData.files.add(MapEntry(
      //     'pathKTP',
      //     await MultipartFile.fromFile(
      //       ktpFile.path,
      //       filename: p.basename(ktpFile.path),
      //       contentType: MediaType('application', 'octet-stream'),
      //     ),
      //   ));
      // }


        // DEBUG: Print form data before sending
      debugFormData(formData);
      debugPrint('Spesialisasi is list? ${spesialisasiList is List<String>}');
      debugPrint('Spesialisasi: ${jsonEncode(spesialisasiList)}');
      // debugPrint('Payload JSON:\n${jsonEncode(dataPayload)}');
      // debugPrint('Form Data: ${jsonEncode(formData.fields)}');

      final response = await _dio.post(
        '/register-guru',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      final responseData = response.data;

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
    } on DioException catch (e) {
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
      return AuthResponse(
        success: false,
        message: 'Terjadi kesalahan tidak diketahui: ${e.toString()}',
      );
    }
  }
}

