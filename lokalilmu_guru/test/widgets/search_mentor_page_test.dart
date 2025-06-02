import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lokalilmu_guru/blocs/mentor_bloc.dart';
import 'package:lokalilmu_guru/dashboard_page.dart';
import 'package:lokalilmu_guru/model/mentor_model.dart';
import 'package:lokalilmu_guru/search_mentor.dart';
import 'package:lokalilmu_guru/widgets/common/header.dart';
import 'package:lokalilmu_guru/widgets/common/navbar.dart';
import 'package:mocktail/mocktail.dart';
// import 'package:lokalilmu_guru/model/mentor_model.dart';
// Import your actual files
import 'package:network_image_mock/network_image_mock.dart';

// Generate mocks
class MockMentorCubit extends Mock implements MentorCubit {}

void main() {
  group('SearchMentorPage Widget Tests', () {
    late MockMentorCubit mockMentorCubit;
    late List<MentorModel> mockMentors;

    setUp(() {
      mockMentorCubit = MockMentorCubit();
      
      // Create mock mentor data
      mockMentors = [
        MentorModel(
          id: '1',
          name: 'Dr. John Doe',
          institution: 'Universitas Indonesia',
          imageUrl: 'https://example.com/avatar1.jpg',
          rating: 4.8,
          reviewCount: 120,
          categories: ['Matematika', 'Fisika'],
          description: 'Pengalaman mengajar 10 tahun di bidang sains',
          pricePerSession: 150000,
        ),
        MentorModel(
          id: '2',
          name: 'Prof. Jane Smith',
          institution: 'Institut Teknologi Bandung',
          imageUrl: 'https://example.com/avatar2.jpg',
          rating: 4.9,
          reviewCount: 200,
          categories: ['Kimia', 'Biologi'],
          description: 'Spesialis dalam kimia organik dan biologi molekuler',
          pricePerSession: 200000,
        ),
      ];
      when(() => mockMentorCubit.initialize()).thenAnswer((_) async {});
    });

    Widget createTestWidget({required MentorState state}) {
      return MaterialApp(
        home: BlocProvider<MentorCubit>.value(
          value: mockMentorCubit,
          child: const SearchMentorPage(),
        ),
      );
    }

    group('UI Elements Verification (Figma Design Check)', () {
      testWidgets('should display all main UI components', (WidgetTester tester) async {
        // Arrange
        final state = MentorState(
          mentors: mockMentors,
          categories: ['Matematika', 'Fisika','Informatika', 'Kimia', 'Biologi'],
          searchQuery: '',
          selectedCategory: 'Semua Subjek',
          isLoading: false,
          error: null,
        );

        when(() => mockMentorCubit.state).thenReturn(state);
        when(() => mockMentorCubit.stream).thenAnswer((_) => const Stream.empty());

        await mockNetworkImagesFor(() async {
          // Act
          await tester.pumpWidget(createTestWidget(state: state));
          await tester.pumpAndSettle();

          // Assert - App Bar Elements
          expect(find.byIcon(Icons.arrow_back), findsOneWidget);
          // expect(find.text('Cari Mentor'), findsOneWidget);

          // Assert - Header/Search Section
          // find.text('Cari Mentor').evaluate().forEach((e) => debugPrint(e.toString()));
          final header = find.byType(Header);
          header.evaluate().forEach((e) => debugPrint(e.widget.toStringDeep()));
          expect(header, findsOneWidget);

          final matches = find.byWidgetPredicate((widget) {
            return widget is Text &&
              widget.data == 'Cari Mentor' &&
              widget.style?.fontWeight == FontWeight.w600 &&
              widget.style?.fontSize == 18;
          });
          expect(matches, findsOneWidget);

          // Assert - Category Chips
          final matematikaChip = find.widgetWithText(ChoiceChip, 'Matematika');
          expect(matematikaChip, findsOneWidget);

          // Assert - Mentor List
          expect(find.byType(ListView), findsAtLeastNWidgets(1));
          expect(find.byType(MentorCard), findsNWidgets(2));

          // Assert - Bottom Navigation
          expect(find.byType(AppBottomNavbar), findsOneWidget);
        });
      });

      testWidgets('should display correct background colors', (WidgetTester tester) async {
        // Arrange
        final state = MentorState(
          mentors: mockMentors,
          categories: [],
          searchQuery: '',
          selectedCategory: 'Semua Subjek',
          isLoading: false,
          error: null,
        );
        
        when(() => mockMentorCubit.state).thenReturn(state);
        when(() => mockMentorCubit.stream).thenAnswer((_) => const Stream.empty());
        await mockNetworkImagesFor(() async {
          // Act
          await tester.pumpWidget(createTestWidget(state: state));

          // Assert - Background color
          final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
          expect(scaffold.backgroundColor, const Color(0xFFFAFAFA));
        });
      });

      testWidgets('should display app bar with correct styling', (WidgetTester tester) async {
        // Arrange
        final state = MentorState(
          mentors: mockMentors,
          categories: [],
          searchQuery: '',
          selectedCategory: 'Semua Subjek',
          isLoading: false,
          error: null,
        );
        
        when(() => mockMentorCubit.state).thenReturn(state);
        when(() => mockMentorCubit.stream).thenAnswer((_) => const Stream.empty());
        await mockNetworkImagesFor(() async {
          // Act
          await tester.pumpWidget(createTestWidget(state: state));

          // Assert - App bar container styling
          final appBarContainer = tester.widget<Container>(
            find.descendant(
              of: find.byType(SafeArea),
              matching: find.byType(Container),
            ).first,
          );

          expect(appBarContainer.decoration, isA<BoxDecoration>());
          final decoration = appBarContainer.decoration as BoxDecoration;
          expect(decoration.color, Colors.white);
          expect(decoration.border, isA<Border>());
        });
      });
    });

    group('MentorCard UI Elements Verification', () {
      testWidgets('should display all mentor card elements correctly', (WidgetTester tester) async {
        // Arrange
       final state = MentorState(
          mentors: mockMentors,
          categories: [],
          searchQuery: '',
          selectedCategory: 'Semua Subjek',
          isLoading: false,
          error: null,
        );

        when(() => mockMentorCubit.state).thenReturn(state);
        when(() => mockMentorCubit.stream).thenAnswer((_) => const Stream.empty());

        await mockNetworkImagesFor(() async {
          // Act
          await tester.pumpWidget(createTestWidget(state: state));
          await tester.pumpAndSettle();

          // Assert - Mentor photo
          expect(find.byType(CircleAvatar), findsNWidgets(2));

          // Assert - Mentor name and institution
          expect(find.text('Dr. John Doe'), findsOneWidget);
          expect(find.text('Universitas Indonesia'), findsOneWidget);

          // Assert - Rating
          expect(find.byIcon(Icons.star), findsNWidgets(2));
          expect(find.text('4.8'), findsOneWidget);

          // Assert - Categories
          final mentorCards = find.byType(MentorCard);

          // For 'Matematika'
          expect(
            find.descendant(of: mentorCards.first, matching: find.text('Matematika')),
            findsOneWidget,
          );
          
          // For 'Fisika'
          expect(
            find.descendant(of: mentorCards.first, matching: find.text('Fisika')),
            findsOneWidget,
          );

          // Assert - Description
          expect(find.text('Pengalaman mengajar 10 tahun di bidang sains'), findsOneWidget);

          // Assert - Price
          expect(find.text('Biaya per sesi'), findsNWidgets(2));
          expect(find.text('Rp150.000'), findsOneWidget);
        });
      });

      testWidgets('should display category tags with correct styling', (WidgetTester tester) async {
        // Arrange
        final state = MentorState(
          mentors: mockMentors,
          categories: ['Matematika', 'Fisika','Informatika', 'Kimia', 'Biologi'],
          searchQuery: '',
          selectedCategory: 'Semua Subjek',
          isLoading: false,
          error: null,
        );
        
        when(() => mockMentorCubit.state).thenReturn(state);
        when(() => mockMentorCubit.stream).thenAnswer((_) => const Stream.empty());

        await mockNetworkImagesFor(() async {
          // Act
          await tester.pumpWidget(createTestWidget(state: state));
          await tester.pumpAndSettle();

          // Assert - Category containers
          final categoryContainers = tester.widgetList<Container>(
            find.descendant(
              of: find.byType(Wrap),
              matching: find.byType(Container),
            ),
          );

          expect(categoryContainers.length, 4); // Matematika and Fisika

          // Check styling of first category container
          final firstContainer = categoryContainers.first;
          final decoration = firstContainer.decoration as BoxDecoration;
          expect(decoration.color, Colors.blue[100]);
          expect(decoration.borderRadius, BorderRadius.circular(16));
        });
      });
    });

    group('Loading and Empty States', () {
      testWidgets('should display empty state message when no mentors found', (WidgetTester tester) async {
        // Arrange
        final state = MentorState(
          mentors: [],
          categories: [],
          searchQuery: '',
          selectedCategory: 'Semua Subjek',
          isLoading: false,
          error: null,
        );
        
        when(() => mockMentorCubit.state).thenReturn(state);
        when(() => mockMentorCubit.stream).thenAnswer((_) => const Stream.empty());

        await mockNetworkImagesFor(() async {
          // Act
          await tester.pumpWidget(createTestWidget(state: state));

          // Assert
          expect(find.text('Tidak ada mentor yang ditemukan'), findsOneWidget);
          expect(find.byType(MentorCard), findsNothing);
        });
      });
    });

    group('Functionality Tests', () {
      testWidgets('should call initialize on MentorCubit when page loads', (WidgetTester tester) async {
        // Arrange
        final state = MentorState(
          mentors: mockMentors,
          categories: [],
          searchQuery: '',
          selectedCategory: 'Semua Subjek',
          isLoading: false,
          error: null,
        );
        
        when(() => mockMentorCubit.state).thenReturn(state);
        when(() => mockMentorCubit.stream).thenAnswer((_) => const Stream.empty());

        await mockNetworkImagesFor(() async {
          // Act
          await tester.pumpWidget(createTestWidget(state: state));

          // Assert
          verify(() => mockMentorCubit.initialize()).called(1);
        });
      });

      testWidgets('should trigger navigation when back button is pressed', (WidgetTester tester) async {
        // Arrange
        final state = MentorState(
          mentors: mockMentors,
          categories: [],
          searchQuery: '',
          selectedCategory: 'Semua Subjek',
          isLoading: false,
          error: null,
        );
        
        when(() => mockMentorCubit.state).thenReturn(state);
        when(() => mockMentorCubit.stream).thenAnswer((_) => const Stream.empty());

        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => SearchMentorPage(),
            ),
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => DashboardPage(),
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            builder: (context, child) {
              return BlocProvider.value(
                value: mockMentorCubit,
                child: child!,
              );
            },
          ),
        );

        await mockNetworkImagesFor(() async {
          // Act
          // await tester.pumpWidget(createTestWidget(state: state));
          await tester.tap(find.byIcon(Icons.arrow_back));
          await tester.pumpAndSettle();

          // Verify that the navigation occurred (you can check for a specific widget in the login screen)
          expect(find.textContaining('Selamat datang'), findsOneWidget);
        });
      });

      testWidgets('should display multiple mentors correctly', (WidgetTester tester) async {
        // Arrange
        final state = MentorState(
          mentors: mockMentors,
          categories: [],
          searchQuery: '',
          selectedCategory: 'Semua Subjek',
          isLoading: false,
          error: null,
        );
        
        when(() => mockMentorCubit.state).thenReturn(state);
        when(() => mockMentorCubit.stream).thenAnswer((_) => const Stream.empty());

        // Act
        await tester.pumpWidget(createTestWidget(state: state));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(MentorCard), findsNWidgets(2));
        expect(find.text('Dr. John Doe'), findsOneWidget);
        expect(find.text('Prof. Jane Smith'), findsOneWidget);
      });
    });

    group('Price Formatting Tests', () {
      testWidgets('should format price correctly with thousand separators', (WidgetTester tester) async {
        // Arrange
        final mentorWithHighPrice = MentorModel(
          id: '3',
          name: 'Expensive Mentor',
          institution: 'Premium University',
          imageUrl: 'https://example.com/avatar3.jpg',
          rating: 5.0,
          reviewCount: 50,
          categories: ['Premium'],
          description: 'Premium mentor',
          pricePerSession: 1500000, // 1.5 million
        );
        
        final state = MentorState(
          mentors: mockMentors..add(mentorWithHighPrice),
          categories: [],
          searchQuery: '',
          selectedCategory: 'Semua Subjek',
          isLoading: false,
          error: null,
        );

        when(() => mockMentorCubit.state).thenReturn(state);
        when(() => mockMentorCubit.stream).thenAnswer((_) => const Stream.empty());

        // Act
        await tester.pumpWidget(createTestWidget(state: state));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Rp1.500.000'), findsOneWidget);
      });
    });

    group('Responsive Design Tests', () {
      testWidgets('should handle different screen sizes', (WidgetTester tester) async {
        // Arrange
        final state = MentorState(
          mentors: mockMentors,
          categories: [],
          searchQuery: '',
          selectedCategory: 'Semua Subjek',
          isLoading: false,
          error: null,
        );
        
        when(() => mockMentorCubit.state).thenReturn(state);
        when(() => mockMentorCubit.stream).thenAnswer((_) => const Stream.empty());

        // Act - Test with different screen sizes
        await tester.binding.setSurfaceSize(const Size(320, 568)); // iPhone SE
        await tester.pumpWidget(createTestWidget(state: state));
        await tester.pumpAndSettle();

        // Assert - All elements should still be visible
        expect(find.byType(MentorCard), findsNWidgets(2));
        expect(find.text('Cari Mentor'), findsOneWidget);

        // Test with tablet size
        await tester.binding.setSurfaceSize(const Size(768, 1024));
        await tester.pumpWidget(createTestWidget(state: state));
        await tester.pumpAndSettle();

        expect(find.byType(MentorCard), findsNWidgets(2));
      });
    });
  });
}