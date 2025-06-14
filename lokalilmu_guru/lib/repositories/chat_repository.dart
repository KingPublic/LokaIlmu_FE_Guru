import 'package:lokalilmu_guru/model/chat_model.dart';

class ChatRepository {
  // Dummy data untuk development - TANPA GRUP
static final List<ChatModel> _dummyChats = [
    ChatModel(
      id: '1',
      name: 'Dr. Budi Santoso',
      lastMessage: 'Terima kasih atas pertanyaannya tentang matematika',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 2,
      isOnline: true,
      isFavorite: true,
      type: ChatType.individual,
      avatarUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
    ),
    ChatModel(
      id: '2',
      name: 'Siti Rahayu, M.Pd',
      lastMessage: 'Materi bahasa Inggris untuk besok sudah saya kirim',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
      unreadCount: 0,
      isOnline: false,
      isFavorite: false,
      type: ChatType.individual,
      avatarUrl: 'https://randomuser.me/api/portraits/women/2.jpg',
    ),
    ChatModel(
      id: '3',
      name: 'Ir. Ahmad Hidayat',
      lastMessage: 'Konsep fisika yang tadi sudah jelas ya',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
      unreadCount: 1,
      isOnline: true,
      isFavorite: false,
      type: ChatType.individual,
      avatarUrl: 'https://randomuser.me/api/portraits/men/3.jpg',
    ),
    ChatModel(
      id: '4',
      name: 'Dewi Lestari, S.Kom',
      lastMessage: 'Selamat pagi, bagaimana kabarnya?',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
      isOnline: true,
      isFavorite: false,
      type: ChatType.individual,
      avatarUrl: 'https://randomuser.me/api/portraits/women/4.jpg',
    ),
    ChatModel(
      id: '5',
      name: 'Prof. Hadi Wijaya',
      lastMessage: 'File presentasi kimia sudah saya share',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 3)),
      unreadCount: 0,
      isOnline: false,
      isFavorite: true,
      type: ChatType.individual,
      avatarUrl: 'https://randomuser.me/api/portraits/men/5.jpg',
    ),
  ];

  // Simulate API call
  Future<List<ChatModel>> getAllChats() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Filter hanya individual chats
    return _dummyChats.where((chat) => !chat.isGroup).toList();
  }

  // Get specific chat by ID
  Future<ChatModel?> getChatById(String chatId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _dummyChats.firstWhere(
        (chat) => chat.id == chatId && !chat.isGroup
      );
    } catch (e) {
      return null;
    }
  }

  // Filter chats based on category - TANPA GRUP
  Future<List<ChatModel>> getChatsByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final individualChats = _dummyChats.where((chat) => !chat.isGroup).toList();
    
    switch (category.toLowerCase()) {
      case 'semua':
        return individualChats;
      case 'belum dibaca':
        return individualChats.where((chat) => chat.unreadCount > 0).toList();
      case 'favorit':
        return individualChats.where((chat) => chat.isFavorite).toList();
      default:
        return individualChats;
    }
  }

  // Search chats - TANPA GRUP
  Future<List<ChatModel>> searchChats(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final individualChats = _dummyChats.where((chat) => !chat.isGroup).toList();
    
    if (query.isEmpty) {
      return individualChats;
    }
    
    return individualChats.where((chat) => 
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