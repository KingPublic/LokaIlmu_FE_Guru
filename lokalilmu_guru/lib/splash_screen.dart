import 'package:flutter/material.dart';



class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCCD52), // Warna kuning
      body: Center(
        child: Image.asset(
          'asset/images/logo.jpg', 
          width: 200,
        ),
      ),
    );
  }
}
