import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/mentor_model.dart';
import '../../repositories/mentor_repository.dart';

// Events
abstract class MentorEvent {}

class InitializeMentorEvent extends MentorEvent {}

class SearchMentorsEvent extends MentorEvent {
  final String query;
  SearchMentorsEvent(this.query);
}

class SelectCategoryEvent extends MentorEvent {
  final String category;
  SelectCategoryEvent(this.category);
}

// States
class MentorState {
  final List<MentorModel> mentors;
  final List<String> categories;
  final String searchQuery;
  final String selectedCategory;
  final bool isLoading;
  final String? error;

  MentorState({
    this.mentors = const [],
    this.categories = const ['Semua'],
    this.searchQuery = '',
    this.selectedCategory = 'Semua',
    this.isLoading = false,
    this.error,
  });

  MentorState copyWith({
    List<MentorModel>? mentors,
    List<String>? categories,
    String? searchQuery,
    String? selectedCategory,
    bool? isLoading,
    String? error,
  }) {
    return MentorState(
      mentors: mentors ?? this.mentors,
      categories: categories ?? this.categories,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Cubit
class MentorCubit extends Cubit<MentorState> {
  final MentorRepository mentorRepository;

  MentorCubit({required this.mentorRepository}) : super(MentorState());

  // Initialize mentors and categories
  Future<void> initialize() async {
    emit(state.copyWith(isLoading: true));
    try {
      await mentorRepository.initialize();
      final mentors = await mentorRepository.getAllMentors();
      final categories = await mentorRepository.getAllCategories();
      emit(state.copyWith(
        mentors: mentors,
        categories: categories,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  // Search mentors by query
  Future<void> searchMentors(String query) async {
    emit(state.copyWith(
      searchQuery: query,
      isLoading: true,
    ));
    try {
      final mentors = await mentorRepository.searchMentors(
        query,
        state.selectedCategory == 'Semua' ? null : state.selectedCategory,
      );
      emit(state.copyWith(
        mentors: mentors,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  // Select category
  Future<void> selectCategory(String category) async {
    emit(state.copyWith(
      selectedCategory: category,
      isLoading: true,
    ));
    try {
      final mentors = await mentorRepository.searchMentors(
        state.searchQuery,
        category == 'Semua' ? null : category,
      );
      emit(state.copyWith(
        mentors: mentors,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }
}