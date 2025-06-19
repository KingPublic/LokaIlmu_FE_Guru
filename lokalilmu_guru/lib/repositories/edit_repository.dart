import 'dart:convert'; // Untuk jsonEncode

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Untuk debugPrint

import '../model/loginregis_model.dart';
import '../services/token.dart';
class EditProfileRepository {
  RegisterModel? _currentUser;
  final TokenService _tokenService = TokenService();

  // Set current user data from AuthBloc
  void setCurrentUser(RegisterModel user) {
    _currentUser = user;
  }

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.193.176:8000/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  // Get current user data
  Future<RegisterModel> getCurrentUser() async {
    try {
      final token = await _tokenService.getToken();
      if (token == null) {
        throw Exception('Token tidak tersedia, silakan login kembali');
      }
      
      _dio.options.headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      final response = await _dio.get('/profile/guru');

      if (response.statusCode == 200) {
        final userData = _parseProfileResponse(response.data);
        _currentUser = userData;
        return userData;
      } else {
        throw Exception('Gagal memuat profil: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Error: ${e.response?.statusCode}');
      } else {
        throw Exception('Koneksi gagal: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  RegisterModel _parseProfileResponse(Map<String, dynamic> json) {
    final userData = json['user'] ?? {};
    final profilGuru = json['profil_guru'] ?? {};
    final spesialisasiData = json['spesialisasi'] is List && json['spesialisasi'].isNotEmpty 
        ? json['spesialisasi'][0] 
        : {};

    return RegisterModel(
      namaLengkap: userData['namaLengkap'] ?? '',
      email: userData['email'] ?? '',
      noHP: userData['noHP'] ?? '',
      password: '', // Tidak disimpan dari response
      confirmPassword: '', // Tidak disimpan dari response
      nip: profilGuru['NUPTK'] ?? '', // Mapping NUPTK ke nip
      namaSekolah: '', // Tidak ada di response
      npsn: profilGuru['NPSN']?.toString() ?? '', // Konversi ke string
      tingkatPengajar: profilGuru['tingkatPengajar'] ?? '',
      spesialisasi: spesialisasiData['spesialisasi'] ?? '',
      ktpPath: profilGuru['pathKTP'] ?? '',
      tglLahir: DateTime.parse(userData['tglLahir'] ?? '2000-01-01'),
    );
  }

  Future<bool> updateProfile(RegisterModel updatedUser) async {
    try {
      final token = await _tokenService.getToken();
      if (token == null) {
        throw Exception('Session expired. Please login again.');
      }

      // 2. Prepare request data
      final requestData = {
        'nama_lengkap': updatedUser.namaLengkap,
        'email': updatedUser.email,
        'no_hp': updatedUser.noHP,
        'password': updatedUser.password.isNotEmpty ? updatedUser.password : null,
        'NPSN': updatedUser.npsn,
        'NUPTK': updatedUser.nip,
        'tingkatPengajar': updatedUser.tingkatPengajar,
        'tgl_lahir': updatedUser.tglLahir?.toIso8601String(),
        'spesialisasi': updatedUser.spesialisasi.split(',').map((s) => s.trim()).toList(),
      };

      // 3. Remove null values
      requestData.removeWhere((key, value) => value == null);

      // 4. Print JSON untuk testing di Insomnia
      final jsonToPrint = {
        'url': '${_dio.options.baseUrl}/editProfileGuru',
        'method': 'PUT',
        'headers': {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        'body': requestData,
      };
      
      debugPrint('=== JSON untuk Insomnia ===');
      debugPrint(jsonEncode(jsonToPrint)); // Cetak dalam format JSON
      debugPrint('==========================');

      // 4. Make API request
      final response = await _dio.put(
        '/edit-profile-guru',
        data: requestData,
      );

      // 5. Handle response
      if (response.statusCode == 200) {
        _currentUser = updatedUser;
        return true;
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Error: ${e.response?.statusCode}');
      } else {
        throw Exception('Koneksi gagal: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Change password
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    // Simulasi delay API
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Validasi password lama
    if (_currentUser?.password != oldPassword) {
      throw Exception('Password lama tidak sesuai');
    }
    
    // Simulasi kemungkinan error (5% chance)
    if (DateTime.now().millisecond % 20 == 0) {
      throw Exception('Gagal mengubah password. Silakan coba lagi.');
    }
    
    // Update password in current user
    if (_currentUser != null) {
      _currentUser = RegisterModel(
        namaLengkap: _currentUser!.namaLengkap,
        email: _currentUser!.email,
        noHP: _currentUser!.noHP,
        password: newPassword,
        confirmPassword: newPassword,
        nip: _currentUser!.nip,
        namaSekolah: _currentUser!.namaSekolah,
        npsn: _currentUser!.npsn,
        tingkatPengajar: _currentUser!.tingkatPengajar,
        spesialisasi: _currentUser!.spesialisasi,
        ktpPath: _currentUser!.ktpPath,
        tglLahir: _currentUser!.tglLahir,
      );
    }
    
    return true;
  }

  // Get current user without async (for immediate access)
  RegisterModel? getCurrentUserSync() {
    return _currentUser;
  }
}