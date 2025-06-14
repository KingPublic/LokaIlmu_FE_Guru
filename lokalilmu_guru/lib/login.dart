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
  
  // Map untuk menyimpan error message untuk setiap field
  Map<String, String> _fieldErrors = {};
  
  // Controller untuk field input
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Focus nodes untuk mendeteksi perubahan focus
  final FocusNode _emailOrPhoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  
  // Set untuk melacak field yang sudah diinteraksi
  final Set<String> _touchedFields = {};

  @override
  void initState() {
    super.initState();
    
    // Setup focus listeners
    _setupFocusListeners();
    
    // Setup text change listeners
    _setupTextChangeListeners();
  }

  void _setupFocusListeners() {
    // Validasi saat focus hilang dari field
    _emailOrPhoneFocus.addListener(() {
      if (!_emailOrPhoneFocus.hasFocus) {
        _touchedFields.add('emailOrPhone');
        _validateEmailOrPhoneField();
      }
    });
    
    _passwordFocus.addListener(() {
      if (!_passwordFocus.hasFocus) {
        _touchedFields.add('password');
        _validatePasswordField();
      }
    });
  }

  void _setupTextChangeListeners() {
    // Validasi saat text berubah, tapi hanya jika field sudah pernah diinteraksi
    _emailOrPhoneController.addListener(() {
      if (_touchedFields.contains('emailOrPhone')) {
        _validateEmailOrPhoneField();
      }
    });
    
    _passwordController.addListener(() {
      if (_touchedFields.contains('password')) {
        _validatePasswordField();
      }
    });
  }

  @override
  void dispose() {
    // Dispose controllers
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    
    // Dispose focus nodes
    _emailOrPhoneFocus.dispose();
    _passwordFocus.dispose();
    
    super.dispose();
  }

  // Validasi email atau nomor HP
  bool _validateEmailOrPhoneField() {
    final value = _emailOrPhoneController.text.trim();
    
    if (value.isEmpty) {
      setState(() {
        _fieldErrors['emailOrPhone'] = 'Email atau nomor HP tidak boleh kosong';
      });
      return false;
    }
    
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    final phoneRegex = RegExp(r'^08[0-9]{8,11}$');

    if (value.contains('@')) {
      if (!emailRegex.hasMatch(value)) {
        setState(() {
          _fieldErrors['emailOrPhone'] = 'Format email tidak valid';
        });
        return false;
      }
    } else {
      if (!phoneRegex.hasMatch(value)) {
        setState(() {
          _fieldErrors['emailOrPhone'] = 'Format email tidak valid';
        });
        return false;
      }
    }
    
    // Hapus error jika valid
    setState(() {
      _fieldErrors.remove('emailOrPhone');
    });
    return true;
  }

  // Validasi password
  bool _validatePasswordField() {
    final value = _passwordController.text;
    
    if (value.isEmpty) {
      setState(() {
        _fieldErrors['password'] = 'Silahkan isi password anda';
      });
      return false;
    }
    
    // Hapus error jika valid
    setState(() {
      _fieldErrors.remove('password');
    });
    return true;
  }

  // Validasi semua field
  bool _validateAllFields() {
    // Tandai semua field sebagai sudah diinteraksi
    _touchedFields.addAll(['emailOrPhone', 'password']);
    
    bool isValid = true;
    
    if (!_validateEmailOrPhoneField()) isValid = false;
    if (!_validatePasswordField()) isValid = false;
    
    return isValid;
  }

  void _handleLogin() {
    if (_validateAllFields()) {
      setState(() => _isSubmitting = true);
      
      final loginData = {
        'emailOrPhone': _emailOrPhoneController.text.trim(),
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

  @override
  Widget build(BuildContext context) {
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
          // Navigate to dashboard page
          context.go('/dashboard');
        } else if (state is AuthError) {
          // Show error message
          _showError(state.message);
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

                    // Email / Nomor HP field with error message
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          key: const Key('emailOrHPField'),
                          controller: _emailOrPhoneController,
                          focusNode: _emailOrPhoneFocus,
                          decoration: _inputDecoration("Email / Nomor HP"),
                        ),
                        if (_fieldErrors.containsKey('emailOrPhone'))
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 12),
                            child: Text(
                              _fieldErrors['emailOrPhone']!,
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
                          key: const Key('passwordField'),
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          obscureText: true,
                          decoration: _inputDecoration("Password"),
                        ),
                        if (_fieldErrors.containsKey('password'))
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 12),
                            child: Text(
                              _fieldErrors['password']!,
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                      ],
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
                        onPressed: _isSubmitting ? null : _handleLogin,
                        child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
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
      },
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
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
    );
  }
}