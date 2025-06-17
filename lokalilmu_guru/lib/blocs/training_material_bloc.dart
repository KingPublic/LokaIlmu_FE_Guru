import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalilmu_guru/model/training_material.dart';
import 'package:lokalilmu_guru/repositories/course_repository.dart'; 

// Events - sama seperti sebelumnya
abstract class TrainingMaterialEvent extends Equatable {
  const TrainingMaterialEvent();

  @override
  List<Object> get props => [];
}

class LoadTrainingMaterialEvent extends TrainingMaterialEvent {
  final String trainingId;

  const LoadTrainingMaterialEvent(this.trainingId);

  @override
  List<Object> get props => [trainingId];
}

class CompleteTrainingEvent extends TrainingMaterialEvent {
  final String trainingId;

  const CompleteTrainingEvent(this.trainingId);

  @override
  List<Object> get props => [trainingId];
}

// States - sama seperti sebelumnya
abstract class TrainingMaterialState extends Equatable {
  const TrainingMaterialState();

  @override
  List<Object?> get props => [];
}

class TrainingMaterialInitial extends TrainingMaterialState {}

class TrainingMaterialLoading extends TrainingMaterialState {}

class TrainingMaterialLoaded extends TrainingMaterialState {
  final TrainingMaterial trainingMaterial;

  const TrainingMaterialLoaded(this.trainingMaterial);

  @override
  List<Object> get props => [trainingMaterial];
}

class TrainingMaterialError extends TrainingMaterialState {
  final String message;

  const TrainingMaterialError(this.message);

  @override
  List<Object> get props => [message];
}

class TrainingMaterialCompleted extends TrainingMaterialState {
  final String trainingId;

  const TrainingMaterialCompleted(this.trainingId);

  @override
  List<Object> get props => [trainingId];
}

// BLoC - Update untuk menggunakan CourseRepository
class TrainingMaterialBloc extends Bloc<TrainingMaterialEvent, TrainingMaterialState> {
  final CourseRepository courseRepository; // Gunakan CourseRepository yang sudah ada

  TrainingMaterialBloc({required this.courseRepository}) : super(TrainingMaterialInitial()) {
    on<LoadTrainingMaterialEvent>(_onLoadTrainingMaterial);
    on<CompleteTrainingEvent>(_onCompleteTraining);
  }

  Future<void> _onLoadTrainingMaterial(
    LoadTrainingMaterialEvent event,
    Emitter<TrainingMaterialState> emit,
  ) async {
    emit(TrainingMaterialLoading());
    
    try {
      final trainingMaterial = await courseRepository.getTrainingMaterial(event.trainingId);
      
      if (trainingMaterial != null) {
        emit(TrainingMaterialLoaded(trainingMaterial));
      } else {
        emit(const TrainingMaterialError('Training material not found'));
      }
    } catch (e) {
      emit(TrainingMaterialError('Failed to load training material: ${e.toString()}'));
    }
  }

  Future<void> _onCompleteTraining(
    CompleteTrainingEvent event,
    Emitter<TrainingMaterialState> emit,
  ) async {
    try {
      await courseRepository.completeTraining(event.trainingId);
      emit(TrainingMaterialCompleted(event.trainingId));
    } catch (e) {
      emit(TrainingMaterialError('Failed to complete training: ${e.toString()}'));
    }
  }
}