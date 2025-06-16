import 'package:lokalilmu_guru/model/loginregis_model.dart';

class AuthResponse {
  final bool success;
  final String? message;
  final String? token;
  final RegisterModel? user;
  final RegisterModel? profilGuru;

  AuthResponse({
    required this.success,
    this.message,
    this.token,
    this.user,
    this.profilGuru,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'],
      message: json['message'],
      token: json['token'],
      user: json['user'] != null && json['user'] is Map 
        ? RegisterModel.fromJson(json['user'])
        : null,
      profilGuru: json['profil_guru'] != null && json['profil_guru'] is Map
          ? RegisterModel.fromJson(json['profil_guru'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'token': token,
      'user': user?.toJson(),
      'profil_guru': profilGuru?.toJson(),
    };
  }

  get errors => null;
}
