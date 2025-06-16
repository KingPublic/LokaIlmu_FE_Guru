import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalilmu_guru/repositories/edit_repository.dart';

import '../model/loginregis_model.dart';

// Events
abstract class EditProfileEvent extends Equatable {
  const EditProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserDataEvent extends EditProfileEvent {
  final RegisterModel? userData;

  const LoadUserDataEvent({this.userData});

  @override
  List<Object?> get props => [userData];
}

class UpdateProfileEvent extends EditProfileEvent {
  final RegisterModel updatedUser;

  const UpdateProfileEvent(this.updatedUser);

  @override
  List<Object?> get props => [updatedUser];
}

class ChangePasswordEvent extends EditProfileEvent {
  final String oldPassword;
  final String newPassword;

  const ChangePasswordEvent(this.oldPassword, this.newPassword);

  @override
  List<Object?> get props => [oldPassword, newPassword];
}

// States
abstract class EditProfileState extends Equatable {
  const EditProfileState();

  @override
  List<Object?> get props => [];
}

class EditProfileInitial extends EditProfileState {}

class EditProfileLoading extends EditProfileState {}

class EditProfileLoaded extends EditProfileState {
  final RegisterModel user;

  const EditProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class EditProfileUpdating extends EditProfileState {
  final RegisterModel user;

  const EditProfileUpdating(this.user);

  @override
  List<Object?> get props => [user];
}

class EditProfileSuccess extends EditProfileState {
  final String message;
  final RegisterModel user;

  const EditProfileSuccess(this.message, this.user);

  @override
  List<Object?> get props => [message, user];
}

class EditProfileError extends EditProfileState {
  final String message;
  final RegisterModel? user;

  const EditProfileError(this.message, {this.user});

  @override
  List<Object?> get props => [message, user];
}

// BLoC
class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  final EditProfileRepository repository;

  EditProfileBloc({required this.repository}) : super(EditProfileInitial()) {
    on<LoadUserDataEvent>(_onLoadUserData);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<ChangePasswordEvent>(_onChangePassword);
  }

  Future<void> _onLoadUserData(
    LoadUserDataEvent event,
    Emitter<EditProfileState> emit,
  ) async {
    emit(EditProfileLoading());
    try {
      RegisterModel user;
      
      // if (event.userData != null) {
      //   // Use provided user data
      //   repository.setCurrentUser(event.userData!);
      //   user = event.userData!;
      // } else {
        // Try to get from repository
        user = await repository.getCurrentUser();
      // }
      
      emit(EditProfileLoaded(user));
    } catch (e) {
      emit(EditProfileError('Gagal memuat data user: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<EditProfileState> emit,
  ) async {
    final currentState = state;
    RegisterModel? currentUser;
    
    if (currentState is EditProfileLoaded) {
      currentUser = currentState.user;
    } else if (currentState is EditProfileSuccess) {
      currentUser = currentState.user;
    }

    emit(EditProfileUpdating(event.updatedUser));
    
    try {
      await repository.updateProfile(event.updatedUser);
      emit(EditProfileSuccess('Profile berhasil diupdate', event.updatedUser));
    } catch (e) {
      emit(EditProfileError(
        'Gagal mengupdate profile: ${e.toString()}',
        user: event.updatedUser,
      ));
    }
  }

  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<EditProfileState> emit,
  ) async {
    final currentState = state;
    RegisterModel? currentUser;
    
    if (currentState is EditProfileLoaded) {
      currentUser = currentState.user;
    } else if (currentState is EditProfileSuccess) {
      currentUser = currentState.user;
    }

    if (currentUser == null) return;

    emit(EditProfileUpdating(currentUser));
    
    try {
      await repository.changePassword(event.oldPassword, event.newPassword);
      emit(EditProfileSuccess('Password berhasil diubah', currentUser));
    } catch (e) {
      emit(EditProfileError(e.toString(), user: currentUser));
    }
  }
}