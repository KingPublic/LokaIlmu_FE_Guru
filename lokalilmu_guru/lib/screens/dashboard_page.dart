import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalilmu_guru/blocs/dashboard/dashboard_bloc.dart';
import 'package:lokalilmu_guru/blocs/dashboard/dashboard_event.dart';
import 'package:lokalilmu_guru/blocs/dashboard/dashboard_state.dart';
import 'package:lokalilmu_guru/model/schedule_item.dart';
import 'package:lokalilmu_guru/widgets/dashboard/current_training_widget.dart';
import 'package:lokalilmu_guru/widgets/dashboard/empty_state_widget.dart';
import 'package:lokalilmu_guru/widgets/dashboard/schedule_item_widget.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.black,
              child: Icon(Icons.person_outline, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kalvin Richie',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Edit Profil',
                  style: TextStyle(
                    color: Colors.blue[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.black),
              onPressed: () {},
            ),
          ],
        ),
        automaticallyImplyLeading: false,
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.laptop),
            label: 'Kelas Mandiri',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Perpustakaan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
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
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Upcoming Schedule Section
            const Text(
              'Jadwal Mendatang',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
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
                fontWeight: FontWeight.bold,
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