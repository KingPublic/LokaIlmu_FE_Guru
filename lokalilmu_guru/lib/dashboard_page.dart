import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lokalilmu_guru/blocs/dashboard_bloc.dart';
import 'package:lokalilmu_guru/model/schedule_item.dart';
import 'package:lokalilmu_guru/model/training_item.dart';
import 'package:lokalilmu_guru/widgets/common/dashboard_header.dart';
import 'package:lokalilmu_guru/widgets/common/navbar.dart';
import 'package:go_router/go_router.dart';
import 'repositories/edit_repository.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? userName;
  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Assuming you have a profile repository instance
      // Replace this with your actual repository instance
      final profileRepository = EditProfileRepository(); // Replace with your actual repository
      final user = await profileRepository.getCurrentUser();
      
      setState(() {
        userName = user?.namaLengkap ?? 'User'; // Use 'User' as fallback if name is null
        isLoadingUser = false;
      });
    } catch (e) {
      setState(() {
        userName = 'User'; // Fallback name in case of error
        isLoadingUser = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppHeader(
        currentIndex: 1,
        // Tambahkan handler jika diperlukanR
        onSearchTap: () => {},
        onNotificationTap: () => {},
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
        currentIndex: 0 // Dashboard adalah tab pertama
        // onTap: (index) {
        // switch (index) {
        //   case 0:
        //     context.go('/dashboard');
        //     break;
        //   case 1:
        //     context.go('/mentor-search'); // contoh nama route
        //     break;
        //   case 2:
        //     context.go('/perpustakaan');
        //     break;
        //   case 3:
        //     context.go('/');
        //     break;
        // }
        // },
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, DashboardLoaded state) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat datang, $userName!',
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
            state.hasJoinedCourses && state.upcomingSchedules.isNotEmpty
                ? _buildUpcomingSchedules(state.upcomingSchedules)
                : const EmptyStateWidget(
                    message: 'Tidak ada pelatihan yang diikuti saat ini...',
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
            state.hasJoinedCourses && state.currentTraining != null
                ? CurrentTrainingWidget(training: state.currentTraining!)
                : const EmptyStateWidget(
                    message: 'Tidak ada pelatihan yang diikuti saat ini...',
                  ),
            
            // Demo toggle button (you would remove this in production)
            const SizedBox(height: 40),
            // Center(
            //   child: ElevatedButton(
            //     onPressed: () {
            //       context.read<DashboardBloc>().add(
            //         ToggleCourseStateEvent(!state.hasJoinedCourses),
            //       );
            //     },
            //     child: Text(state.hasJoinedCourses
            //         ? 'Show Empty State'
            //         : 'Show Courses'),
            //   ),
            // ),
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

    return GestureDetector(
      onTap: () {
        context.go('/materi-pelatihan/${training.id}');
      },
    
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
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
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1B3C73)),
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
      ),
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
    return GestureDetector(
      onTap: () {
        // Tentukan sessionId berdasarkan title schedule
        String sessionId = _getSessionIdFromTitle(schedule.title);
        
        // Navigate ke materi pelatihan dengan sessionId
        context.go('/materi-pelatihan/1?sessionId=$sessionId');
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
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
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method untuk mendapatkan sessionId dari title
  String _getSessionIdFromTitle(String title) {
    if (title.contains('Sesi 1')) {
      return 'session_1';
    } else if (title.contains('Sesi 2')) {
      return 'session_2';
    }
    // Default ke session pertama jika tidak ditemukan
    return 'session_1';
  }

  String _formatScheduleTime(DateTime start, DateTime end) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final timeFormat = DateFormat('HH:mm');
    return '${dateFormat.format(start)} ${timeFormat.format(start)} - ${timeFormat.format(end)}';
  }
}