import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'blocs/chat_bloc.dart';
import 'model/chat_model.dart';

class ChatDetailPage extends StatefulWidget {
  final String chatId;
  
  const ChatDetailPage({super.key, required this.chatId});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Dummy messages for the specific chat
  late List<MessageModel> _messages;
  late ChatModel _currentChat;

  @override
  void initState() {
    super.initState();
    _initializeChatData();
  }

  void _initializeChatData() {
    // Find the current chat (in real app, this would come from BLoC)
    _currentChat = ChatModel(
      id: widget.chatId,
      name: 'Anggi Fatmawati',
      lastMessage: 'Baik, Pak. Saya rasa itu memungkinkan...',
      lastMessageTime: DateTime.now(),
      type: ChatType.individual,
      isOnline: true,
    );

    // Dummy messages for this chat
    _messages = [
      MessageModel(
        id: '1',
        chatId: widget.chatId,
        senderId: 'other',
        senderName: 'Anggi Fatmawati',
        content: 'Halo Bu Anggi, saya tertarik dengan pelatihan Microsoft Excel untuk guru-guru di sekolah kami. Tapi kami punya keterbatasan anggaran, hanya Rp1.200.000 untuk 10 sesi. Apakah memungkinkan?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        type: MessageType.text,
        isRead: true,
      ),
      MessageModel(
        id: '2',
        chatId: widget.chatId,
        senderId: 'me',
        senderName: 'Saya',
        content: 'Halo Pak, terima kasih atas ketarikannya. Untuk 10 sesi, anggaran tersebut memang cukup terbatas. Namun, mungkin kita bisa sesuaikan durasi atau formatnya. Apakah sesi 30 menit masih bisa diterima?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
        type: MessageType.text,
        isRead: true,
      ),
      MessageModel(
        id: '3',
        chatId: widget.chatId,
        senderId: 'other',
        senderName: 'Anggi Fatmawati',
        content: 'Sesi 30 menit tidak masalah, Bu, yang penting guru-guru bisa memahami dasar Excel dengan baik. Kami juga berharap pelatihannya bisa selesai dalam satu bulan.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
        type: MessageType.text,
        isRead: true,
      ),
      MessageModel(
        id: '4',
        chatId: widget.chatId,
        senderId: 'me',
        senderName: 'Saya',
        content: 'Baik, Pak. Saya rasa itu memungkinkan. Saya akan coba susun proposal jadwal dan materinya dulu. Kalau Bapak setuju, kita bisa lanjut ke deal ya.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
        type: MessageType.text,
        isRead: true,
      ),
    ];
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      final newMessage = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: widget.chatId,
        senderId: 'me',
        senderName: 'Saya',
        content: _messageController.text.trim(),
        timestamp: DateTime.now(),
        type: MessageType.text,
        isRead: false,
      );

      setState(() {
        _messages.add(newMessage);
      });

      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
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
    return DateFormat('HH:mm').format(time);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle deal button press
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Memulai deal dengan Anggi Fatmawati')),
          );
        },
        backgroundColor: const Color(0xFFFBCD5F),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.handshake, color: Color(0xFF0C3450), size: 28),
            Text(
              'Mulai Deal',
              style: TextStyle(
                color: Color(0xFF0C3450),
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  // Profile Picture
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: const NetworkImage(
                      'https://randomuser.me/api/portraits/women/44.jpg',
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentChat.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Dosen di UC Makassar',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // More options
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      // Show more options
                    },
                  ),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isMe = message.senderId == 'me';
                  final showTime = index == _messages.length - 1 || 
                      _messages[index + 1].timestamp.difference(message.timestamp).inMinutes > 1;

                  return _MessageBubble(
                    message: message,
                    isMe: isMe,
                    showTime: showTime,
                    formatTime: _formatMessageTime,
                  );
                },
              ),
            ),

            // Message Input
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  // Attachment button
                  IconButton(
                    icon: const Icon(Icons.photo_camera, color: Colors.grey),
                    onPressed: () {
                      // Handle attachment
                    },
                  ),
                  // Text input
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Ketik pesan anda...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send button
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF0C3450)),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final bool showTime;
  final String Function(DateTime) formatTime;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.showTime,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF0C3450) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 8),
              ],
            ],
          ),
          
          // Time
          if (showTime) ...[
            const SizedBox(height: 4),
            Padding(
              padding: EdgeInsets.only(
                left: isMe ? 0 : 8,
                right: isMe ? 8 : 0,
              ),
              child: Text(
                formatTime(message.timestamp),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}