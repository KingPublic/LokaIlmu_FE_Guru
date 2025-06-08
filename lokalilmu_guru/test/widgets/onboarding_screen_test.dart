import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lokalilmu_guru/main.dart'; // adjust the import
// import 'package:lottie/lottie.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockOnboardingService extends Mock implements OnboardingService {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri());
  });

  group('OnboardingPage Widget Tests', () {
    testWidgets('OnboardingScreen displays correct content and navigates',
        (WidgetTester tester) async {
      // Replace real OnboardingService with mock
      final mockService = MockOnboardingService();
      getIt.registerSingleton<OnboardingService>(mockService);
  
      when(() => mockService.setSeen()).thenAnswer((_) async => Future.value());
  
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => OnboardingScreen(),
          ),
          GoRoute(
            path: '/register',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Register Screen')),
            ),
          ),
        ],
      );
  
      // Mock Lottie.asset by using a widget override (avoids loading JSON)
      TestWidgetsFlutterBinding.ensureInitialized();
  
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );
  
  
      // Check for initial page content
      expect(find.text('Selamat Datang di LokaIlmu'), findsOneWidget);
      expect(
          find.text(
              'Platform pelatihan digital untuk meningkatkan kualitas pengajaran guru di sekolah.'),
          findsOneWidget);
  
      // Tap "Next" button
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
  
      // Check second page appears
      expect(find.text('Forum Diskusi dan Perpustakaan Digital'), findsOneWidget);
  
      // Tap "Next" again
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
  
      // Final page
      expect(find.text('Pelatihan Interaktif & Bersertifikat'), findsOneWidget);
  
      // Check that "Get Started" is shown
      expect(find.text('Get Started'), findsOneWidget);
  
      // Tap "Get Started"
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
  
      // Verify that the service was called
      verify(() => mockService.setSeen()).called(1);
    });
  });
}
