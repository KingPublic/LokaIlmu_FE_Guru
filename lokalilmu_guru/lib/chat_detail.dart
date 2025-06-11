import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lokalilmu_guru/model/chat_model.dart';
import 'package:lokalilmu_guru/repositories/chat_repository.dart';

class ChatDetailPage extends StatefulWidget {
  final String chatId;

  const ChatDetailPage({
    super.key,
    required this.chatId,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatRepository _chatRepository = ChatRepository();
  
  ChatModel? _currentChat;
  List<MessageModel> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatData();
  }

  Future<void> _loadChatData() async {
    try {
      // Get all chats and find the current one
      final chats = await _chatRepository.getAllChats();
      _currentChat = chats.firstWhere(
        (chat) => chat.id == widget.chatId,
        orElse: () => throw Exception('Chat not found'),
      );

      // Load dummy messages for this chat
      _messages = await _generateDummyMessages(_currentChat!);
      
      setState(() {
        _isLoading = false;
      });

      // Mark chat as read
      await _chatRepository.markChatAsRead(widget.chatId);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading chat: $e')),
        );
      }
    }
  }

  Future<List<MessageModel>> _generateDummyMessages(ChatModel chat) async {
    // Generate dummy messages based on chat type and content
    final now = DateTime.now();
    
    if (chat.isGroup) {
      return [
        MessageModel(
          id: '1',
          content: 'Selamat pagi semua! Bagaimana kabar kalian hari ini?',
          senderId: 'teacher_1',
          senderName: chat.participants?.first ?? 'Teacher',
          timestamp: now.subtract(const Duration(hours: 2)),
          type: MessageType.text,
          isFromMe: false,
          isRead: true,
        ),
        MessageModel(
          id: '2',
          content: 'Pagi pak! Alhamdulillah baik',
          senderId: 'student_1',
          senderName: 'Siswa A',
          timestamp: now.subtract(const Duration(hours: 1, minutes: 45)),
          type: MessageType.text,
          isFromMe: false,
          isRead: true,
        ),
        MessageModel(
          id: '3',
          content: 'Baik pak, siap untuk pelajaran hari ini',
          senderId: 'me',
          senderName: 'Saya',
          timestamp: now.subtract(const Duration(hours: 1, minutes: 30)),
          type: MessageType.text,
          isFromMe: true,
          isRead: true,
        ),
        MessageModel(
          id: '4',
          content: chat.lastMessage,
          senderId: 'teacher_1',
          senderName: chat.participants?.first ?? 'Teacher',
          timestamp: chat.lastMessageTime,
          type: MessageType.text,
          isFromMe: false,
          isRead: false,
        ),
      ];
    } else {
      return [
        MessageModel(
          id: '1',
          content: 'Selamat pagi, bagaimana kabarnya?',
          senderId: chat.id,
          senderName: chat.name,
          timestamp: now.subtract(const Duration(hours: 3)),
          type: MessageType.text,
          isFromMe: false,
          isRead: true,
        ),
        MessageModel(
          id: '2',
          content: 'Pagi, alhamdulillah baik. Bagaimana dengan bapak/ibu?',
          senderId: 'me',
          senderName: 'Saya',
          timestamp: now.subtract(const Duration(hours: 2, minutes: 45)),
          type: MessageType.text,
          isFromMe: true,
          isRead: true,
        ),
        MessageModel(
          id: '3',
          content: 'Alhamdulillah baik juga. Ada yang bisa saya bantu?',
          senderId: chat.id,
          senderName: chat.name,
          timestamp: now.subtract(const Duration(hours: 2, minutes: 30)),
          type: MessageType.text,
          isFromMe: false,
          isRead: true,
        ),
        MessageModel(
          id: '4',
          content: chat.lastMessage,
          senderId: chat.id,
          senderName: chat.name,
          timestamp: chat.lastMessageTime,
          type: MessageType.text,
          isFromMe: false,
          isRead: false,
        ),
      ];
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: _messageController.text.trim(),
      senderId: 'me',
      senderName: 'Saya',
      timestamp: DateTime.now(),
      type: MessageType.text,
      isFromMe: true,
      isRead: true,
    );

    setState(() {
      _messages.add(newMessage);
    });

    _messageController.clear();
    
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(time);
    } else if (difference.inDays == 1) {
      return 'Kemarin ${DateFormat('HH:mm').format(time)}';
    } else {
      return DateFormat('dd/MM/yy HH:mm').format(time);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go('/chat');
              }
            },
          ),
          title: const Text(
            'Loading...',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF0C3450)),
        ),
      );
    }

    if (_currentChat == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go('/chat');
              }
            },
          ),
          title: const Text(
            'Chat Not Found',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
        ),
        body: const Center(
          child: Text('Chat tidak ditemukan'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/chat');
            }
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: _currentChat!.isGroup ? const Color(0xFF0C3450) : Colors.grey[300],
              child: _currentChat!.avatarUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        _currentChat!.avatarUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            _currentChat!.isGroup ? Icons.group : Icons.person,
                            color: Colors.white,
                            size: 20,
                          );
                        },
                      ),
                    )
                  : Icon(
                      _currentChat!.isGroup ? Icons.group : Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentChat!.name,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!_currentChat!.isGroup)
                    Text(
                      _currentChat!.isOnline ? 'Online' : 'Terakhir dilihat baru saja',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    )
                  else
                    Text(
                      '${_currentChat!.participants?.length ?? 0} anggota',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.black),
            onPressed: () {
              // Video call functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.black),
            onPressed: () {
              // Voice call functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              // More options
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Messages List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _MessageBubble(
                      message: message,
                      formatTime: _formatMessageTime,
                      isGroup: _currentChat!.isGroup,
                    );
                  },
                ),
              ),

              // Message Input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.attach_file, color: Color(0xFF0C3450)),
                        onPressed: () {
                          // Attachment functionality
                        },
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Ketik pesan...',
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.newline,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFF0C3450),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating Action Button - positioned above message input
          Positioned(
            right: 16,
            bottom: 100, // Positioned above the message input area
            child: FloatingActionButton(
              onPressed: () {
                // Scroll to bottom
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              },
              backgroundColor: const Color(0xFF0C3450),
              child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final String Function(DateTime) formatTime;
  final bool isGroup;

  const _MessageBubble({
    required this.message,
    required this.formatTime,
    required this.isGroup,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isFromMe 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (!message.isFromMe && isGroup) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: Text(
                message.senderName.isNotEmpty 
                    ? message.senderName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: message.isFromMe 
                    ? const Color(0xFF0C3450)
                    : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!message.isFromMe && isGroup)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message.senderName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  Text(
                    message.content,
                    style: TextStyle(
                      color: message.isFromMe ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatTime(message.timestamp),
                        style: TextStyle(
                          color: message.isFromMe 
                              ? Colors.white.withOpacity(0.7)
                              : Colors.grey[500],
                          fontSize: 11,
                        ),
                      ),
                      if (message.isFromMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color: message.isRead 
                              ? Colors.blue[300]
                              : Colors.white.withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}