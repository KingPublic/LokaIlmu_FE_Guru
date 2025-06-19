import '../model/forum_model.dart';
import 'edit_repository.dart';

class ForumRepository {
  final EditProfileRepository _profileRepository;

  // Map untuk menyimpan status vote user per post
  // Key: postId, Value: VoteStatus
  final Map<String, VoteStatus> _userVotes = {};

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
      userVoteStatus: VoteStatus.none,
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
      userVoteStatus: VoteStatus.none,
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
      userVoteStatus: VoteStatus.none,
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
      userVoteStatus: VoteStatus.none,
    ),
  ];

  List<ForumPost> getAllPosts() {
    // Update posts dengan status vote user saat ini
    return _posts.map((post) => post.copyWith(
      userVoteStatus: _userVotes[post.id] ?? VoteStatus.none,
    )).toList();
  }

  List<ForumPost> getPostsByCategory(String category) {
    if (category == 'Semua Subjek') return getAllPosts();
    return getAllPosts().where((post) => post.category == category).toList();
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
      userVoteStatus: VoteStatus.none,
    );
    
    _posts.insert(0, newPost);
    return newPost;
  }

  Future<ForumPost> upvotePost(String postId) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index == -1) {
      throw Exception('Post not found');
    }

    final currentPost = _posts[index];
    final currentVoteStatus = _userVotes[postId] ?? VoteStatus.none;
    
    int newUpvotes = currentPost.upvotes;
    int newDownvotes = currentPost.downvotes;
    VoteStatus newVoteStatus;
    
    if (currentVoteStatus == VoteStatus.upvoted) {
      // User sudah upvote, batalkan upvote
      newUpvotes = currentPost.upvotes - 1;
      newVoteStatus = VoteStatus.none;
    } else if (currentVoteStatus == VoteStatus.downvoted) {
      // User sudah downvote, ganti ke upvote
      newUpvotes = currentPost.upvotes + 1;
      newDownvotes = currentPost.downvotes - 1;
      newVoteStatus = VoteStatus.upvoted;
    } else {
      // User belum vote, tambah upvote
      newUpvotes = currentPost.upvotes + 1;
      newVoteStatus = VoteStatus.upvoted;
    }
    
    // Update vote status user
    _userVotes[postId] = newVoteStatus;
    
    // Update post
    _posts[index] = currentPost.copyWith(
      upvotes: newUpvotes,
      downvotes: newDownvotes,
      userVoteStatus: newVoteStatus,
    );
    
    return _posts[index];
  }

  Future<ForumPost> downvotePost(String postId) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index == -1) {
      throw Exception('Post not found');
    }

    final currentPost = _posts[index];
    final currentVoteStatus = _userVotes[postId] ?? VoteStatus.none;
    
    int newUpvotes = currentPost.upvotes;
    int newDownvotes = currentPost.downvotes;
    VoteStatus newVoteStatus;
    
    if (currentVoteStatus == VoteStatus.downvoted) {
      // User sudah downvote, batalkan downvote
      newDownvotes = currentPost.downvotes - 1;
      newVoteStatus = VoteStatus.none;
    } else if (currentVoteStatus == VoteStatus.upvoted) {
      // User sudah upvote, ganti ke downvote
      newUpvotes = currentPost.upvotes - 1;
      newDownvotes = currentPost.downvotes + 1;
      newVoteStatus = VoteStatus.downvoted;
    } else {
      // User belum vote, tambah downvote
      newDownvotes = currentPost.downvotes + 1;
      newVoteStatus = VoteStatus.downvoted;
    }
    
    // Update vote status user
    _userVotes[postId] = newVoteStatus;
    
    // Update post
    _posts[index] = currentPost.copyWith(
      upvotes: newUpvotes,
      downvotes: newDownvotes,
      userVoteStatus: newVoteStatus,
    );
    
    return _posts[index];
  }

  Future<ForumPost> removeVote(String postId) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index == -1) {
      throw Exception('Post not found');
    }

    final currentPost = _posts[index];
    final currentVoteStatus = _userVotes[postId] ?? VoteStatus.none;
    
    int newUpvotes = currentPost.upvotes;
    int newDownvotes = currentPost.downvotes;
    
    if (currentVoteStatus == VoteStatus.upvoted) {
      newUpvotes = currentPost.upvotes - 1;
    } else if (currentVoteStatus == VoteStatus.downvoted) {
      newDownvotes = currentPost.downvotes - 1;
    }
    
    // Remove vote status user
    _userVotes[postId] = VoteStatus.none;
    
    // Update post
    _posts[index] = currentPost.copyWith(
      upvotes: newUpvotes,
      downvotes: newDownvotes,
      userVoteStatus: VoteStatus.none,
    );
    
    return _posts[index];
  }

  // Method helper untuk get post by id
  ForumPost? getPostById(String postId) {
    try {
      return getAllPosts().firstWhere((post) => post.id == postId);
    } catch (e) {
      return null;
    }
  }
}