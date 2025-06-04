import '/domain/entities/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    super.email,
    super.displayName,
    super.photoURL,
    super.token,
    required super.authProvider,
    super.traditionalUserData,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String? apiToken = json['token']?.toString() ?? json['accessToken']?.toString();
    return UserModel(
      id: json['id'].toString(),
      email: json['email']?.toString(),
      displayName: json['firstName']?.toString() ?? json['username']?.toString(),
      photoURL: json['image']?.toString(),
      token: apiToken,
      authProvider: AuthProvider.traditional,
      traditionalUserData: json,
    );
  }

  factory UserModel.fromFirebaseUser(firebase.User firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      authProvider: AuthProvider.firebase,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': traditionalUserData?['username'] ?? displayName,
      'firstName': traditionalUserData?['firstName'] ?? displayName,
      'lastName': traditionalUserData?['lastName'],
      'gender': traditionalUserData?['gender'],
      'image': photoURL,
      'token': token,
    };
  }
}