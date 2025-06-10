import '../model/loginregis_model.dart';

class EditProfileRepository {
  RegisterModel? _currentUser;

  // Set current user data from AuthBloc
  void setCurrentUser(RegisterModel user) {
    _currentUser = user;
  }

  // Get current user data
  Future<RegisterModel> getCurrentUser() async {
    // Simulasi delay API
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_currentUser == null) {
      throw Exception('User data tidak ditemukan. Silakan login ulang.');
    }
    
    return _currentUser!;
  }

  // Update profile
  Future<bool> updateProfile(RegisterModel updatedUser) async {
    // Simulasi delay API
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Simulasi kemungkinan error (10% chance)
    if (DateTime.now().millisecond % 10 == 0) {
      throw Exception('Gagal mengupdate profile. Silakan coba lagi.');
    }
    
    _currentUser = updatedUser;
    return true;
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