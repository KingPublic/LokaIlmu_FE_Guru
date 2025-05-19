import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalilmu_guru/model/mentor_model.dart';
import 'package:lokalilmu_guru/repositories/mentor_repository.dart';

abstract class MentorEvent extends Equatable {
  const MentorEvent();

  @override
  List<Object> get props => [];
}

class LoadMentorsEvent extends MentorEvent {}

class SearchMentorsEvent extends MentorEvent {
  final String query;

  const SearchMentorsEvent(this.query);

  @override
  List<Object> get props => [query];
}

class FilterMentorsBySubjectEvent extends MentorEvent {
  final String subject;

  const FilterMentorsBySubjectEvent(this.subject);

  @override
  List<Object> get props => [subject];
}

abstract class MentorState extends Equatable {
  const MentorState();
  
  @override
  List<Object> get props => [];
}

class MentorInitial extends MentorState {}

class MentorLoading extends MentorState {}

class MentorLoaded extends MentorState {
  final List<Mentor> mentors;
  
  const MentorLoaded(this.mentors);
  
  @override
  List<Object> get props => [mentors];
}

class MentorError extends MentorState {
  final String message;
  
  const MentorError(this.message);
  
  @override
  List<Object> get props => [message];
}

class MentorBloc extends Bloc<MentorEvent, MentorState> {
  final MentorRepository mentorRepository;
  
  MentorBloc({required this.mentorRepository}) : super(MentorInitial()) {
    on<LoadMentorsEvent>(_onLoadMentors);
    on<SearchMentorsEvent>(_onSearchMentors);
    on<FilterMentorsBySubjectEvent>(_onFilterMentorsBySubject);
  }

  Future<void> _onLoadMentors(
    LoadMentorsEvent event,
    Emitter<MentorState> emit,
  ) async {
    emit(MentorLoading());
    
    try {
      final mentors = await mentorRepository.getMentors();
      emit(MentorLoaded(mentors));
    } catch (e) {
      emit(MentorError(e.toString()));
    }
  }

  Future<void> _onSearchMentors(
    SearchMentorsEvent event,
    Emitter<MentorState> emit,
  ) async {
    emit(MentorLoading());
    
    try {
      final mentors = await mentorRepository.searchMentors(event.query);
      emit(MentorLoaded(mentors));
    } catch (e) {
      emit(MentorError(e.toString()));
    }
  }

  Future<void> _onFilterMentorsBySubject(
    FilterMentorsBySubjectEvent event,
    Emitter<MentorState> emit,
  ) async {
    emit(MentorLoading());
    
    try {
      final mentors = await mentorRepository.filterMentorsBySubject(event.subject);
      emit(MentorLoaded(mentors));
    } catch (e) {
      emit(MentorError(e.toString()));
    }
  }
}