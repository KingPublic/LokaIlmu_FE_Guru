import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:lokalilmu_guru/blocs/dashboard/dashboard_bloc.dart';
import 'package:lokalilmu_guru/repositories/course_repository.dart';
import 'package:lokalilmu_guru/repositories/book_repository.dart';
import 'package:lokalilmu_guru/blocs/perpustakaan_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model/book_model.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dashboard_page.dart';
import 'login.dart';
import 'register.dart';
import 'perpus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(BookModelAdapter()); // Adapter wajib
  await Hive.openBox<BookModel>('books');  // Buka box sebelum repository dipakai
  setupDI();
  await getIt<BookRepository>().initializeBooks();
  runApp(const MyApp());
}



final getIt = GetIt.instance;

void setupDI() {
  getIt.registerLazySingleton(() => OnboardingService());

  // Register repositories
  getIt.registerLazySingleton(() => CourseRepository());

  getIt.registerLazySingleton(() => BookRepository());

  // Register blocs
  getIt.registerFactory(() => DashboardBloc(
        courseRepository: getIt<CourseRepository>(),
      ));
  
  getIt.registerFactory(() => PerpusCubit(getIt<BookRepository>()));
  
      
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
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => BlocProvider(
        create: (context) => getIt<DashboardBloc>()..add(LoadDashboardEvent()),
        child: const DashboardPage(),
      ),
    ),
    GoRoute(
      path: '/perpustakaan',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<PerpusCubit>(),
        child: const PerpusPage(), // Tidak perlu inject repository manual lagi
      ),
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

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> pages = [
    {
      "title": "Selamat Datang di LokaIlmu",
      "desc": "Platform pelatihan digital untuk meningkatkan kualitas pengajaran guru di sekolah.",
      "lottie": "asset/images/Animationp1.json"
    },
    {
      "title": "Forum Diskusi dan Perpustakaan Digital",
      "desc": "Bertanya dan berbagi di forum komunitas, serta akses buku secara online.",
      "lottie": "asset/images/Animationp2.json"
    },
    {
      "title": "Pelatihan Interaktif & Bersertifikat",
      "desc": "Ikuti pelatihan digital yang disusun oleh ahli dan dapatkan sertifikat.",
      "lottie": "asset/images/Animationp3.json"
    },
  ];

  void _onNext() {
    if (_currentIndex < pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    await getIt<OnboardingService>().setSeen();
    if (context.mounted) context.go('/register');
  }

  Widget _buildPage(Map<String, String> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Lottie.asset(data["lottie"]!, fit: BoxFit.contain)),
          const SizedBox(height: 12),
          Text(
            data["title"]!,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            data["desc"]!,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: pages.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (_, index) => _buildPage(pages[index]),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pages.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentIndex == index ? 12 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentIndex == index ? Color(0xFF0C3450) : Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: _currentIndex == pages.length - 1
            ? SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _completeOnboarding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C3450),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Get Started",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),  
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: const Text(
                      "Skip",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF0C3450),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C3450),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Next",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
      ),
      const SizedBox(height: 24),

        ],
      ),
    );
  }
}

