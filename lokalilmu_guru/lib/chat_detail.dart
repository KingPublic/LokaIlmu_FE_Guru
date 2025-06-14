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
      final chats = await _chatRepository.getAllChats();
      _currentChat = chats.firstWhere(
        (chat) => chat.id == widget.chatId,
        orElse: () => throw Exception('Chat not found'),
      );

      _messages = await _generateDummyMessages(_currentChat!);
      
      setState(() {
        _isLoading = false;
      });

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
    final now = DateTime.now();
    
    // HANYA INDIVIDUAL CHAT - hapus logika grup
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
              backgroundColor: Colors.grey[300],
              child: _currentChat!.avatarUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        _currentChat!.avatarUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.person,
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
                  // HAPUS logika grup - hanya tampilkan status online
                  Text(
                    _currentChat!.isOnline ? 'Online' : 'Terakhir dilihat baru saja',
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

          // Mulai Deal Button
          Positioned(
            right: 16,
            bottom: 80,
            child: SizedBox(
              width: 65,
              height: 65,
              child: FloatingActionButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Memulai Deal')),
                  );
                },
                backgroundColor: const Color(0xFFFBCD5F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.handshake_rounded,
                      color: Color(0xFF0C3450),
                      size: 28,
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Mulai Deal',
                      style: TextStyle(
                        color: Color(0xFF0C3450),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
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

  const _MessageBubble({
    required this.message,
    required this.formatTime,
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
                  // HAPUS nama sender untuk grup karena tidak ada grup lagi
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