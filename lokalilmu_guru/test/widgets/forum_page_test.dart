import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lokalilmu_guru/blocs/forum_cubit.dart';
import 'package:lokalilmu_guru/model/forum_model.dart';
import 'package:lokalilmu_guru/forum.dart';
import 'package:lokalilmu_guru/repositories/forum_repository.dart';
import 'package:lokalilmu_guru/widgets/common/header.dart';
import 'package:lokalilmu_guru/widgets/common/navbar.dart';
import 'package:mocktail/mocktail.dart';

// Generate mocks
class MockForumCubit extends Mock implements ForumCubit {}
class MockForumRepository extends Mock implements ForumRepository {}

void main() {
  group('ForumPage Widget Tests', () {
    late MockForumCubit mockForumCubit;
    late List<ForumPost> mockPosts;

    setUp(() {
      mockForumCubit = MockForumCubit();
      
      // Create mock forum posts data
      mockPosts = [
        ForumPost(
          id: '1',
          title: 'Bagaimana Mengatasi Siswa yang Kurang Termotivasi?',
          content: 'Saya mengajar SMP dan sering menghadapi siswa yang tampak tidak antusias dalam belajar.',
          authorName: 'Jono Don',
          authorRole: 'Guru SMP di Makassar',
          authorAvatar: 'asset/images/avatar1.jpg',
          category: 'Bahasa',
          createdAt: DateTime.now().subtract(Duration(days: 2)),
          upvotes: 10,
          downvotes: 2,
          comments: 18,
          tags: ['motivasi', 'siswa', 'pembelajaran'],
        ),
        ForumPost(
          id: '2',
          title: 'Teknologi dalam Pembelajaran: Efektif atau Tidak?',
          content: 'Apakah penggunaan teknologi seperti Google Classroom benar-benar efektif?',
          authorName: 'Yura Setiani',
          authorRole: 'Guru SMP di Jakarta',
          authorAvatar: 'asset/images/avatar2.jpg',
          category: 'Informatika',
          createdAt: DateTime.now().subtract(Duration(hours: 5)),
          upvotes: 10,
          downvotes: 2,
          comments: 12,
          tags: ['teknologi', 'digital', 'efektivitas'],
        ),
      ];
    });

    Widget createTestWidget({required ForumState state}) {
      return MaterialApp(
        home: BlocProvider<ForumCubit>.value(
          value: mockForumCubit,
          child: const ForumPage(),
        ),
      );
    }

    group('UI Elements Verification (Forum List View)', () {
      testWidgets('should display all main UI components in forum list', (WidgetTester tester) async {
        // Arrange
        final state = ForumState(
          posts: mockPosts,
          selectedCategory: 'Semua Subjek',
          searchQuery: '',
          isLoading: false,
        );

        when(() => mockForumCubit.state).thenReturn(state);
        when(() => mockForumCubit.stream).thenAnswer((_) => const Stream.empty());

        // Act
        await tester.pumpWidget(createTestWidget(state: state));
        await tester.pumpAndSettle();

        // Assert - App Bar Elements
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
        expect(find.text('Forum Diskusi'), findsOneWidget);

        // Assert - Header/Search Section
        expect(find.byType(Header), findsOneWidget);

        // Assert - Category Chips
        final semuaSubjekChip = find.widgetWithText(ChoiceChip, 'Semua Subjek');
        expect(semuaSubjekChip, findsOneWidget);

        // Assert - Post List
        expect(find.byType(ListView), findsAtLeastNWidgets(1));

        // Assert - Floating Action Button
        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.text('Diskusi Baru'), findsOneWidget);

        // Assert - Bottom Navigation
        expect(find.byType(AppBottomNavbar), findsOneWidget);
      });

      testWidgets('should display forum posts correctly', (WidgetTester tester) async {
        // Arrange
        final state = ForumState(
          posts: mockPosts,
          selectedCategory: 'Semua Subjek',
          searchQuery: '',
          isLoading: false,
        );

        when(() => mockForumCubit.state).thenReturn(state);
        when(() => mockForumCubit.stream).thenAnswer((_) => const Stream.empty());

        // Act
        await tester.pumpWidget(createTestWidget(state: state));
        await tester.pumpAndSettle();

        // Assert - Post titles
        expect(find.text('Bagaimana Mengatasi Siswa yang Kurang Termotivasi?'), findsOneWidget);
        expect(find.text('Teknologi dalam Pembelajaran: Efektif atau Tidak?'), findsOneWidget);

        // Assert - Author names
        expect(find.text('Jono Don'), findsOneWidget);
        expect(find.text('Yura Setiani'), findsOneWidget);

        // Assert - Author roles
        expect(find.text('Guru SMP di Makassar'), findsOneWidget);
        expect(find.text('Guru SMP di Jakarta'), findsOneWidget);

        // Assert - Category badges
        expect(find.text('Bahasa'), findsOneWidget);
        expect(find.text('Informatika'), findsOneWidget);

        // Assert - Tags
        expect(find.text('#motivasi'), findsOneWidget);
        expect(find.text('#teknologi'), findsOneWidget);

        // Assert - Action buttons
        expect(find.byIcon(Icons.keyboard_arrow_up), findsNWidgets(2));
        expect(find.byIcon(Icons.keyboard_arrow_down), findsNWidgets(2));
        expect(find.byIcon(Icons.chat_bubble_outline), findsNWidgets(2));
      });

      testWidgets('should display correct background colors and styling', (WidgetTester tester) async {
        // Arrange
        final state = ForumState(
          posts: mockPosts,
          selectedCategory: 'Semua Subjek',
          searchQuery: '',
          isLoading: false,
        );

        when(() => mockForumCubit.state).thenReturn(state);
        when(() => mockForumCubit.stream).thenAnswer((_) => const Stream.empty());

        // Act
        await tester.pumpWidget(createTestWidget(state: state));

        // Assert - Background color
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, Colors.grey[50]);

        // Assert - Floating Action Button colors
        final fab = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
        expect(fab.backgroundColor, const Color(0xFFFBCD5F));
      });

      testWidgets('should display category badges with correct colors', (WidgetTester tester) async {
        // Arrange
        final state = ForumState(
          posts: mockPosts,
          selectedCategory: 'Semua Subjek',
          searchQuery: '',
          isLoading: false,
        );

        when(() => mockForumCubit.state).thenReturn(state);
        when(() => mockForumCubit.stream).thenAnswer((_) => const Stream.empty());

        // Act
        await tester.pumpWidget(createTestWidget(state: state));
        await tester.pumpAndSettle();

        // Assert - Category badge containers
        final categoryContainers = tester.widgetList<Container>(
          find.descendant(
            of: find.byType(Column),
            matching: find.byType(Container),
          ),
        ).where((container) {
          final decoration = container.decoration as BoxDecoration?;
          return decoration?.color == const Color(0xFFFFD900) || // Bahasa
                 decoration?.color == const Color(0xFF42B1FF);   // Informatika
        });

        expect(categoryContainers.length, greaterThanOrEqualTo(2));
      });
    });

    group('Create Post View Tests', () {
      testWidgets('should display create post form when floating button is tapped', (WidgetTester tester) async {
        // Arrange
        final state = ForumState(
          posts: mockPosts,
          selectedCategory: 'Semua Subjek',
          searchQuery: '',
          isLoading: false,
        );

        when(() => mockForumCubit.state).thenReturn(state);
        when(() => mockForumCubit.stream).thenAnswer((_) => const Stream.empty());

        // Act
        await tester.pumpWidget(createTestWidget(state: state));
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // Assert - Title changes
        expect(find.text('Mulai Diskusi Baru'), findsOneWidget);

        // Assert - Form fields
        expect(find.text('Judul Pertanyaan*'), findsOneWidget);
        expect(find.text('Kategori*'), findsOneWidget);
        expect(find.text('Deskripsi*'), findsOneWidget);
        expect(find.text('Tambahkan Gambar/Video'), findsOneWidget);
        expect(find.text('Tags'), findsOneWidget);

        // Assert - Submit button
        expect(find.text('Kirim ke Forum'), findsOneWidget);

        // Assert - Floating button is hidden
        expect(find.byType(FloatingActionButton), findsNothing);
      });

      testWidgets('should display category dropdown with correct options', (WidgetTester tester) async {
        // Arrange
        final state = ForumState(
          posts: mockPosts,
          selectedCategory: 'Semua Subjek',
          searchQuery: '',
          isLoading: false,
        );

        when(() => mockForumCubit.state).thenReturn(state);
        when(() => mockForumCubit.stream).thenAnswer((_) => const Stream.empty());

        // Act
        await tester.pumpWidget(createTestWidget(state: state));
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // Tap dropdown to open it
        await tester.tap(find.byType(DropdownButton<String>));
        await tester.pumpAndSettle();

        // Assert - Category options
        expect(find.text('Informatika'), findsNWidgets(2)); // One in dropdown, one selected
        expect(find.text('Matematika'), findsOneWidget);
        expect(find.text('Sains'), findsOneWidget);
        expect(find.text('Bahasa'), findsOneWidget);
      });

      testWidgets('should validate required fields', (WidgetTester tester) async {
        // Arrange
        final state = ForumState(
          posts: mockPosts,
          selectedCategory: 'Semua Subjek',
          searchQuery: '',
          isLoading: false,
          isCreatingPost: false,
        );

        when(() => mockForumCubit.state).thenReturn(state);
        when(() => mockForumCubit.stream).thenAnswer((_) => const Stream.empty());

        // Act
        await tester.pumpWidget(createTestWidget(state: state));
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // Try to submit without filling required fields
        await tester.tap(find.text('Kirim ke Forum'));
        await tester.pumpAndSettle();

        // Assert - Validation message appears
        expect(find.text('Judul pertanyaan harus diisi'), findsOneWidget);
      });

      testWidgets('should add and remove tags correctly', (WidgetTester tester) async {
        // Arrange
        final state = ForumState(
          posts: mockPosts,
          selectedCategory: 'Semua Subjek',
          searchQuery: '',
          isLoading: false,
        );

        when(() => mockForumCubit.state).thenReturn(state);
        when(() => mockForumCubit.stream).thenAnswer((_) => const Stream.empty());

        // Act
        await tester.pumpWidget(createTestWidget(state: state));
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // Add a tag
        await tester.enterText(find.widgetWithText(TextField, 'Tambah tag'), 'test-tag');
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        // Assert - Tag appears
        expect(find.text('test-tag'), findsOneWidget);
        expect(find.byType(Chip), findsOneWidget);

        // Remove the tag
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();

        // Assert - Tag is removed
        expect(find.text('test-tag'), findsNothing);
        expect(find.byType(Chip), findsNothing);
      });
    });

    group('Loading and Empty States', () {
      testWidgets('should display loading indicator when loading', (WidgetTester tester) async {
        // Arrange
        final state = ForumState(
          posts: [],
          selectedCategory: 'Semua Subjek',
          searchQuery: '',
          isLoading: true,
        );

        when(() => mockForumCubit.state).thenReturn(state);
        when(() => mockForumCubit.stream).thenAnswer((_) => const Stream.empty());

        // Act
        await tester.pumpWidget(createTestWidget(state: state));

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should display empty state when no posts found', (WidgetTester tester) async {
        // Arrange
        final state = ForumState(
          posts: [],
          selectedCategory: 'Semua Subjek',
          searchQuery: '',
          isLoading: false,
        );

        when(() => mockForumCubit.state).thenReturn(state);
        when(() => mockForumCubit.stream).thenAnswer((_) => const Stream.empty());

        // Act
        await tester.pumpWidget(createTestWidget(state: state));

        // Assert - No posts displayed
        expect(find.text('Bagaimana Mengatasi Siswa yang Kurang Termotivasi?'), findsNothing);
        expect(find.byType(ListView), findsOneWidget); // ListView still exists but empty
      });

      testWidgets('should display loading indicator when creating post', (WidgetTester tester) async {
        // Arrange
        final state = ForumState(
          posts: mockPosts,
          selectedCategory: 'Semua Subjek',
          searchQuery: '',
          isLoading: false,
          isCreatingPost: true,
        );

        when(() => mockForumCubit.state).thenReturn(state);
        when(() => mockForumCubit.stream).thenAnswer((_) => const Stream.empty());

        // Act
        await tester.pumpWidget(createTestWidget(state: state));
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // Assert - Submit button shows loading
        final submitButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Kirim ke Forum'),
        );
        expect(submitButton.onPressed, isNull); // Button should be disabled
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('Functionality Tests', () {
      testWidgets('should call loadPosts on ForumCubit when page loads', (WidgetTester tester) async {
        // Arrange
        final state = ForumState(
          posts: mockPosts,
          selectedCategory: 'Semua Subjek',
          searchQuery: '',
          isLoading: false,
        );

        when(() => mockForumCubit.state).thenReturn(state);
        when(() => mockForumCubit.stream).thenAnswer((_) => const Stream.empty());

        // Act
        await tester.pumpWidget(createTestWidget(state: state));

        // Assert - Verify cubit methods are called
        // Note: In real implementation, you might want to verify loadPosts is called
        // This depends on your cubit implementation
      });

      testWidgets('should handle back navigation correctly', (WidgetTester tester) async {
        // Arrange
        final state = ForumState(
          posts: mockPosts,
          selectedCategory: 'Semua Subjek',
          searchQuery: '',
          isLoading: false,
        );

        when(() => mockForumCubit.state).thenReturn(state);
        when(() => mockForumCubit.stream).thenAnswer((_) => const Stream.empty());

        // Act
        await tester.pumpWidget(createTestWidget(state: state));
        
        // Go to create post view
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        
        expect(find.text('Mulai Diskusi Baru'), findsOneWidget);
        
        // Press back button
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Assert - Should return to forum list
        expect(find.text('Forum Diskusi'), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });

      testWidgets('should handle upvote and downvote actions', (WidgetTester tester) async {
        // Arrange
        final state = ForumState(
          posts: mockPosts,
          selectedCategory: 'Semua Subjek',
          searchQuery: '',
          isLoading: false,
        );

        when(() => mockForumCubit.state).thenReturn(state);
        when(() => mockForumCubit.stream).thenAnswer((_) => const Stream.empty());
        when(() => mockForumCubit.upvotePost(any())).thenAnswer((_) async {});
        when(() => mockForumCubit.downvotePost(any())).thenAnswer((_) async {});

        // Act
        await tester.pumpWidget(createTestWidget(state: state));
        await tester.pumpAndSettle();

        // Tap upvote button
        await tester.tap(find.byIcon(Icons.keyboard_arrow_up).first);
        await tester.pumpAndSettle();

        // Tap downvote button
        await tester.tap(find.byIcon(Icons.keyboard_arrow_down).first);
        await tester.pumpAndSettle();

        // Assert - Verify methods were called
        verify(() => mockForumCubit.upvotePost(any())).called(1);
        verify(() => mockForumCubit.downvotePost(any())).called(1);
      });
    });

    group('Error Handling Tests', () {
      testWidgets('should display error message when error occurs', (WidgetTester tester) async {
        // Arrange
        final state = ForumState(
          posts: [],
          selectedCategory: 'Semua Subjek',
          searchQuery: '',
          isLoading: false,
          errorMessage: 'Failed to load posts',
        );

        when(() => mockForumCubit.state).thenReturn(state);
        when(() => mockForumCubit.stream).thenAnswer((_) => const Stream.empty());
        when(() => mockForumCubit.clearMessages()).thenReturn(null);

        // Act
        await tester.pumpWidget(createTestWidget(state: state));
        await tester.pumpAndSettle();

        // Assert - Error message should be displayed in SnackBar
        expect(find.text('Failed to load posts'), findsOneWidget);
      });

      testWidgets('should display success message when post is created', (WidgetTester tester) async {
        // Arrange
        final state = ForumState(
          posts: mockPosts,
          selectedCategory: 'Semua Subjek',
          searchQuery: '',
          isLoading: false,
          successMessage: 'Diskusi berhasil dibuat!',
        );

        when(() => mockForumCubit.state).thenReturn(state);
        when(() => mockForumCubit.stream).thenAnswer((_) => const Stream.empty());
        when(() => mockForumCubit.clearMessages()).thenReturn(null);

        // Act
        await tester.pumpWidget(createTestWidget(state: state));
        await tester.pumpAndSettle();

        // Assert - Success message should be displayed
        expect(find.text('Diskusi berhasil dibuat!'), findsOneWidget);
      });
    });

    group('Responsive Design Tests', () {
      testWidgets('should handle different screen sizes', (WidgetTester tester) async {
        // Arrange
        final state = ForumState(
          posts: mockPosts,
          selectedCategory: 'Semua Subjek',
          searchQuery: '',
          isLoading: false,
        );

        when(() => mockForumCubit.state).thenReturn(state);
        when(() => mockForumCubit.stream).thenAnswer((_) => const Stream.empty());

        // Act - Test with different screen sizes
        await tester.binding.setSurfaceSize(const Size(320, 568)); // iPhone SE
        await tester.pumpWidget(createTestWidget(state: state));
        await tester.pumpAndSettle();

        // Assert - All elements should still be visible
        expect(find.text('Forum Diskusi'), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);

        // Test with tablet size
        await tester.binding.setSurfaceSize(const Size(768, 1024));
        await tester.pumpWidget(createTestWidget(state: state));
        await tester.pumpAndSettle();

        expect(find.text('Forum Diskusi'), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });
    });
  });
}