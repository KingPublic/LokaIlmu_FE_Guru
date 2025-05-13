import 'package:lokalilmu_guru/model/schedule_item.dart';
import 'package:lokalilmu_guru/model/training_item.dart';

class CourseRepository {
  // In a real app, this would fetch data from an API or local database
  Future<List<ScheduleItem>> getUpcomingSchedules() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Return mock data
    return [
      ScheduleItem(
        id: '1',
        title: 'Sesi 1: Mengenal Microsoft Excel & Navigasi',
        startDate: DateTime(2023, 4, 21, 12, 0),
        endDate: DateTime(2023, 4, 21, 15, 0),
      ),
      ScheduleItem(
        id: '2',
        title: 'Sesi 2: Format Data & Pengolahan Dasar',
        startDate: DateTime(2023, 4, 25, 10, 0),
        endDate: DateTime(2023, 4, 25, 13, 0),
      ),
    ];
  }

  Future<TrainingItem?> getCurrentTraining() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Return mock data
    return TrainingItem(
      id: '1',
      title: 'Pengenalan & Dasar-Dasar Excel',
      startDate: DateTime(2023, 4, 19),
      endDate: DateTime(2023, 5, 3),
      totalSessions: 10,
      completedSessions: 1,
    );
  }

  // For demo purposes - toggle between having courses and not having courses
  Future<bool> hasJoinedCourses() async {
    // In a real app, this would check if the user has any courses
    // For demo, we'll return true to show courses
    return true;
  }

  // For demo purposes - toggle between states
  Future<void> toggleCourseState(bool newState) async {
    // In a real app, this would update a user preference or setting
    await Future.delayed(const Duration(milliseconds: 300));
    // The state is managed in the BLoC
  }
}