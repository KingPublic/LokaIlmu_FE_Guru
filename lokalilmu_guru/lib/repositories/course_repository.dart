import 'package:lokalilmu_guru/model/schedule_item.dart';
import 'package:lokalilmu_guru/model/training_item.dart';
import 'package:lokalilmu_guru/model/training_material.dart';

class CourseRepository {
  // Existing methods - JANGAN DIHAPUS
  Future<List<ScheduleItem>> getUpcomingSchedules() async {
    await Future.delayed(const Duration(milliseconds: 800));
    
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
    await Future.delayed(const Duration(milliseconds: 800));
    
    return TrainingItem(
      id: '1',
      title: 'Pengenalan & Dasar-Dasar Excel',
      startDate: DateTime(2023, 4, 19),
      endDate: DateTime(2023, 5, 3),
      totalSessions: 10,
      completedSessions: 1,
    );
  }

  Future<bool> hasJoinedCourses() async {
    return true;
  }

  Future<void> toggleCourseState(bool newState) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // NEW METHODS - Update dengan TrainingMaterialType
  Future<TrainingMaterial?> getTrainingMaterial(String trainingId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (trainingId == '1') {
      return TrainingMaterial(
        id: 'material_1',
        trainingId: trainingId,
        title: 'Pengenalan & Dasar-Dasar Excel',
        duration: '30 minutes / sesi',
        participantCount: '30 guru SMP',
        sessions: [
          TrainingSession(
            id: 'session_1',
            title: 'Sesi 1: Mengenal Microsoft Excel & Navigasi Dasar',
            materials: [
              MaterialItem(
                id: 'slide_1',
                title: 'Slide Pengenalan',
                subtitle: 'PowerPoint • 12 halaman',
                type: TrainingMaterialType.slide, // Update ke TrainingMaterialType
              ),
              MaterialItem(
                id: 'video_1',
                title: 'Penjelasan Konsep',
                subtitle: 'Video • 8:45 menit',
                type: TrainingMaterialType.video, // Update ke TrainingMaterialType
              ),
            ],
          ),
          TrainingSession(
            id: 'session_2',
            title: 'Sesi 2: Format Data & Pengolahan Dasar',
            materials: [
              MaterialItem(
                id: 'example_1',
                title: 'Contoh Soal',
                subtitle: '',
                type: TrainingMaterialType.example, // Update ke TrainingMaterialType
                description: 'Berikut merupakan beberapa contoh soal yang dapat digunakan sebagai latihan.',
              ),
            ],
          ),
        ],
        teachingNotes: [
          'Gunakan contoh yang relevan agar murid lebih mudah memahami.',
          'Dorong murid untuk praktik langsung dalam setiap sesi.',
          'Berikan quiz atau diskusi di akhir sesi untuk memperkuat pemahaman.',
        ],
      );
    }
    
    return null;
  }

  Future<void> completeTraining(String trainingId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}