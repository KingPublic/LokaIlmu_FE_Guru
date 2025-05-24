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
  final DateTime tglLahir;

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
    required this.tglLahir,
  });

  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(
      namaLengkap: json['namaLengkap'],
      email: json['email'],
      password: json['password'],
      confirmPassword: json['confirmPassword'],
      nip: json['nip'],
      namaSekolah: json['namaSekolah'],
      npsn: json['npsn'],
      tingkatPengajar: json['tingkatPengajar'],
      spesialisasi: json['spesialisasi'],
      ktpPath: json['ktpPath'],
      tglLahir: json['tglLahir'],
    );
  }
}

class LoginModel {
  final String emailOrPhone;
  final String password;

  LoginModel({
    required this.emailOrPhone,
    required this.password,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      emailOrPhone: json['emailOrPhone'],
      password: json['password'],
    );
  }
}
