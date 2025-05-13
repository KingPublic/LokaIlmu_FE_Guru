import 'package:hive/hive.dart';
import '../model/book_model.dart';

class BookRepository {
  final String boxName = 'books';

  Future<void> initializeBooks() async {
    final box = Hive.box<BookModel>(boxName);
    if (box.isEmpty) {
      final dummyBooks = [
        BookModel(
          title: 'Dasar-Dasar Pemrograman',
          author: 'Budi Santoso',
          category: 'Informatika',
          description: 'Panduan lengkap belajar pemrograman dari nol.',
          imageUrl: 'https://via.placeholder.com/100x150?text=Pemrograman',
        ),
        BookModel(
          title: 'Fisika SMA',
          author: 'Sri Wulandari',
          category: 'Sains',
          description: 'Buku pelajaran Fisika untuk tingkat SMA.',
          imageUrl: 'https://via.placeholder.com/100x150?text=Fisika',
        ),
        BookModel(
          title: 'Matematika Dasar',
          author: 'Andi Prasetyo',
          category: 'Matematika',
          description: 'Konsep dasar matematika untuk pemula.',
          imageUrl: 'https://via.placeholder.com/100x150?text=Matematika',
        ),
        BookModel(
          title: 'Bahasa Indonesia Kreatif',
          author: 'Lestari A.',
          category: 'Bahasa',
          description: 'Penggunaan bahasa Indonesia secara kreatif.',
          imageUrl: 'https://via.placeholder.com/100x150?text=Bahasa',
        ),
      ];

      await box.addAll(dummyBooks);
    }
  }

  List<BookModel> getAllBooks() {
    final box = Hive.box<BookModel>(boxName);
    return box.values.toList();
  }

  List<BookModel> getBooksByCategory(String category) {
    final box = Hive.box<BookModel>(boxName);
    if (category == 'Semua Subjek') return getAllBooks();
    return box.values.where((b) => b.category == category).toList();
  }

  List<BookModel> searchBooks(String keyword, String category) {
    final books = getBooksByCategory(category);
    return books.where((b) =>
      b.title.toLowerCase().contains(keyword.toLowerCase()) ||
      b.author.toLowerCase().contains(keyword.toLowerCase())
    ).toList();
  }
}
