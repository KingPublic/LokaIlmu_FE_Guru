import 'package:equatable/equatable.dart';
import 'package:lokalilmu_guru/model/schedule_item.dart';
import 'package:lokalilmu_guru/model/training_item.dart';

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