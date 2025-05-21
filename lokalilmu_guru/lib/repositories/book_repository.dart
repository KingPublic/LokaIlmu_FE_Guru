import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../model/book_model.dart';

class BookRepository {
  final String boxName = 'books';
  final String savedBoxName = 'saved_books';

  Future<void> initializeBooks() async {
    final box = Hive.box<BookModel>(boxName);
    if (box.isEmpty) {
      final dummyBooks = [
        BookModel(
          title: 'Dasar-Dasar Pemrograman',
          author: 'Shinta Esabella, Miftahul Haq',
          category: 'Informatika',
          description: 'Dasar-Dasar Pemrograman adalah buku teks yang dirancang untuk membekali mahasiswa—khususnya di program studi Teknik Informatika—dengan pemahaman awal tentang konsep algoritma dan pemrograman. Buku ini membahas topik fundamental seperti konsep algoritma, flowchart, pseudocode, tipe data, operator, serta pengenalan bahasa pemrograman C++. Materi disusun secara sistematis, dimulai dari teori dasar hingga implementasi praktik dalam bahasa C++. Mahasiswa akan diajak memahami struktur kontrol seperti percabangan dan perulangan, penggunaan array, modular programming (fungsi dan prosedur), hingga pemrosesan file dan pointer. Buku ini juga menyertakan berbagai soal latihan dan praktikum yang mendukung pemahaman secara aplikatif. Diterbitkan oleh Olat Maras Publishing tahun 2021, buku ini merupakan salah satu referensi lokal berkualitas yang dapat digunakan secara gratis dan legal.',
          imageUrl: 'asset/images/dasar_program.jpeg',
          filePath: 'asset/file/dasar_program.pdf',
        ),
        BookModel(
          title: 'Fisika SMA',
          author: 'Marianna Magdalena Radjawane, Alvius Tinambunan, Suntar Jono',
          category: 'Sains',
          description: 'Fisika untuk SMA/MA Kelas XI merupakan buku teks resmi Kurikulum Merdeka yang dirancang untuk memperkenalkan konsep-konsep dasar fisika secara kontekstual dan aplikatif. Buku ini menyajikan pembelajaran berbasis fenomena nyata, seperti gerak penerjun payung, medan magnet, dan fluida, untuk menghubungkan materi fisika dengan kehidupan sehari-hari. Terdiri dari 7 bab utama, topik yang dibahas mencakup: vektor, kinematika, dinamika, fluida, gelombang dan cahaya, kalor, serta termodinamika. Setiap bab diawali dengan tujuan pembelajaran dan dilengkapi fitur interaktif seperti "Ayo, Berdiskusi", "Ayo, Berpikir Kritis", serta eksperimen praktikum untuk mendorong kolaborasi dan pemecahan masalah. Buku ini juga mengintegrasikan aspek teknologi, literasi finansial, dan kesadaran lingkungan. Penyusunan dilakukan oleh para ahli di bawah koordinasi Pusat Perbukuan Kemendikbudristek. Materi disusun agar sesuai perkembangan IPTEK, dan dirancang sebagai "dokumen hidup" yang terus diperbarui. Buku ini dapat diunduh secara gratis melalui situs resmi Kemdikbud.',
          imageUrl: 'asset/images/fisika-bs.png',
          filePath: 'asset/file/fisika-bs.pdf',
        ),
        BookModel(
          title: 'Matematika Lanjut',
          author: 'Wikan Budi Utami, Sri Adi Widodo, Fitria Sulistyowati',
          category: 'Matematika',
          description: 'Matematika Tingkat Lanjut untuk SMA/MA Kelas XII merupakan buku teks utama Kurikulum Merdeka yang disusun untuk mendukung Capaian Pembelajaran Fase F+. Buku ini membahas topik-topik matematika tingkat lanjut secara kontekstual, menyeluruh, dan aplikatif. Materinya mencakup Geometri Analitik (lingkaran, parabola, elips, dan hiperbola), limit, turunan, integral, serta analisis data dan peluang. Penyajian disertai aktivitas seperti Ayo Bereksplorasi, Ayo Mencoba, dan Ayo Berpikir Kritis untuk menumbuhkan karakter Pelajar Pancasila dan keterampilan abad ke-21. Buku ini juga mendorong penggunaan teknologi seperti Photomath dan GeoGebra untuk menyelesaikan masalah matematis. Disusun oleh tim ahli matematika di bawah koordinasi Pusat Perbukuan Kemendikbudristek, buku ini dirancang sebagai dokumen hidup yang terus diperbarui. Dilengkapi contoh soal, latihan bertingkat, dan refleksi tiap bab, buku ini sangat cocok untuk siswa kelas XII yang ingin memperdalam pemahaman matematikanya secara konseptual dan praktis.',
          imageUrl: 'asset/images/matematika-lanjut.png',
          filePath: 'asset/file/matematika-lanjut.pdf',
        ),
        BookModel(
          title: 'Bahasa Indonesia Kreatif',
          author: 'Eva Yulia Nukman, Cicilia Erni Setyowati',
          category: 'Bahasa',
          description: 'Buku ini merupakan buku teks utama Kurikulum Merdeka untuk mata pelajaran Bahasa Indonesia kelas IV SD/MI yang diterbitkan oleh Kementerian Pendidikan, Kebudayaan, Riset, dan Teknologi. Disusun oleh Eva Yulia Nukman dan Cicilia Erni Setyowati, buku ini bertujuan untuk meningkatkan kemampuan berbahasa siswa melalui aktivitas yang menyenangkan dan kontekstual. Materi disusun ke dalam delapan bab yang masing-masing mengusung tema-tema kehidupan sehari-hari, seperti keluarga, lingkungan, dan pengalaman pribadi. Buku ini memadukan pendekatan tematik dan berbasis proyek, seperti membuat kamus kartu dan jurnal membaca. Siswa diajak membaca, menulis, berdiskusi, dan mengekspresikan pendapat secara lisan dan tertulis. Berbagai fitur interaktif seperti cerita bergambar, aktivitas kelompok, serta latihan kosakata dan kaidah kebahasaan (misalnya kalimat transitif-intransitif, awalan me-, dan kalimat majemuk) membuat proses belajar lebih bermakna. Buku ini juga mendukung pembentukan Profil Pelajar Pancasila dan literasi digital.',
          imageUrl: 'asset/images/bindo_bs.png',
          filePath: 'asset/file/bindo_bs.pdf',
        ),
        BookModel(
          title: 'Dasar-Dasar Teknologi',
          author: 'Ignatia Widhiharsanto, Muhammad Akkas',
          category: 'Informatika',
          description: 'Buku ini dirancang sebagai panduan bagi para pendidik PAUD dalam memahami dan mengimplementasikan capaian pembelajaran pada fase fondasi, khususnya dalam elemen dasar-dasar literasi, matematika, sains, teknologi, rekayasa, dan seni (LMSTRS). Buku ini membekali guru dengan pengetahuan dan praktik pembelajaran yang mendukung perkembangan anak usia dini secara holistik, termasuk dalam kemampuan berpikir, berkomunikasi, dan berekspresi. Materi disajikan dalam tiga bab besar: pemahaman pentingnya LMSTRS, pengenalan elemen dan subelemen capaian pembelajaran, serta perancangan kegiatan pembelajaran kontekstual dan reflektif. Disertai ilustrasi, studi kasus, dan latihan refleksi, buku ini mendorong pendidik untuk menyusun pembelajaran yang menyenangkan dan bermakna. Buku ini juga menekankan pentingnya membangun fondasi keterampilan sejak usia dini sebagai bekal menghadapi jenjang pendidikan selanjutnya, sekaligus memperkuat Profil Pelajar Pancasila. Dengan pendekatan praktis dan berbasis Kurikulum Merdeka, buku ini menjadi referensi penting bagi guru, kepala PAUD, dosen, maupun mahasiswa calon guru PAUD.',
          imageUrl: 'asset/images/dasar_Inform_paud.png',
          filePath: 'asset/file/dasar_Inform_paud.pdf',
        ),
      ];

      await box.addAll(dummyBooks);
    }
    
    // Ensure saved books box is initialized
    await Hive.openBox<BookModel>(savedBoxName);
  }

