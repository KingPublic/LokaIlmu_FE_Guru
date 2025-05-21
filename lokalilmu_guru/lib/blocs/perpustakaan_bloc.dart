import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';
import '../model/book_model.dart';
import '../repositories/book_repository.dart';

class PerpusState {
  final List<BookModel> books;
  final List<BookModel> savedBooks;
  final String selectedCategory;
  final String search;
  final bool isLoading;
  final String? errorMessage;

  PerpusState({
    required this.books,
    required this.savedBooks,
    required this.selectedCategory,
    required this.search,
    this.isLoading = false,
    this.errorMessage,
  });

  PerpusState copyWith({
    List<BookModel>? books,
    List<BookModel>? savedBooks,
    String? selectedCategory,
    String? search,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PerpusState(
      books: books ?? this.books,
      savedBooks: savedBooks ?? this.savedBooks,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      search: search ?? this.search,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class PerpusCubit extends Cubit<PerpusState> {
  final BookRepository repository;

  PerpusCubit(this.repository)
      : super(PerpusState(
          books: [],
          savedBooks: [],
          selectedCategory: 'Semua Subjek',
          search: '',
          isLoading: false,
        )) {
    loadBooks();
    loadSavedBooks();
  }

  void loadBooks() {
    final books = repository.getAllBooks();
    emit(state.copyWith(books: books));
  }
  
  void loadSavedBooks() {
    final savedBooks = repository.getSavedBooks();
    emit(state.copyWith(savedBooks: savedBooks));
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
  
  Future<void> saveBook(BookModel book) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await repository.saveBook(book);
      loadSavedBooks(); // Refresh saved books list
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to save book: ${e.toString()}',
      ));
    }
  }
  
  Future<void> unsaveBook(BookModel book) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await repository.unsaveBook(book);
      loadSavedBooks(); // Refresh saved books list
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to remove book: ${e.toString()}',
      ));
    }
  }
  
  bool isBookSaved(String title) {
    return repository.isBookSaved(title);
  }
  
  Future<void> openBookFile(BookModel book) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final file = await repository.getBookFile(book);
      if (file != null) {
        await OpenFile.open(file.path);
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Book file not found',
        ));
      }
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to open book: ${e.toString()}',
      ));
    }
  }
}