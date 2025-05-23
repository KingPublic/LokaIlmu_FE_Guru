import 'package:lokalilmu_guru/model/loginregis_model.dart';

class AuthResponse {
  final bool success;
  final String? message;
  final String? token;
  final RegisterModel? teacher;

  AuthResponse({
    required this.success,
    this.message,
    this.token,
    this.teacher,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'],
      message: json['message'],
      token: json['token'],
      teacher: json['teacher'] != null ? RegisterModel.fromJson(json['teacher']) : null,
    );
  }

  get user => null;

  get profilGuru => null;

  get errors => null;
}
