import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInTraditionally(String username, String password);
  Future<void> signOut(bool isFirebase);
  Future<UserModel?> getFirebaseUser();
  Future<UserModel> getCurrentTraditionalUser(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final firebase.FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.client,
    required this.firebaseAuth,
    required this.googleSignIn,
  });

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthenticationException('Login con Google cancelado por el usuario.');
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final firebase.AuthCredential credential = firebase.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final firebase.UserCredential userCredential = await firebaseAuth.signInWithCredential(credential);
      if (userCredential.user == null) {
        throw AuthenticationException('Error al obtener usuario de Firebase después del login con Google.');
      }
      return UserModel.fromFirebaseUser(userCredential.user!);
    } catch (e) {
      print('Error detallado en signInWithGoogle (DataSource): $e');
      throw AuthenticationException('Error durante el inicio de sesión con Google: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInTraditionally(String username, String password) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.dummyJsonBaseUrl}${ApiConstants.authLoginEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['token'] == null && data['accessToken'] == null) {
         throw ServerException('Token no encontrado en la respuesta de login tradicional.');
      }
      return UserModel.fromJson(data);
    } else {
      final errorBody = jsonDecode(response.body);
      throw AuthenticationException(errorBody['message'] ?? 'Error en login tradicional: ${response.statusCode}');
    }
  }

  @override
  Future<void> signOut(bool isFirebase) async {
    try {
      if (isFirebase) {
        await googleSignIn.signOut();
        await firebaseAuth.signOut();
      }
    } catch (e) {
      throw AuthenticationException('Error al cerrar sesión: ${e.toString()}');
    }
  }
  
  @override
  Future<UserModel?> getFirebaseUser() async {
    final firebaseUser = firebaseAuth.currentUser;
    if (firebaseUser != null) {
      return UserModel.fromFirebaseUser(firebaseUser);
    }
    return null;
  }

  @override
  Future<UserModel> getCurrentTraditionalUser(String token) async {
    final response = await client.get(
      Uri.parse('${ApiConstants.dummyJsonBaseUrl}${ApiConstants.authMeEndpoint}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      Map<String, dynamic> userDataWithToken = Map.from(data);
      userDataWithToken['token'] = token;
      return UserModel.fromJson(userDataWithToken);
    } else {
      throw ServerException('Error al obtener usuario actual de API: ${response.statusCode}');
    }
  }
}