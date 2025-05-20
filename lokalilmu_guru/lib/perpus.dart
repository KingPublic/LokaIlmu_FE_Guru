import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'blocs/perpustakaan_bloc.dart';
import 'model/book_model.dart';
import 'widgets/common/header.dart';
import 'widgets/common/navbar.dart';

class PerpusPage extends StatelessWidget {
  const PerpusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: AppBottomNavbar(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/dashboard');
              break;
            case 1:
              context.go('/mentor');
              break;
            case 2:
              context.go('/perpustakaan');
              break;
            case 3:
              context.go('/forum');
              break;
          }
        },
      ),
      floatingActionButton: SizedBox(
        width:65,
        height:65,
      child: FloatingActionButton(
        onPressed: () => context.go('/bukusaya'),
        backgroundColor: const Color(0xFFFBCD5F),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.menu_book_rounded, color: Color(0xFF0C3450), size: 28),
            Text(
              'Buku Saya',
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
      body: BlocBuilder<PerpusCubit, PerpusState>(
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
                            context.go('/dashboard');
                          }
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'Perpustakaan',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Search and Categories
                Header(
                  onSearchChanged: (v) => context.read<PerpusCubit>().searchBooks(v),
                  onCategorySelected: (c) => context.read<PerpusCubit>().selectCategory(c),
                  selectedCategory: state.selectedCategory,
                ),

                // Book List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: state.books.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final book = state.books[i];
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BookDetailPage(book: book),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
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
                                    
                                    // Description
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        book.description,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black87,
                                          height: 1.3,
                                        ),
                                      ),
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

class BookDetailPage extends StatelessWidget {
  final BookModel book;
  const BookDetailPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    // Pre-load the image to avoid UI freezes during rendering
    precacheImage(NetworkImage(book.imageUrl), context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: AppBottomNavbar(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/dashboard');
              break;
            case 1:
              context.go('/mentor');
              break;
            case 2:
              context.go('/perpustakaan');
              break;
            case 3:
              context.go('/forum');
              break;
          }
        },
      ),
      floatingActionButton: SizedBox(
        width: 65,
        height: 65,
        child: FloatingActionButton(
          onPressed: () => context.go('/bukusaya'),
          backgroundColor: const Color(0xFFFBCD5F),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.menu_book_rounded, color: Color(0xFF0C3450), size: 28),
              Text(
                'Buku Saya',
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
      body: SafeArea(
        child: Column(
          children: [
            // App Bar - Fixed with direct GoRouter navigation
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
                  GestureDetector(
                    onTap: () {
                      // Direct GoRouter navigation to ensure it works
                      context.pop();
                    },
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  const Expanded(
                    child: Text(
                      'Perpustakaan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),
            
            // Content - Using FutureBuilder to avoid UI freezes
            Expanded(
              child: FutureBuilder(
                // This ensures the heavy content loads after the UI is ready
                future: Future.delayed(const Duration(milliseconds: 50)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Book Cover and Info
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Book Cover - Using Hero for smooth transitions
                              Hero(
                                tag: 'book-${book}',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    book.imageUrl,
                                    width: 100,
                                    height: 140,
                                    fit: BoxFit.cover,
                                    // Using memory cache
                                    cacheWidth: 200,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 100,
                                      height: 140,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // Book Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Category Tag
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _categoryColor(book.category),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        book.category,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    
                                    // Title
                                    Text(
                                      book.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    
                                    // Author
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        book.author,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 16),
                                    
                                    // Action Buttons
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () {},
                                            icon: const Icon(Icons.bookmark_border, size: 18, color: Colors.black),
                                            label: const Text('Simpan'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFFECB2E),
                                              foregroundColor: Colors.black,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () {},
                                            icon: const Icon(Icons.menu_book, size: 18),
                                            label: const Text('Baca'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF1B3C73),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
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
                          
                          const SizedBox(height: 24),
                          
                          // Tabs
                          Row(
                            children: [
                              const Text(
                                'Deskripsi',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  decorationThickness: 2,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Text(
                                'Detail Buku',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Description
                          Text(
                            book.description,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                          
                          // "Lihat Semua" link
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: GestureDetector(
                              onTap: () {},
                              child: const Text(
                                'Lihat Semua',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Similar Books Section - Keeping the header but removing the list
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Rekomendasi Buku Serupa',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: const Text(
                                  'Lihat semua',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Empty container instead of the ListView to avoid performance issues
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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