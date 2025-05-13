import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/book_model.dart';
import '../repositories/book_repository.dart';

class PerpusState {
  final List<BookModel> books;
  final String selectedCategory;
  final String search;

  PerpusState({
    required this.books,
    required this.selectedCategory,
    required this.search,
  });

  PerpusState copyWith({
    List<BookModel>? books,
    String? selectedCategory,
    String? search,
  }) {
    return PerpusState(
      books: books ?? this.books,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      search: search ?? this.search,
    );
  }
}

class PerpusCubit extends Cubit<PerpusState> {
  final BookRepository repository;

 PerpusCubit(this.repository)
    : super(PerpusState(
        books: [],
        selectedCategory: 'Semua Subjek',
        search: '')) {
  loadBooks(); 
}

void loadBooks() {
  final books = repository.getAllBooks();
  emit(state.copyWith(books: books));
}

  void selectCategory(String category) {
    final filtered = repository.getBooksByCategory(category);
    emit(state.copyWith(books: filtered, selectedCategory: category));
  }

  void searchBooks(String keyword) {
    final all = repository.getBooksByCategory(state.selectedCategory);
    final filtered = all
        .where((b) => b.title.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
    emit(state.copyWith(books: filtered, search: keyword));
  }
}
