import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signInWithGoogle() async {
    try {
      print('Iniciando proceso de autenticación...');
      
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('Usuario canceló el login');
        return null;
      }

      print('Usuario seleccionado: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print('Tokens obtenidos');

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Credential creado, autenticando con Firebase...');
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      print('Autenticación exitosa: ${userCredential.user?.email}');
      return userCredential.user;
    } catch (e) {
      print('Error detallado en signInWithGoogle: $e');
      return null;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }
}