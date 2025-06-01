import 'dart:convert'; // Untuk menggunakan jsonEncode
import 'dart:io';

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
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nipController = TextEditingController();
  final _sekolahController = TextEditingController();
  final _npsnController = TextEditingController();

  String? selectedLevel;
  String? selectedSpecialization;

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
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nipController.dispose();
    _sekolahController.dispose();
    _npsnController.dispose();
    super.dispose();
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

  void _handleRegister() {
    setState(() {
      _fieldErrors = {};
    });

    if (_formKey.currentState!.validate()) {
      // if (ktpFile == null) {
      //   setState(() {}); // Trigger rebuild to show KTP validation error
      //   return;
      // }

      if (_passwordController.text != _confirmPasswordController.text) {
        _showError("Password dan konfirmasi password tidak cocok");
        return;
      }

      // if (_selectedDate == null) {
      //   _showError("Tanggal lahir harus diisi");
      //   return;
      // }

      // Create registration data matching the Laravel controller requirements
      final Map<String, dynamic> registrationData = {
        'nama_lengkap': _namaController.text,
        'email': _emailController.text,
        'no_hp': '08012345679', // Hardcoded for testing, replace with _emailController.text
        'password': _passwordController.text,
        'NPSN':  _npsnController.text,
        'NUPTK': _nipController.text,
        'tingkatPengajar': selectedLevel,
        // 'spesialisasi': selectedSpecialization,
        'tgl_lahir' : '2000-01-01',
      };

      // TAMBAHAN: Print data JSON yang akan dikirim ke API untuk debugging
      // _printRegistrationData(registrationData, ktpFile!);
      _printRegistrationData(registrationData);

      // Dispatch register event to the BLoC
      context.read<AuthBloc>().add(
        RegisterTeacherEvent(
          registrationData: registrationData,
          // ktpFile: ktpFile!,
        ),
      );
    }
  }

  void _printRegistrationData(Map<String, dynamic> data) { //, File ktpFile) {
    // Format JSON dengan indentasi untuk memudahkan pembacaan
    final prettyJson = const JsonEncoder.withIndent('  ').convert(data);
    
    // Cetak data registrasi
    debugPrint('\n=================== DATA REGISTRASI ===================');
    debugPrint('Data yang akan dikirim ke API:');
    debugPrint(prettyJson);
    
    // Cetak informasi file KTP
    // debugPrint('\nInformasi File KTP:');
    // debugPrint('Path: ${ktpFile.path}');
    // debugPrint('Nama File: ${p.basename(ktpFile.path)}');
    // debugPrint('Ekstensi: ${p.extension(ktpFile.path)}');
    // debugPrint('Ukuran: ${(ktpFile.lengthSync() / 1024).toStringAsFixed(2)} KB');
    // debugPrint('=======================================================\n');
    
    // Tampilkan juga di SnackBar untuk memudahkan debugging di perangkat
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data registrasi dicetak di konsol'),
        duration: const Duration(seconds: 2),
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
                _buildTextField("Email / Nomor HP", key: const Key("emailOrHPField"), controller: _emailController),
                _buildTextField("Password", key: const Key("passwordField"), controller: _passwordController, obscure: true),
                _buildTextField("Konfirmasi Password", key: const Key("confirmPasswordField"), controller: _confirmPasswordController, obscure: true),
                _buildTextField("NIP / NUPTK", key: const Key("NIPNUPTKField"), controller: _nipController),
                _buildTextField("Nama Sekolah", key: const Key("namaSekolahField"), controller: _sekolahController),
                _buildTextField("NPSN", key: const Key("npsnField"), controller: _npsnController),

                DropdownButtonFormField<String>(
                  decoration: _inputDecoration("Tingkat Pengajar"),
                  value: selectedLevel,
                  items: teachingLevels.map((level) => DropdownMenuItem(value: level, child: Text(level))).toList(),
                  onChanged: (value) => setState(() => selectedLevel = value),
                  validator: (value) => value == null ? 'Pilih tingkat pengajar' : null,
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  decoration: _inputDecoration("Spesialisasi"),
                  value: selectedSpecialization,
                  items: allSpecializations
                      .map((spec) => DropdownMenuItem(value: spec, child: Text(spec)))
                      .toList(),
                  onChanged: (value) => setState(() => selectedSpecialization = value),
                  validator: (value) => value == null ? 'Pilih spesialisasi' : null,
                ),

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
                // if (ktpFile == null) // validasi visual untuk file KTP
                //   const Padding(
                //     padding: EdgeInsets.only(top: 8),
                //     child: Align(
                //       alignment: Alignment.centerLeft,
                //       child: Text(
                //         'Silakan upload gambar/file KTP*',
                //         style: TextStyle(color: Colors.red, fontSize: 12),
                //       ),
                //     ),
                //   ),

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
  });
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
          // Jika label adalah "Path KTP", field ini tidak wajib
          if (label.toLowerCase() == 'path ktp') return null;
          // Validasi default untuk field lain
          if (value == null || value.isEmpty) {
            return 'Isi $label terlebih dahulu';
          }

          if (label.toLowerCase().contains('email') || label.toLowerCase().contains('nomor hp')) {
            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
            final phoneRegex = RegExp(r'^08[0-9]{8,11}$');

            if (value.contains('@')) {
              if (!emailRegex.hasMatch(value)) {
                return 'Masukkan email atau nomor HP yang valid';
              }
            } else {
              if (!phoneRegex.hasMatch(value)) {
                return 'Masukkan email atau nomor HP yang valid';
              }
            }
          }
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
