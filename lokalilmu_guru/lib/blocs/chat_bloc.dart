import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalilmu_guru/model/chat_model.dart';
import 'package:lokalilmu_guru/repositories/chat_repository.dart';

// Events
abstract class ChatEvent {}

class LoadChatsEvent extends ChatEvent {}

class FilterChatsByCategoryEvent extends ChatEvent {
  final String category;
  FilterChatsByCategoryEvent(this.category);
}

class SearchChatsEvent extends ChatEvent {
  final String query;
  SearchChatsEvent(this.query);
}

class MarkChatAsReadEvent extends ChatEvent {
  final String chatId;
  MarkChatAsReadEvent(this.chatId);
}

class ToggleFavoriteEvent extends ChatEvent {
  final String chatId;
  ToggleFavoriteEvent(this.chatId);
}

class RefreshChatsEvent extends ChatEvent {}

// States
abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatModel> chats;
  final String selectedCategory;
  final String searchQuery;

  ChatLoaded({
    required this.chats,
    this.selectedCategory = 'Semua',
    this.searchQuery = '',
  });

  ChatLoaded copyWith({
    List<ChatModel>? chats,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return ChatLoaded(
      chats: chats ?? this.chats,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}

// Bloc
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository;
  List<ChatModel> _allChats = [];

  ChatBloc(this._repository) : super(ChatInitial()) {
    on<LoadChatsEvent>(_onLoadChats);
    on<FilterChatsByCategoryEvent>(_onFilterByCategory);
    on<SearchChatsEvent>(_onSearchChats);
    on<MarkChatAsReadEvent>(_onMarkAsRead);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<RefreshChatsEvent>(_onRefreshChats);
  }

  Future<void> _onLoadChats(LoadChatsEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final chats = await _repository.getAllChats();
      _allChats = chats;
      emit(ChatLoaded(chats: chats));
    } catch (e) {
      emit(ChatError('Gagal memuat chat: ${e.toString()}'));
    }
  }

  Future<void> _onFilterByCategory(FilterChatsByCategoryEvent event, Emitter<ChatState> emit) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      emit(ChatLoading());
      
      try {
        final filteredChats = await _repository.getChatsByCategory(event.category);
        emit(currentState.copyWith(
          chats: filteredChats,
          selectedCategory: event.category,
        ));
      } catch (e) {
        emit(ChatError('Gagal memfilter chat: ${e.toString()}'));
      }
    }
  }

  Future<void> _onSearchChats(SearchChatsEvent event, Emitter<ChatState> emit) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      
      try {
        List<ChatModel> searchResults;
        if (event.query.isEmpty) {
          // If search is empty, show filtered results based on current category
          searchResults = await _repository.getChatsByCategory(currentState.selectedCategory);
        } else {
          // Search within current category
          final categoryChats = await _repository.getChatsByCategory(currentState.selectedCategory);
          searchResults = categoryChats.where((chat) => 
            chat.name.toLowerCase().contains(event.query.toLowerCase()) ||
            chat.lastMessage.toLowerCase().contains(event.query.toLowerCase())
          ).toList();
        }
        
        emit(currentState.copyWith(
          chats: searchResults,
          searchQuery: event.query,
        ));
      } catch (e) {
        emit(ChatError('Gagal mencari chat: ${e.toString()}'));
      }
    }
  }

  Future<void> _onMarkAsRead(MarkChatAsReadEvent event, Emitter<ChatState> emit) async {
    try {
      await _repository.markChatAsRead(event.chatId);
      // Refresh current view
      if (state is ChatLoaded) {
        final currentState = state as ChatLoaded;
        add(FilterChatsByCategoryEvent(currentState.selectedCategory));
      }
    } catch (e) {
      emit(ChatError('Gagal menandai chat sebagai dibaca: ${e.toString()}'));
    }
  }

  Future<void> _onToggleFavorite(ToggleFavoriteEvent event, Emitter<ChatState> emit) async {
    try {
      await _repository.toggleFavorite(event.chatId);
      // Refresh current view
      if (state is ChatLoaded) {
        final currentState = state as ChatLoaded;
        add(FilterChatsByCategoryEvent(currentState.selectedCategory));
      }
    } catch (e) {
      emit(ChatError('Gagal mengubah status favorit: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshChats(RefreshChatsEvent event, Emitter<ChatState> emit) async {
    try {
      final chats = await _repository.getAllChats();
      _allChats = chats;
      
      if (state is ChatLoaded) {
        final currentState = state as ChatLoaded;
        add(FilterChatsByCategoryEvent(currentState.selectedCategory));
      } else {
        emit(ChatLoaded(chats: chats));
      }
    } catch (e) {
      emit(ChatError('Gagal memperbarui chat: ${e.toString()}'));
    }
  }
}