  List<BookModel> getAllBooks() {
    final box = Hive.box<BookModel>(boxName);
    return box.values.toList();
  }

  List<BookModel> getSavedBooks() {
    final box = Hive.box<BookModel>(savedBoxName);
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
  
  // Save a book to the saved books box
  Future<void> saveBook(BookModel book) async {
    final savedBox = Hive.box<BookModel>(savedBoxName);
    
    // Check if book is already saved
    final existingBooks = savedBox.values.where((b) => b.title == book.title).toList();
    if (existingBooks.isEmpty) {
      // Mark as saved and add to saved books
      final savedBook = book.copyWith(isSaved: true);
      await savedBox.add(savedBook);
    }
  }
  
  // Remove a book from saved books
  Future<void> unsaveBook(BookModel book) async {
    final savedBox = Hive.box<BookModel>(savedBoxName);
    
    // Find and delete the book
    for (var i = 0; i < savedBox.length; i++) {
      final savedBook = savedBox.getAt(i);
      if (savedBook != null && savedBook.title == book.title) {
        await savedBox.deleteAt(i);
        break;
      }
    }
  }
  
  // Check if a book is saved
  bool isBookSaved(String title) {
    final savedBox = Hive.box<BookModel>(savedBoxName);
    return savedBox.values.any((book) => book.title == title);
  }
  
  // Open a book file
  Future<File?> getBookFile(BookModel book) async {
    if (book.filePath == null) return null;
    
    final appDir = await getApplicationDocumentsDirectory();
    final filePath = '${appDir.path}/${book.title.replaceAll(' ', '_')}.pdf';
    final file = File(filePath);
    
    // Check if file already exists
    if (await file.exists()) {
      return file;
    }
    
    try {
      // Copy from assets to app documents directory
      final ByteData data = await rootBundle.load(book.filePath!);
      final bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      print('Error loading book file: $e');
      return null;
    }
  }
}