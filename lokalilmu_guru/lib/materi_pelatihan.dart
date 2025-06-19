import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lokalilmu_guru/blocs/training_material_bloc.dart';
import 'package:lokalilmu_guru/model/training_material.dart';
import 'package:flutter/services.dart';

class MateriPelatihanPage extends StatefulWidget {
  final String trainingId;
  final String? sessionId; // Tambahkan sessionId parameter
  
  const MateriPelatihanPage({
    Key? key,
    required this.trainingId,
    this.sessionId,
  }) : super(key: key);

  @override
  State<MateriPelatihanPage> createState() => _MateriPelatihanPageState();
}

class _MateriPelatihanPageState extends State<MateriPelatihanPage> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sessionKeys = {}; // Map untuk menyimpan GlobalKey setiap sesi

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Method untuk scroll ke sesi tertentu
  void _scrollToSession(String sessionId) {
    if (_sessionKeys.containsKey(sessionId)) {
      final key = _sessionKeys[sessionId]!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (key.currentContext != null) {
          Scrollable.ensureVisible(
            key.currentContext!,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            alignment: 0.1, // Scroll sedikit dari atas
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<TrainingMaterialBloc, TrainingMaterialState>(
        listener: (context, state) {
          // Ketika data loaded dan ada sessionId, scroll ke sesi tersebut
          if (state is TrainingMaterialLoaded && widget.sessionId != null) {
            _scrollToSession(widget.sessionId!);
          }
        },
        child: BlocBuilder<TrainingMaterialBloc, TrainingMaterialState>(
          builder: (context, state) {
            return SafeArea(
              child: Column(
                children: [
                  // Custom AppBar
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
                            'Materi Pelatihan',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  
                  // Content
                  Expanded(
                    child: _buildBlocContent(context, state),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBlocContent(BuildContext context, TrainingMaterialState state) {
    if (state is TrainingMaterialInitial || state is TrainingMaterialLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1B3C73)),
      );
    } else if (state is TrainingMaterialError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.message}',
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<TrainingMaterialBloc>().add(
                  LoadTrainingMaterialEvent(widget.trainingId),
                );
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    } else if (state is TrainingMaterialLoaded) {
      return _buildContent(context, state.trainingMaterial);
    } else if (state is TrainingMaterialCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.pop();
      });
      return const Center(child: CircularProgressIndicator());
    }
    return const Center(child: Text('Unknown state'));
  }

  Widget _buildContent(BuildContext context, TrainingMaterial material) {
    // Generate GlobalKey untuk setiap sesi
    for (var session in material.sessions) {
      if (!_sessionKeys.containsKey(session.id)) {
        _sessionKeys[session.id] = GlobalKey();
      }
    }

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Training Title
          Text(
            material.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          
          // Training Info
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                material.duration,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.people, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                material.participantCount,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Sessions dengan GlobalKey
          ...material.sessions.map((session) => _buildSession(session)).toList(),
          
          const SizedBox(height: 32),
          
          // Teaching Notes
          if (material.teachingNotes.isNotEmpty) ...[
            const Text(
              'Teaching Notes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            _buildTeachingNotes(material.teachingNotes),
            const SizedBox(height: 40),
          ],
          
          // Selesai Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showCompletionDialog(context, material.trainingId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B3C73),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Selesai',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSession(TrainingSession session) {
    return Container(
      key: _sessionKeys[session.id], // Tambahkan GlobalKey untuk setiap sesi
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // UPDATED: Buat session title menjadi clickable
          GestureDetector(
            onTap: () {
              // Scroll ke sesi ini ketika ditekan
              _scrollToSession(session.id);
              
              // Tambahkan haptic feedback untuk memberikan respons tactile
              HapticFeedback.lightImpact();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: widget.sessionId == session.id 
                    ? const Color(0xFF1B3C73).withOpacity(0.1) // Highlight jika ini target sesi
                    : Colors.grey.shade50, // Background ringan untuk menunjukkan ini clickable
                borderRadius: BorderRadius.circular(8),
                border: widget.sessionId == session.id 
                    ? Border.all(color: const Color(0xFF1B3C73), width: 2)
                    : Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: Row(
                children: [
                  // Icon untuk menunjukkan ini clickable
                  Icon(
                    Icons.play_circle_outline,
                    size: 20,
                    color: widget.sessionId == session.id 
                        ? const Color(0xFF1B3C73)
                        : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      session.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: widget.sessionId == session.id 
                            ? const Color(0xFF1B3C73)
                            : Colors.black,
                      ),
                    ),
                  ),
                  // Arrow icon untuk menunjukkan ini clickable
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: widget.sessionId == session.id 
                        ? const Color(0xFF1B3C73)
                        : Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          ...session.materials.map((material) => _buildMaterialItem(material)).toList(),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMaterialItem(MaterialItem material) {
    IconData icon;
    Widget preview;
    
    switch (material.type) {
      case TrainingMaterialType.slide:
        icon = Icons.slideshow;
        preview = _buildSlidePreview();
        break;
      case TrainingMaterialType.video:
        icon = Icons.play_circle_fill;
        preview = _buildVideoPreview();
        break;
      case TrainingMaterialType.example:
        icon = Icons.image;
        preview = _buildExamplePreview();
        break;
      default:
        icon = Icons.description;
        preview = const SizedBox();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (material.description != null) ...[
            Text(
              material.description!,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.black),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  if (material.subtitle.isNotEmpty)
                    Text(
                      material.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          preview,
        ],
      ),
    );
  }

  // Preview widgets tetap sama seperti sebelumnya
  Widget _buildSlidePreview() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 20,
            top: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sesi 1 - Anggit Fatmawati',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pengenalan\nMicrosoft\nExcel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Senin, 21 April 2023',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ),
          Positioned(
            right: 20,
            top: 20,
            child: Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B7F37),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Text(
                        'XLS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 60,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview() {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Stack(
        children: [
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'CELL',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Kolom',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Baris',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 80,
            child: Icon(Icons.help_outline, color: Colors.grey, size: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildExamplePreview() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Center(
        child: Text(
          'Contoh Soal Excel\n(Tabel Data)',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildTeachingNotes(List<String> notes) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: notes.map((note) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '• $note',
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        )).toList(),
      ),
    );
  }

  void _showCompletionDialog(BuildContext context, String trainingId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selesai'),
          content: const Text('Apakah Anda yakin telah menyelesaikan materi pelatihan ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<TrainingMaterialBloc>().add(
                  CompleteTrainingEvent(trainingId),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B3C73),
              ),
              child: const Text('Ya, Selesai', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}