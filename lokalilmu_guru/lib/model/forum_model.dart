class ForumPost {
  final String id;
  final String title;
  final String content;
  final String authorName;
  final String authorRole;
  final String authorAvatar;
  final String category;
  final DateTime createdAt;
  final int upvotes;
  final int downvotes;
  final int comments;
  final List<String> tags;
  final VoteStatus userVoteStatus; 

  ForumPost({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.authorRole,
    required this.authorAvatar,
    required this.category,
    required this.createdAt,
    this.upvotes = 0,
    this.downvotes = 0,
    this.comments = 0,
    this.tags = const [],
    this.userVoteStatus = VoteStatus.none, // Default tidak ada vote
  });

  ForumPost copyWith({
    String? id,
    String? title,
    String? content,
    String? authorName,
    String? authorRole,
    String? authorAvatar,
    String? category,
    DateTime? createdAt,
    int? upvotes,
    int? downvotes,
    int? comments,
    List<String>? tags,
    VoteStatus? userVoteStatus, // Tambahan parameter
  }) {
    return ForumPost(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      comments: comments ?? this.comments,
      tags: tags ?? this.tags,
      userVoteStatus: userVoteStatus ?? this.userVoteStatus,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Baru saja';
    }
  }
}

// Enum untuk status vote user
enum VoteStatus {
  none,    // Belum vote
  upvoted, // Sudah upvote
  downvoted // Sudah downvote
}

class CreatePostRequest {
  final String title;
  final String content;
  final String category;
  final List<String> tags;
  final String? mediaPath;

  CreatePostRequest({
    required this.title,
    required this.content,
    required this.category,
    this.tags = const [],
    this.mediaPath,
  });
}