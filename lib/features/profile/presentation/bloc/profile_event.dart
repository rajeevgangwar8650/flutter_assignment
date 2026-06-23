import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class ProfileRequested extends ProfileEvent {
  const ProfileRequested();
}

class ProfileUpdateSubmitted extends ProfileEvent {
  final String name;
  final String email;
  final String bio;
  final String imageUrl;

  const ProfileUpdateSubmitted({
    required this.name,
    required this.email,
    required this.bio,
    this.imageUrl = '',
  });

  @override
  List<Object> get props => [name, email, bio, imageUrl];
}

class ProfileResetRequested extends ProfileEvent {
  const ProfileResetRequested();
}
