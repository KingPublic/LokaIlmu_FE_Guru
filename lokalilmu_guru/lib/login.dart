import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lokalilmu_guru/blocs/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  Map<String, String> _fieldErrors = {};
  // Controller opsional jika ingin ambil nilai text
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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

                const SizedBox(height: 24),

                const Text(
                  "Login Guru",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Silahkan lengkapi informasi akun anda",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),

                // Input Email/HP dan Password
                _buildTextField(
                  label: "Email / Nomor HP",
                  key: const Key('emailOrHPField'),
                  validator: _validateEmailOrPhone,
                  controller: _emailOrPhoneController,
                ),
                _buildTextField(
                  label: "Password",
                  key: const Key('passwordField'),
                  obscure: true,
                  controller: _passwordController,
                ),

                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      // aksi lupa password
                    },
                    child: const Text(
                      "Lupa Password?",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Tombol Login
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
                    onPressed: _handleLogin,

                    child: const Text(
                      "Masuk",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Belum punya akun? "),
                    GestureDetector(
                      onTap: () {
                        context.push('/register');
                      },
                      child: const Text(
                        "Daftar",
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

  String? _validateEmailOrPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Isi email atau nomor HP terlebih dahulu';
    }
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
    return null;
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      final loginData = {
        'emailOrPhone': _emailOrPhoneController.text,
        'password': _passwordController.text,
      };

      // Optional: cetak data login untuk debugging
      print('Login Data: $loginData');

      context.read<AuthBloc>().add(
        LoginTeacherEvent(
          emailOrPhone: _emailOrPhoneController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }


  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// Custom reusable TextField builder dengan warna custom
  Widget _buildTextField({
    required String label,
    bool obscure = false,
    TextEditingController? controller,
    String? Function(String?)? validator,
    Key? key,
  }) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() => _isSubmitting = true);
        } else {
          setState(() => _isSubmitting = false);
        }

        if (state is AuthAuthenticated) {
          // Login successful
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login berhasil!')),
          );
          // Navigate to login page
          context.go('/dashboard');
        } else if (state is AuthError) {
          // Show error message
          _showError(state.message);
        }
      },
  builder: (context, state) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        key: key,
        controller: controller,
        obscureText: obscure,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Isi $label terlebih dahulu';
          }

          if (validator != null) {
            return validator(value);
          }

          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF0C3450)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF0C3450)),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  },);
  }
}
