import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalilmu_guru/blocs/dashboard/dashboard_event.dart';
import 'package:lokalilmu_guru/blocs/dashboard/dashboard_state.dart';
import 'package:lokalilmu_guru/repositories/course_repository.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final CourseRepository courseRepository;

  DashboardBloc({required this.courseRepository}) : super(DashboardInitial()) {
    on<LoadDashboardEvent>(_onLoadDashboard);
    on<ToggleCourseStateEvent>(_onToggleCourseState);
  }

  Future<void> _onLoadDashboard(
    LoadDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    
    try {
      final hasJoinedCourses = await courseRepository.hasJoinedCourses();
      
      if (hasJoinedCourses) {
        final upcomingSchedules = await courseRepository.getUpcomingSchedules();
        final currentTraining = await courseRepository.getCurrentTraining();
        
        emit(DashboardLoaded(
          hasJoinedCourses: true,
          upcomingSchedules: upcomingSchedules,
          currentTraining: currentTraining,
        ));
      } else {
        emit(const DashboardLoaded(
          hasJoinedCourses: false,
          upcomingSchedules: [],
          currentTraining: null,
        ));
      }
    } catch (e) {
      emit(DashboardError('Failed to load dashboard: ${e.toString()}'));
    }
  }

  Future<void> _onToggleCourseState(
    ToggleCourseStateEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    
    try {
      await courseRepository.toggleCourseState(event.hasJoinedCourses);
      
      if (event.hasJoinedCourses) {
        final upcomingSchedules = await courseRepository.getUpcomingSchedules();
        final currentTraining = await courseRepository.getCurrentTraining();
        
        emit(DashboardLoaded(
          hasJoinedCourses: true,
          upcomingSchedules: upcomingSchedules,
          currentTraining: currentTraining,
        ));
      } else {
        emit(const DashboardLoaded(
          hasJoinedCourses: false,
          upcomingSchedules: [],
          currentTraining: null,
        ));
      }
    } catch (e) {
      emit(DashboardError('Failed to toggle course state: ${e.toString()}'));
    }
  }
}