import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lokalilmu_guru/model/chat_model.dart';
import 'package:lokalilmu_guru/repositories/chat_repository.dart';
import 'dart:math';
import 'package:lokalilmu_guru/pembayaran.dart';

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
  static int _dealCounter = 0;
  static bool _hasAcceptedDeal = false; // Track if any deal has been accepted
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatRepository _chatRepository = ChatRepository();
  
  ChatModel? _currentChat;
  List<dynamic> _messages = []; // Changed to dynamic to support different message types
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

  Future<List<dynamic>> _generateDummyMessages(ChatModel chat) async {
    final now = DateTime.now();
    
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

  void _showDealPopup() {
    showDialog(
      context: context,
      builder: (context) => _DealPopupWidget(
        chatId: widget.chatId,
        dealNumber: ++_dealCounter,
        onDealSubmitted: (dealData) {
          // Create deal request card and add to chat
          final dealRequest = DealRequestModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            dealRequestId: 'DR#${_dealCounter}',
            fokusLatihan: dealData['fokusLatihan'],
            durasi: int.parse(dealData['durasi']),
            durasiUnit: dealData['durasiUnit'],
            sesiPertemuan: int.parse(dealData['sesiPertemuan']),
            metodeLatihan: dealData['metodeLatihan'],
            lokasiLatihan: dealData['lokasiLatihan'],
            tanggalMulai: dealData['tanggalMulai'],
            tanggalSelesai: dealData['tanggalSelesai'],
            jumlahPartisipan: int.parse(dealData['jumlahPartisipan']),
            hargaPerSesi: double.parse(dealData['hargaPerSesi']),
            catatan: dealData['catatan'],
            status: 'Menunggu',
            timestamp: DateTime.now(),
            isFromMe: true,
          );
          
          setState(() {
            _messages.add(dealRequest);
          });
          
          // Auto change status after 10 seconds
          Future.delayed(const Duration(seconds: 10), () {
            if (mounted) {
              setState(() {
                final index = _messages.indexWhere((msg) => 
                  msg is DealRequestModel && msg.id == dealRequest.id);
                if (index != -1) {
                  // Determine status based on whether a deal has been accepted
                  String newStatus;
                  if (!_hasAcceptedDeal) {
                    newStatus = 'Diterima';
                    _hasAcceptedDeal = true; // Mark that a deal has been accepted
                  } else {
                    newStatus = 'Ditolak'; // Reject subsequent deals
                  }
                  
                  final updatedDeal = DealRequestModel(
                    id: dealRequest.id,
                    dealRequestId: dealRequest.dealRequestId,
                    fokusLatihan: dealRequest.fokusLatihan,
                    durasi: dealRequest.durasi,
                    durasiUnit: dealRequest.durasiUnit,
                    sesiPertemuan: dealRequest.sesiPertemuan,
                    metodeLatihan: dealRequest.metodeLatihan,
                    lokasiLatihan: dealRequest.lokasiLatihan,
                    tanggalMulai: dealRequest.tanggalMulai,
                    tanggalSelesai: dealRequest.tanggalSelesai,
                    jumlahPartisipan: dealRequest.jumlahPartisipan,
                    hargaPerSesi: dealRequest.hargaPerSesi,
                    catatan: dealRequest.catatan,
                    status: newStatus,
                    timestamp: dealRequest.timestamp,
                    isFromMe: dealRequest.isFromMe,
                  );
                  _messages[index] = updatedDeal;
                }
              });
            }
          });
          
          // Auto scroll to bottom
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
          
          print('Deal submitted: $dealData');
        },
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###');
    return formatter.format(amount);
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
                    
                    // Check if it's a deal request or regular message
                    if (message is DealRequestModel) {
                      return _DealRequestCard(
                        dealRequest: message,
                        formatTime: _formatMessageTime,
                      );
                    } else if (message is MessageModel) {
                      return _MessageBubble(
                        message: message,
                        formatTime: _formatMessageTime,
                      );
                    }
                    
                    return const SizedBox.shrink();
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
                onPressed: _showDealPopup,
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

// Deal Request Model
class DealRequestModel {
  final String id;
  final String dealRequestId;
  final String fokusLatihan;
  final int durasi;
  final String durasiUnit;
  final int sesiPertemuan;
  final String metodeLatihan;
  final String lokasiLatihan;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;
  final int jumlahPartisipan;
  final double hargaPerSesi;
  final String catatan;
  final String status;
  final DateTime timestamp;
  final bool isFromMe;

  DealRequestModel({
    required this.id,
    required this.dealRequestId,
    required this.fokusLatihan,
    required this.durasi,
    required this.durasiUnit,
    required this.sesiPertemuan,
    required this.metodeLatihan,
    required this.lokasiLatihan,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.jumlahPartisipan,
    required this.hargaPerSesi,
    required this.catatan,
    required this.status,
    required this.timestamp,
    required this.isFromMe,
  });

  double get totalBiaya => hargaPerSesi * sesiPertemuan;
}

// Deal Request Card Widget
class _DealRequestCard extends StatelessWidget {
  final DealRequestModel dealRequest;
  final String Function(DateTime) formatTime;

  const _DealRequestCard({
    required this.dealRequest,
    required this.formatTime,
  });

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: dealRequest.isFromMe 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Deal Request ${dealRequest.dealRequestId}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: dealRequest.status == 'Menunggu' 
                              ? const Color(0xFFFF6B6B)
                              : dealRequest.status == 'Diterima'
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFFF6B6B), // Ditolak also red
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          dealRequest.status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Deal Details
                  _buildDetailRow('Fokus Pelatihan:', dealRequest.fokusLatihan),
                  _buildDetailRow('Sesi:', '${dealRequest.sesiPertemuan} sesi (${dealRequest.durasi}${dealRequest.durasiUnit == 'Jam' ? 'jam' : 'min'}/sesi)'),
                  _buildDetailRow('Metode:', dealRequest.metodeLatihan),
                  _buildDetailRow(
                    'Pilihan Jadwal:', 
                    '${DateFormat('dd/MM/yyyy').format(dealRequest.tanggalMulai)} - ${DateFormat('dd/MM/yyyy').format(dealRequest.tanggalSelesai)}'
                  ),
                  _buildDetailRow('Jumlah Partisipan:', '+${dealRequest.jumlahPartisipan} guru'),
                  _buildDetailRow('Biaya per Sesi:', 'Rp${_formatCurrency(dealRequest.hargaPerSesi)}'),
                  _buildDetailRow('Total Biaya:', 'Rp${_formatCurrency(dealRequest.totalBiaya)}', isTotal: true),
                  
                  const SizedBox(height: 8),
                  
                  // Timestamp
                  Text(
                    formatTime(dealRequest.timestamp),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
                  // Add this after the timestamp Text widget and before the closing Column
                  if (dealRequest.status == 'Diterima') ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0C3450),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PembayaranPage(
                                    dealRequest: dealRequest,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Bayar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom TextInputFormatter for currency formatting
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digit characters
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.isEmpty) {
      return const TextEditingValue();
    }

    // Format with dots as thousand separators
    String formatted = _addThousandSeparator(digitsOnly);
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _addThousandSeparator(String value) {
    if (value.length <= 3) return value;
    
    String result = '';
    int counter = 0;
    
    for (int i = value.length - 1; i >= 0; i--) {
      if (counter == 3) {
        result = '.' + result;
        counter = 0;
      }
      result = value[i] + result;
      counter++;
    }
    
    return result;
  }
}

// Popup Widget yang sesuai dengan desain gambar
class _DealPopupWidget extends StatefulWidget {
  final String chatId;
  final int dealNumber;
  final Function(Map<String, dynamic>) onDealSubmitted;

  const _DealPopupWidget({
    required this.chatId,
    required this.dealNumber,
    required this.onDealSubmitted,
  });

  @override
  State<_DealPopupWidget> createState() => _DealPopupWidgetState();
}

class _DealPopupWidgetState extends State<_DealPopupWidget> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _fokusLatihanController = TextEditingController();
  final _durasiController = TextEditingController();
  final _sesiPertemuanController = TextEditingController();
  final _jumlahPartisipanController = TextEditingController();
  final _hargaPerSesiController = TextEditingController();
  final _catatanController = TextEditingController();
  
  // Dropdown values
  String _metodeLatihan = 'Online';
  String _lokasiLatihan = 'Online';
  String _durasiUnit = 'Jam';
  
  // Date values
  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  
  // Error messages
  String? _durasiError;
  String? _sesiError;
  String? _hargaError;
  String? _dateError;
  
  bool _isLoading = false;

  final List<String> _metodeOptions = ['Online', 'Offline', 'Hybrid'];
  final List<String> _lokasiOptions = ['Online', 'Janjian', 'Sekolah'];
  final List<String> _durasiUnitOptions = ['Jam', 'Menit'];

  @override
  void dispose() {
    _fokusLatihanController.dispose();
    _durasiController.dispose();
    _sesiPertemuanController.dispose();
    _jumlahPartisipanController.dispose();
    _hargaPerSesiController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  void _validateDuration() {
    final durasiText = _durasiController.text;
    if (durasiText.isNotEmpty) {
      final durasi = int.tryParse(durasiText);
      if (durasi != null) {
        if (_durasiUnit == 'Jam' && durasi > 6) {
          setState(() {
            _durasiError = 'Maksimal 6 jam';
          });
        } else if (_durasiUnit == 'Menit' && durasi > 60) {
          setState(() {
            _durasiError = 'Maksimal 60 menit';
          });
        } else {
          setState(() {
            _durasiError = null;
          });
        }
      }
    } else {
      setState(() {
        _durasiError = null;
      });
    }
  }

  void _validateSesi() {
    final sesiText = _sesiPertemuanController.text;
    if (sesiText.isNotEmpty) {
      final sesi = int.tryParse(sesiText);
      if (sesi != null) {
        if (sesi < 1 || sesi > 24) {
          setState(() {
            _sesiError = 'Sesi 1-24';
          });
        } else {
          setState(() {
            _sesiError = null;
          });
        }
      }
    } else {
      setState(() {
        _sesiError = null;
      });
    }
  }

  void _validateHarga() {
    final hargaText = _hargaPerSesiController.text.replaceAll('.', '');
    if (hargaText.isNotEmpty) {
      final harga = int.tryParse(hargaText);
      if (harga != null) {
        if (harga < 10000) {
          setState(() {
            _hargaError = 'Minimal Rp10.000';
          });
        } else {
          setState(() {
            _hargaError = null;
          });
        }
      }
    } else {
      setState(() {
        _hargaError = null;
      });
    }
  }

  void _validateDates() {
  if (_tanggalMulai == null) {
    setState(() {
      _dateError = 'Pilih tanggal mulai terlebih dahulu';
    });
  } else if (_tanggalSelesai == null) {
    setState(() {
      _dateError = 'Pilih tanggal selesai';
    });
  } else if (_tanggalSelesai!.isBefore(_tanggalMulai!)) {
    setState(() {
      _dateError = 'Tanggal selesai tidak boleh lebih awal dari tanggal mulai';
    });
  } else {
    setState(() {
      _dateError = null;
    });
  }
}

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
  // Jika user mencoba pilih tanggal selesai tapi belum pilih tanggal mulai
  if (!isStartDate && _tanggalMulai == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pilih tanggal mulai terlebih dahulu'),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: isStartDate 
        ? DateTime.now() 
        : (_tanggalMulai ?? DateTime.now()),
    firstDate: isStartDate 
        ? DateTime.now() 
        : (_tanggalMulai ?? DateTime.now()),
    lastDate: DateTime.now().add(const Duration(days: 365)),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1B4D5C),
          ),
        ),
        child: child!,
      );
    },
  );
  
  if (picked != null) {
    setState(() {
      if (isStartDate) {
        _tanggalMulai = picked;
        // Reset tanggal selesai jika sebelumnya sudah dipilih dan lebih awal dari tanggal mulai
        if (_tanggalSelesai != null && _tanggalSelesai!.isBefore(picked)) {
          _tanggalSelesai = null;
        }
      } else {
        _tanggalSelesai = picked;
      }
    });
    _validateDates();
  }
}

  Future<void> _submitDeal() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_tanggalMulai == null || _tanggalSelesai == null) {
      setState(() {
        _dateError = 'Pilih tanggal mulai dan selesai';
      });
      return;
    }

    if (_durasiError != null || _sesiError != null || _hargaError != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulasi delay
    await Future.delayed(const Duration(seconds: 1));

    final dealData = {
      'chatId': widget.chatId,
      'fokusLatihan': _fokusLatihanController.text.trim(),
      'durasi': _durasiController.text,
      'durasiUnit': _durasiUnit,
      'sesiPertemuan': _sesiPertemuanController.text,
      'metodeLatihan': _metodeLatihan,
      'lokasiLatihan': _lokasiLatihan,
      'tanggalMulai': _tanggalMulai,
      'tanggalSelesai': _tanggalSelesai,
      'jumlahPartisipan': _jumlahPartisipanController.text,
      'hargaPerSesi': _hargaPerSesiController.text.replaceAll('.', ''), // Remove dots for parsing
      'catatan': _catatanController.text.trim(),
      'timestamp': DateTime.now(),
    };

    if (mounted) {
      widget.onDealSubmitted(dealData);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permintaan deal berhasil dikirim')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700, maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
              ),
              child: Row(
                children: [
                  const Text(
                    'Mulai Deal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.close,
                      color: Colors.black54,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            
            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fokus Pelatihan
                      _buildTextField(
                        'Fokus Pelatihan',
                        _fokusLatihanController,
                        'Microsoft Excel',
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Fokus pelatihan harus diisi';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Durasi / Sesi dan Sesi Pertemuan
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Durasi / Sesi',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        controller: _durasiController,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                        style: const TextStyle(fontSize: 14),
                                        onChanged: (value) => _validateDuration(),
                                        decoration: InputDecoration(
                                          hintText: '1',
                                          hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
                                          filled: true,
                                          fillColor: const Color(0xFFF5F5F5),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                              color: _durasiError != null ? Colors.red : const Color(0xFFE0E0E0)
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                              color: _durasiError != null ? Colors.red : const Color(0xFFE0E0E0)
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                              color: _durasiError != null ? Colors.red : const Color(0xFF1B4D5C)
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        ),
                                        validator: (value) {
                                          if (value?.isEmpty ?? true) {
                                            return 'Durasi harus diisi';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      flex: 3,
                                      child: DropdownButtonFormField<String>(
                                        value: _durasiUnit,
                                        onChanged: (value) {
                                          setState(() => _durasiUnit = value!);
                                          _validateDuration();
                                        },
                                        style: const TextStyle(fontSize: 14, color: Colors.black),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: const Color(0xFFF5F5F5),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: const BorderSide(color: Color(0xFF1B4D5C)),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        ),
                                        items: _durasiUnitOptions.map((String option) {
                                          return DropdownMenuItem<String>(
                                            value: option,
                                            child: Text(option),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_durasiError != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    _durasiError!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Sesi Pertemuan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _sesiPertemuanController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  style: const TextStyle(fontSize: 14),
                                  onChanged: (value) => _validateSesi(),
                                  decoration: InputDecoration(
                                    hintText: '10',
                                    hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
                                    filled: true,
                                    fillColor: const Color(0xFFF5F5F5),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: _sesiError != null ? Colors.red : const Color(0xFFE0E0E0)
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: _sesiError != null ? Colors.red : const Color(0xFFE0E0E0)
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: _sesiError != null ? Colors.red : const Color(0xFF1B4D5C)
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Sesi harus diisi';
                                    }
                                    return null;
                                  },
                                ),
                                if (_sesiError != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    _sesiError!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Metode Pelatihan dan Lokasi Pelatihan
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              'Metode Pelatihan',
                              _metodeLatihan,
                              _metodeOptions,
                              (value) => setState(() => _metodeLatihan = value!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown(
                              'Lokasi Pelatihan',
                              _lokasiLatihan,
                              _lokasiOptions,
                              (value) => setState(() => _lokasiLatihan = value!),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Pilihan Jadwal
                      const Text(
                        'Pilihan Jadwal',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(
                              _tanggalMulai,
                              '19/04/25',
                              () => _selectDate(context, true),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('-', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          ),
                          Expanded(
                            child: _buildDateField(
                              _tanggalSelesai,
                              '19/05/25',
                              () => _selectDate(context, false),
                              isEndDate: true,
                            ),
                          ),
                        ],
                      ),
                      if (_dateError != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _dateError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 16),
                      
                      // Jumlah Partisipan
                      _buildTextField(
                        'Jumlah Partisipan',
                        _jumlahPartisipanController,
                        '30',
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Jumlah partisipan harus diisi';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Harga Negosiasi / Sesi
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Harga Negosiasi / Sesi',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _hargaPerSesiController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [CurrencyInputFormatter()],
                            style: const TextStyle(fontSize: 14),
                            onChanged: (value) => _validateHarga(),
                            decoration: InputDecoration(
                              hintText: '100.000',
                              hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
                              filled: true,
                              fillColor: const Color(0xFFF5F5F5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: _hargaError != null ? Colors.red : const Color(0xFFE0E0E0)
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: _hargaError != null ? Colors.red : const Color(0xFFE0E0E0)
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: _hargaError != null ? Colors.red : const Color(0xFF1B4D5C)
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Harga harus diisi';
                              }
                              return null;
                            },
                          ),
                          if (_hargaError != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              _hargaError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Catatan
                      _buildTextField(
                        'Catatan',
                        _catatanController,
                        'Masukkan catatan',
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Submit Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitDeal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C3450),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Kirim Permintaan Deal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.8,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1B4D5C)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> options,
    void Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14, color: Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1B4D5C)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateField(
    DateTime? date,
    String placeholder,
    VoidCallback onTap,
    {bool isEndDate = false}
  ) {
  final bool isDisabled = isEndDate && _tanggalMulai == null;
  
  return GestureDetector(
    onTap: isDisabled ? null : onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isDisabled 
            ? const Color(0xFFF0F0F0) 
            : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDisabled 
              ? const Color(0xFFCCCCCC) 
              : const Color(0xFFE0E0E0)
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              date != null 
                  ? DateFormat('dd/MM/yy').format(date)
                  : placeholder,
              style: TextStyle(
                color: isDisabled
                    ? const Color(0xFFCCCCCC)
                    : date != null 
                        ? Colors.black 
                        : const Color(0xFFBBBBBB),
                fontSize: 14,
              ),
            ),
          ),
          Icon(
            Icons.calendar_today,
            size: 16,
            color: isDisabled 
                ? const Color(0xFFCCCCCC) 
                : const Color(0xFF666666),
          ),
        ],
      ),
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
