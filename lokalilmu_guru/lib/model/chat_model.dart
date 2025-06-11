enum ChatType { individual, group }
enum MessageType { text, image, file, voice }

class ChatModel {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final bool isFavorite;
  final bool isGroup;
  final String avatarUrl;
  final ChatType type;
  final List<String>? participants;

  ChatModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isOnline,
    required this.isFavorite,
    this.isGroup = false,
    this.avatarUrl = '',
    required this.type,
    this.participants,
  });

  ChatModel copyWith({
    String? id,
    String? name,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isOnline,
    bool? isFavorite,
    bool? isGroup,
    String? avatarUrl,
    ChatType? type,
    List<String>? participants,
  }) {
    return ChatModel(
      id: id ?? this.id,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      isFavorite: isFavorite ?? this.isFavorite,
      isGroup: isGroup ?? this.isGroup,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      type: type ?? this.type,
      participants: participants ?? this.participants,
    );
  }
}

// MessageModel yang diperbaiki - menghapus chatId yang required
class MessageModel {
  final String id;
  final String content;
  final String senderId;
  final String senderName;
  final DateTime timestamp;
  final MessageType type;
  final bool isFromMe;
  final bool isRead;
  final String? attachmentUrl;
  final String? replyToId;

  MessageModel({
    required this.id,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
    this.type = MessageType.text,
    required this.isFromMe,
    this.isRead = false,
    this.attachmentUrl,
    this.replyToId,
  });

  MessageModel copyWith({
    String? id,
    String? content,
    String? senderId,
    String? senderName,
    DateTime? timestamp,
    MessageType? type,
    bool? isFromMe,
    bool? isRead,
    String? attachmentUrl,
    String? replyToId,
  }) {
    return MessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isFromMe: isFromMe ?? this.isFromMe,
      isRead: isRead ?? this.isRead,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      replyToId: replyToId ?? this.replyToId,
    );
  }
}