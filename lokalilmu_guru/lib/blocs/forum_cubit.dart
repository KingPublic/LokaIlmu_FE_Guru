import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/forum_model.dart';
import '../repositories/forum_repository.dart';

class ForumState {
  final List<ForumPost> posts;
  final String selectedCategory;
  final String searchQuery;
  final bool isLoading;
  final bool isCreatingPost;
  final String? errorMessage;
  final String? successMessage;

  ForumState({
    required this.posts,
    required this.selectedCategory,
    required this.searchQuery,
    this.isLoading = false,
    this.isCreatingPost = false,
    this.errorMessage,
    this.successMessage,
  });

  ForumState copyWith({
    List<ForumPost>? posts,
    String? selectedCategory,
    String? searchQuery,
    bool? isLoading,
    bool? isCreatingPost,
    String? errorMessage,
    String? successMessage,
  }) {
    return ForumState(
      posts: posts ?? this.posts,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      isCreatingPost: isCreatingPost ?? this.isCreatingPost,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class ForumCubit extends Cubit<ForumState> {
  final ForumRepository repository;

  ForumCubit(this.repository)
      : super(ForumState(
          posts: [],
          selectedCategory: 'Semua Subjek',
          searchQuery: '',
        )) {
    loadPosts();
  }

  void loadPosts() {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final posts = repository.searchPosts(state.searchQuery, state.selectedCategory);
      emit(state.copyWith(posts: posts, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load posts: ${e.toString()}',
      ));
    }
  }

  void selectCategory(String category) {
    emit(state.copyWith(selectedCategory: category, errorMessage: null));
    loadPosts();
  }

  void searchPosts(String query) {
    emit(state.copyWith(searchQuery: query, errorMessage: null));
    loadPosts();
  }

  Future<void> createPost(CreatePostRequest request) async {
    emit(state.copyWith(isCreatingPost: true, errorMessage: null));
    try {
      final newPost = await repository.createPost(request);
      final updatedPosts = [newPost, ...state.posts];
      emit(state.copyWith(
        posts: updatedPosts,
        isCreatingPost: false,
        successMessage: 'Diskusi berhasil dibuat!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isCreatingPost: false,
        errorMessage: 'Failed to create post: ${e.toString()}',
      ));
    }
  }

  Future<void> upvotePost(String postId) async {
    try {
      final updatedPost = await repository.upvotePost(postId);
      final updatedPosts = state.posts.map((post) =>
        post.id == postId ? updatedPost : post
      ).toList();
      emit(state.copyWith(posts: updatedPosts));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to upvote: ${e.toString()}'));
    }
  }

  Future<void> downvotePost(String postId) async {
    try {
      final updatedPost = await repository.downvotePost(postId);
      final updatedPosts = state.posts.map((post) =>
        post.id == postId ? updatedPost : post
      ).toList();
      emit(state.copyWith(posts: updatedPosts));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to downvote: ${e.toString()}'));
    }
  }

  void clearMessages() {
    emit(state.copyWith(errorMessage: null, successMessage: null));
  }
}