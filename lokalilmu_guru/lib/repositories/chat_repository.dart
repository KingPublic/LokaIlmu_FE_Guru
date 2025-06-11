import 'package:lokalilmu_guru/model/chat_model.dart';

class ChatRepository {
  // Dummy data untuk development
  static final List<ChatModel> _dummyChats = [
    ChatModel(
      id: '1',
      name: 'Dr. Ahmad Wijaya',
      lastMessage: 'Terima kasih atas pertanyaannya tentang matematika',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 2,
      isOnline: true,
      isFavorite: true,
      type: ChatType.individual,
    ),
    ChatModel(
      id: '2',
      name: 'Prof. Siti Nurhaliza',
      lastMessage: 'Materi fisika untuk besok sudah saya kirim',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
      unreadCount: 0,
      isOnline: false,
      isFavorite: false,
      type: ChatType.individual,
    ),
    ChatModel(
      id: '3',
      name: 'Grup Matematika Kelas 12',
      lastMessage: 'Pak Budi: Jangan lupa tugas untuk minggu depan',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 5,
      isOnline: false,
      isFavorite: true,
      isGroup: true,
      type: ChatType.group,
      participants: ['Dr. Ahmad Wijaya', 'Siswa A', 'Siswa B', 'Siswa C'],
    ),
    ChatModel(
      id: '4',
      name: 'Drs. Bambang Sutrisno',
      lastMessage: 'Selamat pagi, bagaimana kabarnya?',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
      isOnline: true,
      isFavorite: false,
      type: ChatType.individual,
    ),
    ChatModel(
      id: '5',
      name: 'Grup Bahasa Indonesia',
      lastMessage: 'Bu Ani: Materi puisi sudah diupload',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
      unreadCount: 1,
      isOnline: false,
      isFavorite: false,
      isGroup: true,
      type: ChatType.group,
      participants: ['Bu Ani', 'Siswa D', 'Siswa E'],
    ),
    ChatModel(
      id: '6',
      name: 'Dr. Maya Sari',
      lastMessage: 'File presentasi sudah saya share',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 3)),
      unreadCount: 0,
      isOnline: false,
      isFavorite: true,
      type: ChatType.individual,
    ),
  ];

  // Simulate API call
  Future<List<ChatModel>> getAllChats() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_dummyChats);
  }

  // Get specific chat by ID
  Future<ChatModel?> getChatById(String chatId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _dummyChats.firstWhere((chat) => chat.id == chatId);
    } catch (e) {
      return null;
    }
  }

  // Filter chats based on category
  Future<List<ChatModel>> getChatsByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    switch (category.toLowerCase()) {
      case 'semua':
        return List.from(_dummyChats);
      case 'belum dibaca':
        return _dummyChats.where((chat) => chat.unreadCount > 0).toList();
      case 'favorit':
        return _dummyChats.where((chat) => chat.isFavorite).toList();
      case 'grup':
        return _dummyChats.where((chat) => chat.isGroup).toList();
      default:
        return List.from(_dummyChats);
    }
  }

  // Search chats
  Future<List<ChatModel>> searchChats(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (query.isEmpty) {
      return List.from(_dummyChats);
    }
    
    return _dummyChats.where((chat) => 
      chat.name.toLowerCase().contains(query.toLowerCase()) ||
      chat.lastMessage.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Get messages for a specific chat (for future implementation)
  Future<List<MessageModel>> getMessagesForChat(String chatId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Return dummy messages for now
    return [];
  }

  // Send message (for future implementation)
  Future<MessageModel> sendMessage(String chatId, String content, MessageType type) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate sending message
    throw UnimplementedError('Send message not implemented yet');
  }

  // Mark chat as read
  Future<void> markChatAsRead(String chatId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final chatIndex = _dummyChats.indexWhere((chat) => chat.id == chatId);
    if (chatIndex != -1) {
      _dummyChats[chatIndex] = _dummyChats[chatIndex].copyWith(unreadCount: 0);
    }
  }

  // Toggle favorite
  Future<void> toggleFavorite(String chatId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final chatIndex = _dummyChats.indexWhere((chat) => chat.id == chatId);
    if (chatIndex != -1) {
      _dummyChats[chatIndex] = _dummyChats[chatIndex].copyWith(
        isFavorite: !_dummyChats[chatIndex].isFavorite
      );
    }
  }
}