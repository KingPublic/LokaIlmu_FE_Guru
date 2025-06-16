import '../model/forum_model.dart';
import 'edit_repository.dart';

class ForumRepository {

  final EditProfileRepository _profileRepository;

  ForumRepository({required EditProfileRepository profileRepository})
      : _profileRepository = profileRepository;
  // Dummy data untuk forum posts
  List<ForumPost> _posts = [
    ForumPost(
      id: '1',
      title: 'Bagaimana Mengatasi Siswa yang Kurang Termotivasi?',
      content: 'Saya mengajar SMP dan sering menghadapi siswa yang tampak tidak antusias dalam belajar. Saya sudah mencoba berbagai metode, tetapi masih sulit menarik perhatian mereka. Adakah yang punya tips efektif?',
      authorName: 'Jono Don',
      authorRole: 'Guru SMP di Makassar',
      authorAvatar: 'asset/images/avatar1.jpg',
      category: 'Bahasa',
      createdAt: DateTime.now().subtract(Duration(days: 2)),
      upvotes: 10,
      downvotes: 2,
      comments: 18,
      tags: ['motivasi', 'siswa', 'pembelajaran'],
    ),
    ForumPost(
      id: '2',
      title: 'Teknologi dalam Pembelajaran: Efektif atau Tidak?',
      content: 'Apakah penggunaan teknologi seperti Google Classroom atau Kahoot benar-benar meningkatkan efektivitas belajar? Saya ragu menggunakannya, tapi masih ragu-ragu.',
      authorName: 'Yura Setiani',
      authorRole: 'Guru SMP di Jakarta',
      authorAvatar: 'asset/images/avatar2.jpg',
      category: 'Informatika',
      createdAt: DateTime.now().subtract(Duration(hours: 5)),
      upvotes: 10,
      downvotes: 2,
      comments: 12,
      tags: ['teknologi', 'digital', 'efektivitas'],
    ),
    ForumPost(
      id: '3',
      title: 'Tips Mengajar Matematika yang Menyenangkan',
      content: 'Bagaimana cara membuat pelajaran matematika menjadi lebih menarik dan mudah dipahami siswa? Saya butuh ide-ide kreatif untuk mengajar konsep yang sulit.',
      authorName: 'Ahmad Rizki',
      authorRole: 'Guru Matematika SMA',
      authorAvatar: 'asset/images/avatar3.jpg',
      category: 'Matematika',
      createdAt: DateTime.now().subtract(Duration(hours: 12)),
      upvotes: 15,
      downvotes: 1,
      comments: 25,
      tags: ['matematika', 'kreatif', 'metode'],
    ),
    ForumPost(
      id: '4',
      title: 'Eksperimen Sains Sederhana untuk Kelas',
      content: 'Ada yang punya rekomendasi eksperimen sains yang mudah dilakukan di kelas dengan alat-alat sederhana? Siswa saya sangat antusias dengan praktikum.',
      authorName: 'Dr. Sarah',
      authorRole: 'Guru IPA SMP',
      authorAvatar: 'asset/images/avatar4.jpg',
      category: 'Sains',
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      upvotes: 8,
      downvotes: 0,
      comments: 14,
      tags: ['eksperimen', 'praktikum', 'ipa'],
    ),
  ];

  List<ForumPost> getAllPosts() {
    return List.from(_posts);
  }

  List<ForumPost> getPostsByCategory(String category) {
    if (category == 'Semua Subjek') return getAllPosts();
    return _posts.where((post) => post.category == category).toList();
  }

  List<ForumPost> searchPosts(String keyword, String category) {
    final posts = getPostsByCategory(category);
    if (keyword.isEmpty) return posts;
    
    return posts.where((post) =>
      post.title.toLowerCase().contains(keyword.toLowerCase()) ||
      post.content.toLowerCase().contains(keyword.toLowerCase()) ||
      post.authorName.toLowerCase().contains(keyword.toLowerCase())
    ).toList();
  }

  Future<ForumPost> createPost(CreatePostRequest request) async {
    // Simulate API delay
    await Future.delayed(Duration(seconds: 1));

    final user = await _profileRepository.getCurrentUser();
    
    final newPost = ForumPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: request.title,
      content: request.content,
      authorName: user?.namaLengkap ?? 'Current User',
      authorRole: 'Guru',
      authorAvatar: 'asset/images/default_avatar.jpg',
      category: request.category,
      createdAt: DateTime.now(),
      tags: request.tags,
    );
    
    _posts.insert(0, newPost);
    return newPost;
  }

  Future<ForumPost> upvotePost(String postId) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      _posts[index] = _posts[index].copyWith(
        upvotes: _posts[index].upvotes + 1,
      );
      return _posts[index];
    }
    throw Exception('Post not found');
  }

  Future<ForumPost> downvotePost(String postId) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      _posts[index] = _posts[index].copyWith(
        downvotes: _posts[index].downvotes + 1,
      );
      return _posts[index];
    }
    throw Exception('Post not found');
  }
}