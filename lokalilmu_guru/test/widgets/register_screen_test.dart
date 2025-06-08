import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lokalilmu_guru/blocs/auth_bloc.dart';
import 'package:lokalilmu_guru/login.dart';
import 'package:lokalilmu_guru/register.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends Mock implements AuthBloc {}
class FakeAuthEvent extends Fake implements AuthEvent {}
class FakeAuthState extends Fake implements AuthState {}

void main() {
  late AuthBloc authBloc;

  setUpAll(() {
    registerFallbackValue(FakeAuthEvent());
    registerFallbackValue(FakeAuthState());
  });

  setUp(() {
    authBloc = MockAuthBloc();
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: const RegisterScreen(),
      ),
    );
  }

  group('RegisterPage Widget Tests', () {
    testWidgets('Menampilkan semua input form di RegisterScreen', (WidgetTester tester) async {
      when(() => authBloc.state).thenReturn(AuthInitial());
      when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Registrasi Guru'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(7));
      expect(find.byKey(const Key('ktp_picker')), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(2));
      expect(find.text('Nama Lengkap'), findsOneWidget);
      expect(find.text('Email / Nomor HP'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Konfirmasi Password'), findsOneWidget);
      expect(find.text('NIP / NUPTK'), findsOneWidget);
      expect(find.text('Nama Sekolah'), findsOneWidget);
      expect(find.text('NPSN'), findsOneWidget);
      expect(find.text('Tingkat Pengajar'), findsOneWidget);
      expect(find.text('Spesialisasi'), findsOneWidget);
      expect(find.text('Upload Gambar/File KTP'), findsOneWidget);
      expect(find.text('Daftar'), findsOneWidget);
    });

    testWidgets('Validasi input kosong akan menampilkan error', (WidgetTester tester) async {
      when(() => authBloc.state).thenReturn(AuthInitial());
      when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());
      // await tester.tap(find.text('Daftar')); // Atau bisa trigger langsung tombol submit jika ada
      // await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Daftar'));
      await tester.tap(find.text('Daftar'));
      await tester.pump();

      expect(find.textContaining('terlebih dahulu'), findsWidgets);
      expect(find.textContaining('Pilih'), findsWidgets);
      // expect(find.text('Isi Nama terlebih dahulu'), findsOneWidget);
    });

    testWidgets('Mengetik dan mengisi form berhasil', (WidgetTester tester) async {
      when(() => authBloc.state).thenReturn(AuthInitial());
      when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.widgetWithText(TextFormField, 'Nama Lengkap'), 'Budi');
      await tester.enterText(find.widgetWithText(TextFormField, 'Email / Nomor HP'), 'budi@mail.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), '12345678');
      await tester.enterText(find.widgetWithText(TextFormField, 'Konfirmasi Password'), '12345678');
      await tester.enterText(find.widgetWithText(TextFormField, 'NIP / NUPTK'), '1234567811');
      await tester.enterText(find.widgetWithText(TextFormField, 'Nama Sekolah'), 'Pelita Kasih');

      await tester.pump();

      expect(find.text('Budi'), findsOneWidget);
      expect(find.text('budi@mail.com'), findsOneWidget);
      expect(find.text('12345678'), findsNWidgets(2));
      expect(find.text('1234567811'), findsOneWidget);
      expect(find.text('Pelita Kasih'), findsOneWidget);
    });

    testWidgets('Password fields should be obscure', (WidgetTester tester) async {
      when(() => authBloc.state).thenReturn(AuthInitial());
      when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());

      final passwordField = find.descendant(
        of: find.byKey(const Key('passwordField')),
        matching: find.byType(EditableText),
      );

      final confirmPasswordField = find.descendant(
        of: find.byKey(const Key('confirmPasswordField')),
        matching: find.byType(EditableText),
      );

      expect(passwordField, findsOneWidget);
      expect(confirmPasswordField, findsOneWidget);
      expect(tester.widget<EditableText>(passwordField).obscureText, isTrue);
      expect(tester.widget<EditableText>(confirmPasswordField).obscureText, isTrue);
    });

    testWidgets('Page navigates to Login Screen', (WidgetTester tester) async {
      when(() => authBloc.state).thenReturn(AuthInitial());
      when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());

      // await tester.pumpWidget(createTestWidget());

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => RegisterScreen(),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => LoginScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          builder: (context, child) {
            return BlocProvider.value(
              value: authBloc,
              child: child!,
            );
          },
        ),
      );

      await tester.ensureVisible(find.text('Masuk'));
      // Check if the "Sudah punya akun? Masuk" text is present
      expect(find.text('Masuk'), findsOneWidget);

      // Tap the text to navigate to login
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      // Verify that the navigation occurred (you can check for a specific widget in the login screen)
      expect(find.text('Login Guru'), findsOneWidget);
    });

    testWidgets('Menolak email tidak valid', (WidgetTester tester) async {
      when(() => authBloc.state).thenReturn(AuthInitial());
      when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());
      final field = find.byKey(const Key("emailOrHPField"));

      await tester.enterText(field, 'guru@invalid');
      await tester.ensureVisible(find.text('Daftar'));
      await tester.tap(find.text('Daftar'));
      await tester.pump();

      expect(find.text('Masukkan email atau nomor HP yang valid'), findsOneWidget);
    });

    testWidgets('Menerima email valid', (WidgetTester tester) async {
      when(() => authBloc.state).thenReturn(AuthInitial());
      when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());
      final field = find.byKey(const Key("emailOrHPField"));

      await tester.enterText(field, 'guru@example.com');
      await tester.ensureVisible(find.text('Daftar'));
      await tester.tap(find.text('Daftar'));
      await tester.pump();

      expect(find.text('Masukkan email atau nomor HP yang valid'), findsNothing);
    });

    testWidgets('Menolak nomor HP tidak valid', (WidgetTester tester) async {
      when(() => authBloc.state).thenReturn(AuthInitial());
      when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());
      final field = find.byKey(const Key("emailOrHPField"));

      await tester.enterText(field, '08123');
      await tester.ensureVisible(find.text('Daftar'));
      await tester.tap(find.text('Daftar'));
      await tester.pump();

      expect(find.text('Masukkan email atau nomor HP yang valid'), findsOneWidget);
    });

    testWidgets('Menerima nomor HP valid', (WidgetTester tester) async {
      when(() => authBloc.state).thenReturn(AuthInitial());
      when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());
      final field = find.byKey(const Key("emailOrHPField"));

      await tester.enterText(field, '081234567890');
      await tester.ensureVisible(find.text('Daftar'));
      await tester.tap(find.text('Daftar'));
      await tester.pump();

      expect(find.text('Masukkan email atau nomor HP yang valid'), findsNothing);
    });
  });
}
