import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'blocs/chat_bloc.dart';
import 'model/chat_model.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  bool _localeInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    context.read<ChatBloc>().add(LoadChatsEvent());
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('id_ID', null);
    setState(() {
      _localeInitialized = true;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    context.read<ChatBloc>().add(SearchChatsEvent(query));
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _searchQuery = '';
    });
    context.read<ChatBloc>().add(FilterChatsByCategoryEvent(category));
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(time);
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      if (_localeInitialized) {
        return DateFormat('EEEE', 'id_ID').format(time);
      } else {
        return DateFormat('EEEE').format(time);
      }
    } else {
      return DateFormat('dd/MM/yy').format(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        context.go('/dashboard');
                      }
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'Pesan',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Header with search and filters
            Container(
              color: Colors.white,
              child: _ChatHeader(
                onSearchChanged: _onSearchChanged,
                onCategorySelected: _onCategorySelected,
                selectedCategory: _selectedCategory,
              ),
            ),

            // Chat List
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0C3450),
                      ),
                    );
                  } else if (state is ChatError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<ChatBloc>().add(LoadChatsEvent());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0C3450),
                            ),
                            child: const Text(
                              'Coba Lagi',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (state is ChatLoaded) {
                    if (state.chats.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty 
                                  ? 'Tidak ada chat yang ditemukan'
                                  : 'Belum ada chat',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<ChatBloc>().add(RefreshChatsEvent());
                      },
                      color: const Color(0xFF0C3450),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: state.chats.length,
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          indent: 72,
                          endIndent: 16,
                        ),
                        itemBuilder: (context, index) {
                          final chat = state.chats[index];
                          return _ChatTile(
                            chat: chat,
                            onTap: () {
                              if (chat.unreadCount > 0) {
                                context.read<ChatBloc>().add(MarkChatAsReadEvent(chat.id));
                              }
                              context.go('/chat/${chat.id}');
                            },
                            onLongPress: () {
                              _showChatOptions(context, chat);
                            },
                            formatTime: _formatTime,
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChatOptions(BuildContext context, ChatModel chat) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  chat.isFavorite ? Icons.star : Icons.star_border,
                  color: chat.isFavorite ? Colors.amber : null,
                ),
                title: Text(chat.isFavorite ? 'Hapus dari Favorit' : 'Tambah ke Favorit'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<ChatBloc>().add(ToggleFavoriteEvent(chat.id));
                },
              ),
              if (chat.unreadCount > 0)
                ListTile(
                  leading: const Icon(Icons.mark_email_read),
                  title: const Text('Tandai Sudah Dibaca'),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<ChatBloc>().add(MarkChatAsReadEvent(chat.id));
                  },
                ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Info Chat'),
                onTap: () {
                  Navigator.pop(context);
                  // Show chat info
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChatHeader extends StatelessWidget {
  final Function(String) onSearchChanged;
  final Function(String) onCategorySelected;
  final String selectedCategory;

  const _ChatHeader({
    required this.onSearchChanged,
    required this.onCategorySelected,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    // HAPUS 'Grup' dari categories
    final categories = ['Semua', 'Belum Dibaca', 'Favorit'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Cari pesan...',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1B3C73), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1B3C73), width: 2),
              ),
            ),
          ),
        ),

        // Category pills
        SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final cat = categories[i];
              final isSelected = cat == selectedCategory;

              return ChoiceChip(
                label: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => onCategorySelected(cat),
                selectedColor: const Color(0xFF0C3450),
                checkmarkColor: Colors.white,
                backgroundColor: const Color(0xFFF0F0F0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: isSelected
                      ? BorderSide.none
                      : const BorderSide(color: Colors.transparent),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final String Function(DateTime) formatTime;

  const _ChatTile({
    required this.chat,
    required this.onTap,
    required this.onLongPress,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.white,
        child: Row(
          children: [
            // Avatar - HAPUS logika grup
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey[300],
                  child: chat.avatarUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Image.network(
                            chat.avatarUrl,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 28,
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 28,
                        ),
                ),
                // Online indicator - hanya untuk individual
                if (chat.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            // Chat info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: chat.unreadCount > 0 ? FontWeight.w600 : FontWeight.w500,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.isFavorite)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat.lastMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: chat.unreadCount > 0 ? Colors.black87 : Colors.grey[600],
                      fontWeight: chat.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Time and unread count
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatTime(chat.lastMessageTime),
                  style: TextStyle(
                    fontSize: 12,
                    color: chat.unreadCount > 0 ? const Color(0xFF0C3450) : Colors.grey[500],
                    fontWeight: chat.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (chat.unreadCount > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0C3450),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      chat.unreadCount > 99 ? '99+' : chat.unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}