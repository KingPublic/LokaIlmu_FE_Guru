import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokalilmu_guru/blocs/dashboard_bloc.dart';
import 'package:lokalilmu_guru/dashboard_page.dart';
import 'package:lokalilmu_guru/model/schedule_item.dart';
import 'package:lokalilmu_guru/model/training_item.dart';
import 'package:lokalilmu_guru/repositories/course_repository.dart';

void main() {
  Widget createWidgetUnderTest(DashboardState state) {
    return MaterialApp(
      home: BlocProvider<DashboardBloc>(
        create: (_) => FakeDashboardBloc(state),
        child: const DashboardPage(),
      ),
    );
  }

  testWidgets('menampilkan loading indicator saat loading', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(DashboardLoading()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('menampilkan empty state jika tidak ada kursus', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(
      DashboardLoaded(
        hasJoinedCourses: false,
        upcomingSchedules: [],
        currentTraining: null,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Tidak ada pelatihan yang diikuti saat ini...'), findsNWidgets(2));
  });

  testWidgets('menampilkan jadwal dan pelatihan saat tersedia', (tester) async {
    final schedule = ScheduleItem(
      id: 'schedule1',
      title: 'Sesi 1',
      startDate: DateTime(2025, 6, 5, 12),
      endDate: DateTime(2025, 6, 5, 14),
    );

    final training = TrainingItem(
      id: 'training1',
      title: 'Pelatihan Flutter',
      startDate: DateTime(2025, 6, 1),
      endDate: DateTime(2025, 6, 30),
      completedSessions: 3,
      totalSessions: 5,
    );

    await tester.pumpWidget(createWidgetUnderTest(
      DashboardLoaded(
        hasJoinedCourses: true,
        upcomingSchedules: [schedule],
        currentTraining: training,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Sesi 1'), findsOneWidget);
    expect(find.text('Pelatihan Flutter'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
  });
}

// FakeBloc untuk testing
class FakeDashboardBloc extends DashboardBloc {
  final DashboardState testState;

  FakeDashboardBloc(this.testState)
      : super(courseRepository: FakeCourseRepository()) {
    emit(testState);
  }

  @override
  Stream<DashboardState> mapEventToState(DashboardEvent event) async* {
    yield testState;
  }
}

// Add a fake repository for testing
class FakeCourseRepository implements CourseRepository {
  @override
  Future<TrainingItem?> getCurrentTraining() async {
    return null;
  }

  @override
  Future<List<ScheduleItem>> getUpcomingSchedules() async {
    return [];
  }

  @override
  Future<bool> hasJoinedCourses() async {
    return false;
  }

  @override
  Future<void> toggleCourseState(bool newState) async {
    // Do nothing for test
  }
}
