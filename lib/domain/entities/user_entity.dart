import 'package:equatable/equatable.dart';

enum AuthProvider { firebase, traditional }

class UserEntity extends Equatable {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final String? token;
  final AuthProvider authProvider;
  final Map<String, dynamic>?
      traditionalUserData;

  const UserEntity({
    required this.id,
    this.email,
    this.displayName,
    this.photoURL,
    this.token,
    required this.authProvider,
    this.traditionalUserData,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoURL,
        token,
        authProvider,
        traditionalUserData
      ];

  String get effectiveDisplayName {
    if (authProvider == AuthProvider.traditional && traditionalUserData != null) {
      return traditionalUserData!['firstName']?.toString() ??
             traditionalUserData!['username']?.toString() ??
             traditionalUserData!['name']?.toString() ??
             'Usuario';
    }
    return displayName ?? email ?? 'Usuario';
  }

  String? get effectivePhotoUrl {
     if (authProvider == AuthProvider.traditional && traditionalUserData != null) {
      return traditionalUserData!['image']?.toString();
    }
    return photoURL;
  }
}