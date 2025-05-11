abstract class DashboardEvent {}

class LoadDashboardEvent extends DashboardEvent {}

class ToggleCourseStateEvent extends DashboardEvent {
  final bool hasJoinedCourses;

  ToggleCourseStateEvent(this.hasJoinedCourses);
}