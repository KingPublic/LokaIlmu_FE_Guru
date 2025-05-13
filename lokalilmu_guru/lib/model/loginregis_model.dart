class RegisterModel {
  final String namaLengkap;
  final String email;
  final String password;
  final String confirmPassword;
  final String nip;
  final String namaSekolah;
  final String npsn;
  final String tingkatPengajar;
  final String spesialisasi;
  final String ktpPath;

  RegisterModel({
    required this.namaLengkap,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.nip,
    required this.namaSekolah,
    required this.npsn,
    required this.tingkatPengajar,
    required this.spesialisasi,
    required this.ktpPath,
  });
}

class LoginModel {
  final String emailOrPhone;
  final String password;

  LoginModel({
    required this.emailOrPhone,
    required this.password,
  });
}
