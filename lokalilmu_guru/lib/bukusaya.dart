import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'blocs/perpustakaan_bloc.dart';
import 'perpus.dart';
import 'model/book_model.dart';
import 'widgets/common/header.dart';
import 'widgets/common/navbar.dart';

class BukuSayaPage extends StatefulWidget {
  const BukuSayaPage({super.key});

  @override
  State<BukuSayaPage> createState() => _BukuSayaPageState();
}

class _BukuSayaPageState extends State<BukuSayaPage> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua Subjek';
  List<BookModel> _filteredBooks = [];

  @override
  void initState() {
    super.initState();
    // Load saved books when page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PerpusCubit>().loadSavedBooks();
    });
  }

  // Filter books based on search query and category
  void _filterBooks(List<BookModel> books) {
    setState(() {
      _filteredBooks = books.where((book) {
        // Filter by category
        bool matchesCategory = _selectedCategory == 'Semua Subjek' || 
                              book.category == _selectedCategory;
        
        // Filter by search query
        bool matchesSearch = _searchQuery.isEmpty || 
                            book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            book.author.toLowerCase().contains(_searchQuery.toLowerCase());
        
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Tidak ada floatingActionButton sesuai permintaan
      bottomNavigationBar: AppBottomNavbar(
        currentIndex: 2, // Perpustakaan tab aktif sesuai gambar
        // onTap: (index) {
        //   switch (index) {
        //     case 0:
        //       context.go('/dashboard');
        //       break;
        //     case 1:
        //       context.go('/mentor');
        //       break;
        //     case 2:
        //       context.go('/perpustakaan');
        //       break;
        //     case 3:
        //       context.go('/forum');
        //       break;
        //   }
        // },
      ),
      body: BlocConsumer<PerpusCubit, PerpusState>(
        listener: (context, state) {
          // Update filtered books when saved books change
          _filterBooks(state.savedBooks);
          
          // Show error message if any
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
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
                            context.go('/perpustakaan');
                          }
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'Buku Saya',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                
                // Menggunakan Header widget yang sudah ada
                Header(
                  onSearchChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _filterBooks(state.savedBooks);
                    });
                  },
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategory = category;
                      _filterBooks(state.savedBooks);
                    });
                  },
                  selectedCategory: _selectedCategory,
                ),

                // Saved Books List
                Expanded(
                  child: Stack(
                    children: [
                      // Empty state
                      if (_filteredBooks.isEmpty)
                        const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Belum ada buku yang tersimpan',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // Book list
                      if (_filteredBooks.isNotEmpty)
                        ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          itemCount: _filteredBooks.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final book = _filteredBooks[i];
                            return InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<PerpusCubit>(),
                                      child: BookDetailPage(book: book),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Book Cover
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        book.imageUrl,
                                        width: 80,
                                        height: 110,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 80,
                                          height: 110,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.broken_image),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    
                                    // Book Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Title and Category
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  book.title,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(left: 8),
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: _categoryColor(book.category),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  book.category,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          
                                          // Author
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(
                                              book.author,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ),
                                          
                                          const SizedBox(height: 12),
                                          
                                          // Action buttons
                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton.icon(
                                                  onPressed: () {
                                                    context.read<PerpusCubit>().unsaveBook(book);
                                                  },
                                                  icon: const Icon(Icons.delete_outline, size: 16),
                                                  label: const Text('Hapus'),
                                                  style: OutlinedButton.styleFrom(
                                                    foregroundColor: Colors.red,
                                                    side: const BorderSide(color: Colors.red),
                                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  onPressed: () {
                                                    context.read<PerpusCubit>().openBookFile(book);
                                                  },
                                                  icon: const Icon(Icons.menu_book, size: 16),
                                                  label: const Text('Baca'),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF1B3C73),
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      
                      // Loading indicator
                      if (state.isLoading)
                        Container(
                          color: Colors.black.withOpacity(0.3),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _categoryColor(String cat) {
    switch (cat) {
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
}