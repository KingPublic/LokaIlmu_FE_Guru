import 'dart:convert';
import 'dart:io';
import 'model/school_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lokalilmu_guru/blocs/auth_bloc.dart';
import 'package:path/path.dart' as p;


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _noHpController = TextEditingController(); // Controller baru untuk nomor HP
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nipController = TextEditingController();
  final _npsnController = TextEditingController();

  String? selectedLevel;
  String? selectedSpecialization;
  SchoolModel? selectedSchool;
  final List<String> _spesialisasiList = [];

  // Variable untuk mengecek apakah info box harus ditampilkan
  bool _showInfoBox = true;

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
  Map<String, String> _fieldErrors = {};

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Listener untuk mengecek apakah salah satu field sudah diisi
    _emailController.addListener(_updateInfoBoxVisibility);
    _noHpController.addListener(_updateInfoBoxVisibility);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _noHpController.dispose(); // Dispose controller nomor HP
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nipController.dispose();
    _npsnController.dispose();
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
  }

  // Fungsi validasi untuk memastikan minimal salah satu dari email atau nomor HP diisi
  String? _validateEmailOrPhone() {
    final email = _emailController.text.trim();
    final phone = _noHpController.text.trim();
    
    if (email.isEmpty && phone.isEmpty) {
      return 'Minimal isi salah satu: Email atau Nomor HP';
    }
    return null;
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
    } else if (_spesialisasiList.length >= 5) {
      _showError("Maksimal 5 spesialisasi");
    }
  }

  void _removeSpesialisasi(String spesialisasi) {
    setState(() {
      _spesialisasiList.remove(spesialisasi);
    });
  }

  void _handleRegister() {
    setState(() {
      _fieldErrors = {};
    });

    // Validasi manual untuk email atau nomor HP
    final emailOrPhoneError = _validateEmailOrPhone();
    if (emailOrPhoneError != null) {
      _showError(emailOrPhoneError);
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        _showError("Password dan konfirmasi password tidak cocok");
        return;
      }

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

                    _buildTextField("Nama Lengkap", key: const Key("namaLengkapField"), controller: _namaController),
                    
                    // Field Email (opsional jika nomor HP diisi)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextFormField(
                        key: const Key("emailField"),
                        controller: _emailController,
                        decoration: _inputDecoration("Email"),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          // Jika email diisi, harus valid
                          if (value != null && value.isNotEmpty) {
                            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                            if (!emailRegex.hasMatch(value)) {
                              return 'Masukkan email yang valid';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    
                    // Field khusus untuk nomor HP (opsional jika email diisi)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextFormField(
                        key: const Key("noHpField"),
                        controller: _noHpController,
                        decoration: _inputDecoration("Nomor HP (opsional)").copyWith(
                          prefixText: "+62 ",
                          hintText: "",
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          // Jika nomor HP diisi, harus valid
                          if (value != null && value.isNotEmpty) {
                            // Validasi harus dimulai dengan 8 (karena +62 8xxx)
                            final phoneRegex = RegExp(r'^8[0-9]{8,12}$');
                            
                            if (!phoneRegex.hasMatch(value)) {
                              return 'Nomor HP harus diawali dengan 8 dan memiliki 9-13 digit';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    
                    
                    // Hanya tampil jika kedua field kosong
                    if (_showInfoBox)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade600, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Minimal isi salah satu: Email atau Nomor HP",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    _buildTextField("Password", key: const Key("passwordField"), controller: _passwordController, obscure: true),
                    _buildTextField("Konfirmasi Password", key: const Key("confirmPasswordField"), controller: _confirmPasswordController, obscure: true),
                    _buildTextField("NIP / NUPTK", key: const Key("NIPNUPTKField"), controller: _nipController),
                    
                    // Dropdown Nama Sekolah
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: DropdownButtonFormField<SchoolModel>(
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
                        validator: (value) => value == null ? 'Pilih nama sekolah' : null,
                        isExpanded: true,
                      ),
                    ),

                    // NPSN Field (Auto-populated, read-only)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextFormField(
                        key: const Key("npsnField"),
                        controller: _npsnController,
                        decoration: _inputDecoration("NPSN").copyWith(
                          suffixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                        ),
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'NPSN akan terisi otomatis setelah memilih sekolah';
                          }
                          return null;
                        },
                      ),
                    ),

                    DropdownButtonFormField<String>(
                      decoration: _inputDecoration("Tingkat Pengajar"),
                      value: selectedLevel,
                      items: teachingLevels.map((level) => DropdownMenuItem(value: level, child: Text(level))).toList(),
                      onChanged: (value) => setState(() => selectedLevel = value),
                      validator: (value) => value == null ? 'Pilih tingkat pengajar' : null,
                    ),

                    const SizedBox(height: 16),

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
                      validator: (value) {
                        if (_spesialisasiList.isEmpty) {
                          return 'Tambahkan minimal 1 spesialisasi';
                        }
                        return null;
                      },
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
                              setState(() => _isSubmitting = true);
                               debugPrint('\n=================== DATA FORM USER ===================');
                                debugPrint('Nama Lengkap: ${_namaController.text}');
                                debugPrint('Email: ${_emailController.text.isEmpty ? "Tidak diisi" : _emailController.text}');
                                debugPrint('Nomor HP: ${_noHpController.text.isEmpty ? "Tidak diisi" : "+62${_noHpController.text}"}');
                                debugPrint('Password: ${_passwordController.text.isEmpty ? "Tidak diisi" : "****** (${_passwordController.text.length} karakter)"}');
                                debugPrint('Konfirmasi Password: ${_confirmPasswordController.text.isEmpty ? "Tidak diisi" : "****** (${_confirmPasswordController.text.length} karakter)"}');
                                debugPrint('NIP/NUPTK: ${_nipController.text}');
                                debugPrint('Nama Sekolah: ${selectedSchool?.namaSekolah ?? "Belum dipilih"}');
                                debugPrint('NPSN: ${_npsnController.text}');
                                debugPrint('Tingkat Pengajar: ${selectedLevel ?? "Belum dipilih"}');
                                debugPrint('Spesialisasi: ${_spesialisasiList.isEmpty ? "Belum ada" : _spesialisasiList.join(", ")}');
                                debugPrint('File KTP: ${ktpFile?.path ?? "Belum diupload"}');
                                debugPrint('=======================================================\n');
                                
                              _handleRegister();
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

  Widget _buildTextField(String label, {Key? key, bool obscure = false, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        key: key,
        controller: controller,
        obscureText: obscure,
        decoration: _inputDecoration(label),
        validator: (value) {
          if (label.toLowerCase() == 'path ktp') return null;
          if (value == null || value.isEmpty) {
            return 'Isi $label terlebih dahulu';
          }
          return null;
        },
      ),
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