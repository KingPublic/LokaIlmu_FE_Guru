import 'package:lokalilmu_guru/model/mentor_model.dart';

class MentorRepository {
  // Ini adalah data dummy untuk contoh
  // Pada implementasi sebenarnya, data akan diambil dari API
  final List<Mentor> _mentors = [
    Mentor(
      id: '1',
      name: 'Anggi Fatmawati',
      institution: 'Dosen di UC Makassar',
      photoUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
      rating: 4.9,
      subjects: ['Teknologi', 'Aplikasi Office'],
      description: 'Berpengalaman lebih dari 10 tahun dalam mengajar topik teknologi dan aplikasi perkantoran tingkat lanjut.',
      pricePerSession: 150000,
    ),
    Mentor(
      id: '2',
      name: 'Arunika Dina',
      institution: 'Dosen di Atma Jaya',
      photoUrl: 'https://randomuser.me/api/portraits/women/68.jpg',
      rating: 4.7,
      subjects: ['Kalkulus', 'Statistika'],
      description: 'Memahami konsep-konsep numerik dan analisis data secara mendalam',
      pricePerSession: 200000,
    ),
    Mentor(
      id: '3',
      name: 'Arnold Rafli',
      institution: 'Dosen di ITB',
      photoUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
      rating: 4.8,
      subjects: ['Fisika', 'Matematika'],
      description: 'Spesialis dalam bidang fisika kuantum dan matematika terapan dengan pengalaman mengajar 15 tahun',
      pricePerSession: 250000,
    ),
  ];

  // Get all mentors
  Future<List<Mentor>> getMentors() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    return _mentors;
  }

  // Search mentors by name or description
  Future<List<Mentor>> searchMentors(String query) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (query.isEmpty) {
      return _mentors;
    }
    
    final lowercaseQuery = query.toLowerCase();
    return _mentors.where((mentor) {
      return mentor.name.toLowerCase().contains(lowercaseQuery) ||
             mentor.description.toLowerCase().contains(lowercaseQuery) ||
             mentor.institution.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Filter mentors by subject
  Future<List<Mentor>> filterMentorsBySubject(String subject) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (subject == 'Semua Subjek') {
      return _mentors;
    }
    
    return _mentors.where((mentor) {
      return mentor.subjects.any((s) => s.toLowerCase() == subject.toLowerCase());
    }).toList();
  }
}