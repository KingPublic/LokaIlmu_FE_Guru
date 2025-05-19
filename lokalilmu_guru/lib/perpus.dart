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
                                child: Image.network(
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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      context.go('/perpustakaan');
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
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

            const SizedBox(height: 16),

            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    book.imageUrl,
                    width: 100,
                    height: 130,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 100,
                      height: 130,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(book.author,
                          style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _categoryColor(book.category),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(book.category,
                            style: const TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFECB2E),
                              ),
                              child: const Text('Simpan',
                                  style: TextStyle(color: Colors.black)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B3C73),
                              ),
                              child: const Text('Baca'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),

            const SizedBox(height: 24),

            Row(
              children: const [
                Text('Deskripsi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      fontSize: 16,
                    )),
                SizedBox(width: 24),
                Text('Detail Buku',
                    style: TextStyle(color: Colors.black38, fontSize: 16)),
              ],
            ),

            const SizedBox(height: 8),
            Text(book.description, style: const TextStyle(height: 1.4)),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Rekomendasi Buku Serupa',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Lihat semua', style: TextStyle(color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(book.imageUrl,
                          width: 80, height: 100, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 80,
                      child: Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
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