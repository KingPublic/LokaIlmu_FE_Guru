import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  String? selectedLevel;
  final List<String> teachingLevels = ['TK', 'SD', 'SMP', 'SMA', 'SMK'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 16),
                const CircleAvatar(
                  backgroundColor: Color(0xFFFCD266),
                  radius: 30,
                  child: Icon(Icons.school, size: 30, color: Colors.black),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Registrasi Guru",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Silahkan lengkapi profil anda",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),

                _buildTextField("Nama Lengkap"),
                _buildTextField("Email / Nomor HP"),
                _buildTextField("Password", obscure: true),
                _buildTextField("Konfirmasi Password", obscure: true),
                _buildTextField("NIP"),
                _buildTextField("Nama Sekolah"),
                _buildTextField("NPSN"),

                // Tingkat Pengajar (Dropdown)
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration("Tingkat Pengajar"),
                  value: selectedLevel,
                  items: teachingLevels.map((level) {
                    return DropdownMenuItem(value: level, child: Text(level));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedLevel = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Spesialisasi (tombol +)
                TextFormField(
                  decoration: _inputDecoration("Spesialisasi").copyWith(
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        // aksi tambah spesialisasi
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Upload Gambar KTP
                GestureDetector(
                  onTap: () {
                    // aksi upload file
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.upload, size: 30),
                        SizedBox(height: 8),
                        Text(
                          "Upload Gambar KTP",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "PDF, JPG, PNG (max. 5MB)",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Daftar
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
                        // aksi daftar
                      }
                    },
                    child: const Text(
                      "Daftar",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                // Sudah punya akun
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Sudah punya akun? "),
                    GestureDetector(
                      onTap: () {
                        // aksi masuk
                      },
                      child: const Text(
                        "Masuk",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
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
    );
  }

  // TextField reusable builder
  Widget _buildTextField(String label, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        obscureText: obscure,
        decoration: _inputDecoration(label),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
