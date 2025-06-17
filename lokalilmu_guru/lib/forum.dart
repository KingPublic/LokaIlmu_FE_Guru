import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/forum_cubit.dart';
import '../model/forum_model.dart';
import '../widgets/common/header.dart';
import '../widgets/common/navbar.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  bool _showCreatePost = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Custom App Bar
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
                    if (_showCreatePost) {
                      setState(() {
                        _showCreatePost = false;
                      });
                    } else {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        context.go('/dashboard');
                      }
                    }
                  },
                ),
                Expanded(
                  child: Text(
                    _showCreatePost ? 'Mulai Diskusi Baru' : 'Forum Diskusi',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          // Body content
          Expanded(
            child: _showCreatePost ? _buildCreatePostView() : _buildForumListView(),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavbar(currentIndex: 3),
      floatingActionButton: _showCreatePost ? null : SizedBox(
        width: 65,
        height: 65,
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              _showCreatePost = true;
            });
          },
          backgroundColor: const Color(0xFFFBCD5F),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline, color: Color(0xFF0C3450), size: 28),
              Text(
                'Diskusi Baru',
                style: TextStyle(
                  color: Color(0xFF0C3450),
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Bahasa':
        return const Color(0xFFFFD900);
      case 'Sains':
        return const Color(0xFF31DA4B);
      case 'Matematika':
        return const Color(0xFFFF5656);
      case 'Informatika':
        return const Color(0xFF42B1FF);
      default:
        return Colors.blueGrey;
    }
  }

  Widget _buildForumListView() {
    return BlocConsumer<ForumCubit, ForumState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
          context.read<ForumCubit>().clearMessages();
        }
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.successMessage!)),
          );
          context.read<ForumCubit>().clearMessages();
          setState(() {
            _showCreatePost = false;
          });
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            Header(
              onSearchChanged: (query) => context.read<ForumCubit>().searchPosts(query),
              onCategorySelected: (category) => context.read<ForumCubit>().selectCategory(category),
              selectedCategory: state.selectedCategory,
            ),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.posts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final post = state.posts[index];
                        return _buildPostCard(post);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPostCard(ForumPost post) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author info with category badge
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      post.authorRole,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    post.timeAgo,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Category badge
                  if (post.category != 'Semua Subjek')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _categoryColor(post.category),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        post.category,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Post title
          Text(
            post.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          
          // Post content
          Text(
            post.content,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          
          // Tags
          if (post.tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: post.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '#$tag',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 12),
          ],
          
          // Action buttons
          Row(
            children: [
              _buildVoteButton(
                icon: Icons.keyboard_arrow_up,
                label: post.upvotes.toString(),
                isSelected: post.userVoteStatus == VoteStatus.upvoted,
                onTap: () => context.read<ForumCubit>().upvotePost(post.id),
              ),
              const SizedBox(width: 16),
              _buildVoteButton(
                icon: Icons.keyboard_arrow_down,
                label: post.downvotes.toString(),
                isSelected: post.userVoteStatus == VoteStatus.downvoted,
                onTap: () => context.read<ForumCubit>().downvotePost(post.id),
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                label: '${post.comments} balasan',
                onTap: () {
                  // Navigate to comments
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

Widget _buildVoteButton({
  required IconData icon,
  required String label,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(6),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1B3C73).withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: isSelected 
          ? Border.all(color: const Color(0xFF1B3C73), width: 1)
          : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isSelected ? 22 : 20, // Ukuran lebih besar saat selected
            color: isSelected 
              ? const Color(0xFF1B3C73)
              : Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected 
                ? const Color(0xFF1B3C73)
                : Colors.grey[600],
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatePostView() {
    return CreatePostView(
      onCancel: () {
        setState(() {
          _showCreatePost = false;
        });
      },
      onSuccess: () {
        setState(() {
          _showCreatePost = false;
        });
      },
    );
  }
}

class CreatePostView extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onSuccess;

  const CreatePostView({
    super.key,
    required this.onCancel,
    required this.onSuccess,
  });

  @override
  State<CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _tags = [];
  String _selectedCategory = 'Informatika'; // Default category

  final List<String> _categories = ['Informatika', 'Matematika', 'Sains', 'Bahasa'];

  Color _categoryColor(String category) {
    switch (category) {
      case 'Bahasa':
        return const Color(0xFFFFD900);
      case 'Sains':
        return const Color(0xFF31DA4B);
      case 'Matematika':
        return const Color(0xFFFF5656);
      case 'Informatika':
        return const Color(0xFF42B1FF);
      default:
        return Colors.blueGrey;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForumCubit, ForumState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          widget.onSuccess();
          context.go('/forum'); // Navigate back to forum
        }
      },
      child: BlocBuilder<ForumCubit, ForumState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title field
                const Text(
                  'Judul Pertanyaan*',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Apa pertanyaan anda?',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF1B3C73)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 24),

                // Category selection
                const Text(
                  'Kategori*',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        }
                      },
                      items: _categories.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _categoryColor(value),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(value),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Description field
                const Text(
                  'Deskripsi*',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // Toolbar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey)),
                        ),
                        child: Row(
                          children: [
                            _buildToolbarButton(Icons.format_bold),
                            _buildToolbarButton(Icons.format_italic),
                            _buildToolbarButton(Icons.format_list_bulleted),
                            _buildToolbarButton(Icons.code),
                          ],
                        ),
                      ),
                      // Text area
                      TextField(
                        controller: _contentController,
                        maxLines: 8,
                        decoration: const InputDecoration(
                          hintText: 'Berikan deskripsi detail terkait pertanyaanmu...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Media upload
                const Text(
                  'Tambahkan Gambar/Video',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      style: BorderStyle.solid,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, color: Colors.grey, size: 32),
                            SizedBox(width: 8),
                            Icon(Icons.videocam, color: Colors.grey, size: 32),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Upload media pendukung',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Tags
                const Text(
                  'Tags',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _tagController,
                        decoration: InputDecoration(
                          hintText: 'Tambah tag',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBCD5F),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: _addTag,
                        icon: const Icon(Icons.add, color: Color(0xFF0C3450)),
                      ),
                    ),
                  ],
                ),
                if (_tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tags.map((tag) => Chip(
                      label: Text(tag),
                      onDeleted: () => _removeTag(tag),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      backgroundColor: Colors.grey[100],
                    )).toList(),
                  ),
                ],
                const SizedBox(height: 32),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: state.isCreatingPost ? null : _submitPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B3C73),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: state.isCreatingPost
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Kirim ke Forum',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildToolbarButton(IconData icon) {
    return IconButton(
      onPressed: () {},
      icon: Icon(icon, size: 20),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
    );
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _submitPost() {
    // Validation
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul pertanyaan harus diisi')),
      );
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deskripsi harus diisi')),
      );
      return;
    }

    final request = CreatePostRequest(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: _selectedCategory,
      tags: _tags,
    );

    context.read<ForumCubit>().createPost(request);
  }
}
