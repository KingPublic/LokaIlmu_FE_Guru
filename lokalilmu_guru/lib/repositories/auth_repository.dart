import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:lokalilmu_guru/model/auth_response.dart';
import 'package:path/path.dart' as p;

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
      debugPrint("Response Body: ${response.data}");

      final responseData = response.data;
      
    //   if (response.statusCode != null && response.statusCode >= 200 && response.statusCode < 300) {
    //     final data = responseData['data'];
    //     return AuthResponse.fromJson({
    //       'success': true,
    //       'message': responseData['message'],
    //       'user': data['user'],
    //       'profil_guru': data['profil_guru'],
    //       'token': data['token'],
    //     });
    //   } else {
    //     return AuthResponse.fromJson({
    //       'success': false,
    //       'message': responseData['message'],
    //       'errors': responseData['errors'],
    //     });
    //   }
    // } catch (e) {
    //   return AuthResponse(
    //     success: false,
    //     message: 'Terjadi kesalahan: ${e.toString()}',
    //   );
    // }

    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        final data = responseData['data'];
        return AuthResponse.fromJson({
          'success': true,
          'message': responseData['message'],
          'user': data['user'],
          'profil_guru': data['profil_guru'],
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
      final formData = FormData.fromMap({
        'nama_lengkap': data['nama_lengkap'] ?? '',
        'email': data['email'] ?? '',
        'no_hp': data['no_hp'] ?? '',
        'password': data['password'] ?? '',
        'NPSN': data['NPSN'] ?? '',
        'NUPTK': data['NUPTK'] ?? '',
        'tingkatPengajar': data['tingkatPengajar'] ?? '',
        'tgl_lahir': data['tgl_lahir'] ?? '',
        if (ktpFile != null && ktpFile.path.isNotEmpty)
          'pathKTP': await MultipartFile.fromFile(
            ktpFile.path,
            filename: p.basename(ktpFile.path),
            contentType: MediaType('application', 'octet-stream'), // Atur sesuai mime-type yang lebih tepat jika diperlukan
          ),
      });

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

