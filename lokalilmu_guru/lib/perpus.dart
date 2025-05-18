import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/perpustakaan_bloc.dart';
import 'model/book_model.dart';
import 'widgets/common/header.dart';

class PerpusPage extends StatelessWidget {
  const PerpusPage({super.key});

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perpustakaan')),
        body: BlocBuilder<PerpusCubit, PerpusState>(
          builder: (context, state) {
            return Column(
              children: [
                Header(
                  onSearchChanged: (value) =>
                      context.read<PerpusCubit>().searchBooks(value),
                  onCategorySelected: (cat) =>
                      context.read<PerpusCubit>().selectCategory(cat),
                  selectedCategory: state.selectedCategory,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.books.length,
                    itemBuilder: (context, index) {
                      final book = state.books[index];
                      return ListTile(
                        leading: Image.network(book.imageUrl, width: 50,errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image)),
                        title: Text(book.title),
                        subtitle: Text(book.author),
                        trailing: Chip(
                          label: Text(book.category),
                          backgroundColor: _categoryColor(book.category),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookDetailPage(book: book),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      );
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Bahasa':
        return Colors.yellow.shade600;
      case 'Sains':
        return Colors.green.shade400;
      case 'Matematika':
        return Colors.red.shade300;
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
      appBar: AppBar(title: const Text('Perpustakaan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Row(
              children: [
                Image.network(book.imageUrl, width: 100,errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book.title,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(book.author),
                      const SizedBox(height: 8),
                      Chip(
                          label: Text(book.category),
                          backgroundColor: Colors.amber),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('Baca'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () {},
                            child: const Text('Simpan'),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            const Text('Deskripsi',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(book.description),
            const SizedBox(height: 16),
            const Text('Rekomendasi Buku Serupa',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (int i = 0; i < 3; i++)
                    Container(
                      width: 100,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        children: [
                          Image.network(book.imageUrl, height: 100),
                          const SizedBox(height: 4),
                          Text(book.title,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
