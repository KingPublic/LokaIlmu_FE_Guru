import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:lokalilmu_guru/model/auth_response.dart';
import 'package:path/path.dart' as p;

class AuthRepository {
  final String baseUrl;
  
  AuthRepository({required this.baseUrl});

  Future<AuthResponse> loginTeacher(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login-guru'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
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
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  Future<AuthResponse> registerTeacher(Map<String, dynamic> data, File ktpFile) async {
    try {
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:8000/api/register-guru'),
      );

      // Add text fields based on the Laravel controller requirements
      request.fields['nama_lengkap'] = data['nama_lengkap'] ?? '';
      request.fields['email'] = data['email'] ?? '';
      request.fields['no_hp'] = data['no_hp'] ?? '';
      request.fields['password'] = data['password'] ?? '';
      request.fields['NPSN'] = data['NPSN'] ?? '';
      request.fields['NUPTK'] = data['NUPTK'] ?? '';
      request.fields['tingkatPengajar'] = data['tingkatPengajar'] ?? '';
      request.fields['tgl_lahir'] = data['tgl_lahir'] ?? '';
      
      // Add KTP file if provided
      if (ktpFile.path.isNotEmpty) {
        final fileExtension = p.extension(ktpFile.path).toLowerCase();
        final mimeType = fileExtension == '.pdf' 
            ? 'application/pdf' 
            : 'image/${fileExtension.replaceAll('.', '')}';
        
        request.files.add(
          await http.MultipartFile.fromPath(
            'pathKTP',
            ktpFile.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      final responseData = jsonDecode(response.body);
      
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
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }
}
