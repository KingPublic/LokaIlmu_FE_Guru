import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lokalilmu_guru/blocs/dashboard/dashboard_bloc.dart';
import 'package:lokalilmu_guru/model/schedule_item.dart';
import 'package:lokalilmu_guru/model/training_item.dart';
import 'package:lokalilmu_guru/widgets/common/dashboard_header.dart';
import 'package:lokalilmu_guru/widgets/common/navbar.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: const AppHeader(
        currentIndex: 0
        // Tambahkan handler jika diperlukan
        // onSearchTap: () => {},
        // onNotificationTap: () => {},
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardInitial || state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DashboardError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is DashboardLoaded) {
            return _buildDashboardContent(context, state);
          }
          return const Center(child: Text('Unknown state'));
        },
      ),
      bottomNavigationBar: AppBottomNavbar(
        currentIndex: 0, // Dashboard adalah tab pertama
        onTap: (index) {
          // Handle navigasi ke tab lain
          // Misalnya dengan go_router
          // if (index != 0) context.go('/other-route');
        },
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, DashboardLoaded state) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selamat datang, Kalvin!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            
            // Upcoming Schedule Section
            const Text(
              'Jadwal Mendatang',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            // Toggle between empty and filled states
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: state.hasJoinedCourses && state.upcomingSchedules.isNotEmpty
                ? _buildUpcomingSchedules(state.upcomingSchedules)
                : const EmptyStateWidget(
                    message: 'Tidak ada pelatihan yang diikuti saat ini...',
                  ),
            ),
            
            const SizedBox(height: 24),
            
            // Current Training Section
            const Text(
              'Pelatihan Saat Ini',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            // Toggle between empty and filled states
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: state.hasJoinedCourses && state.currentTraining != null
                  ? CurrentTrainingWidget(training: state.currentTraining!)
                  : const EmptyStateWidget(
                      message: 'Tidak ada pelatihan yang diikuti saat ini...',
                    ),
            ),
            
            // Demo toggle button (you would remove this in production)
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  context.read<DashboardBloc>().add(
                    ToggleCourseStateEvent(!state.hasJoinedCourses),
                  );
                },
                child: Text(state.hasJoinedCourses
                    ? 'Show Empty State'
                    : 'Show Courses'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSchedules(List<ScheduleItem> schedules) {
    return Column(
      children: schedules.map((schedule) => 
        ScheduleItemWidget(schedule: schedule)
      ).toList(),
    );
  }
}

class CurrentTrainingWidget extends StatelessWidget {
  final TrainingItem training;

  const CurrentTrainingWidget({
    Key? key,
    required this.training,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = training.progressPercentage.clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.book, color: Colors.black),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    training.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTrainingDates(training.startDate, training.endDate) +
                    ' (${training.completedSessions} sesi)',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Format training dates (e.g., "19/04/2023 - 03/05/2023")
  String _formatTrainingDates(DateTime start, DateTime end) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return '${dateFormat.format(start)} - ${dateFormat.format(end)}';
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String message;

  const EmptyStateWidget({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
      ),
    );
  }
}

class ScheduleItemWidget extends StatelessWidget {
  final ScheduleItem schedule;

  const ScheduleItemWidget({
    Key? key,
    required this.schedule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.calendar_today, color: Colors.black),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatScheduleTime(schedule.startDate, schedule.endDate),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Format schedule time (e.g., "21 Apr 2023 12:00 - 15:00")
  String _formatScheduleTime(DateTime start, DateTime end) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final timeFormat = DateFormat('HH:mm');
    return '${dateFormat.format(start)} ${timeFormat.format(start)} - ${timeFormat.format(end)}';
  }
}