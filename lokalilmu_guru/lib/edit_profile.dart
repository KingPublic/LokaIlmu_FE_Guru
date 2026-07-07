import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../model/loginregis_model.dart';
import '../model/school_model.dart';
import 'blocs/edit_bloc.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _noHpController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nipController = TextEditingController();
  final _npsnController = TextEditingController();

  // Focus nodes
  final _namaFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _noHpFocus = FocusNode();
  final _oldPasswordFocus = FocusNode();
  final _newPasswordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  final _nipFocus = FocusNode();

  // Dropdown values
  String? selectedLevel;
  SchoolModel? selectedSchool;
  final List<String> _spesialisasiList = [];
  String? selectedSpecialization;

  // Original data untuk cancel functionality
  RegisterModel? _originalUserData;
  String? _originalSelectedLevel;
  SchoolModel? _originalSelectedSchool;
  List<String> _originalSpesialisasiList = [];

  // Validation
  final Set<String> _touchedFields = {};
  Map<String, String> _fieldErrors = {};

  // Data
  final List<SchoolModel> schools = [
    SchoolModel(idSekolah: 1, npsn: "12345678", namaSekolah: "SMA Negeri 1 Jakarta"),
    SchoolModel(idSekolah: 2, npsn: "23456789", namaSekolah: "SMA Negeri 2 Jakarta"),
    SchoolModel(idSekolah: 3, npsn: "34567890", namaSekolah: "SMP Negeri 1 Jakarta"),
    SchoolModel(idSekolah: 4, npsn: "45678901", namaSekolah: "SMP Negeri 2 Jakarta"),
    SchoolModel(idSekolah: 5, npsn: "56789012", namaSekolah: "SD Negeri 1 Jakarta"),
    SchoolModel(idSekolah: 6, npsn: "67890123", namaSekolah: "SD Negeri 2 Jakarta"),
  ];

  final List<String> teachingLevels = ['TK', 'SD', 'SMP', 'SMA', 'SMK'];
  final List<String> allSpecializations = [
    'Matematika', 'Bahasa Indonesia', 'Bahasa Inggris', 'IPA', 'IPS', 'PKn',
    'TIK', 'Agama', 'Seni Budaya', 'Kimia', 'Fisika', 'Biologi'
  ];

  @override
  void initState() {
    super.initState();
    _setupFocusListeners();
    _setupTextChangeListeners();
  }

  void _setupFocusListeners() {
    _namaFocus.addListener(() {
      if (!_namaFocus.hasFocus) {
        _touchedFields.add('nama');
        _validateNama();
      }
    });
    
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) {
        _touchedFields.add('email');
        _validateEmail();
      }
    });
    
    _noHpFocus.addListener(() {
      if (!_noHpFocus.hasFocus) {
        _touchedFields.add('phone');
        _validatePhone();
      }
    });
    
    _oldPasswordFocus.addListener(() {
      if (!_oldPasswordFocus.hasFocus) {
        _touchedFields.add('oldPassword');
        _validateOldPassword();
      }
    });
    
    _newPasswordFocus.addListener(() {
      if (!_newPasswordFocus.hasFocus) {
        _touchedFields.add('newPassword');
        _validateNewPassword();
      }
    });
    
    _confirmPasswordFocus.addListener(() {
      if (!_confirmPasswordFocus.hasFocus) {
        _touchedFields.add('confirmPassword');
        _validateConfirmPassword();
      }
    });
    
    _nipFocus.addListener(() {
      if (!_nipFocus.hasFocus) {
        _touchedFields.add('nip');
        _validateNIP();
      }
    });
  }

  void _setupTextChangeListeners() {
    _namaController.addListener(() {
      if (_touchedFields.contains('nama')) _validateNama();
    });
    
    _emailController.addListener(() {
      if (_touchedFields.contains('email')) _validateEmail();
    });
    
    _noHpController.addListener(() {
      if (_touchedFields.contains('phone')) _validatePhone();
    });
    
    _oldPasswordController.addListener(() {
      if (_touchedFields.contains('oldPassword')) _validateOldPassword();
    });
    
    _newPasswordController.addListener(() {
      if (_touchedFields.contains('newPassword')) _validateNewPassword();
      if (_touchedFields.contains('confirmPassword')) _validateConfirmPassword();
    });
    
    _confirmPasswordController.addListener(() {
      if (_touchedFields.contains('confirmPassword')) _validateConfirmPassword();
    });
    
    _nipController.addListener(() {
      if (_touchedFields.contains('nip')) _validateNIP();
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _nipController.dispose();
    _npsnController.dispose();
    
    _namaFocus.dispose();
    _emailFocus.dispose();
    _noHpFocus.dispose();
    _oldPasswordFocus.dispose();
    _newPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _nipFocus.dispose();
    
    super.dispose();
  }

  void _populateFields(RegisterModel user) {
    // Store original data for cancel functionality
    _originalUserData = user;
    
    _namaController.text = user.namaLengkap;
    _emailController.text = user.email;
    _nipController.text = user.nip;
    
    // Handle sekolah - perlu disesuaikan dengan data yang tersedia
    try {
      selectedSchool = schools.firstWhere(
        (school) => school.npsn == user.npsn,
        orElse: () => schools.first
      );
      _npsnController.text = selectedSchool?.npsn ?? user.npsn;
    } catch (e) {
      selectedSchool = schools.first;
      _npsnController.text = user.npsn;
    }
    _originalSelectedSchool = selectedSchool;
    
    // When populating fields
    selectedLevel = teachingLevels.firstWhere(
      (level) => level.toLowerCase() == user.tingkatPengajar.toLowerCase(),
      orElse: () => teachingLevels.first
    );
    _originalSelectedLevel = selectedLevel;
    
    // Parse specializations
    if (user.spesialisasi.isNotEmpty) {
      _spesialisasiList.clear();
      // Handle both comma-separated string and list format
      if (user.spesialisasi.contains(',')) {
        _spesialisasiList.addAll(user.spesialisasi.split(','));
      } else {
        _spesialisasiList.add(user.spesialisasi);
      }
    }
    _originalSpesialisasiList = List.from(_spesialisasiList);
  }

  void _resetToOriginalData() {
    if (_originalUserData != null) {
      setState(() {
        _namaController.text = _originalUserData!.namaLengkap;
        _emailController.text = _originalUserData!.email;
        _nipController.text = _originalUserData!.nip;
        selectedSchool = _originalSelectedSchool;
        _npsnController.text = selectedSchool?.npsn ?? _originalUserData!.npsn;
        selectedLevel = _originalSelectedLevel;
        _spesialisasiList.clear();
        _spesialisasiList.addAll(_originalSpesialisasiList);
        
        // Clear password fields
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        
        // Clear errors and touched fields
        _fieldErrors.clear();
        _touchedFields.clear();
      });
    }
  }

  // Validation methods
  bool _validateNama() {
    if (_namaController.text.trim().isEmpty) {
      setState(() => _fieldErrors['nama'] = 'Nama tidak boleh kosong');
      return false;
    } else {
      setState(() => _fieldErrors.remove('nama'));
      return true;
    }
  }

  bool _validateEmail() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _fieldErrors['email'] = 'Email tidak boleh kosong');
      return false;
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      setState(() => _fieldErrors['email'] = 'Format email tidak valid');
      return false;
    } else {
      setState(() => _fieldErrors.remove('email'));
      return true;
    }
  }

  bool _validatePhone() {
    final phone = _noHpController.text.trim();
    if (phone.isNotEmpty) {
      final phoneRegex = RegExp(r'^8[0-9]{8,12}$');
      if (!phoneRegex.hasMatch(phone)) {
        setState(() => _fieldErrors['phone'] = 'Nomor HP harus diawali dengan 8 dan memiliki 9-13 digit');
        return false;
      }
    }
    setState(() => _fieldErrors.remove('phone'));
    return true;
  }

  bool _validateOldPassword() {
    // Password lama hanya wajib jika user ingin mengubah password
    if (_newPasswordController.text.isNotEmpty && _oldPasswordController.text.isEmpty) {
      setState(() => _fieldErrors['oldPassword'] = 'Password lama wajib diisi jika ingin mengubah password');
      return false;
    } else {
      setState(() => _fieldErrors.remove('oldPassword'));
      return true;
    }
  }

  bool _validateNewPassword() {
    final password = _newPasswordController.text;
    if (password.isNotEmpty && password.length < 6) {
      setState(() => _fieldErrors['newPassword'] = 'Password minimal 6 karakter');
      return false;
    } else {
      setState(() => _fieldErrors.remove('newPassword'));
      return true;
    }
  }

  bool _validateConfirmPassword() {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;
    
    if (newPassword.isNotEmpty) {
      if (confirmPassword.isEmpty) {
        setState(() => _fieldErrors['confirmPassword'] = 'Konfirmasi password tidak boleh kosong');
        return false;
      }
      if (newPassword != confirmPassword) {
        setState(() => _fieldErrors['confirmPassword'] = 'Password tidak cocok');
        return false;
      }
    }
    setState(() => _fieldErrors.remove('confirmPassword'));
    return true;
  }

  bool _validateNIP() {
    if (_nipController.text.trim().isEmpty) {
      setState(() => _fieldErrors['nip'] = 'NIP tidak boleh kosong');
      return false;
    } else {
      setState(() => _fieldErrors.remove('nip'));
      return true;
    }
  }

  bool _validateAllFields() {
    _touchedFields.addAll([
      'nama', 'email', 'phone', 'oldPassword', 'newPassword', 
      'confirmPassword', 'nip', 'school', 'level', 'specialization'
    ]);
    
    bool isValid = true;
    if (!_validateNama()) isValid = false;
    if (!_validateEmail()) isValid = false;
    if (!_validatePhone()) isValid = false;
    if (!_validateOldPassword()) isValid = false;
    if (!_validateNewPassword()) isValid = false;
    if (!_validateConfirmPassword()) isValid = false;
    if (!_validateNIP()) isValid = false;
    if (selectedSchool == null) {
      setState(() => _fieldErrors['school'] = 'Pilih nama sekolah');
      isValid = false;
    }
    if (selectedLevel == null) {
      setState(() => _fieldErrors['level'] = 'Pilih tingkat pengajar');
      isValid = false;
    }
    if (_spesialisasiList.isEmpty) {
      setState(() => _fieldErrors['specialization'] = 'Tambahkan minimal 1 spesialisasi');
      isValid = false;
    }
    
    return isValid;
  }

  void _onSchoolSelected(SchoolModel? school) {
    setState(() {
      selectedSchool = school;
      if (school != null) {
        _npsnController.text = school.npsn;
      } else {
        _npsnController.clear();
      }
      _fieldErrors.remove('school');
    });
  }

  void _addSpesialisasi() {
    if (selectedSpecialization != null && 
        !_spesialisasiList.contains(selectedSpecialization!) && 
        _spesialisasiList.length < 5) {
      setState(() {
        _spesialisasiList.add(selectedSpecialization!);
        selectedSpecialization = null;
        _fieldErrors.remove('specialization');
      });
    }
  }

  void _removeSpesialisasi(String spesialisasi) {
    setState(() {
      _spesialisasiList.remove(spesialisasi);
      if (_spesialisasiList.isEmpty) {
        _fieldErrors['specialization'] = 'Tambahkan minimal 1 spesialisasi';
      }
    });
  }

  void _handleCancel() {
    // Show confirmation dialog before canceling
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Batalkan Perubahan'),
          content: const Text('Apakah Anda yakin ingin membatalkan semua perubahan?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetToOriginalData();
              },
              child: const Text('Ya, Batalkan'),
            ),
          ],
        );
      },
    );
  }

  void _handleSave() {
    if (_validateAllFields()) {
      // Show confirmation dialog before saving
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Simpan Perubahan'),
            content: const Text('Apakah Anda yakin ingin menyimpan perubahan profil?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _saveProfile();
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      );
    }
  }

  void _saveProfile() {
    // Update profile dengan format yang sesuai dengan registrasi
    final updatedUser = RegisterModel(
      namaLengkap: _namaController.text.trim(),
      email: _emailController.text.trim(),
      noHP: _noHpController.text.trim(),
      password: _newPasswordController.text.isNotEmpty ? _newPasswordController.text : _originalUserData?.password ?? "",
      confirmPassword: _confirmPasswordController.text,
      nip: _nipController.text.trim(),
      namaSekolah: selectedSchool?.namaSekolah ?? "",
      npsn: selectedSchool?.npsn ?? "",
      tingkatPengajar: selectedLevel ?? "",
      spesialisasi: _spesialisasiList.join(','),
      ktpPath: _originalUserData?.ktpPath ?? "",
      tglLahir: _originalUserData?.tglLahir ?? DateTime.now(),
    );

    // Send update profile event to BLoC (this will call API)
    context.read<EditProfileBloc>().add(UpdateProfileEvent(updatedUser));

    // Change password if provided
    if (_oldPasswordController.text.isNotEmpty && _newPasswordController.text.isNotEmpty) {
      context.read<EditProfileBloc>().add(
        ChangePasswordEvent(_oldPasswordController.text, _newPasswordController.text)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditProfileBloc, EditProfileState>(
      listener: (context, state) {
        if (state is EditProfileLoaded) {
          _populateFields(state.user);
        } else if (state is EditProfileSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );
          _populateFields(state.user);
          // Clear password fields after successful update
          _oldPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        } else if (state is EditProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is EditProfileLoading || _originalUserData == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final isLoading = state is EditProfileLoading || state is EditProfileUpdating;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Custom App Bar dengan logout button yang benar
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          } else {
                            context.go('/dashboard');
                          }
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'Profil',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                      // Logout button dengan icon dan text kecil
                      GestureDetector(
                        onTap: () {
                          // Handle logout
                          context.go('/login');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.exit_to_app,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Logout',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Body Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Profile Picture Section
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.black, width: 2),
                                  ),
                                  child: CircleAvatar(
                                    radius: 58,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Ganti gambar profil',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Form Fields dengan styling seperti register screen
                          _buildTextField(
                            controller: _namaController,
                            focusNode: _namaFocus,
                            label: 'Nama Lengkap',
                            errorKey: 'nama',
                          ),
                          
                          _buildTextField(
                            controller: _emailController,
                            focusNode: _emailFocus,
                            label: 'Email',
                            errorKey: 'email',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          
                          _buildTextField(
                            controller: _noHpController,
                            focusNode: _noHpFocus,
                            label: 'Nomor hp',
                            errorKey: 'phone',
                            keyboardType: TextInputType.phone,
                            prefixText: '+62 ',
                          ),
                          
                          _buildTextField(
                            controller: _oldPasswordController,
                            focusNode: _oldPasswordFocus,
                            label: 'Password lama',
                            errorKey: 'oldPassword',
                            obscureText: true,
                          ),
                          
                          _buildTextField(
                            controller: _newPasswordController,
                            focusNode: _newPasswordFocus,
                            label: 'Password baru',
                            errorKey: 'newPassword',
                            obscureText: true,
                          ),
                          
                          _buildTextField(
                            controller: _confirmPasswordController,
                            focusNode: _confirmPasswordFocus,
                            label: 'Konfirmasi password baru',
                            errorKey: 'confirmPassword',
                            obscureText: true,
                          ),
                          
                          _buildTextField(
                            controller: _nipController,
                            focusNode: _nipFocus,
                            label: 'NIP',
                            errorKey: 'nip',
                          ),
                          
                          // School Dropdown
                          _buildDropdownField(
                            label: 'Nama Sekolah',
                            value: selectedSchool,
                            items: schools.map((school) => DropdownMenuItem<SchoolModel>(
                              value: school,
                              child: Text(school.namaSekolah, overflow: TextOverflow.ellipsis),
                            )).toList(),
                            onChanged: _onSchoolSelected,
                            errorKey: 'school',
                          ),
                          
                          // NPSN Field (Read-only)
                          _buildTextField(
                            controller: _npsnController,
                            label: 'NPSN',
                            readOnly: true,
                            suffixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                          ),
                          
                          // Teaching Level Dropdown
                          _buildDropdownField(
                            label: 'Tingkat Pengajar',
                            value: selectedLevel,
                            items: teachingLevels.map((level) => DropdownMenuItem<String>(
                              value: level,
                              child: Text(level),
                            )).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedLevel = value;
                                _fieldErrors.remove('level');
                              });
                            },
                            errorKey: 'level',
                          ),
                          
                          // Specialization Dropdown
                          _buildDropdownField(
                            label: 'Spesialisasi',
                            value: selectedSpecialization,
                            items: allSpecializations
                                .where((spec) => !_spesialisasiList.contains(spec))
                                .map((spec) => DropdownMenuItem<String>(
                                  value: spec,
                                  child: Text(spec),
                                )).toList(),
                            onChanged: (value) => setState(() => selectedSpecialization = value),
                            suffixIcon: IconButton(
                              onPressed: _addSpesialisasi,
                              icon: const Icon(Icons.add, color: Color(0xFF0C3450)),
                            ),
                            errorKey: 'specialization',
                          ),
                          
                          // Specialization Chips
                          if (_spesialisasiList.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _spesialisasiList.map((spesialisasi) => Chip(
                                label: Text(spesialisasi),
                                onDeleted: () => _removeSpesialisasi(spesialisasi),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                backgroundColor: Colors.grey[100],
                              )).toList(),
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          const SizedBox(height: 24),
                          
                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFD32F2F),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: isLoading ? null : _handleCancel,
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0C3450),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: isLoading ? null : _handleSave,
                                    child: isLoading
                                        ? const CircularProgressIndicator(color: Colors.white)
                                        : const Text(
                                            'Save',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Input decoration yang sama seperti di register screen
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF0C3450)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF0C3450)),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String label,
    String? errorKey,
    bool obscureText = false,
    bool readOnly = false,
    TextInputType? keyboardType,
    String? prefixText,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          readOnly: readOnly,
          keyboardType: keyboardType,
          decoration: _inputDecoration(label).copyWith(
            prefixText: prefixText,
            suffixIcon: suffixIcon,
          ),
        ),
        if (errorKey != null && _fieldErrors.containsKey(errorKey))
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              _fieldErrors[errorKey]!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    Widget? suffixIcon,
    String? errorKey,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: _inputDecoration(label).copyWith(
            suffixIcon: suffixIcon,
          ),
          isExpanded: true,
        ),
        if (errorKey != null && _fieldErrors.containsKey(errorKey))
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              _fieldErrors[errorKey]!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}