import '../model/mentor_model.dart';

class MentorRepository {
  // Data dummy untuk mentor
  final List<MentorModel> _mentors = [];
  
  // Flag untuk menandai apakah repository sudah diinisialisasi
  bool _isInitialized = false;

  Future<void> initialize() async {
    // Hindari inisialisasi berulang
    if (_isInitialized) return;
    
    try {
      // Inisialisasi data dummy
      _mentors.clear();
      _mentors.addAll(_createDummyMentors());
      _isInitialized = true;
    } catch (e, stackTrace) {
      print("Error initializing mentor repository: $e");
      print("Stack trace: $stackTrace");
      rethrow;
    }
  }

  List<MentorModel> _createDummyMentors() {
    return [
      MentorModel(
        id: '1',
        name: 'Dr. Budi Santoso',
        institution: 'Matematika',
        imageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
        rating: 4.8,
        reviewCount: 120,
        description: 'Dosen matematika dengan pengalaman mengajar 15 tahun',
        categories: ['Matematika', 'Aljabar', 'Kalkulus'],
        pricePerSession: 100000,
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
        pricePerSession: 100000,
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
        pricePerSession: 100000,
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
        pricePerSession: 100000,
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
        pricePerSession: 100000,
      ),
    ];
  }

  Future<List<MentorModel>> getAllMentors() async {
    // Pastikan repository sudah diinisialisasi
    if (!_isInitialized) {
      await initialize();
    }
    return _mentors;
  }

  Future<List<MentorModel>> searchMentors(String query, String? category) async {
    // Pastikan repository sudah diinisialisasi
    if (!_isInitialized) {
      await initialize();
    }
    
    if (query.isEmpty && category == null) {
      return getAllMentors();
    }

    return _mentors.where((mentor) {
      // Cek apakah query cocok dengan nama, expertise, atau deskripsi
      bool matchesQuery = query.isEmpty || 
                         mentor.name.toLowerCase().contains(query.toLowerCase()) ||
                         mentor.institution.toLowerCase().contains(query.toLowerCase()) ||
                         mentor.description.toLowerCase().contains(query.toLowerCase()) ||
                         // Cek apakah query cocok dengan salah satu kategori
                         mentor.categories.any((cat) => cat.toLowerCase().contains(query.toLowerCase()));
      
      // Cek apakah kategori yang dipilih cocok
      bool matchesCategory = category == null || category == 'Semua Subjek' || 
                            mentor.categories.contains(category);
      
      return matchesQuery && matchesCategory;
    }).toList();
  }

  Future<List<String>> getAllCategories() async {
    // Pastikan repository sudah diinisialisasi
    if (!_isInitialized) {
      await initialize();
    }
    
    final Set<String> categories = {'Semua Subjek'};
    
    for (var mentor in _mentors) {
      categories.addAll(mentor.categories);
    }
    
    return categories.toList();
  }
}