import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDI();
  runApp(const MyApp());
}

final getIt = GetIt.instance;

void setupDI() {
  getIt.registerLazySingleton(() => OnboardingService());
}

class OnboardingService {
  Future<bool> isSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('seenOnboarding') ?? false;
  }

  Future<void> setSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashWrapper(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      title: 'LokaIlmu',
      theme: ThemeData(
        fontFamily: 'Poppins',
        textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Poppins'),
      ),
    );
  }
}

class SplashWrapper extends StatelessWidget {
  const SplashWrapper({super.key});

  Future<String> _determineStartPage() async {
    await Future.delayed(const Duration(seconds: 2)); // splash delay
    final seen = await getIt<OnboardingService>().isSeen();
    return seen ? '/register' : '/onboarding';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _determineStartPage(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SplashScreen();
        }

        // Redirect once ready
        Future.microtask(() => context.go(snapshot.data!));
        return const SplashScreen();
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBCD5F),
      body: Center(
        child: Image.asset(
          'asset/images/Logo@300x-100.jpg',
          width: 200,
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await getIt<OnboardingService>().setSeen();
            if (context.mounted) {
              context.go('/register');
            }
          },
          child: const Text("Selesai Onboarding"),
        ),
      ),
    );
  }
}
