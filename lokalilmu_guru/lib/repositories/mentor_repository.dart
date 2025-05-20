import 'package:hive/hive.dart';

import '../model/mentor_model.dart';

class MentorRepository {
  final String _boxName = 'mentors';
  late Box<MentorModel> _mentorBox;

  Future<void> initialize() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _mentorBox = await Hive.openBox<MentorModel>(_boxName);
    } else {
      _mentorBox = Hive.box<MentorModel>(_boxName);
    }

    // Jika box kosong, isi dengan data dummy
    if (_mentorBox.isEmpty) {
      await _initializeMentors();
    }
  }

  Future<void> _initializeMentors() async {
    final dummyMentors = [
      MentorModel(
        id: '1',
        name: 'Dr. Budi Santoso',
        institution: 'Dosen di UC Makassar',
        imageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
        rating: 4.8,
        reviewCount: 120,
        description: 'Dosen matematika dengan pengalaman mengajar 15 tahun',
        categories: ['Matematika', 'Aljabar', 'Kalkulus'],
      ),
      MentorModel(
        id: '2',
        name: 'Siti Rahayu, M.Pd',
        institution: 'Bahasa Inggris',
        imageUrl: 'https://randomuser.me/api/portraits/women/2.jpg',
        rating: 4.6,
        reviewCount: 98,
        description: 'Guru bahasa Inggris berpengalaman dengan sertifikasi TOEFL',
        categories: ['Bahasa Inggris', 'Grammar', 'Speaking'],
      ),
      MentorModel(
        id: '3',
        name: 'Ir. Ahmad Hidayat',
        institution: 'Fisika',
        imageUrl: 'https://randomuser.me/api/portraits/men/3.jpg',
        rating: 4.9,
        reviewCount: 150,
        description: 'Insinyur dan pengajar fisika dengan pendekatan praktis',
        categories: ['Fisika', 'Mekanika', 'Termodinamika'],
      ),
      MentorModel(
        id: '4',
        name: 'Dewi Lestari, S.Kom',
        institution: 'Pemrograman',
        imageUrl: 'https://randomuser.me/api/portraits/women/4.jpg',
        rating: 4.7,
        reviewCount: 110,
        description: 'Software engineer yang mengajar pemrograman web dan mobile',
        categories: ['Pemrograman', 'Web', 'Mobile'],
      ),
      MentorModel(
        id: '5',
        name: 'Prof. Hadi Wijaya',
        institution: 'Kimia',
        imageUrl: 'https://randomuser.me/api/portraits/men/5.jpg',
        rating: 4.5,
        reviewCount: 85,
        description: 'Profesor kimia dengan publikasi internasional',
        categories: ['Kimia', 'Organik', 'Anorganik'],
      ),
    ];

    for (var mentor in dummyMentors) {
      await _mentorBox.put(mentor.id, mentor);
    }
  }

  Future<List<MentorModel>> getAllMentors() async {
    return _mentorBox.values.toList();
  }

  Future<List<MentorModel>> searchMentors(String query, String? category) async {
    if (query.isEmpty && category == null) {
      return getAllMentors();
    }

    return _mentorBox.values.where((mentor) {
      bool matchesQuery = query.isEmpty || 
                         mentor.name.toLowerCase().contains(query.toLowerCase()) ||
                         mentor.expertise.toLowerCase().contains(query.toLowerCase()) ||
                         mentor.description.toLowerCase().contains(query.toLowerCase());
      
      bool matchesCategory = category == null || category == 'Semua' || 
                            mentor.categories.contains(category);
      
      return matchesQuery && matchesCategory;
    }).toList();
  }

  Future<List<String>> getAllCategories() async {
    final Set<String> categories = {'Semua'};
    
    for (var mentor in _mentorBox.values) {
      categories.addAll(mentor.categories);
    }
    
    return categories.toList();
  }
}