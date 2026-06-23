import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
  }) : super(const ProfileInitial()) {
    on<ProfileRequested>(_onProfileRequested);
    on<ProfileUpdateSubmitted>(_onProfileUpdateSubmitted);
    on<ProfileResetRequested>(_onProfileResetRequested);
  }

  Future<void> _onProfileRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await getProfileUseCase(NoParams());
    result.fold(
      (failure) => emit(ProfileFailure(failure.message)),
      (profile) => emit(ProfileSuccess(profile)),
    );
  }

  Future<void> _onProfileUpdateSubmitted(
    ProfileUpdateSubmitted event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final profile = ProfileEntity(
      name: event.name.trim(),
      email: event.email.trim(),
      bio: event.bio.trim(),
      imageUrl: event.imageUrl.trim(),
    );
    final result = await updateProfileUseCase(UpdateProfileParams(profile));
    result.fold(
      (failure) => emit(ProfileFailure(failure.message)),
      (profile) => emit(
        ProfileSuccess(profile, message: 'Profile updated successfully.'),
      ),
    );
  }

  void _onProfileResetRequested(
    ProfileResetRequested event,
    Emitter<ProfileState> emit,
  ) {
    emit(const ProfileInitial());
  }
}
