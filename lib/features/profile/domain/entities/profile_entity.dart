import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String name;
  final String email;
  final String bio;
  final String imageUrl;

  const ProfileEntity({
    required this.name,
    required this.email,
    required this.bio,
    this.imageUrl = '',
  });

  ProfileEntity copyWith({
    String? name,
    String? email,
    String? bio,
    String? imageUrl,
  }) {
    return ProfileEntity(
      name: name ?? this.name,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object> get props => [name, email, bio, imageUrl];
}
