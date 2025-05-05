import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splash_screen.dart';
import 'onboarding_screen.dart'; 
import 'regis.dart';   

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _seenOnboarding = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingSeen();
  }

  Future<void> _checkOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seenOnboarding') ?? false;

    setState(() {
      _seenOnboarding = seen;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LokaIlmu',
      theme: ThemeData(
        fontFamily: 'Poppins',
        textTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'Poppins',
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: _isLoading
          ? const Scaffold(
              backgroundColor: Color(0xFFFCCD52),
              body: Center(child: CircularProgressIndicator()),
            )
          : SplashScreenWrapper(seenOnboarding: _seenOnboarding),
    );
  }
}


class SplashScreenWrapper extends StatelessWidget {
  final bool seenOnboarding;

  const SplashScreenWrapper({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    return SplashScreenWithRedirect(seenOnboarding: seenOnboarding);
  }
}

class SplashScreenWithRedirect extends StatefulWidget {
  final bool seenOnboarding;

  const SplashScreenWithRedirect({super.key, required this.seenOnboarding});

  @override
  State<SplashScreenWithRedirect> createState() => _SplashScreenWithRedirectState();
}

class _SplashScreenWithRedirectState extends State<SplashScreenWithRedirect> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (widget.seenOnboarding) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RegisterScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}

