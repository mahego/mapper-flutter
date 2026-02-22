import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:logger/logger.dart';

/// Service for Firebase authentication operations
/// Handles Google Sign In, Facebook Login, and email/password auth
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Logger _logger = Logger();

  /// Current Firebase user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current Firebase user
  User? get currentUser => _auth.currentUser;

  /// Sign in with Google
  /// Returns the Firebase User or null if canceled/failed
  Future<User?> signInWithGoogle() async {
    try {
      _logger.i('[FirebaseAuth] Starting Google Sign In');
      
      // Trigger the Google authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        _logger.w('[FirebaseAuth] Google Sign In canceled by user');
        return null; // The user canceled the sign-in
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      _logger.i('[FirebaseAuth] Google Sign In successful: ${userCredential.user?.email}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      _logger.e('[FirebaseAuth] Google Sign In error: ${e.code} - ${e.message}');
      throw Exception('Error al iniciar sesión con Google: ${e.message}');
    } catch (e) {
      _logger.e('[FirebaseAuth] Google Sign In error: $e');
      throw Exception('Error inesperado al iniciar sesión con Google');
    }
  }

  /// Sign in with Facebook
  /// Returns the Firebase User or null if canceled/failed
  Future<User?> signInWithFacebook() async {
    try {
      _logger.i('[FirebaseAuth] Starting Facebook Login');
      
      // Trigger the Facebook authentication flow
      final LoginResult loginResult = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (loginResult.status == LoginStatus.cancelled) {
        _logger.w('[FirebaseAuth] Facebook Login canceled by user');
        return null;
      }

      if (loginResult.status != LoginStatus.success) {
        _logger.e('[FirebaseAuth] Facebook Login failed: ${loginResult.status}');
        throw Exception('Facebook login failed: ${loginResult.message}');
      }

      // Get the access token
      final AccessToken? accessToken = loginResult.accessToken;
      
      if (accessToken == null) {
        throw Exception('Facebook access token is null');
      }

      // Create a Facebook credential
      final OAuthCredential facebookCredential = 
          FacebookAuthProvider.credential(accessToken.tokenString);

      // Sign in to Firebase with the Facebook credential
      final UserCredential userCredential = 
          await _auth.signInWithCredential(facebookCredential);
      
      _logger.i('[FirebaseAuth] Facebook Login successful: ${userCredential.user?.email}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      _logger.e('[FirebaseAuth] Facebook Login error: ${e.code} - ${e.message}');
      throw Exception('Error al iniciar sesión con Facebook: ${e.message}');
    } catch (e) {
      _logger.e('[FirebaseAuth] Facebook Login error: $e');
      throw Exception('Error inesperado al iniciar sesión con Facebook');
    }
  }

  /// Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      _logger.i('[FirebaseAuth] Email sign in: $email');
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      _logger.e('[FirebaseAuth] Email sign in error: ${e.code} - ${e.message}');
      throw Exception('Error al iniciar sesión: ${e.message}');
    } catch (e) {
      _logger.e('[FirebaseAuth] Email sign in error: $e');
      throw Exception('Error inesperado al iniciar sesión');
    }
  }

  /// Register with email and password
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      _logger.i('[FirebaseAuth] Email registration: $email');
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      _logger.e('[FirebaseAuth] Email registration error: ${e.code} - ${e.message}');
      throw Exception('Error al registrar: ${e.message}');
    } catch (e) {
      _logger.e('[FirebaseAuth] Email registration error: $e');
      throw Exception('Error inesperado al registrar');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _logger.i('[FirebaseAuth] Sending password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      _logger.e('[FirebaseAuth] Password reset error: ${e.code} - ${e.message}');
      throw Exception('Error al enviar email de recuperación: ${e.message}');
    } catch (e) {
      _logger.e('[FirebaseAuth] Password reset error: $e');
      throw Exception('Error inesperado al enviar email de recuperación');
    }
  }

  /// Sign out from all providers
  Future<void> signOut() async {
    try {
      _logger.i('[FirebaseAuth] Signing out');
      
      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      
      // Sign out from Facebook
      await FacebookAuth.instance.logOut();
      
      // Sign out from Firebase
      await _auth.signOut();
      
      _logger.i('[FirebaseAuth] Sign out successful');
    } on FirebaseAuthException catch (e) {
      _logger.e('[FirebaseAuth] Sign out error: ${e.code} - ${e.message}');
      throw Exception('Error al cerrar sesión: ${e.message}');
    } catch (e) {
      _logger.e('[FirebaseAuth] Sign out error: $e');
      throw Exception('Error inesperado al cerrar sesión');
    }
  }

  /// Get the current user's ID token
  Future<String?> getIdToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      
      return await user.getIdToken();
    } catch (e) {
      _logger.e('[FirebaseAuth] Get ID token error: $e');
      return null;
    }
  }

  /// Check if user is new (for handling complete-profile flow)
  bool isNewUser(UserCredential credential) {
    return credential.additionalUserInfo?.isNewUser ?? false;
  }
}
