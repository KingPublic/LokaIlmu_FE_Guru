import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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

  final ImagePicker _picker = ImagePicker();

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

  @override
  Widget build(BuildContext context) {
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

                _buildTextField("Nama Lengkap", controller: _namaController),
                _buildTextField("Email / Nomor HP", controller: _emailController),
                _buildTextField("Password", controller: _passwordController, obscure: true),
                _buildTextField("Konfirmasi Password", controller: _confirmPasswordController, obscure: true),
                _buildTextField("NIP / NUPTK", controller: _nipController),
                _buildTextField("Nama Sekolah", controller: _sekolahController),
                _buildTextField("NPSN", controller: _npsnController),

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
                  validator: (value) => value == null ? 'Pilih satu spesialisasi' : null,
                ),

                const SizedBox(height: 16),

                GestureDetector(
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
                if (ktpFile == null) // validasi visual untuk file KTP
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Silakan upload gambar/file KTP*',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF012C3D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (ktpFile == null) {
                          setState(() {}); 
                          return;
                        }
                        context.push('/login');
                      }
                    },
                    child: const Text("Daftar", style: TextStyle(color: Colors.white)),
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

  Widget _buildTextField(String label, {bool obscure = false, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: _inputDecoration(label),
        validator: (value) => value == null || value.isEmpty ? 'Isi $label terlebih dahulu' : null,
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF012C3D)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF012C3D)),
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
