import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalilmu_guru/model/schedule_item.dart';
import 'package:lokalilmu_guru/model/training_item.dart';
import 'package:lokalilmu_guru/repositories/course_repository.dart';

// Events
abstract class DashboardEvent {}

class LoadDashboardEvent extends DashboardEvent {}

class ToggleCourseStateEvent extends DashboardEvent {
  final bool hasJoinedCourses;

  ToggleCourseStateEvent(this.hasJoinedCourses);
}

// States
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final bool hasJoinedCourses;
  final List<ScheduleItem> upcomingSchedules;
  final TrainingItem? currentTraining;

  const DashboardLoaded({
    required this.hasJoinedCourses,
    required this.upcomingSchedules,
    this.currentTraining,
  });

  @override
  List<Object?> get props => [hasJoinedCourses, upcomingSchedules, currentTraining];

  DashboardLoaded copyWith({
    bool? hasJoinedCourses,
    List<ScheduleItem>? upcomingSchedules,
    TrainingItem? currentTraining,
  }) {
    return DashboardLoaded(
      hasJoinedCourses: hasJoinedCourses ?? this.hasJoinedCourses,
      upcomingSchedules: upcomingSchedules ?? this.upcomingSchedules,
      currentTraining: currentTraining ?? this.currentTraining,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}

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