import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lokalilmu_guru/blocs/auth_bloc.dart';
import 'package:path/path.dart' as p;

import 'model/school_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _noHpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nipController = TextEditingController();
  final _npsnController = TextEditingController();

  // Focus nodes to track field focus
  final _namaFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _noHpFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  final _nipFocus = FocusNode();

  // Track which fields have been touched (interacted with)
  final Set<String> _touchedFields = {};

  String? selectedLevel;
  String? selectedSpecialization;
  SchoolModel? selectedSchool;
  final List<String> _spesialisasiList = [];

  // Variable untuk mengecek apakah info box harus ditampilkan
  bool _showInfoBox = true;

  // Map untuk menyimpan error message untuk setiap field
  Map<String, String> _fieldErrors = {};

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

  File? ktpFile;
  bool _isSubmitting = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Listener untuk mengecek apakah salah satu field sudah diisi
    _emailController.addListener(_updateInfoBoxVisibility);
    _noHpController.addListener(_updateInfoBoxVisibility);
    
    // Setup focus listeners
    _setupFocusListeners();
    
    // Setup text change listeners for real-time validation of already touched fields
    _setupTextChangeListeners();
  }

  void _setupFocusListeners() {
    // When focus is lost, validate the field
    _namaFocus.addListener(() {
      if (!_namaFocus.hasFocus) {
        _touchedFields.add('nama');
        _validateNama();
      }
    });
    
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) {
        _touchedFields.add('email');
        _validateEmailOrPhone();
        _validateEmail();
      }
    });
    
    _noHpFocus.addListener(() {
      if (!_noHpFocus.hasFocus) {
        _touchedFields.add('phone');
        _validatePhone();
      }
    });
    
    _passwordFocus.addListener(() {
      if (!_passwordFocus.hasFocus) {
        _touchedFields.add('password');
        _validatePassword();
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
    // Only validate if the field has been touched before
    _namaController.addListener(() {
      if (_touchedFields.contains('nama')) {
        _validateNama();
      }
    });
    
    _emailController.addListener(() {
      if (_touchedFields.contains('email')) {
        _validateEmailOrPhone();
        _validateEmail();
      }
    });
    
    _noHpController.addListener(() {
      if (_touchedFields.contains('phone')) {
        _validatePhone();
      }
    });
    
    _passwordController.addListener(() {
      if (_touchedFields.contains('password')) {
        _validatePassword();
      }
      // Always revalidate confirm password if it's been touched
      if (_touchedFields.contains('confirmPassword')) {
        _validateConfirmPassword();
      }
    });
    
    _confirmPasswordController.addListener(() {
      if (_touchedFields.contains('confirmPassword')) {
        _validateConfirmPassword();
      }
    });
    
    _nipController.addListener(() {
      if (_touchedFields.contains('nip')) {
        _validateNIP();
      }
    });
  }

  @override
  void dispose() {
    // Dispose controllers
    _namaController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nipController.dispose();
    _npsnController.dispose();
    
    // Dispose focus nodes
    _namaFocus.dispose();
    _emailFocus.dispose();
    _noHpFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _nipFocus.dispose();
    
    super.dispose();
  }

  // Fungsi untuk mengupdate visibility info box
  void _updateInfoBoxVisibility() {
    final email = _emailController.text.trim();
    final phone = _noHpController.text.trim();
    
    setState(() {
      _showInfoBox = email.isEmpty && phone.isEmpty;
    });
  }

  // Fungsi untuk mengupdate NPSN ketika sekolah dipilih
  void _onSchoolSelected(SchoolModel? school) {
    setState(() {
      selectedSchool = school;
      if (school != null) {
        _npsnController.text = school.npsn;
      } else {
        _npsnController.clear();
      }
    });
    
    // Mark school as touched and validate
    _touchedFields.add('school');
    _validateSchool();
  }

  // Fungsi untuk mengupdate tingkat pengajar
  void _onLevelSelected(String? level) {
    setState(() {
      selectedLevel = level;
    });
    
    // Mark level as touched and validate
    _touchedFields.add('level');
    _validateLevel();
  }

  // Fungsi validasi untuk memastikan email terisi
  bool _validateEmailOrPhone() {
    final email = _emailController.text.trim();
    
    if (email.isEmpty) {
      setState(() {
        _fieldErrors['contact'] = 'Email tidak boleh kosong';
      });
      return false;
    } else {
      setState(() {
        _fieldErrors.remove('contact');
      });
    }
    return true;
  }

  // Validasi email
  bool _validateEmail() {
    final email = _emailController.text.trim();
    
    if (email.isNotEmpty) {
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      if (!emailRegex.hasMatch(email)) {
        setState(() {
          _fieldErrors['email'] = 'Format email tidak valid';
        });
        return false;
      } else {
        setState(() {
          _fieldErrors.remove('email');
        });
      }
    }
    return true;
  }

  // Validasi nomor HP
  bool _validatePhone() {
    final phone = _noHpController.text.trim();
    
    if (phone.isNotEmpty) {
      final phoneRegex = RegExp(r'^8[0-9]{8,12}$');
      if (!phoneRegex.hasMatch(phone)) {
        setState(() {
          _fieldErrors['phone'] = 'Nomor HP harus diawali dengan 8 dan memiliki 9-13 digit';
        });
        return false;
      } else {
        setState(() {
          _fieldErrors.remove('phone');
        });
      }
    } else {
      setState(() {
        _fieldErrors.remove('phone');
      });
    }
    return true;
  }

  // Validasi password
  bool _validatePassword() {
    final password = _passwordController.text;
    
    if (password.isEmpty) {
      setState(() {
        _fieldErrors['password'] = 'Password tidak boleh kosong';
      });
      return false;
    } else if (password.length < 6) {
      setState(() {
        _fieldErrors['password'] = 'Password minimal harus 6 karakter';
      });
      return false;
    } else {
      setState(() {
        _fieldErrors.remove('password');
      });
    }
    return true;
  }
  
  // Validasi konfirmasi password
  bool _validateConfirmPassword() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    
    if (confirmPassword.isEmpty) {
      setState(() {
        _fieldErrors['confirmPassword'] = 'Konfirmasi password tidak boleh kosong';
      });
      return false;
    } else if (password != confirmPassword) {
      setState(() {
        _fieldErrors['confirmPassword'] = 'Password dan konfirmasi password tidak cocok';
      });
      return false;
    } else {
      setState(() {
        _fieldErrors.remove('confirmPassword');
      });
    }
    return true;
  }

  // Validasi nama
  bool _validateNama() {
    if (_namaController.text.trim().isEmpty) {
      setState(() {
        _fieldErrors['nama'] = 'Nama tidak boleh kosong';
      });
      return false;
    } else {
      setState(() {
        _fieldErrors.remove('nama');
      });
    }
    return true;
  }

  // Validasi NIP/NUPTK
  bool _validateNIP() {
    if (_nipController.text.trim().isEmpty) {
      setState(() {
        _fieldErrors['nip'] = 'NIP/NUPTK tidak boleh kosong';
      });
      return false;
    } else {
      setState(() {
        _fieldErrors.remove('nip');
      });
    }
    return true;
  }

  // Validasi sekolah dan NPSN
  bool _validateSchool() {
    if (selectedSchool == null) {
      setState(() {
        _fieldErrors['school'] = 'Pilih nama sekolah';
      });
      return false;
    } else {
      setState(() {
        _fieldErrors.remove('school');
      });
    }
    return true;
  }

  // Validasi tingkat pengajar
  bool _validateLevel() {
    if (selectedLevel == null) {
      setState(() {
        _fieldErrors['level'] = 'Pilih tingkat pengajar';
      });
      return false;
    } else {
      setState(() {
        _fieldErrors.remove('level');
      });
    }
    return true;
  }

  // Validasi spesialisasi
  bool _validateSpecialization() {
    if (_spesialisasiList.isEmpty) {
      setState(() {
        _fieldErrors['specialization'] = 'Tambahkan minimal 1 spesialisasi';
      });
      return false;
    } else {
      setState(() {
        _fieldErrors.remove('specialization');
      });
    }
    return true;
  }

  // Validasi semua field
  bool _validateAllFields() {
    // Mark all fields as touched
    _touchedFields.addAll([
      'nama', 'email', 'phone', 'password', 'confirmPassword', 
      'nip', 'school', 'level', 'specialization'
    ]);
    
    bool isValid = true;
    
    // Validasi semua field
    if (!_validateNama()) isValid = false;
    if (!_validateEmailOrPhone()) isValid = false;
    if (!_validateEmail()) isValid = false;
    if (!_validatePhone()) isValid = false;
    if (!_validatePassword()) isValid = false;
    if (!_validateConfirmPassword()) isValid = false;
    if (!_validateNIP()) isValid = false;
    if (!_validateSchool()) isValid = false;
    if (!_validateLevel()) isValid = false;
    if (!_validateSpecialization()) isValid = false;
    
    return isValid;
  }

  Future<void> _pickKTP() async {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil dari Kamera'),
                onTap: () async {
                  Navigator.pop(context);
                  final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                  _setKTPFile(picked);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Pilih dari Galeri'),
                onTap: () async {
                  Navigator.pop(context);
                  final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                  _setKTPFile(picked);
                },
              ),
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text('Pilih File (PDF/JPG/PNG)'),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                    withData: true,
                  );
                  if (result != null && result.files.single.size <= 5 * 1024 * 1024) {
                    setState(() => ktpFile = File(result.files.single.path!));
                  } else {
                    _showError("File terlalu besar atau format tidak didukung.");
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _setKTPFile(XFile? pickedFile) {
    if (pickedFile == null) return;

    final ext = p.extension(pickedFile.path).toLowerCase();
    final file = File(pickedFile.path);
    final fileSize = file.lengthSync();

    if (['.jpg', '.jpeg', '.png'].contains(ext) && fileSize <= 5 * 1024 * 1024) {
      setState(() => ktpFile = file);
    } else {
      _showError("Format harus JPG/PNG dan ukuran maksimal 5MB.");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _addSpesialisasi() {
    if (selectedSpecialization != null && 
        !_spesialisasiList.contains(selectedSpecialization!) && 
        _spesialisasiList.length < 5) {
      setState(() {
        _spesialisasiList.add(selectedSpecialization!);
        selectedSpecialization = null;
      });
      
      // Mark specialization as touched and validate
      _touchedFields.add('specialization');
      _validateSpecialization();
    } else if (_spesialisasiList.length >= 5) {
      _showError("Maksimal 5 spesialisasi");
    }
  }

  void _removeSpesialisasi(String spesialisasi) {
    setState(() {
      _spesialisasiList.remove(spesialisasi);
    });
    
    // Mark specialization as touched and validate
    _touchedFields.add('specialization');
    _validateSpecialization();
  }

  void _handleRegister() {
    // Format nomor HP dengan +62 jika ada
    String? formattedPhone;
    if (_noHpController.text.isNotEmpty) {
      formattedPhone = '+62${_noHpController.text}';
    }

    final Map<String, dynamic> registrationData = {
      'nama_lengkap': _namaController.text,
      'email': _emailController.text.isNotEmpty ? _emailController.text : null,
      'no_hp': formattedPhone,
      'password': _passwordController.text,
      'NPSN': _npsnController.text,
      'NUPTK': _nipController.text,
      'tingkatPengajar': selectedLevel,
      'spesialisasi': _spesialisasiList,
      'tgl_lahir': '2000-01-01',
    };

    _printRegistrationData(registrationData);

    context.read<AuthBloc>().add(
      RegisterTeacherEvent(
        registrationData: registrationData,
      ),
    );
  }

  void _printRegistrationData(Map<String, dynamic> data) {
    final prettyJson = const JsonEncoder.withIndent('  ').convert(data);
    
    debugPrint('\n=================== DATA REGISTRASI ===================');
    debugPrint('Data yang akan dikirim ke API:');
    debugPrint(prettyJson);
    debugPrint('=======================================================\n');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data registrasi dicetak di konsol'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() => _isSubmitting = true);
        } else {
          setState(() => _isSubmitting = false);
        }

        if (state is AuthRegistrationSuccess) {
          // Registration successful
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
          );
          // Navigate to login page
          context.go('/login');
        } else if (state is AuthError) {
          // Show error message
          _showError(state.message);
          
          // Handle validation errors from the server
          if (state.errors != null) {
            Map<String, String> fieldErrors = {};
            
            state.errors!.forEach((key, value) {
              if (value is List) {
                fieldErrors[key] = value.first.toString();
              } else {
                fieldErrors[key] = value.toString();
              }
            });
            
            setState(() {
              _fieldErrors = fieldErrors;
            });
          }
        }
      },
      builder: (context, state) { 
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    const CircleAvatar(
                      backgroundColor: Color(0xFFFBCD5F),
                      radius: 30,
                      child: Icon(Icons.school, size: 30, color: Colors.black),
                    ),
                    const SizedBox(height: 16),
                    const Text("Registrasi Guru", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(height: 8),
                    const Text("Silahkan lengkapi profil anda", style: TextStyle(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 24),

                    // Nama Lengkap field with error message
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          key: const Key("namaLengkapField"),
                          controller: _namaController,
                          focusNode: _namaFocus,
                          decoration: _inputDecoration("Nama Lengkap"),
                        ),
                        if (_fieldErrors.containsKey('nama'))
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 12),
                            child: Text(
                              _fieldErrors['nama']!,
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),
                    
                    // Email field with error message
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          key: const Key("emailField"),
                          controller: _emailController,
                          focusNode: _emailFocus,
                          decoration: _inputDecoration("Email"),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        if (_fieldErrors.containsKey('email'))
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 12),
                            child: Text(
                              _fieldErrors['email']!,
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        if (_fieldErrors.containsKey('contact'))
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 12),
                            child: Text(
                              _fieldErrors['contact']!,
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),
                    
                    // Nomor HP field with error message
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          key: const Key("noHpField"),
                          controller: _noHpController,
                          focusNode: _noHpFocus,
                          decoration: _inputDecoration("Nomor HP (opsional)").copyWith(
                            prefixText: "+62 ",
                            hintText: "",
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        if (_fieldErrors.containsKey('phone'))
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 12),
                            child: Text(
                              _fieldErrors['phone']!,
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),
                    
                    // Password field with error message
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          key: const Key("passwordField"),
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          decoration: _inputDecoration("Password"),
                          obscureText: true,
                        ),
                        if (_fieldErrors.containsKey('password'))
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 12),
                            child: Text(
                              _fieldErrors['password']!,
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),
                    
                    // Konfirmasi Password field with error message
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          key: const Key("confirmPasswordField"),
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocus,
                          decoration: _inputDecoration("Konfirmasi Password"),
                          obscureText: true,
                        ),
                        if (_fieldErrors.containsKey('confirmPassword'))
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 12),
                            child: Text(
                              _fieldErrors['confirmPassword']!,
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),
                    
                    // NIP/NUPTK field with error message
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          key: const Key("NIPNUPTKField"),
                          controller: _nipController,
                          focusNode: _nipFocus,
                          decoration: _inputDecoration("NIP / NUPTK"),
                        ),
                        if (_fieldErrors.containsKey('nip'))
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 12),
                            child: Text(
                              _fieldErrors['nip']!,
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),
                    
                    // Dropdown Nama Sekolah with error message
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<SchoolModel>(
                          key: const Key("namaSekolahDropdown"),
                          decoration: _inputDecoration("Nama Sekolah"),
                          value: selectedSchool,
                          items: schools.map((school) => DropdownMenuItem<SchoolModel>(
                            value: school,
                            child: Text(
                              school.namaSekolah,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )).toList(),
                          onChanged: _onSchoolSelected,
                          isExpanded: true,
                        ),
                        if (_fieldErrors.containsKey('school'))
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 12),
                            child: Text(
                              _fieldErrors['school']!,
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),

                    // NPSN Field (Auto-populated, read-only)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          key: const Key("npsnField"),
                          controller: _npsnController,
                          decoration: _inputDecoration("NPSN").copyWith(
                            suffixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                          ),
                          readOnly: true,
                        ),
                        if (_npsnController.text.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 4, left: 12),
                            child: Text(
                              'NPSN akan terisi otomatis setelah memilih sekolah',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),

                    // Tingkat Pengajar dropdown with error message
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: _inputDecoration("Tingkat Pengajar"),
                          value: selectedLevel,
                          items: teachingLevels.map((level) => DropdownMenuItem(value: level, child: Text(level))).toList(),
                          onChanged: _onLevelSelected,
                        ),
                        if (_fieldErrors.containsKey('level'))
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 12),
                            child: Text(
                              _fieldErrors['level']!,
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),

                    // Spesialisasi dropdown with error message
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: _inputDecoration("Spesialisasi").copyWith(
                            suffixIcon: IconButton(
                              onPressed: _addSpesialisasi,
                              icon: const Icon(Icons.add, color: Color(0xFF0C3450)),
                            ),
                          ),
                          value: selectedSpecialization,
                          items: allSpecializations
                              .where((spec) => !_spesialisasiList.contains(spec))
                              .map((spec) => DropdownMenuItem(value: spec, child: Text(spec)))
                              .toList(),
                          onChanged: (value) => setState(() => selectedSpecialization = value),
                        ),
                        if (_fieldErrors.containsKey('specialization'))
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 12),
                            child: Text(
                              _fieldErrors['specialization']!,
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                    
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
                    ],

                    const SizedBox(height: 16),

                    GestureDetector(
                      key: const Key('ktp_picker'),
                      onTap: _pickKTP,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black26),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.upload, size: 30),
                            const SizedBox(height: 8),
                            Text(
                              ktpFile != null ? p.basename(ktpFile!.path) : "Upload Gambar/File KTP",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text("PDF, JPG, PNG (max. 5MB)", style: TextStyle(fontSize: 12, color: Colors.black54)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0C3450),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isSubmitting
                          ? null
                          : () {
                              // Validasi semua field terlebih dahulu
                              if (_validateAllFields()) {
                                setState(() => _isSubmitting = true);
                                _handleRegister();
                              }
                            },
                        child: _isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Daftar", style: TextStyle(color: Colors.white)),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Sudah punya akun? "),
                        GestureDetector(
                          onTap: () => context.push('/login'),
                          child: const Text("Masuk", style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

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
}